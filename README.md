# Digital Home

我用这个 Repo 来存放我所有的电脑环境和配置文件，这样我可以在任何一台电脑上快速地初始化我的环境，而不用担心配置文件的丢失或遗忘。

理论上我可以只用 Brew 或者只用 nix 来管理所有的软件和配置，但是两者都有各自的问题：

- 只使用 Brew 的问题：Brew 的命令行工具依赖管理很混乱，每次更新软件时总会出现未知的问题，它的依赖管理并不是可重现的。
- 只使用 Nix 的问题：我的主力电脑是 macOS，很多 GUI 的软件 Nix 上并没有。而且我发现在 macOS 上搭建那样一套纯 Nix 的环境，实际上是一件非常耗费心智的事，我更愿意让 Nix 保持轻量化，只用它来管理命令行工具，只把它作为一个mac上的可重现的命令行包管理工具，这样我的心智负担就最小化了。

下面的步骤是写给我自己看的，所以有一些地方可能不太详细并且混乱，仅供参考。

我的原则是：

GUI 应用只使用 Homebrew 安装，用单文件 `~/Brewfile` 管理即可，比如：

```
cask "firefox-developer-edition"
cask "google-chrome"
cask "iterm2"
cask "telegram"
cask "visual-studio-code"
mas "CoffeeTea - Prevent Sleep", id: 6443935401
mas "Immersive Translate", id: 6447957425
mas "iPic", id: 1101244278
mas "Microsoft Word", id: 462054704
mas "S3", id: 6447647340
mas "WeChat", id: 836500024
mas "Xcode", id: 497799835
```

所有的命令行应用，只使用 Nix 安装，也是只用一个文件 `~/flake.nix` 管理就行了，比如：

```nix
{
  description = "my global env";
  inputs = {
	nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv/latest";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

  };
  outputs = { self, nixpkgs,devenv,disko }: {
    # profile for my arm -darwin machine
    packages."aarch64-darwin".default = let
      system = "aarch64-darwin";
      pkgs = (nixpkgs.legacyPackages.${system}.extend (import ./overlays.nix));
    in pkgs.buildEnv {
      name = "global-env";
      paths = with pkgs; [
        nixVersions.nix_2_21
        bashInteractive
        cachix
        devenv.packages."${system}".default
        git
        fzf
        inetutils # telnet
        awscli2
        stripe-cli
        jq
        # custom packages
        (pkgs.callPackage ./packages/whistle/default.nix {})
        (pkgs.callPackage ./packages/web-ext/default.nix {})
      ];
    };
  };
}
```

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

2. 安装 [nix](https://nixos.org/download.html#nix-install-macos)

```

sh <(curl -L https://nixos.org/nix/install)

```

一路确认就ok，nix 很详细的描述了它具体都做了啥，可以观察学习一下。 我更推荐使用官方的安装脚本，很多人喜欢用第三方的，他们觉得更干净，默认的配置更友好，但是我觉得好像也没差多少，用原生的，可以顺便学习一下。另外就是我昨天测试的时候，发现第三方安装的nix版本不是最新的，并且在我的osx 14 电脑上有权限错误，但是nix官方的脚本是正常的。

运行完成后重启 terminal 客户端

3. 安装 homebrew

(用于安装 casks)

```

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

```

3.1 用 brew 安装最新版的 bash （这是使用 brew 安装命令行的一个例外，因为 bash 太低层了，如果都用 nix 来管理的话，可能在重装的时候会出现一些边缘问题)


```
brew install bash
```

4. 下载我的配置 Repo 到 临时目录

```

mkdir -p ~/inbox
git clone http://github.com/theowenyoung/home ~/inbox/home
```

5. 安装gui软件

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

8. 使用 nix 的最新版 bash 版本：

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

10. 安装字体

nix 安装的字体不会自动被安装到系统，需要手动打开 `font book`, 选择 `file` `add fonts to current user`, 选择 `~/nix-profile/share/fonts/truetype/nerdfonts`

11. 打开 iterm2:

    1. Profile -> Window -> Style[Full Screen]
    1. Profile -> Keys -> Left Option Key -> Esc+
    1. Profile -> Keys -> Right Option Key -> Esc+
    1. Profile -> Text -> Font -> FiraCode Nerd Font
    1. General -> Selections -> Applications in terminal may access clipboard.
    1. General -> Selections -> double click performs smart selections

12. alfred 工作流配置

13. 修改快捷键为 `cmd+space`, 移除默认的 spotlight 快捷键
14. item to finder: <https://github.com/LeEnno/alfred-terminalfinder>

15. vimium 浏览器插件配置

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

## 如何卸载 nix （当升级的时候）

1. 先把默认的bash 恢复

```
chsh -s /bin/bash
```

1. 参考[这里](https://nix.dev/manual/nix/2.22/installation/uninstall)

## 参考

- [andreykaipov home](https://github.com/andreykaipov/home)
