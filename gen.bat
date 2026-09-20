@echo off
REM Thin wrapper around gen.ps1 so `gen.bat -l go` works on Windows.
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0gen.ps1" %*
exit /b %ERRORLEVEL%


