#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_SRC="$BASE_DIR/plugins/agent-chrome"
PLUGIN_LINK="$HOME/.gemini/config/plugins/agent-chrome"
PLIST_TMPL="$BASE_DIR/launchd/com.local.agent-chrome.plist.tmpl"
PLIST_DEST="$HOME/Library/LaunchAgents/com.local.agent-chrome.plist"
LAUNCHD_LABEL="com.local.agent-chrome"
INSTALL_LAUNCHD=1
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --no-launchd) INSTALL_LAUNCHD=0 ;;
    --uninstall)  UNINSTALL=1 ;;
    -h|--help)
      cat <<EOF
Usage: ~/.config/agent-chrome/setup.sh [options]

Options:
  --no-launchd   Link Antigravity plugin and CLI without installing LaunchAgent
  --uninstall    Remove LaunchAgent, CLI symlink, and Antigravity plugin symlink (keeps ~/.config/agent-chrome and browser profile)
EOF
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

chmod +x "$BASE_DIR/bin/agent-chrome" "$BASE_DIR/bin/agent-chrome-mcp" "$BASE_DIR/setup.sh"

UID_NUM="$(id -u)"

if (( UNINSTALL == 1 )); then
  echo "==> Uninstalling local wiring for agent-chrome..."
  launchctl bootout "gui/${UID_NUM}/${LAUNCHD_LABEL}" >/dev/null 2>&1 || true
  rm -f "$PLIST_DEST" "$HOME/.local/bin/agent-chrome"
  if [[ -L "$PLUGIN_LINK" ]]; then
    rm -f "$PLUGIN_LINK"
  fi
  "$BASE_DIR/bin/agent-chrome" stop || true
  echo "Done. Source files in $BASE_DIR and profile in ~/.local/share/agent-chrome-profile were kept."
  exit 0
fi

echo "==> 1. Linking CLI into ~/.local/bin/agent-chrome"
mkdir -p "$HOME/.local/bin"
ln -sfn "$BASE_DIR/bin/agent-chrome" "$HOME/.local/bin/agent-chrome"

echo "==> 2. Symlinking Antigravity global plugin into $PLUGIN_LINK"
mkdir -p "$(dirname "$PLUGIN_LINK")"
ln -sfn "$PLUGIN_SRC" "$PLUGIN_LINK"

if (( INSTALL_LAUNCHD == 1 )); then
  echo "==> 3. Installing and loading macOS LaunchAgent ($LAUNCHD_LABEL)"
  mkdir -p "$(dirname "$PLIST_DEST")" "$HOME/Library/Logs"
  sed "s|__HOME__|${HOME}|g" "$PLIST_TMPL" > "$PLIST_DEST"
  launchctl bootout "gui/${UID_NUM}/${LAUNCHD_LABEL}" >/dev/null 2>&1 || true
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    if ! launchctl print "gui/${UID_NUM}/${LAUNCHD_LABEL}" >/dev/null 2>&1; then
      break
    fi
    sleep 0.5
  done
  launchctl bootstrap "gui/${UID_NUM}" "$PLIST_DEST"
else
  echo "==> 3. Skipping LaunchAgent (--no-launchd)"
fi

echo "==> 4. Ensuring dedicated Agent Chrome is running on 127.0.0.1:9333"
"$BASE_DIR/bin/agent-chrome" ensure
"$BASE_DIR/bin/agent-chrome" status

echo
echo "Setup complete!"
echo "Tip: Open the Agent Chrome window on this Mac (or run 'agent-chrome open https://accounts.google.com') to sign in once."
