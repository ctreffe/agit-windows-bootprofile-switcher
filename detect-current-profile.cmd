@echo off
setlocal
pushd "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    set "BPS_SCRIPT=%~f0"
    set "BPS_ROOT=%~dp0"
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath $env:BPS_SCRIPT -WorkingDirectory $env:BPS_ROOT -Verb RunAs"
    exit /b
)

echo Detecting current BootProfile Switcher profile...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Get-CurrentBootProfile.ps1"
set "exitCode=%errorlevel%"

echo.
if "%exitCode%"=="0" (
    echo Detection completed.
) else (
    echo Detection failed with exit code %exitCode%.
)

echo.
pause
exit /b %exitCode%
