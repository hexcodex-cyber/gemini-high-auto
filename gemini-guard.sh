#!/bin/bash

# gemini-guard.sh: Linux version of the guard shell
# Intercepts and validates shell commands against a safety policy.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_FILE="${GEMINI_GUARD_RULES:-$ROOT_DIR/destructive_matchers.rules}"
MEMORY_DIR="$ROOT_DIR/memory"
SUMMARY_FILE="$MEMORY_DIR/SUMMARY.md"
COUNTER_FILE="$MEMORY_DIR/.counter"
LOG_DATE=$(date +%Y-%m-%d)
LOG_FILE="$MEMORY_DIR/history_$LOG_DATE.md"

# Ensure memory directory exists
mkdir -p "$MEMORY_DIR"
[ ! -f "$SUMMARY_FILE" ] && echo "# Episode Summary" > "$SUMMARY_FILE"

# Parse arguments. 
# We want to handle both "bash -c 'cmd'" and direct execution.
if [[ "$1" == "-c" || "$1" == "-lc" ]]; then
    COMMAND="$2"
elif [[ $# -gt 0 ]]; then
    COMMAND="$*"
else
    echo "gemini-guard: no command provided" >&2
    exit 1
fi

INTERACTION_ID=$(cat /proc/sys/kernel/random/uuid | cut -c1-8)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
GUARD_ACTION="ALLOWED"
RULE_TRIGGERED="N/A"
EXIT_CODE=0

log_interaction() {
    cat <<EOF >> "$LOG_FILE"
### [$TIMESTAMP] Interaction ID: $INTERACTION_ID
- **Intent (Requested):** \`$COMMAND\`
- **Guard Action:** $GUARD_ACTION
- **Rule Triggered:** $RULE_TRIGGERED

#### 💻 Execution Result
**Exit Code:** $EXIT_CODE
**Stdout/Stderr:**
\`\`\`text
$STDOUT_STDERR
\`\`\`
---
EOF
}

update_summary() {
    # Increment counter
    count=0
    [ -f "$COUNTER_FILE" ] && count=$(cat "$COUNTER_FILE")
    count=$((count + 1))
    echo "$count" > "$COUNTER_FILE"

    # Every 10 commands, add a summary placeholder
    if [ $((count % 10)) -eq 0 ]; then
        echo "- **[$(date +%H:%M)]** Batch of 10 commands completed (ID: $INTERACTION_ID). Last command: $COMMAND" >> "$SUMMARY_FILE"
    fi

}

# --- Guard Logic ---
if [ "${GEMINI_ALLOW_DESTRUCTIVE:-0}" = "1" ]; then
    GUARD_ACTION="ALLOWED (Override)"
else
    if [ -f "$RULES_FILE" ]; then
        while IFS='|' read -r action rule_id regex || [ -n "$action" ]; do
            # Skip comments and empty lines
            [[ "$action" =~ ^#.*$ ]] && continue
            [[ -z "$action" ]] && continue
            
            if [[ "$COMMAND" =~ $regex ]]; then
                RULE_TRIGGERED="$rule_id"
                EXIT_CODE=126
                if [ "$action" = "deny" ]; then
                    GUARD_ACTION="BLOCKED"
                    echo -e "\e[31mgemini-guard: denied by rule '$rule_id'\e[0m" >&2
                    log_interaction
                    exit 126
                elif [ "$action" = "confirm" ]; then
                    GUARD_ACTION="BLOCK (Confirmation Required)"
                    echo -e "\e[33mgemini-guard: blocked by rule '$rule_id'. Re-run with GEMINI_ALLOW_DESTRUCTIVE=1\e[0m" >&2
                    log_interaction
                    exit 126
                fi
            fi
        done < "$RULES_FILE"
    fi
fi

# --- Execution ---
# Execute the command, capture merged stdout/stderr for logging, 
# AND output it to the terminal so the user/AI can see it.
TMP_OUTPUT=$(mktemp)
bash -lc "$COMMAND" 2>&1 | tee "$TMP_OUTPUT"
EXIT_CODE=${PIPESTATUS[0]}
STDOUT_STDERR=$(cat "$TMP_OUTPUT")
rm "$TMP_OUTPUT"

log_interaction
update_summary

exit $EXIT_CODE
