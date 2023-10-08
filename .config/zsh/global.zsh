## custom



## path
export PATH=./node_modules/.bin
export PATH=$PATH:$HOME/bin
export PATH=$PATH:$HOME/.local/bin
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.deno/bin"
export PATH="$PATH:$HOME/.npm-packages/bin"
export PATH="$PATH:$HOME/.bun/bin"
export PATH=$PATH:/opt/local/bin
export PATH=$PATH:/opt/local/sbin
export PATH=$PATH:/usr/local/bin
export PATH=$PATH:/usr/bin
export PATH=$PATH:/bin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin


# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
# End Nix



# termcolor info
# https://gpanders.com/blog/the-definitive-guide-to-using-tmux-256color-on-macos/
export TERMINFO_DIRS=$TERMINFO_DIRS:$HOME/.local/share/terminfo

# pnpm
# export PNPM_HOME="$HOME/.local/share/pnpm"
# pnpm end

# deno
export DENO_INSTALL="$HOME/.deno"
# denoend

# navi

export NAVI_CONFIG="$HOME/.config/navi/config.yaml"

# nnn
export NNN_OPENER="$HOME/dotfiles/nnn/files/plugins/nuke"
export NNN_OPTS="e"
export NNN_BMS="d:$HOME/Desktop;D:$HOME/Downloads/"
# trash (needs trash-cli) instead of delete
export NNN_TRASH=1
NNN_PLUG_DEFAULT='x:!chmod +x $nnn*;o:fzopen;c:-fzcd;k:-kakopen'
NNN_PLUG="$NNN_PLUG_DEFAULT"
export NNN_PLUG



## fpath
fpath=($HOME/.zsh/functions $fpath)

## env

export DOTFILES_ROOT_PATH="$HOME/dotfiles"
export DOTFILES_PRIVATE_PATH="$HOME/dotfiles/private"
export HOSTNAME=$(hostname)

DOTFILES_FUNCTIONS_PATH="$DOTFILES_ROOT_PATH/scripts/common.sh"
if [ -f "$DOTFILES_FUNCTIONS_PATH" ]; then
  . $DOTFILES_FUNCTIONS_PATH
fi

# editor
if [ -z "$EDITOR_FORCE" ]; then
    export VIM_EDITOR=nvim
else
    export VIM_EDITOR="$EDITOR_FORCE"
fi
export MAIN_EDITOR=$VIM_EDITOR
export EDITOR=$MAIN_EDITOR
export VISUAL=$EDITOR
export TMUX_EDITOR="tmux-$EDITOR"
# acme.sh env
ACME_ENV_FILE="$HOME/.acme.sh/acme.sh.env"
if [ -f "$ACME_ENV_FILE" ]; then
  . $ACME_ENV_FILE
fi
case "$OSTYPE" in
	  linux*)    export XDG_RUNTIME_DIR="/run/user/$UID";;
esac
# ssh agent for debian

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# xdg env

# export XDG_CONFIG_HOME="$HOME/.config"
# export XDG_DATA_HOME="$HOME/.local/share"
# export XDG_CACHE_HOME="$HOME/.cache"
# export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"




# fzf
export FZF_DEFAULT_COMMAND="fd  --exclude={.git,.idea,.vscode,.sass-cache,node_modules,build,\*\*/.DS_Store} --hidden --type f -I"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd -t d . $HOME"
export FZF_DEFAULT_OPTS='--reverse --color="info:#000000,spinner:#000000" --prompt="  "'

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8';
export LC_ALL='en_US.UTF-8';




# history
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=$HISTSIZE

# use emacs as default mode
bindkey -e
## functions
# run yamlscript shortcut

function li (){
  $DOTFILES_ROOT_PATH/scripts/link.sh "$@"
}


