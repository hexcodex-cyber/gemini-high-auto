param (
    [string]$Command
)

$RulesFile = $env:GEMINI_GUARD_RULES
if (-not $RulesFile) {
    $RulesFile = Join-Path $PSScriptRoot "destructive_matchers.rules"
}

if (-not (Test-Path $RulesFile)) {
    Write-Error "gemini-guard: rules file not found: $RulesFile"
    exit 2
}

# Check for intentional override
if ($env:GEMINI_ALLOW_DESTRUCTIVE -eq "1") {
    Invoke-Expression $Command
    exit $LASTEXITCODE
}

# Load and check rules
$rules = Get-Content $RulesFile
foreach ($line in $rules) {
    if ($line -match "^#" -or [string]::IsNullOrWhiteSpace($line)) { continue }
    
    $parts = $line.Split('|')
    if ($parts.Count -lt 3) { continue }
    
    $action = $parts[0]
    $ruleId = $parts[1]
    $regex  = $parts[2]

    if ($Command -match $regex) {
        switch ($action) {
            "deny" {
                Write-Host "gemini-guard: denied by rule '$ruleId'" -ForegroundColor Red
                Write-Host "cmd: $Command" -ForegroundColor Gray
                exit 126
            }
            "confirm" {
                Write-Host "gemini-guard: blocked (confirmation required) by rule '$ruleId'" -ForegroundColor Yellow
                Write-Host "cmd: $Command" -ForegroundColor Gray
                Write-Host "Re-run intentionally with: `$env:GEMINI_ALLOW_DESTRUCTIVE=1" -ForegroundColor Gray
                exit 126
            }
            default {
                Write-Error "gemini-guard: invalid action '$action' in rules file"
                exit 2
            }
        }
    }
}

# If safe, execute
Invoke-Expression $Command
exit $LASTEXITCODE
