# Agent Chrome Browser Routing

On this machine, a dedicated Chrome profile (`~/.local/share/agent-chrome-profile`) is exposed on `127.0.0.1:9333` via the `agent-chrome` plugin's `browser` MCP server (`agent-chrome_browser`) so browser automation never triggers Chrome's blocking "Allow remote debugging?" dialog during Remote Control sessions.

- For live web page tasks (navigating interactive or authenticated sites, clicking, filling forms, taking visual screenshots, inspecting console/network), **use the `agent-chrome` MCP browser tools directly** instead of invoking the `/browser` subagent.
- If the MCP browser tools fail to connect to `127.0.0.1:9333`, load the `agent-chrome` skill to restart/ensure the dedicated Chrome instance and retry.
- Never attempt to bypass CAPTCHAs, MFA, or login screens; leave the page open in the dedicated Agent Chrome window and ask the user to sign in, then continue once they confirm.
