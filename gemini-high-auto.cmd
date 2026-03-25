@echo off
setlocal

set "ROOT=%~dp0"
set "GEMINI_GUARD_RULES=%ROOT%destructive_matchers.rules"
set "GEMINI_GUARD_PS1=%ROOT%gemini-guard.ps1"
set "SUMMARY_FILE=%ROOT%memory\SUMMARY.md"

:: Ensure memory directory exists
if not exist "%ROOT%memory" mkdir "%ROOT%memory"
if not exist "%SUMMARY_FILE%" echo # Episode Summary > "%SUMMARY_FILE%"

:: This environment variable is used by the Gemini CLI to wrap shell commands
set "GEMINI_GUARD_SHELL=powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%GEMINI_GUARD_PS1%" -Command"

:: System Instruction for Episodic Memory
set "SYSTEM_MSG=Before starting, read %SUMMARY_FILE% to understand the current state and previous actions. "

:: Launch Gemini with the system instruction prepended to the interactive prompt
gemini --approval-mode yolo -i "%SYSTEM_MSG% %*"
