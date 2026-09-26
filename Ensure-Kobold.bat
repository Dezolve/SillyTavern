@echo off
setlocal

set "KOBOLDCPP_EXE=%~dp0..\KoboldCpp\koboldcpp.exe"
set "MODEL_PATH=%~dp0..\Models\L3-8B-Stheno-v3.2-Q4_K_S.gguf"
set "MODEL_URL=http://127.0.0.1:5001/v1/models"

REM Reuse a healthy backend if one is already running.
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $response = Invoke-RestMethod -Uri '%MODEL_URL%' -TimeoutSec 3; if ($response.data.Count -gt 0) { exit 0 } } catch {}; exit 1"
if not errorlevel 1 (
    echo KoboldCpp is already ready on 127.0.0.1:5001.
    exit /b 0
)

if not exist "%KOBOLDCPP_EXE%" (
    echo KoboldCpp was not found at:
    echo   %KOBOLDCPP_EXE%
    exit /b 1
)

if not exist "%MODEL_PATH%" (
    echo Model file was not found at:
    echo   %MODEL_PATH%
    exit /b 1
)

echo Starting KoboldCpp with CUDA...
start "KoboldCpp" "%KOBOLDCPP_EXE%" --skiplauncher --singleinstance --host 127.0.0.1 --port 5001 --usecuda 0 --contextsize 8192 --model "%MODEL_PATH%"

echo Waiting for KoboldCpp on 127.0.0.1:5001...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$deadline=(Get-Date).AddMinutes(5); while((Get-Date) -lt $deadline){ try { $response = Invoke-RestMethod -Uri '%MODEL_URL%' -TimeoutSec 5; if ($response.data.Count -gt 0) { exit 0 } } catch {}; Start-Sleep -Seconds 2 }; exit 1"
if errorlevel 1 (
    echo KoboldCpp did not become ready in time.
    exit /b 1
)

echo KoboldCpp is ready.
exit /b 0
