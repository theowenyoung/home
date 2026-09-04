require "nvchad.options"

local opt = vim.opt
local g = vim.g
local wo = vim.wo

-- hide cmd line
opt.cmdheight = 0

-- auto reload
opt.autoread = true

opt.exrc = false

-- relative line numbers
wo.relativenumber = true

-- fold method
opt.foldlevel = 99
opt.foldmethod = "indent"

-- :s/:g 等命令边打边预览，并在下方 split 窗口列出所有受影响的行
opt.inccommand = "split"

-- snippets path
g.vscode_snippets_path = "./snippets"

-- ============================================================
-- Clipboard: remote (SSH) -> local machine, via OSC 52
-- ------------------------------------------------------------
-- 这台机器上 $DISPLAY=:0 是 tmux server 继承下来的残留（并没有 X server 在跑）。
-- nvim 的 provider 自动探测在 $DISPLAY 非空时会无条件选中 xclip
-- （autoload/provider/clipboard.vim 里 xclip 分支没有可用性检测），
-- 于是每次写 "+ 都报 `Can't open display: :0`。
--
-- 改成强制走 OSC 52：把内容以转义序列写到 tty，由 tmux 转发给本地终端，
-- 本地终端再放进本地系统剪贴板。需要配合 tmux 的 `set-clipboard on`。
if vim.env.SSH_TTY or vim.env.SSH_CONNECTION then
  local osc52 = require "vim.ui.clipboard.osc52"

  -- 读方向：nvim 发 `\033]52;c;?`，tmux（get-clipboard=request，需 >= 3.7）
  -- 替我们去问终端要本机剪贴板。
  --
  -- 【重要】这条只在 *ssh* 会话下可靠。mosh 下不可用，原因在 mosh 源码：
  -- terminalfunctions.cc 的 OSC_dispatch 对 `?` 没有特殊处理，把它当普通内容
  -- 存进 framebuffer 的 clipboard 字段；terminaldisplay.cc 又只在该字段
  -- *发生变化* 时才下发给客户端。于是第一次查询（字段 内容->"?"）能透传出去，
  -- 之后字段已经是 "?"，再查就不算变化，被静默吞掉 -- 而 mac 上原生复制
  -- 根本不会改变服务端这个字段。实测：写入后首查 76ms 成功，紧接着再查无回复。
  --
  -- 所以拿不到回复时 *绝不能* 用上次的缓存冒充 -- 那是静默粘贴错误内容，
  -- 比明着失败糟糕得多。这里退回 nvim 内部的 unnamed 寄存器并给出提示。
  local function osc52_read(sel)
    local contents = nil
    local id = vim.api.nvim_create_autocmd("TermResponse", {
      callback = function(ev)
        local encoded = ev.data.sequence:match "\027%]52;%w?;([A-Za-z0-9+/=]*)"
        if encoded then
          contents = vim.base64.decode(encoded)
          return true
        end
      end,
    })
    vim.api.nvim_ui_send(string.format("\027]52;%s;?\027\\", sel))
    -- 实测有回复时 23-95ms，500ms 足够宽裕，又不至于让失败时卡手
    if not vim.wait(500, function()
      return contents ~= nil
    end) then
      pcall(vim.api.nvim_del_autocmd, id)
    end
    return contents
  end

  local function make_paste(sel)
    return function()
      local got = osc52_read(sel)
      if got then
        return vim.split(got, "\n")
      end
      vim.notify(
        "系统剪贴板读取无响应（mosh 会话下已知不可用），本次粘贴的是 nvim 内部寄存器。"
          .. "要粘贴 mac 剪贴板请用 Cmd-V。",
        vim.log.levels.WARN
      )
      return vim.split(vim.fn.getreg '"', "\n")
    end
  end

  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy "+", ["*"] = osc52.copy "*" },
    paste = { ["+"] = make_paste "c", ["*"] = make_paste "p" },
  }
end
