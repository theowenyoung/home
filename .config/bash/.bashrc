#! /bin/bash

source "$HOME/.config/bash/git-completion.bash"
source "$HOME/.config/bash/ssh-completion.bash"
# If you do not plan on having Home Manager manage your shell configuration then you must source the file
# https://nix-community.github.io/home-manager/
source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

# alias

alias w2start="w2 start --socksPort 8889"
alias di="dig @114.114.114.114"

alias t='tmux attach || tmux new-session'

alias m="make"

alias status="sudo systemctl status"
alias start="sudo systemctl start"
alias stop="sudo systemctl stop"
alias restart="sudo systemctl restart"
alias reload="sudo systemctl daemon-reload"

alias pg="ps aux | grep "

alias ll="ls -l "
alias la="ls -la "

alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias ss='source ~/.bashrc'

# git commit
alias gpull="git pull"
alias gpush="git push"
alias gd="git diff"
alias gs="git status 2>/dev/null"
alias gv="git remote -v"

function gc() {
	git clone ssh://git@github.com/"$*"
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

proxy() {
	export HTTP_PROXY="http://127.0.0.1:7890"
	export HTTPS_PROXY="http://127.0.0.1:7890"
	export SOCKS_PROXY="socks://127.0.0.1:7891"
}

noproxy() {
	unset HTTP_PROXY
	unset HTTPS_PROXY
	unset SOCKS_PROXY
}

# other config

# bash config
# Enable tab completion
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete-backward'

# editor
if [ -z "$EDITOR_FORCE" ]; then
	# check is nvim exists
	if command -v nvim >/dev/null 2>&1; then
		export EDITOR_FORCE=nvim
	else
		export EDITOR_FORCE=vi
	fi
else
	export VIM_EDITOR="$EDITOR_FORCE"
fi
export MAIN_EDITOR=$VIM_EDITOR
export EDITOR=$MAIN_EDITOR
export VISUAL=$EDITOR
export TMUX_EDITOR="tmux-$EDITOR"

# direnv init
# if ~/.nix-profile/bin/direnv exists, load it.
if [[ -x ~/.nix-profile/bin/direnv ]]; then
	eval "$(~/.nix-profile/bin/direnv hook bash)"
fi

# homebrew
# no analytics
export HOMEBREW_NO_ANALYTICS=1

# flox
# no analytics
export FLOX_DISABLE_METRICS=true

# whistle
export WHISTLE_PATH="$HOME/secret/.WhistleAppData"
