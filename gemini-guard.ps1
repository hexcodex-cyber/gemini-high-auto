param (
    [string]$Command
)

$RulesFile = $env:GEMINI_GUARD_RULES
if (-not $RulesFile) {
    $RulesFile = Join-Path $PSScriptRoot "destructive_matchers.rules"
}

$MemoryDir = Join-Path $PSScriptRoot "memory"
if (-not (Test-Path $MemoryDir)) { New-Item -ItemType Directory -Path $MemoryDir -Force }

$LogDate = Get-Date -Format "yyyy-MM-dd"
$LogFile = Join-Path $MemoryDir "history_$($LogDate).md"
$SummaryFile = Join-Path $MemoryDir "SUMMARY.md"
$CounterFile = Join-Path $MemoryDir ".counter"

$InteractionID = [Guid]::NewGuid().ToString().Substring(0, 8)
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$GuardAction = "ALLOWED"
$RuleTriggered = "N/A"
$ExitCode = 0
$StdoutStderr = ""

# --- Helper Functions ---
function Log-Interaction {
    $entry = @"
### [$Timestamp] Interaction ID: $InteractionID
- **Intent (Requested):** ``$Command``
- **Guard Action:** $GuardAction
- **Rule Triggered:** $RuleTriggered

#### 💻 Execution Result
**Exit Code:** $ExitCode
**Stdout/Stderr:**
\`\`\`text
$StdoutStderr
\`\`\`
---
"@
    $entry | Out-File -FilePath $LogFile -Append -Encoding utf8
}

function Update-Summary {
    # Increment counter
    $count = 0
    if (Test-Path $CounterFile) { $count = [int](Get-Content $CounterFile) }
    $count++
    $count | Out-File $CounterFile -Encoding utf8

    # Every 10 commands, add a summary placeholder
    if ($count % 10 -eq 0) {
        $summary = "- **[$(Get-Date -Format "HH:mm")]** Batch of 10 commands completed (ID: $InteractionID). Last command: $Command"
        $summary | Out-File -FilePath $SummaryFile -Append -Encoding utf8
    }
}

# --- Guard Logic ---
if ($env:GEMINI_ALLOW_DESTRUCTIVE -eq "1") {
    $GuardAction = "ALLOWED (Override)"
} else {
    if (Test-Path $RulesFile) {
        $rules = Get-Content $RulesFile
        foreach ($line in $rules) {
            if ($line -match "^#" -or [string]::IsNullOrWhiteSpace($line)) { continue }
            $parts = $line.Split('|')
            if ($parts.Count -lt 3) { continue }
            $action = $parts[0]
            $ruleId = $parts[1]
            $regex  = $parts[2]

            if ($Command -match $regex) {
                $RuleTriggered = $ruleId
                if ($action -eq "deny") {
                    $GuardAction = "BLOCKED"
                    Write-Host "gemini-guard: denied by rule '$ruleId'" -ForegroundColor Red
                    Log-Interaction
                    exit 126
                } elseif ($action -eq "confirm") {
                    $GuardAction = "BLOCK (Confirmation Required)"
                    Write-Host "gemini-guard: blocked by rule '$ruleId'. Re-run with GEMINI_ALLOW_DESTRUCTIVE=1" -ForegroundColor Yellow
                    Log-Interaction
                    exit 126
                }
            }
        }
    }
}

# --- Execution ---
try {
    # Capture both output and error streams
    $result = Invoke-Expression "$Command 2>&1"
    $StdoutStderr = $result | Out-String
    $ExitCode = $LASTEXITCODE
} catch {
    $StdoutStderr = $_.Exception.Message
    $ExitCode = 1
} finally {
    Log-Interaction
    Update-Summary
}

exit $ExitCode
