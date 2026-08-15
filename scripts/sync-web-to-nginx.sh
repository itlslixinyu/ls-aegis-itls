#!/usr/bin/env bash
# 可选：将本机前端 dist 同步到 docker/nginx/web
#
# 默认 Docker 部署请使用多阶段镜像（docker/nginx/Dockerfile），无需本脚本。
# 仅在自行改 compose 挂载 nginx/web 覆盖镜像静态资源时使用。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB_SRC="$ROOT/ls-aegis-web"
WEB_DST="$ROOT/docker/nginx/web"

echo "==> 构建前端..."
pnpm -C "$WEB_SRC" build

echo "==> 同步到 docker/nginx/web ..."
find "$WEB_DST" -mindepth 1 ! -name '.gitkeep' ! -name 'README.md' -exec rm -rf {} + 2>/dev/null || true
cp -a "$WEB_SRC/dist/." "$WEB_DST/"

echo "==> 完成。注意：默认 compose 不挂载本目录；覆盖镜像需自行改 volumes。"
