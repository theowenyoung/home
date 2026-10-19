# Source this before launching node: exports proxy vars from the current
# macOS system proxy (System Settings / Clash "set system proxy"), so Alfred
# follows whatever the GUI is set to. Already-set vars are left untouched.

if [ -z "$HTTPS_PROXY$https_proxy" ]; then
  _proxy_info="$(/usr/sbin/scutil --proxy 2>/dev/null)"
  _proxy_get() { printf '%s\n' "$_proxy_info" | awk -v k="$1" '$1 == k { print $3; exit }'; }

  if [ "$(_proxy_get HTTPSEnable)" = "1" ]; then
    export HTTPS_PROXY="http://$(_proxy_get HTTPSProxy):$(_proxy_get HTTPSPort)"
  fi
  if [ "$(_proxy_get HTTPEnable)" = "1" ]; then
    export HTTP_PROXY="http://$(_proxy_get HTTPProxy):$(_proxy_get HTTPPort)"
  fi
  if [ -n "$HTTPS_PROXY$HTTP_PROXY" ]; then
    export NO_PROXY="localhost,127.0.0.1,::1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,*.local"
  fi
  unset -f _proxy_get
  unset _proxy_info
fi

# Node's built-in fetch ignores *_PROXY unless this is set (Node >= 24.5)
export NODE_USE_ENV_PROXY=1
