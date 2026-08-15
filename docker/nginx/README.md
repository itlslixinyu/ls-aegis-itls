# Nginx（前端网关）

- 配置：`conf/nginx.conf`（Compose 以卷挂载，改反代可即时生效）
- 镜像：`Dockerfile` 多阶段构建 `ls-aegis-web` → 打入 `/usr/share/nginx/html`
- `web/`：可选本地静态目录（默认不挂载进容器，产物不入库）

构建（在 `docker/` 下）：

```bash
docker compose build web
docker compose up -d web
```
