@echo off
setlocal EnableExtensions

where pwsh.exe >nul 2>&1
if errorlevel 1 (
  echo PowerShell 7 ^(pwsh.exe^) is required.
  echo Install PowerShell 7, then run this launcher again.
  exit /b 1
)

set "SCRIPT_DIR=%~dp0"
pwsh.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" %*
set "EXIT_CODE=%ERRORLEVEL%"

if not "%EXIT_CODE%"=="0" (
  echo Installation failed with exit code %EXIT_CODE%.
)

exit /b %EXIT_CODE%
