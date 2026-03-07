@echo off
setlocal

set "ROOT=%~dp0"
set "GEMINI_GUARD_RULES=%ROOT%destructive_matchers.rules"
set "GEMINI_GUARD_PS1=%ROOT%gemini-guard.ps1"

:: This environment variable is used by the Gemini CLI to wrap shell commands
set "GEMINI_GUARD_SHELL=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%GEMINI_GUARD_PS1%" -Command"

gemini --profile high_autonomy_safe --dangerously-bypass-approvals-and-sandbox %*
