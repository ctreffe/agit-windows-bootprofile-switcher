@echo off
setlocal
pushd "%~dp0"

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    set "elevateScript=%temp%\bootprofile-switcher-elevate-install.vbs"
    > "%elevateScript%" echo Set UAC = CreateObject^("Shell.Application"^)
    >> "%elevateScript%" echo UAC.ShellExecute "%~f0", "", "%~dp0", "runas", 1
    cscript //nologo "%elevateScript%"
    del "%elevateScript%" >nul 2>&1
    exit /b
)

echo Installing BootProfile Switcher boot menu entries...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-BootProfileMenu.ps1"
set "exitCode=%errorlevel%"

echo.
if "%exitCode%"=="0" (
    echo Installation completed.
) else (
    echo Installation failed with exit code %exitCode%.
)

echo.
pause
exit /b %exitCode%
