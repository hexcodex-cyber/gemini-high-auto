# gemini-high-auto: High-Autonomy Windows Launcher

`gemini-high-auto` is a specialized wrapper for the Gemini CLI designed for high-autonomy operations on Windows. It utilizes a custom "Guard Shell" to intercept and validate potentially destructive commands before they are executed.

## Architecture Overview

The system consists of three primary components working in tandem:

1.  **`gemini-high-auto.cmd` (The Launcher)**:
    - Sets the `GEMINI_GUARD_SHELL` environment variable.
    - Points the CLI to use `gemini-guard.ps1` for all shell operations.
    - Injects system instructions for contextual awareness.
    - Launches Gemini in `--approval-mode yolo`.

2.  **`gemini-guard.ps1` (The Guard Shell)**:
    - Acts as a proxy between Gemini and the OS.
    - Captures and inspects every shell command.
    - Implements safety checks, logging, and episodic memory.
    - Returns standard exit codes and merged stdout/stderr to the CLI.

3.  **`destructive_matchers.rules` (Safety Policy)**:
    - A regex-based configuration file defining "Deny" and "Confirm" rules.
    - Targets risky operations like disk formatting, recursive deletions, and system reboots.

## Execution Flow

1.  **Initialization**: The user runs `gemini-high-auto "Task description"`.
2.  **Environment Setup**: The CMD script exports paths for rules, the guard script, and the memory directory.
3.  **Command Interception**: When Gemini attempts a `run_shell_command`, it executes the command via the Guard Shell.
4.  **Rule Validation**: The Guard matches the command against `destructive_matchers.rules`.
5.  **Logging & Memory**: The Guard records the intent and result (see `EPISODIC-MEMORY.md`).
6.  **Final Execution**: If safe, the command is executed via `Invoke-Expression`.

## Usage & Overrides

### Basic Usage
```cmd
gemini-high-auto "Refactor the authentication module"
```

### Forcing Destructive Actions
If a command is blocked by a `confirm` rule but is necessary, set the override variable:
```powershell
$env:GEMINI_ALLOW_DESTRUCTIVE=1
gemini-high-auto
```

## Safety Warning
This tool is designed for **high autonomy**. It will automatically approve file edits and non-destructive shell commands. Always ensure you have a clean git state or backups before use.
