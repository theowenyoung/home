# Digital Home

我的 dotfiles 仓库。这个 Repo 就是我的 `$HOME` 目录，用 `.gitignore` 白名单模式管理，只跟踪需要的配置文件。

## 原则

- 所有 GUI 应用和命令行工具通过 [Homebrew](https://brew.sh/) 安装，统一在 `~/Brewfile` 中管理，使用 `brew bundle` 安装、`brew bundle --cleanup` 清理不在列表中的软件
- 所有开发语言运行时通过 [mise](https://mise.jdx.dev/) 管理，配置在 `~/.config/mise/config.toml`
  - npm 全局包：`~/.default-npm-packages`（mise 安装 node 时自动安装）
  - gems 全局包：`~/.default-gems`（mise 安装 ruby 时自动安装）
- 敏感信息（token、密钥）使用 macOS Keychain 管理，通过 `sec` 函数操作（定义在 bashrc 中）
- `.gitignore` 采用白名单模式：默认忽略所有文件，显式取消忽略需要跟踪的配置

## 目录结构

```
~/
├── Brewfile                    # Homebrew 软件清单
├── .default-npm-packages       # mise 安装 node 时自动安装的 npm 全局包
├── .default-gems               # mise 安装 ruby 时自动安装的 gems
├── .config/
│   ├── bash/                   # bash 配置、补全脚本
│   ├── git/                    # git 配置和全局 ignore
│   ├── ghostty/                # Ghostty 终端配置
│   ├── tmux/                   # tmux 配置
│   ├── nvim/                   # Neovim 配置（NvChad）
│   ├── mise/                   # mise 运行时版本配置
│   ├── alfred-workflows/       # Alfred 自定义工作流
│   ├── surfingkeys/            # SurfingKeys 浏览器插件配置
│   ├── caddy/                  # Caddy 反向代理配置
│   ├── ss/ sslocal/            # 代理相关配置
│   ├── clash/                  # Clash 代理配置
│   ├── systemd/                # systemd 用户服务
│   └── ...
├── deploy/                     # 服务器部署（Ansible、K3s、Helm）
└── .gnupg/gpg-agent.conf       # GPG agent 配置
```

## macOS 初始化

### 0. 系统偏好设置

1. 输入法设置为双拼，caps 切换中英输入法
2. Settings -> Keyboard：按键速度和延迟都调到最快
4. Settings -> Trackpad：启用 Tap to click
3. Settings -> Accessibility -> Pointer Control -> Trackpad Options > enable Use trackpad for draffing -> Dragging style -> 三指拖动（Three Finger Drag）
5. Settings -> Dock：自动隐藏 Dock 栏
6. 删除 Dock 里不需要的应用。

### 1. 安装 Xcode Command Line Tools

```bash
xcode-select --install
sudo xcodebuild -license   # 仅在装了完整 Xcode 时需要；只装 Command Line Tools 可跳过
```

### 2. 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装完成后，`brew` 还不在 PATH 里，需要先把它加载进当前 shell（之后 step 7 加载 bashrc 后会自动处理，这里只是为了让后续步骤能用）：

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

或直接关闭并重开终端。验证：

```bash
brew --version
```

### 3. SSH 密钥

SSH 私钥以文本形式存储在 macOS Passwords app 中（作为密码条目的值），通过 iCloud 在设备间同步。

**备份密钥到 Passwords app：**

```bash
# 复制私钥内容到剪贴板，然后在 Passwords app 中新建条目粘贴保存
cat ~/.ssh/id_ed25519 | pbcopy
```

**在新机器上恢复密钥：**

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh

# 在 Passwords app 中找到 SSH 条目，复制内容，然后粘贴写入文件
pbpaste > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

# 从私钥生成对应的公钥
ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
```

### 4. 将 home repo 初始化到 $HOME

```bash
cd "$HOME"
rm -rf .git
git init -b main
git remote add origin git@github.com:theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main
```

### 5. 安装 Bash / Ghostty / Chrome

提前装好后续要用到的几个基础软件：

- `bash`：后续 bashrc 依赖较新版本（macOS 自带的是 3.x）
- `ghostty`：日常用的终端（之后切到 Ghostty 里继续操作更顺）
- `google-chrome`：日常浏览器（登录账号 / 同步扩展用）

```bash
brew install bash mise
brew install --cask ghostty google-chrome
mise install
```

### 6. 切换默认 Shell 为 Homebrew Bash

> 装完 Ghostty 后，建议在 Ghostty 里继续后面的步骤，体验更好。

```bash
# 添加 homebrew bash 到合法 shell 列表
echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/bash
```

### 7. 加载自定义 bashrc

`~/.bash_profile` 与 `~/.bashrc` 都被 `.gitignore` 屏蔽，新机器需要手动建立两条最小引导：

- `~/.bashrc`：source 仓库里的共享配置（PATH、aliases、`sec` 函数、API token 导出等都在 `~/.config/bash/.bashrc` 里集中管理）
- `~/.bash_profile`：登录 shell 入口，source `~/.bashrc`（macOS 登录 shell 默认不会自动读 `.bashrc`）

```bash
# 1) ~/.bashrc 接入共享配置
if ! grep -q "# green-bashrc-start" ~/.bashrc 2>/dev/null; then
cat >>~/.bashrc <<'EOF'
# green-bashrc-start

if [ -f ~/.config/bash/.bashrc ]; then
  source ~/.config/bash/.bashrc
fi

# green-bashrc-end
EOF
fi

# 2) ~/.bash_profile source ~/.bashrc
if ! grep -q "source ~/.bashrc\|\. ~/.bashrc" ~/.bash_profile 2>/dev/null; then
cat >>~/.bash_profile <<'EOF'
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi
EOF
fi
```

```bash
source ~/.bash_profile
```

> 说明：`~/.bash_profile` 中其它工具自动写入的片段（iTerm2 shell integration、Windsurf PATH、`~/.local/bin/env`、Kiro CLI 等）会在对应工具安装/首次运行时自动追加，无需手工维护。API token 等敏感信息通过 `sec add <KEY> "<value>"` 写入 macOS Keychain（见后文「密钥管理」），共享 bashrc 会在启动时自动读取。
>
> 如果是从旧 Mac 迁移：在旧机 `sec export` 写入剪贴板，本机（已登录同一 iCloud，Universal Clipboard 自动同步）执行 `sec import` 即可一次性灌入全部 token，无需逐个 `sec add`。

### 8. 安装所有软件

home repo 已在 `$HOME`，直接用 Brewfile 安装其余软件：

```bash
cd ~ && brew bundle
```

### 9. GPG 密钥（可选）

如果需要保持同一个 GPG 签名身份，GPG 私钥同样以文本形式存储在 Passwords app 中。

> 私钥已经包含公钥，导入后 `gpg --list-keys` 自动可见，无需单独导出公钥。

**备份密钥到 Passwords app：**

```bash
# 账户 1: theowenyoung@gmail.com
gpg --armor --export-secret-keys 6453791878A4BC69317FEF9DA5142BBAFFEF7028 | pbcopy

# 账户 2: owen@owenyoung.com (Main)
gpg --armor --export-secret-keys B12C44A2E9386B993A8FFC53F822CE4444B1D606 | pbcopy
```

每条命令执行后，去 Passwords app 新建对应条目粘贴保存。

**在新机器上恢复密钥：**

```bash
# 依次从 Passwords app 复制每个条目的内容，然后执行：
pbpaste | gpg --import                  # 导入私钥（两个账户各执行一次）

gpg --list-secret-keys                  # 验证
```

### 10. Alfred 配置


1. 快捷键改为 `Cmd+Space`，移除默认 Spotlight 快捷键
2. 剪贴板管理快捷键：`Cmd+Cmd`（双击 Cmd）
3. 主题改为 Alfred macOS
4. Advanced sync 选择 icloud drive Documents/alfred-settings
5. 参考 [alfred-workflows](https://github.com/theowenyoung/home/tree/main/.config/alfred-workflows), 安装自己写的 alfred workflow


### 11. Bartender 配置

菜单栏整理工具（已通过 Brewfile 安装），首次启动需要做几件事：

1. 授予 **Accessibility** 权限（System Settings → Privacy & Security → Accessibility）
2. 授予 **Screen Recording** 权限（用于读取菜单栏图标）
3. 设置开机自启（Bartender → Settings → General → Launch at login）
4. 配置 iCloud 同步（Bartender → Settings → Profiles → 启用 iCloud sync），新机器会自动拉到同样的隐藏/显示规则

### 12. Cleanshot 配置

1. 根据提示配置系统快捷键
2. 打开截图后，自动复制到剪贴板和 Downloads 文件夹


### 其他没有在 brew 管理的软件

1. [Clash](https://github.com/MetaCubeX/ClashX.Meta/releases)
2. [闪电说](https://shandianshuo.cn/)

自定义词典：

```
mise
jant
Mise
小象
tumblr
通义千问
变体
最佳实践
Obsidian
网址
app store
apple store
windows
iOS
macOS
PWA
Chrome
Blog
APP
Touch grass
gemini
markdown
AI
LLM
ChatGPT
rss
Owen
Claude
prompt
Claude 4.6
wrangler
repo
Jant
CLAUDE.md
commands
command
AGENTS.md
sql
sqlite
build
```

## 日常使用

### 升级所有软件

```bash
brew upgrade
```

### mise 管理开发环境

安装/更新全局 node（`--force` 会重新安装 `.default-npm-packages` 中的所有包）：

```bash
mise u -g node@lts --force
```

安装 mise 配置中的所有运行时：

```bash
mise install
```

当前通过 mise 管理的运行时（见 `.config/mise/config.toml`）：
node, deno, bun, python, ruby, rust, go, zig, uv, redis, zola, awscli, neovim, ansible(pipx)

### AI Agent skills 管理

通过 [`npx skills`](https://github.com/vercel-labs/skills) 管理 Claude Code / Codex 等 agent 的 skills，全局清单保存在 `~/.agents/.skill-lock.json`（类似 Brewfile 的角色，已纳入 git）。

新机器一键还原:

```bash
mise run skills-restore
```

该 task 会读取 lock 文件，逐个执行 `npx skills add ... -g`，自动重建 `~/.agents/skills/` 目录和各 agent 目录下的符号链接（如 `~/.claude/skills/`）。

### 密钥管理

API token 等敏感信息不应该写死在 bashrc 。这里用 macOS Keychain 来存储（本地 login keychain，不走 iCloud Keychain 同步），通过定义在 bashrc 中的 `sec` 函数操作：

```bash
sec add GITHUB_TOKEN "ghp_xxx"    # 添加
sec get GITHUB_TOKEN              # 获取
sec rm GITHUB_TOKEN               # 删除
sec ls                            # 列出所有

# 配合 export 使用
export GITHUB_TOKEN=$(sec get GITHUB_TOKEN 2>/dev/null)
```

跨机器迁移：通过剪贴板（配合 macOS Universal Clipboard，可在登录同一 iCloud 的 Mac 之间无缝传输）：

```bash
sec export    # 在源机：把所有 secret/* 编码（base64）后写入剪贴板
sec import    # 在目标机：从剪贴板读入并校验 magic header，逐个写入 keychain
```

剪贴板里短暂存在 base64 编码的明文 token，不在同一 iCloud 时可手动粘到加密笔记中转。

## Linux 服务器初始化

适用于需要复用 bash 和 mise 配置的 Linux 服务器环境。

### 1. 创建用户并配置 SSH 登录

以 root 登录服务器后执行：

```bash
# 创建用户（无密码）并赋予免密 sudo 权限
useradd -m -s /bin/bash green
usermod -aG sudo,docker green
echo "green ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/green

# 将本地公钥写入 authorized_keys
mkdir -p /home/green/.ssh
# 把本地 ~/.ssh/id_ed25519.pub 的内容粘贴进去
vi /home/green/.ssh/authorized_keys
chmod 700 /home/green/.ssh
chmod 600 /home/green/.ssh/authorized_keys
chown -R green:green /home/green/.ssh

# 为 green 用户生成 SSH 密钥（用于 GitHub clone）
su - green -c 'ssh-keygen -t ed25519 -C "green@$(hostname)" -N ""'
# 查看公钥，添加到 https://github.com/settings/ssh/new
cat /home/green/.ssh/id_ed25519.pub
```

之后即可从本地免密登录：`ssh green@<server-ip>`

### 2. 初始化 home repo

```bash
# 将 repo 初始化到 $HOME
cd "$HOME"
rm -rf .git
git init -b main
git remote add origin git@github.com:theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main
```

### 3. 安装系统依赖和 mise

```bash
sudo apt install -y tmux
curl https://mise.run | sh
```

### 4. 加载自定义 bashrc

```bash
if ! grep -q "# green-bashrc-start" ~/.bashrc; then
cat >>~/.bashrc <<EOF
# green-bashrc-start

if [ -f ~/.config/bash/.bashrc ]; then
    source ~/.config/bash/.bashrc
fi

# green-bashrc-end
EOF
fi
```

```bash
source ~/.bashrc
```

### 5. 安装开发运行时

```bash
mise install
```

## 部署

服务器部署和基础设施即代码在单独的仓库管理：[theowenyoung/studio-example](https://github.com/theowenyoung/studio-example)


## 迁移

旧机器在弃用 / 抹除前要做的清单：

1. 最好保留旧的 Mac，这样可以同步复制粘贴（依赖 iCloud Universal Clipboard）。
2. 迁移 `~/.ssh/`：直接复制粘贴。
3. 迁移 keychain 中的 API token：在旧机执行 `sec export`（写入剪贴板），新机 `sec import` 一次性灌入。详见「密钥管理」。
4. 复制 Chrome 插件的本地设置（账号同步不会带过来的部分），常见的：
   - **Claude**：扩展里的快捷键设置（chrome://extensions/shortcuts）
   - 其他扩展中靠本地存储而非账号同步的偏好（如自定义快捷键、白名单域名等）
