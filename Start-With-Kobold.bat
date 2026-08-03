@echo off
setlocal
pushd %~dp0

set "KOBOLDCPP_EXE=%~dp0..\KoboldCpp\koboldcpp.exe"
set "MODEL_PATH=%~dp0..\Models\L3-8B-Stheno-v3.2-Q4_K_S.gguf"
set "MODEL_URL=http://127.0.0.1:5001/v1/models"

if not exist "%KOBOLDCPP_EXE%" (
    echo KoboldCpp was not found at:
    echo   %KOBOLDCPP_EXE%
    goto end
)

if not exist "%MODEL_PATH%" (
    echo Model file was not found at:
    echo   %MODEL_PATH%
    goto end
)

echo Starting KoboldCpp...
start "KoboldCpp" "%KOBOLDCPP_EXE%" --skiplauncher --singleinstance --host 127.0.0.1 --port 5001 --model "%MODEL_PATH%"

echo Waiting for KoboldCpp on 127.0.0.1:5001...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$deadline=(Get-Date).AddMinutes(5); while((Get-Date) -lt $deadline){ try { $null = Invoke-WebRequest -UseBasicParsing '%MODEL_URL%' -TimeoutSec 5; exit 0 } catch { Start-Sleep -Seconds 2 } }; exit 1"
if errorlevel 1 (
    echo KoboldCpp did not become ready in time.
    goto end
)

echo KoboldCpp is ready. Starting SillyTavern...
call "%~dp0Start.bat" %*

:end
pause
popd
endlocal