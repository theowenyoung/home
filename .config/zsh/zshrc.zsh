# My zsh includes

# source global first

source ~/.config/zsh/global.zsh

for file in ~/.config/zsh/includes/*; do
  source "$file"
done


EXTRA_DIR=~/.config/zsh/extra
if [ -d "$EXTRA_DIR" ]; then
	for file in "$EXTRA_DIR/"*; do
		source "$file"
  done

fi

# Tab completion
autoload -Uz compinit && compinit -u

# load general config
source ~/.config/zsh/general_config.zsh


# pnpm
export PNPM_HOME="/home/green/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end
# bun completions
[ -s "/Users/green/.bun/_bun" ] && source "/Users/green/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
