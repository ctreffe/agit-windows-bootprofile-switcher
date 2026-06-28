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

echo Installing BootProfile Switcher profile configuration...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-BootProfileConfiguration.ps1"
set "exitCode=%errorlevel%"

echo.
if "%exitCode%"=="0" (
    echo Configuration installation completed.
) else (
    echo Configuration installation failed with exit code %exitCode%.
)

echo.
pause
exit /b %exitCode%
