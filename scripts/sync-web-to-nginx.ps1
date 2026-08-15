# 可选：将本机前端 dist 同步到 docker/nginx/web
#
# 默认 Docker 部署请使用多阶段镜像（docker/nginx/Dockerfile），无需本脚本。
# 仅在自行改 compose 挂载 nginx/web 覆盖镜像静态资源时使用。

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

Write-Host '==> 完成。注意：默认 compose 不挂载本目录；覆盖镜像需自行改 volumes。'
