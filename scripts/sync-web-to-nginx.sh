#!/usr/bin/env bash
# 将前端 dist 同步到 docker/nginx/web（Docker Nginx 站点根）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WEB_SRC="$ROOT/ls-aegis-web"
WEB_DST="$ROOT/docker/nginx/web"

echo "==> 构建前端..."
pnpm -C "$WEB_SRC" build

echo "==> 同步到 docker/nginx/web ..."
# 保留说明文件与占位
find "$WEB_DST" -mindepth 1 ! -name '.gitkeep' ! -name 'README.md' -exec rm -rf {} + 2>/dev/null || true
cp -a "$WEB_SRC/dist/." "$WEB_DST/"

echo "==> 完成。可执行: cd docker && docker compose up -d web"
