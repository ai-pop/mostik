@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"
title Мостик

echo.
echo  ===============================================
echo    Мостик - локальный AI-API (формат OpenAI)
echo  ===============================================
echo.

if not exist "appsettings.json" (
  echo  Первый запуск: создаю конфиг и API-ключ...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0generate-key.ps1"
  echo.
)

tasklist /FI "IMAGENAME eq opencode-openai-bridge.exe" | find /I "opencode-openai-bridge.exe" >nul
if errorlevel 1 (
  echo  Поднимаю сервис...
  powershell -NoProfile -Command "Start-Process -FilePath '%~dp0opencode-openai-bridge.exe' -WindowStyle Hidden"
) else (
  echo  Сервис уже запущен.
)

powershell -NoProfile -Command "for($i=0;$i -lt 60;$i++){try{Invoke-WebRequest -UseBasicParsing -TimeoutSec 2 'http://127.0.0.1:4891/healthz' | Out-Null; exit 0}catch{Start-Sleep -Milliseconds 800}}; exit 1"

if errorlevel 1 (
  echo  [!] Сервис не ответил. Смотрите server.err.log в этой папке.
) else (
  echo  Сервис работает: http://127.0.0.1:4891/v1
)

tasklist /FI "IMAGENAME eq opencode-bridge-ui.exe" | find /I "opencode-bridge-ui.exe" >nul
if errorlevel 1 (
  echo  Открываю окно управления...
  start "" "%~dp0opencode-bridge-ui.exe"
) else (
  echo  Окно управления уже открыто.
)

echo.
echo  Адрес и ключ для своих программ - в окне, блок "Подключение клиентов".
echo  Остановить всё: "Остановить Мостик.cmd"
echo.
timeout /t 6 >nul
