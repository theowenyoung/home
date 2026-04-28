# Homebrew 软件包管理器配置文件
# 使用 `brew bundle ` 安装全部
# 使用 `brew bundle check --file=~/Brewfile` 检查缺失项

# ===== 命令行工具 (brew) =====
brew "bash"                        # 新版 Bash（macOS 自带版本太旧）
brew "curl"                        # 命令行 HTTP 客户端（比系统自带更新）
brew "mas"                         # Mac App Store 命令行（管理 mas 条目用）
brew "mise"                        # 多语言运行时版本管理器
brew "terminal-notifier"           # 脚本里触发 macOS 通知中心
brew "git"                         # 版本控制
brew "jq"                          # JSON 命令行处理器
brew "wget"                        # 文件下载工具
brew "tmux"                        # 终端复用器
brew "coreutils"                   # GNU 核心工具集（gls/gdate 等）
brew "gnupg"                       # GPG 加密 / 签名
brew "age"                         # 现代化文件加密（配合 sops 用）
brew "nmap"                        # 网络扫描 / 端口探测
brew "ffmpeg"                      # 音视频转码处理
brew "sshpass"                     # 非交互式 SSH 密码登录
brew "tree"                        # 树形目录显示
brew "fd"                          # 用户友好的 find 替代品
brew "ripgrep"                     # 快速代码搜索（与 fd 配套）
brew "fzf"                         # 模糊查找（含 shell 集成脚本）
brew "mkcert"                      # 本地 HTTPS 证书生成
brew "telnet"                      # 网络端口调试（macOS 已移除）
brew "gh"                          # GitHub 官方 CLI

# ===== 应用程序 (cask) =====

# --- 浏览器 ---
cask "google-chrome"               # Chrome 主浏览器
cask "google-chrome@beta"          # Chrome Beta（提前体验新特性）
cask "helium-browser"              # Helium，基于 Chromium 的现代浏览器
cask "orion"                       # 类 Safari 但支持 Chrome 扩展

# --- 编辑器 / 终端 ---
cask "visual-studio-code"          # VSCode 代码编辑器
cask "zed"                         # Zed 高性能编辑器
cask "ghostty"                     # 现代 GPU 终端
cask "font-fira-code-nerd-font"    # 等宽字体含图标（终端/编辑器用）

# --- 开发工具 ---
cask "claude-code@latest"          # Claude Code CLI（最新版）
cask "cc-switch"                   # Claude Code 多账号/配置切换
cask "orbstack"                    # Docker Desktop 替代品（更轻量）
cask "sequel-ace"                  # MySQL / MariaDB GUI
cask "postico"                     # PostgreSQL GUI

# --- AI 桌面端 ---
cask "claude"                      # Claude 桌面端
cask "chatgpt"                     # ChatGPT 桌面端
cask "codex"                       # OpenAI Codex 桌面端

# --- 效率工具 ---
cask "alfred"                      # 启动器 + 工作流
cask "cleanshot"                   # 截图 / 录屏
cask "keyboard-maestro"            # 键盘宏自动化
cask "bartender"                   # 菜单栏整理
cask "selfcontrol"                 # 屏蔽干扰网站，专注用
cask "keepingyouawake"             # 菜单栏防睡眠工具
cask "marta"                       # 双面板文件管理器

# --- 通讯 / 协作 ---
cask "telegram"                    # Telegram
cask "wechat"                      # 微信
cask "feishu"                      # 飞书
cask "tencent-meeting"             # 腾讯会议

# --- 笔记 / 信息流 ---
cask "notion"                      # Notion 知识库
cask "obsidian"                    # 本地优先 Markdown 笔记
cask "heynote"                     # 程序员 scratchpad
cask "netnewswire"                 # RSS 阅读器

# --- 媒体 / 阅读 ---
cask "iina"                        # 视频播放器
cask "spotify"                     # 音乐流媒体
cask "downie"                      # 视频下载
cask "calibre"                     # 电子书管理 / 转换

# --- 系统辅助 ---
cask "tencent-lemon"               # 柠檬清理（系统垃圾清理）

# ===== Mac App Store 应用 (mas) =====
# 查询 ID：`mas search <名字>` ；验证：`mas info <id>`

# --- 苹果官方 ---
mas "Xcode", id: 497799835                 # Xcode 开发环境
mas "TestFlight", id: 899247664            # 测试版应用分发
mas "Pages", id: 361309726                 # iWork - Pages（中区"Pages 文稿"）
mas "Numbers", id: 361304891               # iWork - Numbers（中区"Numbers 表格"）
mas "Keynote", id: 361285480               # iWork - Keynote（中区"Keynote 讲演"）

# --- 微软 Office ---
mas "Microsoft Word", id: 462054704        # Word 文档
mas "Microsoft PowerPoint", id: 462062816  # PowerPoint 演示

# --- 笔记 / 阅读 ---
mas "MindNode", id: 1289197285             # 思维导图（已改名 MindNode Classic）
mas "Exporter", id: 1099120373             # 备忘录批量导出 Markdown

# --- 开发 / 工具 ---
# mas "Ridill SQLIte", id: 1058773711        # 轻量 SQLite 客户端
mas "Boop", id: 1518425043                 # 开发者文本处理工具（Base64/格式化等）
mas "uPic", id: 1549159979                 # 图床上传工具
mas "Immersive Translate", id: 6447957425  # 沉浸式翻译（网页双语）
mas "Windows App", id: 1295203466          # 微软官方 RDP 客户端

# --- 健康 / 提醒 ---
mas "Eye Monitor", id: 1527031341          # 护眼休息提醒
