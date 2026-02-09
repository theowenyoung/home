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
3. Settings -> Accessibility：启用三指拖动（Three Finger Drag）
4. Settings -> Trackpad：启用 Tap to click
5. Settings -> Dock：自动隐藏 Dock 栏
6. [HyperKey.app](https://hyperkey.app/) 设置 caps lock 为 Hyper 键

### 1. 安装 Xcode Command Line Tools

```bash
xcode-select --install
sudo xcodebuild -license
```

### 2. 安装 Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. 安装所有软件

先将 Repo 克隆到临时目录，用 Brewfile 安装所有软件：

```bash
mkdir -p ~/inbox
git clone https://github.com/theowenyoung/home ~/inbox/home
cd ~/inbox/home && brew bundle
```

### 4. SSH 密钥

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

### 5. 将 home repo 初始化到 $HOME

```bash
cd "$HOME"
rm -rf .git
git init -b main
git remote add origin https://github.com/theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main
git remote set-url --push origin git@github.com:theowenyoung/home.git
```

### 6. 切换默认 Shell 为 Homebrew Bash

```bash
# 添加 homebrew bash 到合法 shell 列表
echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/bash
```

### 7. 加载自定义 bashrc

```bash
if ! grep -q "# green-bashrc-start" ~/.bash_profile; then
cat >>~/.bash_profile <<EOF
# green-bashrc-start

if [ -f ~/.config/bash/.bashrc ]; then
    source ~/.config/bash/.bashrc
fi

# green-bashrc-end
EOF
fi
```

```bash
source ~/.bash_profile
```

### 8. GPG 密钥（可选）

如果需要保持同一个 GPG 签名身份，GPG 私钥同样以文本形式存储在 Passwords app 中。

**备份密钥到 Passwords app：**

```bash
# 导出私钥内容到剪贴板，然后在 Passwords app 中新建条目粘贴保存
gpg --export-secret-keys --armor | pbcopy
```

**在新机器上恢复密钥：**

```bash
# 在 Passwords app 中找到 GPG 条目，复制内容，然后导入
pbpaste | gpg --import
```

### 9. Alfred 配置

参考 [alfred-workflows](https://github.com/theowenyoung/home/tree/main/.config/alfred-workflows)

1. 快捷键改为 `Cmd+Space`，移除默认 Spotlight 快捷键
2. 剪贴板管理快捷键：`Cmd+Cmd`（双击 Cmd）
3. Text action 快捷键：`Option+Cmd`

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
node, deno, bun, python, ruby, rust, go, zig, uv, redis, zola, awscli, ansible(pipx)

### 密钥管理

API token 等敏感信息不应该写死在 bashrc 。这里用 macOS Keychain（iCloud 同步）来存储，通过定义在 bashrc 中的 `sec` 函数操作：

```bash
sec add GITHUB_TOKEN "ghp_xxx"    # 添加
sec get GITHUB_TOKEN              # 获取
sec rm GITHUB_TOKEN               # 删除
sec ls                            # 列出所有

# 配合 export 使用
export GITHUB_TOKEN=$(sec get GITHUB_TOKEN 2>/dev/null)
```

## 部署

服务器部署和基础设施即代码在单独的仓库管理：[theowenyoung/studio-example](https://github.com/theowenyoung/studio-example)
