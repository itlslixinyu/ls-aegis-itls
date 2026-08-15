# 将前端 dist 同步到 docker/nginx/web（Docker Nginx 站点根）
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$WebSrc = Join-Path $Root 'ls-aegis-web'
$WebDst = Join-Path $Root 'docker\nginx\web'

Write-Host '==> 构建前端...'
pnpm -C $WebSrc build
if ($LASTEXITCODE -ne 0) { throw '前端构建失败' }

Write-Host '==> 同步到 docker/nginx/web ...'
Get-ChildItem -Path $WebDst -Force | Where-Object {
  $_.Name -notin @('.gitkeep', 'README.md')
} | Remove-Item -Recurse -Force

Copy-Item -Path (Join-Path $WebSrc 'dist\*') -Destination $WebDst -Recurse -Force

Write-Host '==> 完成。可执行: cd docker; docker compose up -d web'
