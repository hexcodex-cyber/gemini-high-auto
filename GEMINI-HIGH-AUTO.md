# gemini-high-auto: High-Autonomy Guarded Launcher

`gemini-high-auto` is a specialized wrapper for the Gemini CLI designed for high-autonomy operations on Windows and Linux. It utilizes a custom "Guard Shell" to intercept and validate potentially destructive commands before they are executed.

## Architecture Overview

The system consists of three primary components working in tandem:

1.  **The Launcher (`gemini-high-auto.sh` / `.cmd`)**:
    - Sets the `GEMINI_GUARD_SHELL` environment variable.
    - Points the CLI to use the appropriate guard script for all shell operations.
    - Injects system instructions for contextual awareness.
    - Launches Gemini in `--approval-mode yolo`.

2.  **The Guard Shell (`gemini-guard.sh` / `.ps1`)**:
    - Acts as a proxy between Gemini and the OS.
    - Captures and inspects every shell command.
    - Implements safety checks, logging, and episodic memory.
    - Returns standard exit codes and merged stdout/stderr to the CLI.

3.  **`destructive_matchers.rules` (Safety Policy)**:
    - A regex-based configuration file defining "Deny" and "Confirm" rules.
    - Targets risky operations like disk formatting, recursive deletions, and system reboots for both Windows and Linux.

## Execution Flow

1.  **Initialization**: The user runs `gemini-high-auto "Task description"`.
2.  **Environment Setup**: The launcher script exports paths for rules, the guard script, and the memory directory.
3.  **Command Interception**: When Gemini attempts a `run_shell_command`, it executes the command via the Guard Shell.
4.  **Rule Validation**: The Guard matches the command against `destructive_matchers.rules`.
5.  **Logging & Memory**: The Guard records the intent and result (see `EPISODIC-MEMORY.md`).
6.  **Final Execution**: If safe, the command is executed.

## What is YOLO Mode?

The Gemini CLI includes an `--approval-mode yolo` flag. **YOLO** stands for **"You Only Live Once"** and it enables maximum autonomy:

- **No Confirmations**: Gemini will execute all tools (file edits, shell commands, web searches) without asking for user permission.
- **Unattended Tasking**: This allows the AI to perform complex, multi-step operations autonomously.
- **The Risk**: Without a wrapper like `gemini-high-auto`, a raw YOLO session could accidentally delete critical files or run dangerous commands if the model makes a mistake.

### How this project makes YOLO safer:
`gemini-high-auto` is designed to give you the speed of YOLO with a **Safety Net**. The guard shell acts as a final gatekeeper, matching every command against `destructive_matchers.rules` *after* the AI has already "approved" it but *before* it hits your operating system.

## Usage & Overrides

### Basic Usage
```bash
./gemini-high-auto.sh "Refactor the authentication module"
```

### Forcing Destructive Actions
If a command is blocked by a `confirm` rule but is necessary, set the override variable:
```bash
export GEMINI_ALLOW_DESTRUCTIVE=1
./gemini-high-auto.sh
```

## Safety Warning
This tool is designed for **high autonomy**. It will automatically approve file edits and non-destructive shell commands. Always ensure you have a clean git state or backups before use.
