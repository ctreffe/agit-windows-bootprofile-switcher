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

echo Installing config-driven boot menu demo...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-ConfigDrivenBootMenuDemo.ps1" -CleanupExisting -Force
set "exitCode=%errorlevel%"

echo.
if "%exitCode%"=="0" (
    echo Config-driven boot menu demo installation completed.
) else (
    echo Config-driven boot menu demo installation failed with exit code %exitCode%.
)

echo.
pause
exit /b %exitCode%
