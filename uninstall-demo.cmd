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

echo Removing BootProfile Switcher demo setup...
echo.

echo [1/3] Removing startup hook...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Uninstall-StartupHook.ps1"
if %errorlevel% neq 0 goto failed

echo.
echo [2/3] Removing boot menu entries...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Uninstall-BootProfileMenu.ps1"
if %errorlevel% neq 0 goto failed

echo.
echo [3/3] Removing temporary demo marker if present...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Remove-Item -LiteralPath (Join-Path $env:ProgramData 'BootProfileSwitcher\runtime\demo-current-profile.json') -Force -ErrorAction SilentlyContinue"
if %errorlevel% neq 0 goto failed

echo.
echo BootProfile Switcher demo setup removed.
echo Profile configuration in ProgramData was left unchanged.
echo.
pause
exit /b 0

:failed
set "exitCode=%errorlevel%"
echo.
echo BootProfile Switcher demo removal failed with exit code %exitCode%.
echo Review the output above. Remaining parts can still be removed with the individual uninstall wrappers.
echo.
pause
exit /b %exitCode%
