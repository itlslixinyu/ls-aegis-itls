# Nginx 前端静态资源（可选本地挂载点）

默认部署路径：**Compose 多阶段构建**（`docker/nginx/Dockerfile`）在镜像内生成静态文件，**无需**本目录有内容，裸 clone 后直接：

```bash
cd docker
docker compose up -d --build
```

本目录仅作可选用途（例如本地覆盖镜像内静态资源时自行挂载），**不要将构建产物提交到 Git**。

## 可选：本机构建后覆盖（不重建 web 镜像）

若暂时要用卷挂载覆盖，可先同步再改 compose 增加挂载（一般不推荐，易与空目录冲突）：

```bash
# Linux / macOS
./scripts/sync-web-to-nginx.sh

# Windows PowerShell
.\scripts\sync-web-to-nginx.ps1
```

日常请优先：`docker compose build web && docker compose up -d web`。
