# Neovim Configuration

基于 [NvChad v2.0](https://github.com/NvChad/NvChad) 的 Neovim 配置，面向 Web 开发（TypeScript/JavaScript/Deno）、Lua、C/C++ 和 Shell 脚本。

## 目录结构

```
~/.config/nvim/
├── init.lua                    # 入口文件，加载 core、mise PATH、lazy.nvim
├── .stylua.toml                # Lua 格式化配置
├── lazy-lock.json              # lazy.nvim 锁文件
├── snippets/                   # 自定义 VSCode 格式代码片段
│   ├── package.json
│   └── javascript/
│       └── javascript.json     # JS/TS 片段 (tc=try/catch, cl=console.log)
└── lua/
    ├── core/                   # NvChad 核心框架
    │   ├── bootstrap.lua       # lazy.nvim & base46 引导
    │   ├── default_config.lua  # 默认配置
    │   ├── init.lua            # 编辑器选项 & autocmd
    │   ├── mappings.lua        # 默认键位映射
    │   └── utils.lua           # 工具函数
    ├── plugins/                # NvChad 默认插件
    │   ├── init.lua            # 插件列表 & lazy.nvim setup
    │   └── configs/            # 插件默认配置
    │       ├── cmp.lua         # 自动补全
    │       ├── lazy_nvim.lua
    │       ├── lspconfig.lua   # LSP 基础配置
    │       ├── mason.lua
    │       ├── nvimtree.lua
    │       ├── telescope.lua
    │       ├── treesitter.lua
    │       └── others.lua      # LuaSnip, autopairs, gitsigns 等
    └── custom/                 # 用户自定义配置（主要修改区域）
        ├── chadrc.lua          # 主配置：主题 & 插件 & 映射入口
        ├── init.lua            # 编辑器选项 & autocommand
        ├── mappings.lua        # 自定义键位映射
        ├── highlights.lua      # 主题高亮覆盖
        ├── plugins.lua         # 自定义插件列表
        └── configs/
            ├── lspconfig.lua   # LSP 服务器配置
            ├── conform.lua     # 代码格式化配置
            └── overrides.lua   # treesitter/mason/nvimtree 覆盖
```

## 主题

- 当前主题: `onedark`（暗色）
- 主题切换: `<leader>th`（onedark / one_light）
- 自定义高亮: 注释斜体，NvimTree 打开的文件夹名绿色加粗

## 插件列表

### 核心 UI
| 插件 | 用途 |
|------|------|
| NvChad/base46 | 主题编译系统 |
| NvChad/ui | UI 组件（statusline, tabufline） |
| nvim-web-devicons | 文件图标 |
| nvim-colorizer.lua | 颜色代码高亮 |

### 编辑 & 导航
| 插件 | 用途 |
|------|------|
| nvim-treesitter | 基于语法树的高亮 |
| nvim-tree.lua | 文件树（宽度 40，显示 git 状态和隐藏文件） |
| telescope.nvim | 模糊查找（文件/内容/buffer） |
| Comment.nvim | 注释切换 (`gcc`, `<leader>/`) |
| indent-blankline.nvim | 缩进参考线 |
| nvim-surround | 环绕编辑（引号/括号） |
| nvim-autopairs | 自动配对 |

### LSP & 补全
| 插件 | 用途 |
|------|------|
| nvim-lspconfig | LSP 客户端配置 |
| mason.nvim | LSP/formatter/linter 安装管理 |
| nvim-cmp | 自动补全引擎 |
| LuaSnip | 代码片段引擎 |
| friendly-snippets | 预制代码片段集合 |
| conform.nvim | 代码格式化（prettier/deno_fmt/stylua/shfmt） |

### Git
| 插件 | 用途 |
|------|------|
| gitsigns.nvim | Git diff 标记 & 操作 |
| blamer.nvim | 行内 git blame |

### 工具
| 插件 | 用途 |
|------|------|
| windsurf.vim (Codeium) | AI 代码补全（`<M-j>` 接受） |
| nvim-tmux-navigation | Tmux/Nvim 无缝窗口导航 |
| smartim | 输入法自动切换 |
| vim-open-url | 浏览器打开 URL (`gx`) |
| nvterm | 内置终端 |

## LSP 服务器

| 服务器 | 语言 | 备注 |
|--------|------|------|
| ts_ls | TypeScript/JavaScript | 通过 `package.json` 检测根目录 |
| denols | Deno | 通过 `deno.json`/`deno.jsonc` 检测根目录 |
| html | HTML | - |
| cssls | CSS | - |
| clangd | C/C++ | - |
| lua_ls | Lua | NvChad 核心配置 |

**注意**: ts_ls 和 denols 通过根目录文件互斥，避免冲突。

## 代码格式化 (conform.nvim)

格式化优先级（按顺序尝试，第一个可用的生效）：

- **JS/TS/CSS/JSON/Markdown**: `prettier_from_project` > `deno_fmt` > `prettier`
  - `prettier_from_project`: 仅在项目中有 `.prettierrc` 等配置文件时使用
  - `deno_fmt`: 仅在有 `deno.json`/`deno.jsonc` 时使用
  - `.min.js` 文件自动排除
- **Lua**: `stylua`
- **Shell**: `shfmt`（2 空格缩进）
- 保存时自动格式化（500ms 超时，LSP fallback）
- `:FormatToggle` 命令可切换保存时自动格式化

## 关键键位映射

**Leader 键**: `<Space>`

### 文件 & Buffer
| 键位 | 功能 |
|------|------|
| `<leader>w` | 保存文件 |
| `qq` | 退出 |
| `<BS>` | 切换上一个 buffer |
| `<Tab>` / `<S-Tab>` | 下/上一个 buffer |
| `<leader><BS>` | 关闭当前 buffer |
| `<Space>X` | 关闭所有其他 buffer |

### 查找 (Telescope)
| 键位 | 功能 |
|------|------|
| `<leader>ff` | 查找文件 |
| `<leader>fw` | 全文搜索 (live grep) |
| `<leader>fb` | 查找 buffer |
| `<leader>fo` | 最近文件 |
| `<C-A-o>` | 查找文件（所有模式可用） |
| `<C-A-b>` | 查找 buffer（所有模式可用） |
| `<C-A-r>` | 恢复上次 Telescope 结果 |
| `<C-A-n>` | 在 NvimTree 选中目录内搜索 |

### LSP
| 键位 | 功能 |
|------|------|
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `gr` | 查看引用 |
| `K` | 悬浮文档 |
| `<leader>ra` | 重命名 |
| `<leader>ca` | 代码操作 |
| `<leader>e` | 显示行内诊断 |
| `<leader>E` | 显示所有诊断 |
| `<leader>fm` | 格式化 |

### 删除行为（自定义）
默认 `x/d/c/D` 删除**不进入**剪贴板（使用黑洞寄存器），需要剪切时加 `<leader>` 前缀：
| 键位 | 功能 |
|------|------|
| `d` / `x` / `c` / `D` | 删除（不影响剪贴板） |
| `<leader>d` / `<leader>x` / `<leader>c` / `<leader>D` | 删除并剪切到系统剪贴板 |

### 其他
| 键位 | 功能 |
|------|------|
| `;` | 进入命令模式 |
| `<C-n>` | 切换文件树 |
| `<A-i>` | 浮动终端 |
| `<A-h>` / `<A-v>` | 水平/垂直终端 |
| `<C-h/j/k/l>` | 窗口导航（兼容 tmux） |
| `<leader>S` | 查找替换 |
| `<leader>o` | 在 Finder 中打开（macOS） |
| `gx` | 在浏览器中打开 URL |

## 编辑器选项

- 缩进: 2 空格
- 相对行号: 开启
- 命令行高度: 0（隐藏）
- 折叠: indent 方式，默认全部展开
- 剪贴板: 系统剪贴板 (`unnamedplus`)
- 自动读取: 开启（外部修改自动加载）
- mise: 自动添加到 PATH

## Autocommand

- **高亮复制**: 复制后短暂高亮选中文本
- **保存时格式化**: 保存前自动 LSP 格式化 + conform.nvim 格式化
- **VimLeave fix**: 退出时 sleep 10ms（修复 neovim#21856）
- **配置热重载**: 修改 `lua/custom/` 下文件后自动重载

## 故障排除

### LuaSnip jsregexp git 错误
```
fatal: not a git repository: ../../.git/modules/deps/jsregexp006
```
解决方法:
```bash
rm -rf ~/.local/share/nvim/lazy/LuaSnip
```
然后重新打开 nvim 运行 `:Lazy sync`。
