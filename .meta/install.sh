#!/bin/sh
# shellcheck disable=SC1090

set -e

nl="$(printf '\nx')"
nl="${nl%x}"

case "$(uname -s)" in
        Linux) os=linux ;;
        Darwin) os=darwin ;;
        *)
                echo >&2 "Unknown OS"
                exit 1
                ;;
esac

main() {
        trap 'cd -' EXIT
        cd "$HOME"
        # ensure_prereqs
        # ensure_nix
        # ensure_apps
        #ensure_tpm
        echo "Done"
}

log() { echo "$*" >&2; }

ensure_prereqs() {
        if [ "$os" = linux ] && [ -n "${WSL_DISTRO_NAME:-}" ]; then
                ~/.meta/install.wsl.sh
        fi

        if [ "$os" = darwin ]; then
                ~/.meta/install.macos.sh
        fi
}

# see https://nixos.org/manual/nix/stable/#sect-single-user-installation
# and https://nixos.org/manual/nix/stable/#sect-macos-installation
ensure_nix() {
        echo "Ensuring Nix"

        if ! command -v nix >/dev/null; then
                log "Nix is not installed!"
                 set -x
                curl -sLo- https://nixos.org/nix/install | sh -s -- --no-daemon --no-channel-add --no-modify-profile
                set +x
        fi

        # nixprofile=~/.nix-profile/etc/profile.d/nix.sh
	    # if ! [ -r "$nixprofile" ]; then
        #         log "Seems like the above install failed!"
        #         log "Nix profile file not present: $nixprofile"
        # fi

        # . "$nixprofile"

        nix-channel --update
        nix-shell -p nix-info --run "nix-info -m"
        if [ "$os" = darwin ]; then
            nix run home-manager -- switch --flake ~/.config/home-manager#x86_64-darwin
        fi
}

ensure_apps() {
        if [ "$os" != darwin ]; then return; fi

        echo "Ensuring apps"

        IFS="$nl"
        hashApp() {
                path="$1/Contents/MacOS"
                shift
                find "$path" -perm +111 -type f -maxdepth 1 2>/dev/null | while read -r bin; do
                        md5sum "$bin" | cut -b-32
                done | md5sum | cut -b-32
        }

        mkdir -p ~/Applications/Nix\ Apps

        appspath="$(nix-instantiate --eval --expr '(import <nixpkgs> {}).macos.outPath' | tr -d '"')"

        find "$appspath"/Applications/*.app -maxdepth 1 -type l | while read -r app; do
                echo "$app"

                name="$(basename "$app")"

                src="$(/usr/bin/stat -f%Y "$app")"
                dst="$HOME/Applications/Nix Apps/$name"

                hash1="$(hashApp "$src")"
                hash2="$(hashApp "$dst")"

                if [ "$hash1" != "$hash2" ]; then
                        echo "Current hash of '$name' differs than the Nix store's. Overwriting..."
                        sudo rm -rf "$dst"
                        cp -R "$src" ~/Applications/Nix\ Apps
                fi
        done
}

main "$@"

# create .run directory for op cli
#❯ mkdir -p ~/.local/homebrew && curl -sL https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ~/.local/homebrew
# #❯eval "$(homebrew/bin/brew shellenv)"
# brew update --force --quiet
# chmod -R go-w "$(brew --prefix)/share/zsh"
