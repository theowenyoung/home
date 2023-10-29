# Digital Home

`~` config files repo.




## Todo

- bash show current branch



## GUI 应用只使用 homebrew 安装

`~/Brewfile`

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

## 命令行应用只使用 nixos 安装


## Macos Setup


1. install xcode tools

```
xcode-select --install
```

2. 安装 [nix](https://nixos.org/download.html#nix-install-macos)

```
sh <(curl -L https://nixos.org/nix/install)
```

一路确认就ok，nix 很详细的描述了它具体都做了啥，可以观察学习一下。 我更推荐使用官方的安装脚本，很多人喜欢用第三方的，他们觉得更干净，默认的配置更友好，但是我觉得好像也没差多少，用原生的，可以顺便学习一下。另外就是我昨天测试的时候，发现第三方安装的nix版本不是最新的，并且在我的osx 14 电脑上有权限错误，但是nix官方的脚本是正常的。

3. 安装 homebrew

(用于安装 casks)

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

4. 安装gui软件

```
brew bundle
```

4. 用于恢复我的 ssh 文件，随后用于 github repo下载，加密解密密钥等。

5. 在浏览器打开 Github 上存放 keepassxc 加密文件的repo，下载密钥文件 `main.kdbx`, 用 keepassxc 打开，找到我之前保存的 ssh 条目，下载该条目下的附件到 `~/.ssh/`, （finder 无法直接选中 `~/.ssh`文件夹，需要`cmd+shift+g` 手动输入该文件夹，选择后，keepassxc软件就会帮我把我的主ssh 下载到本机电脑了，之后各种需要密钥的操作都依赖这个）

6. 下载我的配置repo 到 临时目录

```
mkdir -p ~/inbox
git clone http://github.com/theowenyoung/home ~/inbox/home
```

7. 执行初始化

```
~/inbox/home/.meta/init.sh
```


## Linux init

1. 安装nix 

```
sh <(curl -L https://nixos.org/nix/install) --daemon --yes
```

2. 重新进入 sheel

```
exit
# reconnect to ssh
```

3. 安装对应的环境软件

```
nix --extra-experimental-features "nix-command flakes" profile install github:theowenyoung/home?dir=/.config/env#proxy
```

4. 下载 dotfiles

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






## GUI 软件配置

8. 打开 iterm2:

  1. Profile -> Window -> Style[Full Screen]
  2. Profile -> Keys -> Left Option Key -> Esc+
  3. Profile -> Keys -> Right Option Key -> Esc+
  4. General -> Selections -> Applications in terminal may access clipboard.
  5. General -> Selections -> double click performs smart selections
  6. Profile -> Text -> Font -> FiraCode Nerd Font


9. surfingkeys 扩展配置

加载远程配置： <https://raw.githubusercontent.com/theowenyoung/home/main/.config/surfingkeys/default.js>




## 参考


- [andreykaipov home](https://github.com/andreykaipov/home)
