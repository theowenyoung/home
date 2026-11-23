---
name: agent-chrome
description: Manage and recover the dedicated local Agent Chrome profile (127.0.0.1:9333) used by the agent-chrome MCP server. Use when agent-chrome MCP fails to connect, needs a restart, or when guiding the user to sign in manually.
---

# Agent Chrome Runbook

This machine runs a dedicated Google Chrome instance isolated from the user's primary Chrome profile:

- **CDP endpoint**: `http://127.0.0.1:9333` (avoids port `9222`, which may be occupied by Chrome's built-in remote debugging)
- **Persistent profile**: `~/.local/share/agent-chrome-profile` (cookies and sign-ins persist across restarts; never commit to Git)
- **Control CLI**: `~/.config/agent-chrome/bin/agent-chrome` (symlinked to `~/.local/bin/agent-chrome`)

## Recovery Procedure

When an `agent-chrome` MCP tool reports a connection refused / browser closed error:

1. Check status and start if needed:
   ```bash
   ~/.config/agent-chrome/bin/agent-chrome ensure
   ```
2. Verify CDP responds:
   ```bash
   ~/.config/agent-chrome/bin/agent-chrome status
   ```
3. Retry the `agent-chrome` MCP tool call.

## Sign-In / CAPTCHA Handoff

1. Leave the target login or verification page open in the Agent Chrome window.
2. Tell the user clearly which site needs sign-in or verification in the dedicated **Agent Chrome** window on the host machine (or run `~/.config/agent-chrome/bin/agent-chrome open <url>` if they want the URL focused).
3. Wait for the user to confirm completion, then continue using `agent-chrome` MCP tools on the same authenticated session.

## Stopping or Re-registering

- Stop only the dedicated instance (does not touch the user's main Chrome):
  ```bash
  ~/.config/agent-chrome/bin/agent-chrome stop
  ```
- Re-run machine setup (LaunchAgent + `~/.gemini/config/plugins.json`):
  ```bash
  ~/.config/agent-chrome/setup.sh
  ```
