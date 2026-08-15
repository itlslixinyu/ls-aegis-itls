# LS-Aegis

国密 / 信创方向的企业级管理系统（前后端分离）。

| 项 | 说明 |
|---|---|
| 当前版本 | 见根目录 [`VERSION`](./VERSION)（权威版本号） |
| 后端 | `ls-aegis-server`（JDK 21 / Spring Boot 3，启动模块 `ls-aegis-boot`） |
| 前端 | `ls-aegis-web`（Vue 3 + Vite + Arco） |
| 部署 | `docker/`（MySQL / Redis / 后端 / Nginx） |
| 报告 | [`reports/`](./reports/README.md) |

## 目录结构

```
LS-Aegis/
├── VERSION                 # 权威版本号（同步 package.json / server pom revision）
├── ls-aegis-server/        # 后端多模块 Maven 工程
├── ls-aegis-web/           # 前端
├── docker/                 # Compose 与 Nginx / 运行时挂载
├── scripts/                # 辅助脚本（如前端同步到 Nginx）
└── reports/                # 本地正式报告（仅 Markdown）
```

## 快速开始

### 后端

```bash
cd ls-aegis-server
mvn -pl ls-aegis-boot -am package -DskipTests
# 本地可直接运行 ls-aegis-boot，或将 jar 放入 docker/ls-aegis-server/bin/ 后用 Compose
```

### 前端开发

```bash
cd ls-aegis-web
pnpm bootstrap   # 或 pnpm install（国内镜像见 package.json scripts）
pnpm dev         # 默认 Vite，接口经 /api 代理到后端
```

本地 mock 默认关闭；需要时在 `.env.development` 设 `VITE_LOCAL_MOCK=true`。

### Docker（含前端静态资源）

`docker/nginx/web/` **不入库构建产物**。部署前先同步：

```bash
# Windows
.\scripts\sync-web-to-nginx.ps1

# Linux / macOS
./scripts/sync-web-to-nginx.sh
```

再：

```bash
cd docker
# 密钥等见 docker/.env.example → 复制为 docker/.env
docker compose up -d
```

前端访问：`http://localhost:8080`；后端 API：`18000`。

## 国密要点

- 全局开关 `gm.enable`（默认 `true`）：传输 SM2、字段 SM4、摘要/口令 SM3。
- 密钥走环境变量 / `gm.key-store-path`，禁止硬编码、禁止提交仓库；私钥不下发前端。
- 算法模块：`ls-aegis-crypto`（BouncyCastle 纯 Java，适配信创）。
- 关闭国密（`gm.enable=false`）仅用于普通开源兼容环境。

详见 [`reports/国密/国密功能测试报告.md`](./reports/国密/国密功能测试报告.md)。

## 版本同步

升版时对齐：

1. 根目录 `VERSION`
2. `ls-aegis-web/package.json` → `version`
3. `ls-aegis-server/pom.xml` → `<revision>`
