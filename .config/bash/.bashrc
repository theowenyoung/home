#! /bin/bash
# try to set XDG_CONFIG_HOME to ~/.config, if not exists
if [ -z "$XDG_CONFIG_HOME" ]; then
  export XDG_CONFIG_HOME="$HOME/.config"
fi
# if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
#   source "$GHOSTTY_RESOURCES_DIR/shell-integration/bash/ghostty.bash"
# fi
# nix allow unfree
export NIXPKGS_ALLOW_UNFREE=1

# path first

# add path
export PATH="$HOME/.local/bin:$HOME/.config/bin:/opt/homebrew/bin:$HOME/bin:$PATH"
# mise experimental
export MISE_EXPERIMENTAL="1"

# ruby
# export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
# cargo
# export PATH="$HOME/.cargo/bin:$PATH"

# curl
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# check mise is exist
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# x11 forward
export DISPLAY=:0

# export KUBECONFIG="$HOME/secret/kubenetes/vultr.yaml"
export KUBECONFIG="$HOME/secret/kubenetes/kubeconfig-owen.yaml"

# for gpg tmux
export GPG_TTY=$(tty)

# alias

# whistle
export WHISTLE_PATH="$HOME/secret/.WhistleAppData"
alias w2start="w2 start --socksPort 8889"
alias di="dig @114.114.114.114"
alias dd="devbox shell"
alias vv="cd $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Vault"

alias cl="codex-auth list"
alias cs="codex-auth switch"
alias clogin="codex-auth login"
alias cremove="codex-auth remove"

alias t='tmux attach || tmux new-session'

alias m="make"

alias kc="kubectl"

alias status="sudo systemctl status"
alias start="sudo systemctl start"
alias stop="sudo systemctl stop"
alias restart="sudo systemctl restart"
alias reload="sudo systemctl daemon-reload"

alias gb="git for-each-ref --sort=-committerdate refs/ --format='%(committerdate:format:%Y-%m-%d %H:%M) %(authorname) %(refname:short)' | head -n 10"

alias pg="ps aux | grep"

alias ll="ls -l "
alias la="ls -la "

alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'

if [ -f ~/.bashrc ]; then
  alias ss='source ~/.bashrc'
else
  alias ss='source ~/.bash_profile'
fi
alias bb='brew bundle --cleanup --file $HOME/Brewfile'
# git commit
alias gpull="git pull"
alias gpush="git push"
alias gd="git diff"
alias gs="git status 2>/dev/null"
alias gv="git remote -v"

function gc() {
  # check is starts with git@ or https:
  if [[ "$*" =~ ^git@ || "$*" =~ ^https: ]]; then
    git clone "$1"
  else
    git clone ssh://git@github.com/"$*"
  fi
}
function gg() {
  git commit -m "$*" -a
}
function gp() {
  git commit -a -m "$*" && git push
}
function gt() {
  git tag -a "$1" -m "$1" && git push
}
function ga() {
  git add .
}
function gskip() {
  git commit -a -m "[skip ci] $*" && git push
}

# show git brach on bash

parse_git_branch() {
  git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1="\u@\h \[\e[32m\]\w \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "

install_service() {
  local UNIT="$1"

  if [[ -z "$UNIT" ]]; then
    echo "Please provide a unit name."
    return 1
  fi

  systemctl --user enable "$UNIT"
  systemctl --user daemon-reload
  systemctl --user restart "$UNIT"
  systemctl --user status "$UNIT"
}
uninstall_service() {
  local UNIT="$1"

  if [[ -z "$UNIT" ]]; then
    echo "Please provide a unit name."
    return 1
  fi

  systemctl --user stop "$UNIT"
  systemctl --user disable "$UNIT"
  systemctl --user daemon-reload
}

install_system_service() {
  local UNIT="$1"

  if [[ -z "$UNIT" ]]; then
    echo "Please provide a unit name."
    return 1
  fi

  sudo systemctl enable "$UNIT"
  sudo systemctl daemon-reload
  sudo systemctl restart "$UNIT"
  sudo systemctl status "$UNIT"
}
uninstall_system_service() {
  local UNIT="$1"

  if [[ -z "$UNIT" ]]; then
    echo "Please provide a unit name."
    return 1
  fi

  sudo systemctl stop "$UNIT"
  sudo systemctl disable "$UNIT"
  sudo systemctl daemon-reload
}

proxy() {
  export HTTP_PROXY="http://127.0.0.1:7890"
  export HTTPS_PROXY="http://127.0.0.1:7890"
  export SOCKS_PROXY="socks://127.0.0.1:7890"
  export ALL_PROXY="socks://127.0.0.1:7890"
  export http_proxy="$HTTP_PROXY"
  export https_proxy="$HTTPS_PROXY"
  export socks_proxy="$SOCKS_PROXY"
  export all_proxy="$ALL_PROXY"
}

noproxy() {
  unset HTTP_PROXY HTTPS_PROXY SOCKS_PROXY ALL_PROXY
  unset http_proxy https_proxy socks_proxy all_proxy
}

pp() {
  proxy
  perl -i -pe 's/^#// if /proxy_start/../proxy_end/ and !/proxy_(start|end)/' ~/.bashrc
  perl -i -pe 's/^(\s*)# /$1/ if /proxy_start/../proxy_end/ and !/proxy_(start|end)/' ~/.ssh/config
  echo "proxy ON (shell + bashrc + ssh)"
}

nopp() {
  noproxy
  perl -i -pe 's/^/#/ if /proxy_start/../proxy_end/ and !/proxy_(start|end)/ and !/^#/' ~/.bashrc
  perl -i -pe 's/^(\s*)(?!#\s*proxy_(start|end))(\S)/$1# $3/ if /proxy_start/../proxy_end/ and !/proxy_(start|end)/ and !/^\s*#/' ~/.ssh/config
  echo "proxy OFF (shell + bashrc + ssh)"
}

# ==============================================================================
# sec - macOS Keychain 密钥管理工具
#
# 用法:
#   sec add <key> <value>   添加一个密钥 (例: sec add GITHUB_TOKEN "ghp_xxx")
#   sec get <key>           获取密钥的值 (例: sec get GITHUB_TOKEN)
#   sec rm <key>            删除一个密钥 (例: sec rm GITHUB_TOKEN)
#   sec ls                  列出所有已存储的密钥
#
# 密钥会以 "secret/<key>" 的格式存入 macOS Keychain，由系统加密保护。
# 磁盘上不会有任何明文 token。
#
# 配合 export 使用，替代在 .zshrc 里写死 token：
#   export GITHUB_TOKEN=$(sec get GITHUB_TOKEN 2>/dev/null)
#   export OPENAI_API_KEY=$(sec get OPENAI_API_KEY 2>/dev/null)
# ==============================================================================
sec() {
  local prefix="secret"
  case "$1" in
    add) security add-generic-password -a "$USER" -s "$prefix/$2" -w "$3" ;;
    get) security find-generic-password -a "$USER" -s "$prefix/$2" -w ;;
    rm) security delete-generic-password -a "$USER" -s "$prefix/$2" ;;
    ls) security dump-keychain | grep "svce" | grep "$prefix/" | awk -F'"' '{print $4}' | sed "s|$prefix/||" | sort -u ;;
    export)
      local count=0 out="# sec-export v1"$'\n'
      while IFS= read -r k; do
        [ -z "$k" ] && continue
        local v
        v=$(security find-generic-password -a "$USER" -s "$prefix/$k" -w 2>/dev/null) || continue
        out+="$k=$(printf '%s' "$v" | base64 | tr -d '\n')"$'\n'
        count=$((count + 1))
      done < <(sec ls)
      printf '%s' "$out" | pbcopy
      echo "exported $count keys to clipboard"
      ;;
    import)
      local input
      input=$(pbpaste)
      if [ "$(printf '%s\n' "$input" | head -n1)" != "# sec-export v1" ]; then
        echo "error: clipboard is not a sec-export v1 payload" >&2
        return 1
      fi
      local count=0
      while IFS='=' read -r k v; do
        [ -z "$k" ] || [ "${k:0:1}" = "#" ] && continue
        local decoded
        decoded=$(printf '%s' "$v" | base64 -D 2>/dev/null) \
          || { echo "skip $k (base64 decode failed)" >&2; continue; }
        security add-generic-password -U -a "$USER" -s "$prefix/$k" -w "$decoded"
        count=$((count + 1))
      done <<< "$input"
      echo "imported $count keys"
      ;;
    *) echo "usage: sec <add|get|rm|ls|export|import> [key] [value]" ;;
  esac
}

# ==============================================================================
# 环境变量：API token / 端点配置（通过 sec 函数从 macOS Keychain 读取）
#
# 这些行不是密钥本身——只是"运行时从 Keychain 读"的指令。真正的 secret 锁在
# Keychain 里。如果某个 key 没存，sec get 返回空字符串，对应的变量就是空，无害。
# 在新机器上配置：sec add <KEY> "<value>"
# ==============================================================================
export BEDROCK_KEYS=$(sec get BEDROCK_KEYS 2>/dev/null)
export CUSTOM_ANTHROPIC_API_KEY=$(sec get ANTHROPIC_API_KEY 2>/dev/null)
export AZURE_OPENAI_API_KEY=$(sec get AZURE_OPENAI_API_KEY 2>/dev/null)
export AWS_BEARER_TOKEN_BEDROCK=$(sec get AWS_BEARER_TOKEN_BEDROCK 2>/dev/null)
export GITHUB_API_TOKEN=$(sec get GITHUB_API_TOKEN 2>/dev/null)
export GITHUB_TOKEN=$(sec get GITHUB_TOKEN 2>/dev/null)
export HF_TOKEN=$(sec get HF_TOKEN 2>/dev/null)
export CUSTOM_OPENAI_API_ENDPOINT=$(sec get CUSTOM_OPENAI_API_ENDPOINT 2>/dev/null)
export CUSTOM_OPENAI_BASE_URL="$CUSTOM_OPENAI_API_ENDPOINT"
export CUSTOM_OPENAI_API_KEY=$(sec get OPENAI_API_KEY 2>/dev/null)
export SHOWBOAT_REMOTE_URL=$(sec get SHOWBOAT_REMOTE_URL 2>/dev/null)
export CUSTOM_CLAUDE_CODE_OAUTH_TOKEN=$(sec get CLAUDE_CODE_OAUTH_TOKEN 2>/dev/null)
# export CLAUDE_CODE_USE_BEDROCK=1
# export CLAUDE_CODE_MAX_OUTPUT_TOKENS=1000000
export AWS_REGION=us-west-2

# cloudflare
CLOUDFLARE_API_TOKEN=${CLOUDFLARE_API_TOKEN:-$(sec get CLOUDFLARE_API_TOKEN 2>/dev/null)}
CLOUDFLARE_ACCOUNT_ID=${CLOUDFLARE_ACCOUNT_ID:-$(sec get CLOUDFLARE_ACCOUNT_ID 2>/dev/null)}

# other config
# if [ -t 1 ]; then
# bash config
# Enable tab completion
# bind 'set show-all-if-ambiguous on'
# bind 'TAB:menu-complete'
# bind '"\e[Z":menu-complete-backward'
# fi

# editor
if [ -z "$EDITOR_FORCE" ]; then
  # check is nvim exists
  if command -v nvim >/dev/null 2>&1; then
    export VIM_EDITOR=nvim
  else
    export VIM_EDITOR=vi
  fi
else
  export VIM_EDITOR="$EDITOR_FORCE"
fi
export MAIN_EDITOR=$VIM_EDITOR
export EDITOR=$MAIN_EDITOR
export VISUAL=$EDITOR
export TMUX_EDITOR="tmux-$EDITOR"
alias vi="$EDITOR"

# direnv init
# if ~/.nix-profile/bin/direnv exists, load it.
# if [[ -x ~/.nix-profile/bin/direnv ]]; then
# 	eval "$(~/.nix-profile/bin/direnv hook bash)"
# fi

# homebrew
# no analytics
export HOMEBREW_NO_ANALYTICS=1

# flox
# no analytics
export FLOX_DISABLE_METRICS=true

source "$HOME/.config/bash/ssh-completion.bash"
source "$HOME/.config/bash/make-completion.bash"

source "$HOME/.config/bash/pnpm-completion.bash"
complete -o default -o bashdefault -F _mise mr
if command -v git >/dev/null 2>&1; then
  source "$HOME/.config/bash/git-completion.bash"
fi

# test if kubectl is installed
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
fi

# 改成类似 kubectl的,mise completion bash
source <(mise completion bash --include-bash-completion-lib)

# 把 mr 的补全指向 mise 的补全函数（名字通常叫 _mise）
# 注意：这行要在上面的 completion 加载之后
# add alias
# 推荐：函数转发 + 绑定补全
function mr() {
  mise run "$@"
}
#
if [[ "$TERM_PROGRAM" == "iTerm.app" ]] && test -e "${HOME}/.config/bash/.iterm2_shell_integration.bash"; then
  source "${HOME}/.config/bash/.iterm2_shell_integration.bash"
fi

alias p="pnpm"

# Bash 需要用 complete 命令
complete -F _pnpm_completion pp

alias gittree="git ls-tree -r HEAD --name-only | tree --fromfile"

alias c="claude --dangerously-skip-permissions"
alias cc="claude --dangerously-skip-permissions --permission-mode plan"
alias cccc="claude --dangerously-skip-permissions --continue"
alias ccccc="claude --dangerously-skip-permissions --resume"
alias upnode="mise u -g node@lts --force"
