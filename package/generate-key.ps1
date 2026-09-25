# Создаёт appsettings.json из шаблона со случайным API-ключом.
$ErrorActionPreference = 'Stop'
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$tpl = Join-Path $dir 'appsettings.template.json'
$cfg = Join-Path $dir 'appsettings.json'

if (Test-Path $cfg) {
    Write-Host '  Конфиг уже есть (appsettings.json) - ключ не менялся.'
    Write-Host '  Текущий ключ смотрите в окне "Мостик" или в appsettings.json.'
    exit 0
}
if (-not (Test-Path $tpl)) {
    Write-Host '  [!] Не найден appsettings.template.json - распакуйте архив заново.'
    exit 1
}

$key = -join (1..32 | ForEach-Object { '{0:x2}' -f (Get-Random -Maximum 256) })
(Get-Content $tpl -Raw).Replace('__API_KEY__', $key) | Set-Content -Path $cfg -Encoding UTF8

Write-Host '  Создан appsettings.json'
Write-Host ''
Write-Host '  Ваш API-ключ:'
Write-Host "  $key"
Write-Host ''
Write-Host '  Его нужно указывать программам в заголовке: Authorization: Bearer <ключ>'
