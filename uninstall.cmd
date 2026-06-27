@echo off
setlocal
pushd "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    set "elevateScript=%temp%\bootprofile-switcher-elevate-uninstall.vbs"
    > "%elevateScript%" echo Set UAC = CreateObject^("Shell.Application"^)
    >> "%elevateScript%" echo UAC.ShellExecute "%~f0", "", "%~dp0", "runas", 1
    cscript //nologo "%elevateScript%"
    del "%elevateScript%" >nul 2>&1
    exit /b
)

echo Removing BootProfile Switcher boot menu entries...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Uninstall-BootProfileMenu.ps1"
set "exitCode=%errorlevel%"

echo.
if "%exitCode%"=="0" (
    echo Removal completed.
) else (
    echo Removal failed with exit code %exitCode%.
)

echo.
pause
exit /b %exitCode%
