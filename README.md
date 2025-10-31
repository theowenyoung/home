# Digital Home

我用这个 Repo 来存放我所有的电脑环境和配置文件，这样我可以在任何一台电脑上快速地初始化我的环境，而不用担心配置文件的丢失或遗忘。

- 所有应用都应该使用 `~/Brewfile` 来安装，比如：
- 所有开发环境相关的软件，都使用 [mise](https://mise.jdx.dev/), 来管理，也就是 `~/.config/mise/config.toml`
  - 所有 npm 的全局软件包，使用 `~/.default-npm-packages`来管理，这个会由 mise 来安装
  - 所有 gems 的全局软件包，使用 `~/.default-gem-packages`来管理，这个会由 mise 来安装

## Macos Setup

遗憾的事，初始化的时候目前还做不到一键，但是理论上下面的操作可以用一些脚本来自动化，也许未来会优化这里，目前手动也能接受：

0.  手动设置

    1. 输入法设置为双拼
    2. 键盘速度调整：Settings -> Keyboard 按键速度和延迟都调到最低。
    3. 启用三指拖动 Settings -> (Accessibility) -> Enable (Use trackpad for dragging) -> (Dragging Style -> Three Finger Drag)
    4. 启用 tap to click: (Trackpad) -> Enable [Tap to click]
    5. 自动隐藏 dock 栏 Settings -> Dock -> Automatically hide and show the Dock

1.  install xcode tools

```

xcode-select --install

```

然后同意协议：

```

sudo xcodebuild -license

```

2. 安装 homebrew

(用于安装 casks)

```

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

```

3.1 用 brew 安装最新版的 bash

```
brew install bash
```

4. 下载我的配置 Repo 到 临时目录

```

mkdir -p ~/inbox
git clone http://github.com/theowenyoung/home ~/inbox/home
```

5. 安装所有软件

```
cd ~/inbox/home && brew bundle

```

6. 在浏览器打开 Github 上存放 keepassxc 加密文件的repo，下载密钥文件 `main.kdbx`, 用 keepassxc 打开，找到我保存的 ssh 条目，保存该条目下的所有附件到 `~/.ssh/`, （finder 无法直接选中 `~/.ssh`文件夹，需要`cmd+shift+g` 手动输入该文件夹，选择后，keepassxc软件就会帮我把我的主ssh 下载到本机电脑，这样就可以恢复我的 ssh 文件，随后用于 github repo下载，加密解密密钥等。

6.1 将 home repo 下载到当前用户：

```bash
cd "$HOME"
rm -rf .git
git init -b main
git remote add origin https://github.com/theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main
git remote set-url --push origin git@github.com:theowenyoung/home.git
git remote -v
```

6.2 把 我的bashrc 引入到系统：

加入到 `~/.bashrc`

```
if [ -f ~/.config/bash/.bashrc ]; then
    source ~/.config/bash/.bashrc
fi
```

6.3 临时切换zsh到 bash

```
/bin/bash
source /etc/bashrc
source ~/.bashrc
```

7. 用 nix 安装所有的命令行工具

```
NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features "nix-command flakes" profile install --refresh ~
```

8. 使用 homebrew 的最新版 bash 版本：

```bash
sudo vi /etc/shells
```

添加下面的内容到最后一行：

```
/opt/homebrew/bin/bash
```

```
chsh -s /opt/homebrew/bin/bash
```

9. 使用我的bashrc

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

source it

```bash
. ~/.bash_profile
```

12. alfred 工作流配置, 参考[这里](https://github.com/theowenyoung/home/tree/main/.config/alfred-workflows)

    1. 修改快捷键为 `cmd+space`, 移除默认的 spotlight 快捷键
    2. 修改剪贴板管理的快捷键为 `cmd+cmd`, 两次cmd
    3. 修改 text action 的快捷键为 `option+cmd`
    4. item to finder: <https://github.com/LeEnno/alfred-terminalfinder>

13. vimium 浏览器插件配置

```bash
unmapAll
map j scrollDown
map k scrollUp
map d scrollPageDown
map a LinkHints.activateModeToOpenInNewTab
map f LinkHints.activateMode
map J nextTab
map K previousTab
map gg scrollToTop
map G scrollToBottom
map h scrollLeft
map l scrollRight
```

16. 导入 gpg 私钥，在 keepassxc 里先下载私钥，然后：

```
gpg --import gpg-private.asc
gpg --import gpn2.as
```

## Linux Proxy init

0. (可选) 打开端口

TCP: 34000-37000
UDP: 34000-37000

0. (可选) 如果需要代理的话，在这里启动，请查看 `./.config/bin/ssnow.sh`

```
sudo apt-get -y update
sudo apt -y install snapd
sudo apt -y install sudo
sudo snap install shadowsocks-rust

# use your own ss://xxxxx
export SERVER_URL=

/snap/bin/shadowsocks-rust.sslocal -b 127.0.0.1:1080 --server-url $SERVER_URL &
/snap/bin/shadowsocks-rust.sslocal --protocol http -b 127.0.0.1:8080 --server-url $SERVER_URL &
export http_proxy=http://127.0.0.1:8080
export https_proxy=http://127.0.0.1:8080
export all_proxy=socks5://127.0.0.1:1080

```

1. 安装nix

```
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```

2. 重新进入 sheel

```
exit
# reconnect to ssh
```

（可选）

临时代理需要重新开启：

```
export SERVER_URL=

/snap/bin/shadowsocks-rust.sslocal -b 127.0.0.1:1080 --server-url $SERVER_URL &
/snap/bin/shadowsocks-rust.sslocal --protocol http -b 127.0.0.1:8080 --server-url $SERVER_URL &
export http_proxy=http://127.0.0.1:8080
export https_proxy=http://127.0.0.1:8080
export all_proxy=socks5://127.0.0.1:1080

```

3. 启用 linger (这样让用户级别的任务即使退出也能运行)

```
sudo loginctl enable-linger $USER
```

4. 安装对应的环境软件

```
nix --extra-experimental-features "nix-command flakes" profile install --refresh "github:theowenyoung/home#proxy"
```

（可选）如果需要安装root only：

```
sudo su
```

如果需要代理：

```
export http_proxy=http://127.0.0.1:8080
export https_proxy=http://127.0.0.1:8080
export all_proxy=socks5://127.0.0.1:1080
```

安装 rootonly

```
nix --extra-experimental-features "nix-command flakes" profile install --refresh "github:theowenyoung/home#rootonly"
```

5. 写入 密钥token

// infisical 似乎被墙了...?

在[这里](https://app.infisical.com/project/6547bc625cd2f14fb4bfc19f/members)获取服务器密钥，根据需要选择过期时间

```
# Get infisical token
export INFISICAL_TOKEN=
# 写入到该地址，root 和 普通用户 应该都需要一份
touch ~/.infisicalenv && chmod 600 ~/.infisicalenv && echo "INFISICAL_TOKEN=$INFISICAL_TOKEN" > ~/.infisicalenv
```

4. 下载 dotfiles

只读：

```
cd "$HOME"
rm -rf .git
git init -b main
git remote add origin https://github.com/theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main

```

后期可写：

```
cd "$HOME"
rm -rf .git
git init -b main
git remote add origin https://github.com/theowenyoung/home.git
git fetch origin main
git reset --hard origin/main
git branch --set-upstream-to origin/main main
git remote set-url --push origin git@github.com:theowenyoung/home.git
git remote -v
```

5. 使用我的bashrc(可选)

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

6. source it(可选)

```bash
. ~/.bashrc
```

7. 安装 ss 的service（只能普通用户）

```
./.config/ss/init.sh
```

8. 启动 ss

```
./.config/ss/up.sh
```

9. （可选）安装 Clash meta

**Clone secret**

```
git clone git@github.com:theowenyoung/secret.git
```

```
./.config/clash/init.sh
```

everything is ok now.

## 客户端 ss

## 一键ss

## nixos 初始化

制作 flake.lock 文件

```
nix flake lock
```

```
nix run github:nix-community/nixos-anywhere -- --flake .#nixos root@5.78.116.171 --build-on-remote
```

更新：

ssh to server

```
nixos-rebuild switch --refresh --flake github:theowenyoung/home#nixos
```

## 如何升级现有的软件？

```
brew upgrade
```

## mise

我使用 [mise](https://mise.jdx.dev/) 来管理依赖动态语言的全局脚本和项目级别的依赖。比如全局安装的 node_modules, python modules, ruby gems 等等，直接在 `.default-npm-packages` 指定即可。

安装全局node(--force 触发重新安装所有的.default-npm-packages):

```
mise u -g node@lts --force
```

安装mise全局的软件:

```
mise install
```

## ai-shell

<https://github.com/BuilderIO/ai-shell>

初始化配置:

```
ai config set OPENAI_API_ENDPOINT=https://openrouter.ai/api/v1
ai config set OPENAI_KEY=<your token>


```

## Ansible

coming soon.

## 如何卸载 nix （当升级的时候）

1. 参考[这里](https://nix.dev/manual/nix/2.22/installation/uninstall)

## 参考

- [andreykaipov home](https://github.com/andreykaipov/home)
