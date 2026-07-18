#!/bin/bash

set -e

# merge config_linux_add.yml content to config_linux.yml

config_source_path="$HOME/secret/clash/config.yaml"
config_linux_add_path="$HOME/.config/clash/config_linux_add.yml"
config_target_path="$HOME/.config/clash/config.yml"

if [ ! -f "$config_linux_add_path" ]; then
  echo "config_linux_add.yml not exist"
  exit 1
fi

if [ ! -f "$config_source_path" ]; then
  config_source_path="$HOME/secret/clash/config.yml"
fi

if [ ! -f "$config_source_path" ]; then
  echo "shared config not found (config.yaml or config.yml)" >&2
  exit 1
fi

config_tmp_path="$(mktemp "${config_target_path}.tmp.XXXXXX")"
trap 'rm -f "$config_tmp_path"' EXIT

# Both files own distinct top-level sections, so no external YAML processor is
# needed. Keep an explicit separator in case the first file lacks a final LF.
{
  cat "$config_source_path"
  printf '\n'
  cat "$config_linux_add_path"
} >"$config_tmp_path"
chmod 600 "$config_tmp_path"

if ! duplicate_keys="$(awk '
  match($0, /^[[:alnum:]_-]+[[:space:]]*:/) {
    key = substr($0, RSTART, RLENGTH)
    sub(/[[:space:]]*:$/, "", key)
    if (++seen[key] == 2) {
      duplicates = duplicates (duplicates ? ", " : "") key
    }
  }
  END {
    if (duplicates) {
      print duplicates
      exit 1
    }
  }
' "$config_tmp_path")"; then
  echo "duplicate top-level YAML keys: $duplicate_keys" >&2
  exit 1
fi

mv "$config_tmp_path" "$config_target_path"
trap - EXIT
