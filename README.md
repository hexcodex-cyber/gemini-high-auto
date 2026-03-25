# gemini-high-auto

> [!CAUTION]
> **READ THE [DISCLAIMER.md](DISCLAIMER.md) BEFORE USE.** High-autonomy operations carry significant risk of data loss. By using this tool, you assume all responsibility for any damage caused.

A Windows-native high-autonomy Gemini launcher with a local PowerShell guard script to block or confirm risky destructive commands by regex policy.

## Architecture

This project is a port of the Linux `codex-high-auto` utility. It provides:
- **`gemini-high-auto.cmd`**: Launcher batch file that sets environment variables and starts Gemini in high-autonomy mode.
- **`gemini-guard.ps1`**: PowerShell guard script that intercepts shell commands, matching them against local safety rules.
- **`destructive_matchers.rules`**: Configuration file containing regex patterns for dangerous Windows commands (e.g., `Remove-Item -Recurse`, `Format-Volume`, `diskpart`).

## How it Works

When `gemini-high-auto` is launched, it sets the `GEMINI_GUARD_SHELL` environment variable. The Gemini CLI utilizes this to run shell operations through the guard script. If a command matches a "deny" rule, it's blocked; if it matches a "confirm" rule, it's blocked unless an override is provided.

## Usage

1. Add this folder to your system `PATH`.
2. Run `gemini-high-auto` from your terminal:
   ```cmd
   gemini-high-auto
   ```

## Session Logging

Every time `gemini-high-auto` is executed, it automatically generates a unique session log in the `logs/` directory.

- **File Format:** `logs/session-YYYY-DD-MM-HHMM.md`
- **Content:**
  - Initial user request.
  - Chronological list of all shell commands executed.
  - Status for each command: `ALLOW`, `DENY` (blocked by rule), or `BLOCK` (confirmation required).

This provides a clear audit trail of all high-autonomy actions taken by the CLI.

## Override (Intentional Destructive Operations)

If you explicitly need to run a command that is being blocked:
```powershell
$env:GEMINI_ALLOW_DESTRUCTIVE=1
gemini-high-auto
```

## Warning

This setup runs Gemini in a high-autonomy mode that bypasses most user approvals. Use only on systems where you have full control and recent backups.
