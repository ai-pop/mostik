@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Мостик

taskkill /IM opencode-bridge-ui.exe /F >nul 2>&1
taskkill /IM opencode-openai-bridge.exe /F >nul 2>&1
taskkill /IM opencode.exe /F >nul 2>&1

echo.
echo  Мостик остановлен: окно, сервис и OpenCode закрыты.
echo.
timeout /t 4 >nul
