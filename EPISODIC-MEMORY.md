# Episodic Memory: Persistent Action Logging & Summarization

The "Episodic Memory" system provides a high-fidelity record of all shell actions performed by the Gemini CLI within the `gemini-high-auto` environment. It ensures that the LLM has contextual awareness of previous states and actions.

## Memory Architecture

All memory-related data is stored in the `memory/` directory:

| File | Purpose |
| :--- | :--- |
| `history_YYYY-MM-DD.md` | Detailed "Flight Recorder" of every shell interaction. |
| `SUMMARY.md` | High-level summary of major milestones and batch operations. |
| `.counter` | Tracks the number of commands executed for summarization triggers. |

## The Flight Recorder (History Logs)

For every command intercepted, the system logs a detailed Markdown block:

```markdown
### [TIMESTAMP] Interaction ID: {Unique-8-Char-ID}
- **Intent (Requested):** `ls -R`
- **Guard Action:** ALLOWED
- **Rule Triggered:** N/A

#### 💻 Execution Result
**Exit Code:** 0
**Stdout/Stderr:**
(Full command output captured here)
```

### Key Features
- **Guid Generation**: Every interaction is assigned a unique UUID prefix for easy tracking.
- **Full Capture**: Both stdout and stderr are merged and captured, ensuring error diagnostics are preserved in the log.
- **Fail-Safe Logging**: Uses `try/catch/finally` blocks in PowerShell to ensure the log is written even if the command itself crashes the shell.

## Contextual Awareness (The Summary)

To prevent context bloat, the system maintains a `SUMMARY.md` file:
- **Automatic Summarization**: Every 10 commands, a one-line entry is appended summarizing the batch.
- **System Instruction**: The `gemini-high-auto.cmd` launcher prepends a directive: *"Before starting, read memory/SUMMARY.md to understand the current state and previous actions."*

This allows the LLM to "remember" what it did in previous sessions without re-reading thousands of lines of raw logs.

## Maintenance

- **Log Rotation**: History files are created daily (`history_YYYY-MM-DD.md`).
- **Persistence**: The memory remains across sessions, allowing for long-running autonomous tasks (e.g., complex infrastructure setups).
