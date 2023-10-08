# old commented out stuff from the old meta/install.sh script that I don't want
# to completely remove because I wouldn't want to look through git history for
# it later

install_xcode() {
    if xcode-select -p >/dev/null; then
        echo "XCode CLI tools already installed"
        return
    fi

    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    if ! softwareupdate --list --no-scan | grep -q 'Command Line Tools'; then
        echo "Can't find the update for the XCode CLI tools. Scanning..."
        softwareupdate --list
    fi
    if ! softwareupdate --list --no-scan | grep -q 'Command Line Tools'; then
        1>&2 echo "Can't find the update for the XCode CLI tools at all... :/"
        exit 3
    fi
    xcodeclitools="$(softwareupdate --list --no-scan | grep -Eo 'Command Line Tools for Xcode-.+')"
    softwareupdate --install "$xcodeclitools"
}


wt_settings() {
    if [ -n "${WSL_DISTRO_NAME:-}" ]; then
        echo "Running within WSL distro"

        echo "Installing Windows Terminal settings"
        cp ~/.config/windows.terminal/settings.json /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/
    fi
}

pathify_alt() {
    nlx="$(printf '\nx')"; nl="${nlx%x}"; IFS="$nl"
    for o in $1; do
        # trim spaces, and skip comments or empty lines
        o="${o#${o%%[![:space:]]*}}"
        case "$o" in ''|\#*) continue; esac

        echo "Installing $o"
        eval "install_$o"
        echo
    done
}


f() {
    case "$(uname -s)" in
    Linux)  os=linux ;;
    Darwin) os=darwin ;;
    *)      >&2 echo "Unknown OS"; exit 1;;
    esac

    if [ "$os" = darwin ]; then
        echo "Updating macOS domain defaults with our property lists"

        for plist in ~/.config/macos/*.plist; do
            domain="$(basename "${plist%.*}")"
            echo "$domain"
            defaults import "$domain" "$plist"
        done
    fi
}
