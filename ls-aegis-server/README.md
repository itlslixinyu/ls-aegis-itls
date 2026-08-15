# LS Aegis Server

前后端分离后端工程（Maven 多模块）。前端同级目录：`../ls-aegis-web`。

## 模块

| 模块 | 包名 | 说明 |
|------|------|------|
| ls-aegis-crypto | `com.ls.aegis.crypto` | 国密 SM2/SM3/SM4（可配置关闭） |
| ls-aegis-common | `com.ls.aegis.common` | 工具、常量、枚举、API、异常、用户上下文、校验分组 |
| ls-aegis-mybatis | `com.ls.aegis.mybatis` | 实体/Service 基类、MP 配置 |
| ls-aegis-redis | `com.ls.aegis.redis` | 缓存常量、Redis 装配 |
| ls-aegis-security | `com.ls.aegis.security` | Sa-Token、权限拦截、Controller 基类 |
| ls-aegis-starter | `com.ls.aegis.starter` | 核心自动装配（不含 rbac/biz，避免循环依赖） |
| ls-aegis-rbac | `com.ls.aegis.rbac` | 登录认证、用户/角色/菜单/部门/字典/审计 |
| ls-aegis-biz-file | `com.ls.aegis.biz.file` | 文件与存储 |
| ls-aegis-biz-notice | `com.ls.aegis.biz.notice` | 公告与站内消息 |
| ls-aegis-biz-open | `com.ls.aegis.biz.open` | 开放能力示例 |
| ls-aegis-biz-tenant | `com.ls.aegis.biz.tenant` | 多租户（默认不接入启动） |
| ls-aegis-biz-schedule | `com.ls.aegis.biz.schedule` | 任务调度 |
| ls-aegis-boot | `com.ls.aegis.boot` | 启动入口 `LsAegisApplication` |

预留（本仓库未建模块）：`ls-aegis-biz-itsi` / `com.ls.aegis.biz.itsi`（ITSI 进销存）。

## 依赖关系（简）

```
ls-aegis-boot → ls-aegis-rbac / 各 ls-aegis-biz-* / ls-aegis-starter
ls-aegis-biz-* → ls-aegis-starter（核心能力）
ls-aegis-rbac → ls-aegis-starter + ls-aegis-biz-file/sms/notice（跨域协作）
ls-aegis-starter → common / mybatis / redis / security / crypto
```

## 编译

```bash
mvn -DskipTests compile
```
