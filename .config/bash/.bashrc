#! /bin/bash
# nix allow unfree
NIXPKGS_ALLOW_UNFREE=1

source "$HOME/.config/bash/ssh-completion.bash"
source "$HOME/.config/bash/make-completion.bash"

# path first

# add path
export PATH="$HOME/.config/bin:/opt/homebrew/bin:$HOME/bin:$PATH"

# ruby
# export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
# export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
# cargo
# export PATH="$HOME/.cargo/bin:$PATH"

# curl
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# check is git exist

if command -v git >/dev/null 2>&1; then
  source "$HOME/.config/bash/git-completion.bash"
fi

# test if kubectl is installed
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
fi

# check mise is exist
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

#
if [[ "$TERM_PROGRAM" == "iTerm.app" ]] && test -e "${HOME}/.config/bash/.iterm2_shell_integration.bash"; then
  source "${HOME}/.config/bash/.iterm2_shell_integration.bash"
fi

# x11 forward
export DISPLAY=:0

export KUBECONFIG="$HOME/secret/kubenetes/vultr.yaml"

# alias

# whistle
export WHISTLE_PATH="$HOME/secret/.WhistleAppData"
alias w2start="w2 start --socksPort 8889"
alias di="dig @114.114.114.114"
alias dd="devbox shell"

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
  # lowercase
  export http_proxy="$HTTP_PROXY"
  export https_proxy="$HTTPS_PROXY"
  export socks_proxy="$SOCKS_PROXY"
  export all_proxy="$ALL_PROXY"
}

noproxy() {
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset SOCKS_PROXY
  unset ALL_PROXY
  unset http_proxy
  unset https_proxy
  unset socks_proxy
  unset all_proxy
}

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
