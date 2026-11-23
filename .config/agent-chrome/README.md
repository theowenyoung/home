# Agent Chrome

一套面向 **Antigravity + Remote Control（无人值守 Mac mini）** 的免弹窗独立 Chrome 工作流。

通过给 Chrome 启动独立的 `--user-data-dir` 并监听本地 `127.0.0.1:9333` CDP 端口，配合 Antigravity 全局 Plugin（`chrome-devtools-mcp --browserUrl=http://127.0.0.1:9333`），彻底绕开 Chrome `v144+` 在主 Profile 下的「是否允许远程调试？」阻塞弹窗，同时长期持久化登录态和 Cookie。

---

## 目录结构

```text
~/.config/agent-chrome/                     # ✅ 随 dotfiles 同步到 GitHub
├── README.md                               # 本说明文档
├── setup.sh                                # 新机器一键激活脚本（幂等）
├── bin/
│   ├── agent-chrome                        # 独立 Chrome 生命周期管理（ensure/status/stop/open）
│   └── agent-chrome-mcp                    # MCP 启动包装器（自动补全 PATH 并自愈拉起 Chrome）
├── launchd/
│   └── com.local.agent-chrome.plist.tmpl   # macOS 登录自启模板（不含硬编码用户名）
└── plugins/
    └── agent-chrome/                       # Antigravity 全局 Plugin 本体（通过软链挂载）
        ├── plugin.json
        ├── mcp_config.json
        ├── rules/AGENTS.md                 # 全局路由规则：所有项目自动走 agent-chrome MCP
        └── skills/agent-chrome/SKILL.md    # 故障自愈与人工登录交接手册
```

**本机私有/运行时文件（不进 GitHub）**：
* `~/.local/share/agent-chrome-profile/` — 独立 Chrome 分身的 Cookie 与登录态（严禁提交）
* `~/.gemini/config/plugins/agent-chrome` — 由 `setup.sh` 创建的软链（按设备决定是否启用：只在 `macmini` 激活，在随身 `macbook-air` 不激活）
* `~/Library/LaunchAgents/com.local.agent-chrome.plist` — 由 `setup.sh` 渲染生成

---

## 换新 Mac / 重置电脑恢复指南（30 秒）

前提：已安装 Google Chrome 和 Node.js（`npx` 可用），且已拉下你的 dotfiles（包含 `~/.config/agent-chrome/`）。

1. **在需要启用本工作流的机器（如 Mac mini）上运行一键恢复**：
   ```bash
   ~/.config/agent-chrome/setup.sh
   ```
   *(如果不想开机自启，只按需由 Agent 拉起，可加 `--no-launchd`。)*
2. **首次人工登录**：
   切到该 Mac 的桌面/屏幕共享，在刚打开的 **Agent Chrome** 窗口里登录常用网站（建议在 Chrome 外观设置里给它换个醒目的主题色，方便和日常主 Chrome 区分；首次弹出 macOS 钥匙串访问提示时选「始终允许」）。
3. **验证**：
   ```bash
   agent-chrome status
   ```
   看到 `running on http://127.0.0.1:9333` 即就绪；打开任意新 Antigravity 会话即可在所有项目中自动使用 `agent-chrome` MCP。

---

## 日常命令

```bash
agent-chrome status                  # 检查 127.0.0.1:9333 CDP 状态
agent-chrome ensure                  # 幂等拉起（已运行则无操作）
agent-chrome open https://luma.com   # 在分身 Chrome 中打开指定网址
agent-chrome stop                    # 仅关闭分身 Chrome（不影响主 Chrome）
```

### 停用 / 卸载

* **临时停用**：在 Antigravity UI 的 **Customizations > Plugins** 中关闭 `Agent Chrome` 即可即时生效。
* **本机取消注册**（保留 `~/.config/agent-chrome` 源码和登录 Cookie）：
  ```bash
  ~/.config/agent-chrome/setup.sh --uninstall
  ```

---

## 为什么选择端口 `9333`？

Chrome 主实例的 `chrome://inspect/#remote-debugging` 默认占用 `9222`，Node.js 调试器常用 `9229`。使用 `9333` 且仅绑定 `127.0.0.1` 可避免端口冲突，同时不向局域网暴露调试接口。如需自定义端口，设置环境变量 `AGENT_CHROME_PORT` 即可。
