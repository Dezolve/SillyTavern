@echo off
setlocal
pushd %~dp0

call "%~dp0Ensure-Kobold.bat"
if errorlevel 1 (
    goto end
)

echo Starting SillyTavern...
call "%~dp0Start.bat" %*

:end
pause
popd
endlocal
