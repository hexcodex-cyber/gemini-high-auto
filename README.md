# gemini-high-auto

> [!CAUTION]
> **READ THE [DISCLAIMER.md](DISCLAIMER.md) BEFORE USE.** High-autonomy operations carry significant risk of data loss. By using this tool, you assume all responsibility for any damage caused.

A cross-platform (Windows/Linux) high-autonomy Gemini launcher with a local guard script to block or confirm risky destructive commands by regex policy.

## Architecture

This project provides:
- **`gemini-high-auto.sh` / `.cmd`**: Launchers that set environment variables and start Gemini in high-autonomy mode (`--approval-mode yolo`).
- **`gemini-guard.sh` / `.ps1`**: Guard scripts (Bash/PowerShell) that intercept shell commands, matching them against local safety rules.
- **`destructive_matchers.rules`**: Configuration file containing regex patterns for dangerous commands (e.g., `rm -rf`, `format`, `dd`).

## How it Works

When `gemini-high-auto` is launched, it sets the `GEMINI_GUARD_SHELL` environment variable. The Gemini CLI utilizes this to run shell operations through the guard script. If a command matches a "deny" rule, it's blocked; if it matches a "confirm" rule, it's blocked unless an override is provided.

## Usage

### Windows
1. Add this folder to your system `PATH`.
2. Run `gemini-high-auto` from your terminal:
   ```cmd
   gemini-high-auto "Refactor my project"
   ```

### Linux
1. Ensure `gemini-guard.sh` and `gemini-high-auto.sh` are executable:
   ```bash
   chmod +x gemini-*.sh
   ```
2. Run the launcher:
   ```bash
   ./gemini-high-auto.sh "Refactor my project"
   ```

## Episodic Memory & Session Logging

Every interaction is automatically logged in the `memory/` directory to provide a persistent "flight recorder" for the AI's actions.

- **History Logs:** `memory/history_YYYY-MM-DD.md` (detailed record of every shell command and its output).
- **Episode Summary:** `memory/SUMMARY.md` (high-level milestones for long-running tasks).

This allows the AI to "remember" its previous actions across sessions without re-reading thousands of lines of raw logs. See [EPISODIC-MEMORY.md](EPISODIC-MEMORY.md) for details.

## Override (Intentional Destructive Operations)

If you explicitly need to run a command that is being blocked:

**Windows:**
```powershell
$env:GEMINI_ALLOW_DESTRUCTIVE=1
gemini-high-auto
```

**Linux:**
```bash
export GEMINI_ALLOW_DESTRUCTIVE=1
./gemini-high-auto.sh
```

## Warning

This setup runs Gemini in a high-autonomy mode that bypasses most user approvals. Use only on systems where you have full control and recent backups.
