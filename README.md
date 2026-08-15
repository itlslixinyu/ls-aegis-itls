# LS・Aegis 雷铄御警安全应用构建平台

面向国密与信创场景的企业级安全应用构建平台（前后端分离）。提供鉴权、权限、业务插件、文件与调度等基础能力，默认全链路国密，可配置关闭以兼容普通开源环境。

| 项 | 说明 |
|---|---|
| 产品名 | LS・Aegis（雷铄御警）安全应用构建平台 |
| 当前版本 | [`VERSION`](./VERSION)（权威版本号，当前 **v1.3.2**） |
| 后端 | `ls-aegis-server`（JDK 21 / Spring Boot 3，启动模块 `ls-aegis-boot`） |
| 前端 | `ls-aegis-web`（Vue 3 + Vite + Arco Design） |
| 部署 | `docker/`（MySQL / Redis / 后端 / Nginx） |
| 部署 SQL | `ls-aegis-server/docs/sql/init.sql`（唯一部署入口） |
| 正式报告 | [`reports/`](./reports/README.md) |

---

## 能力概览

- **安全底座**：Sa-Token 鉴权、RBAC、审计日志；密钥与口令走环境变量，禁止硬编码入库
- **国密全链路**（`gm.enable` 默认 `true`）：传输 SM2、字段 SM4、摘要/口令 SM3；算法模块 `ls-aegis-crypto`（BouncyCastle 纯 Java）
- **信创适配**：x86_64 / ARM64；银河麒麟、统信 UOS；达梦 / 人大金仓可配置切换（默认 MySQL）
- **业务插件**：文件存储、短信、公告、开放能力、任务调度、多租户（租户默认不接入启动）
- **一键部署**：Docker Compose；前端由 `docker/nginx` 多阶段镜像构建打入 Nginx，裸 clone 无需预同步静态资源

---

## 仓库结构

```
LS-Aegis/
├── VERSION                      # 权威版本号（同步 web package.json / server pom revision）
├── README.md                    # 本文件
├── ls-aegis-server/             # 后端多模块 Maven 工程
│   ├── ls-aegis-boot/           # 启动入口 LsAegisApplication
│   ├── ls-aegis-crypto/         # 国密 SM2/SM3/SM4
│   ├── ls-aegis-common/         # 公共工具、API、异常
│   ├── ls-aegis-mybatis/         # MyBatis-Plus 基类与配置
│   ├── ls-aegis-redis/          # Redis 装配
│   ├── ls-aegis-security/       # Sa-Token、权限拦截
│   ├── ls-aegis-starter/        # 核心自动装配
│   ├── ls-aegis-rbac/           # 登录、用户/角色/菜单/部门/字典/审计
│   ├── ls-aegis-biz-file/       # 文件与存储
│   ├── ls-aegis-biz-sms/        # 短信
│   ├── ls-aegis-biz-notice/     # 公告与站内消息
│   ├── ls-aegis-biz-open/       # 开放能力
│   ├── ls-aegis-biz-schedule/   # 任务调度（SnailJob）
│   ├── ls-aegis-biz-tenant/     # 多租户（默认不接入）
│   └── docs/sql/init.sql        # 部署用 SQL（表结构 + 种子 + 插件）
├── ls-aegis-web/                # 前端（Vue 3 + Vite + Arco）
├── docker/                      # Compose、Nginx、运行时挂载
│   ├── docker-compose.yml
│   ├── .env.example             # 密钥模板（复制为 .env，勿提交）
│   ├── nginx/Dockerfile         # 多阶段：构建 ls-aegis-web → Nginx
│   ├── nginx/web/               # 可选本地覆盖挂载点（产物不入库，默认不挂载）
│   └── data/                    # 运行数据（gitignore）
├── scripts/                     # 辅助脚本（可选：本机同步静态到 nginx/web）
└── reports/                     # 本地正式报告（仅 Markdown）
    ├── 安全/
    ├── 国密/
    └── 清理/
```

后端模块说明详见 [`ls-aegis-server/README.md`](./ls-aegis-server/README.md)。

---

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

### Docker（推荐：Compose 多阶段构建前端）

前端静态资源由 `docker/nginx/Dockerfile` 在镜像内 `pnpm build` 打入，**裸 clone 无需预同步** `docker/nginx/web/`。

```bash
cd docker
# 密钥等见 docker/.env.example → 复制为 docker/.env（已 gitignore）
docker compose up -d --build
```

仅重建前端网关：

```bash
cd docker
docker compose build web
docker compose up -d web
```

| 入口 | 地址 |
|---|---|
| 前端（Nginx） | http://localhost:8080 |
| 后端 API | http://localhost:18000 |
| MySQL / Redis | 仅绑定 `127.0.0.1`（3306 / 6379） |

可选：本机先 `pnpm build` 再执行 `scripts/sync-web-to-nginx.*`，仅在自行改 compose 挂载 `nginx/web` 覆盖镜像内容时使用；默认部署路径不要依赖该目录。

---

## 国密与信创

### 国密（默认开启）

| 环节 | 算法 | 说明 |
|---|---|---|
| 传输 | SM2 | 前端 `/auth/gm/public-key` + `encryptTransport`；私钥不下发 |
| 字段存储 | SM4 | `Sm4Encryptor` |
| 摘要 / 新口令 | SM3 | `{sm3}`；校验仍兼容存量 `{bcrypt}` |
| 行为验证码坐标 | SM4/ECB | |
| 分片指纹 / ETag | SM3 | |
| 调度登录摘要 | SM3 | 见 `ls-aegis-biz-schedule` 相关说明 |

- 全局开关：`gm.enable`（默认 `true`）；`false` 仅用于普通开源兼容环境
- 密钥：环境变量 / `gm.key-store-path`；未配置时自动生成并持久化；**禁止硬编码、禁止提交仓库**
- 存量兼容（默认关闭）：`gm.legacy-rsa-fallback`、`gm.legacy-aes-fallback`

验证结论见 [`reports/国密/国密功能测试报告.md`](./reports/国密/国密功能测试报告.md)（用例 **20/20** 通过）。

### 信创

- CPU：x86_64、ARM64（鲲鹏、飞腾）；纯 Java BC，不依赖本地 so
- OS：银河麒麟服务器、统信 UOS 服务器版
- 数据库：默认 MySQL；达梦 DM8 / 人大金仓 KingbaseES 用配置/profile 切换

---

## 版本同步

升版时对齐：

1. 根目录 `VERSION`
2. `ls-aegis-web/package.json` → `version`
3. `ls-aegis-server/pom.xml` → `<revision>`

提交说明建议：`release: vX.Y.Z <中文说明>`；升版时打 tag `vX.Y.Z`。

---

## 报告与文档索引

正式本地报告**只允许**写在 `reports/**/*.md`，索引见 [`reports/README.md`](./reports/README.md)。同类主题合并为一份，避免分散。

| 主题 | 文件 | 说明 |
|---|---|---|
| 安全 | [安全审计与外连扫描报告.md](./reports/安全/安全审计与外连扫描报告.md) | 后门/密钥/加固 + 外连扫描（原三份合并） |
| 国密 | [国密功能测试报告.md](./reports/国密/国密功能测试报告.md) | 国密全链路验证，通过率 100% |
| 清理 | [项目文件清理报告-20260815.md](./reports/清理/项目文件清理报告-20260815.md) | 构建产物 / 死代码 / 规范债务清理落地 |
| 运维 | [换机迁移备忘-20260813.md](./reports/换机迁移备忘-20260813.md) | 指向本地 `backups/` 迁移包（勿提交密钥） |

### 其它文档入口

| 路径 | 说明 |
|---|---|
| [`ls-aegis-server/README.md`](./ls-aegis-server/README.md) | 后端模块与依赖关系 |
| [`ls-aegis-web/README.md`](./ls-aegis-web/README.md) | 前端工程说明 |
| [`docker/nginx/README.md`](./docker/nginx/README.md) | Nginx 多阶段镜像与部署说明 |
| [`docker/nginx/web/README.md`](./docker/nginx/web/README.md) | 可选本地静态覆盖约定（默认不挂载） |
| [`docker/.env.example`](./docker/.env.example) | Compose 密钥与国密路径模板 |
| `ls-aegis-server/docs/sql/init.sql` | 全新安装部署 SQL（非报告目录） |

---

## 安全与配置约定（摘要）

1. 密钥、数据库口令、JWT、国密 keystore 一律放 `docker/.env` 或环境变量，**勿提交**
2. 国密私钥绝不下发前端；Compose 已挂载 `data/gm/` 做密钥持久化
3. 种子数据变更须同步 Liquibase 与 `docs/sql/init.sql`；敏感字段种子优先 `NULL`
4. 含中文 SQL 使用 UTF-8 无 BOM；MySQL 用 `utf8mb4`
5. 探针日志、临时 JSON、构建产物、`docker/data`、`node_modules`、`target` 不入库

---

## 许可证

前后端子工程各自携带 `LICENSE` 文件；以仓库内对应模块声明为准。
