

alias yb="YS_DEV=1 deno run -A --unstable ~/yamlscript/ys.ts build"
alias yy="YS_DEV=1 deno run -A --unstable ~/yamlscript/ys.ts run"
alias ys="YS_DEV=1 deno run -A --unstable ~/yamlscript/ys.ts"

# Custom
pr(){
	export HTTP_PROXY="http://127.0.0.1:7890"
	export HTTPS_PROXY="http://127.0.0.1:7890"
	export SOCKS_PROXY="socks://127.0.0.1:7891"
}

rp(){
	unset HTTP_PROXY
	unset HTTPS_PROXY
	unset SOCKS_PROXY
}



# git commit

function gc() { git clone ssh://git@github.com/"$*" }
function gg() { git commit -m "$*" -a }
function gp() { git commit -a -m "$*" && git push }
function gt() { git tag -a "$1" -m "$1" && git push }
function ga() { git add . }
function gskip() { git commit -a -m "[skip ci] $*" && git push }


alias gpull="git pull"
alias gpush="git push"


# Some tmux-related shell aliases


# Attaches tmux to the last session; creates a new session if none exists.
alias t='tmux attach || tmux new-session'

function tk(){
  export EDITOR_FORCE="kak"
  source ~/.zshrc
  tmux attach || tmux new-session
}
# Attaches tmux to a session (example: ta portal)
alias ta='tmux attach -t'

# Creates a new session
alias tn='tmux new-session'

# Lists all ongoing sessions
alias tl='tmux list-sessions'



# broot alias, must be set <https://dystroy.org/broot/install-br/>
function br {
    local cmd cmd_file code
    cmd_file=$(mktemp)
    if broot --outcmd "$cmd_file" "$@"; then
        cmd=$(<"$cmd_file")
        rm -f "$cmd_file"
        eval "$cmd"
    else
        code=$?
        rm -f "$cmd_file"
        return "$code"
    fi
}
function b {
  # start with br
  local kak_session_name=$(get-current-project-name)
  # fisrt delete sock file if exist
  rm -f "/tmp/broot-server-$kak_session_name.sock"
  br --listen $kak_session_name;
}
nnn_cd()
{
    if ! [ -z "$NNN_PIPE" ]; then
        printf "%s\0" "0c${PWD}" > "${NNN_PIPE}" !&
    fi
}

trap nnn_cd EXIT

n ()
{
    # Block nesting of nnn in subshells
    if [[ "${NNNLVL:-0}" -ge 1 ]]; then
        echo "nnn is already running"
        return
    fi

    # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
    # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
    # see. To cd on quit only on ^G, remove the "export" and make sure not to
    # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
    #     NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

    # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
    # stty start undef
    # stty stop undef
    # stty lwrap undef
    # stty lnext undef

    # The backslash allows one to alias n to nnn if desired without making an
    # infinitely recursive alias
    START_DIR="$PWD" VISUAL="$TMUX_EDITOR" \nnn "$@"

    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}



# open project with broot and kakoune
p(){
  # check is in tmux
  if [[ -z "${TMUX}" ]]; then
      echo "Not in tmux"
      exit 1
  fi
  session_name="$(get-current-project-name)"
  is_session_exist=$(kak -l | grep $session_name || echo "")
  if [[ -z "${is_session_exist}" ]]; then
    # Create new kakoune daemon for current dir
    kak -d -s $session_name &
    sleep 0.1
  fi
  # check current tmux panes number, if panes length is 1, then create a new pane, xargs for trim output
  local panes=$(tmux list-panes -F "#{pane_active} #{pane_current_command}" | wc -l | xargs)

  # if panes number is 1, then create a new pane
  if [[ $panes -eq 1 ]]; then
      tmux split-window -d -h -l 80% -c '#{pane_current_path}' "kak -c $session_name $@" \; selectp -R
  fi
  # then start broot
  # NNN_FIFO="/tmp/nnn_${session_name}.fifo" n
  lf -command "\$printf \"set global lf_id \$id\" | kak -p $session_name"
}



## clash
alias cl="sudo clash -d ~/.config/clash"
alias rcl="cd -- $HOME/dotfiles && make pull && mergeclash && sudo systemctl restart clash"
alias mergeclash="~/dotfiles/root/clash/merge_clash_config.sh"

## caddy

alias rca="sudo systemctl restart caddy"


## make

alias m="make"


## zeje

alias ze="zellij"

## systemctl

alias sstatus="systemctl --user status"
alias sstart="systemctl --user start"
alias sstop="systemctl --user stop"
alias srestart="systemctl --user restart"
alias sreload="systemctl --user daemon-reload"
alias jlog="journalctl --user -n 100 -f -u"
alias suj="sudo journalctl -n 100 -f -u"
alias sustatus="sudo systemctl status"
alias sustart="sudo systemctl start"
alias sustop="sudo systemctl stop"
alias surestart="sudo systemctl restart"
alias sureload="sudo systemctl daemon-reload"
## process grep
alias pgr="ps aux | grep "

alias pos="port search"
alias poi="sudo port -N install"
alias s='ssh'

# alias lf='ls -lh $(fzf)'

## cd directory
alias cf='cd $(fd --type directory | fzf)'

## rm file
alias rr='rm $(fzf)'
alias rd='rm -r $(fd --type directory | fzf)'
# other

#alias t="tmux"
alias ctags="uctags"
#alias ns="hx --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'"
# Unix
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
v() {
  if [[ $# -eq 1 && -d $1 ]]; then
    (cd $1; $VIM_EDITOR .)
  else
    $VIM_EDITOR "$@"
  fi
}
alias v.='v .'
alias vi=v
alias vi.=v.
alias path='echo $PATH | tr -s ":" "\n"'
alias psgrep='pstree | grep'
alias chx='chmod +x'
alias wh='which'
alias cmd='command'
alias ss='source ~/.zshrc'

# GNU and BSD (macOS) ls flags aren't compatible

if [ "$OSTYPE" = "linux-gnu" ]; then  # Is this the Ubuntu system?
    lsflags='--color --group-directories-first -F'
else
    lsflags='-GF'
    export CLICOLOR=1
fi

# Aliases
alias ls="ls ${lsflags}"
alias ll="ls ${lsflags} -l"
alias la="ls ${lsflags} -la"
alias h="history"
alias hg="history -1000 | grep -i"
alias ,="cd .."
alias l="less"

# GIT
# Do this: git config --global url.ssh://git@github.com/.insteadOf https://github.com
alias gd="git diff"
alias gs="git status 2>/dev/null"
alias gv="git remote -v"
