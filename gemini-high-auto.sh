#!/bin/bash

# gemini-high-auto.sh: High-Autonomy Linux Launcher

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export GEMINI_GUARD_RULES="$ROOT_DIR/destructive_matchers.rules"
export GEMINI_GUARD_SH="$ROOT_DIR/gemini-guard.sh"
SUMMARY_FILE="$ROOT_DIR/memory/SUMMARY.md"

# Ensure memory directory exists
mkdir -p "$ROOT_DIR/memory"
[ ! -f "$SUMMARY_FILE" ] && echo "# Episode Summary" > "$SUMMARY_FILE"

# This environment variable is used by the Gemini CLI to wrap shell commands
export GEMINI_GUARD_SHELL="/bin/bash $GEMINI_GUARD_SH"

# System Instruction for Episodic Memory
SYSTEM_MSG="Before starting, read $SUMMARY_FILE to understand the current state and previous actions. "

# Launch Gemini with the system instruction prepended to the interactive prompt
gemini --approval-mode yolo -i "$SYSTEM_MSG $*"
