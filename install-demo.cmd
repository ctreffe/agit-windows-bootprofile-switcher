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

echo Installing BootProfile Switcher demo setup...
echo.

echo [1/3] Installing boot menu entries...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-BootProfileMenu.ps1"
if %errorlevel% neq 0 goto failed

echo.
echo [2/3] Installing profile configuration...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-BootProfileConfiguration.ps1"
if %errorlevel% neq 0 goto failed

echo.
echo [3/3] Installing startup hook...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\Install-StartupHook.ps1"
if %errorlevel% neq 0 goto failed

echo.
echo BootProfile Switcher demo setup completed.
echo.
pause
exit /b 0

:failed
set "exitCode=%errorlevel%"
echo.
echo BootProfile Switcher demo setup failed with exit code %exitCode%.
echo Review the output above. Already completed steps were not rolled back automatically.
echo.
pause
exit /b %exitCode%
