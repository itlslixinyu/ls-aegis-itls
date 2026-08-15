-- LS-Aegis MySQL 全新安装初始化脚本（唯一部署 SQL）
-- 由 Liquibase mysql changelog 合并生成：表结构 + 种子 + 插件
-- 导入前请确保库已创建且客户端使用 utf8mb4
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ========== main_table.sql ==========

CREATE TABLE IF NOT EXISTS `sys_menu` (
    `id`          bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `title`       varchar(30)  NOT NULL                    COMMENT '标题',
    `parent_id`   bigint(20)   NOT NULL DEFAULT 0          COMMENT '上级菜单ID',
    `type`        tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '类型（1：目录；2：菜单；3：按钮）',
    `path`        varchar(255) DEFAULT NULL                COMMENT '路由地址',
    `name`        varchar(50)  DEFAULT NULL                COMMENT '组件名称',
    `component`   varchar(255) DEFAULT NULL                COMMENT '组件路径',
    `redirect`    varchar(255) DEFAULT NULL                COMMENT '重定向地址',
    `icon`        varchar(50)  DEFAULT NULL                COMMENT '图标',
    `is_external` bit(1)       DEFAULT b'0'                COMMENT '是否外链',
    `is_cache`    bit(1)       DEFAULT b'0'                COMMENT '是否缓存',
    `is_hidden`   bit(1)       DEFAULT b'0'                COMMENT '是否隐藏',
    `permission`  varchar(100) DEFAULT NULL                COMMENT '权限标识',
    `sort`        int          NOT NULL DEFAULT 999        COMMENT '排序',
    `status`      tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `create_user` bigint(20)   NOT NULL                    COMMENT '创建人',
    `create_time` datetime     NOT NULL                    COMMENT '创建时间',
    `update_user` bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time` datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`     bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_title_parent_id`(`title`, `parent_id`, `deleted`),
    INDEX `idx_parent_id`(`parent_id`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单表';

CREATE TABLE IF NOT EXISTS `sys_dept` (
    `id`          bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `name`        varchar(30)  NOT NULL                    COMMENT '名称',
    `parent_id`   bigint(20)   NOT NULL DEFAULT 0          COMMENT '上级部门ID',
    `ancestors`   varchar(512) NOT NULL DEFAULT ''         COMMENT '祖级列表',
    `description` varchar(200) DEFAULT NULL                COMMENT '描述',
    `sort`        int          NOT NULL DEFAULT 999        COMMENT '排序',
    `status`      tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `is_system`   bit(1)       NOT NULL DEFAULT b'0'       COMMENT '是否为系统内置数据',
    `create_user` bigint(20)   NOT NULL                    COMMENT '创建人',
    `create_time` datetime     NOT NULL                    COMMENT '创建时间',
    `update_user` bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time` datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`     bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_name_parent_id`(`name`, `parent_id`, `deleted`),
    INDEX `idx_parent_id`(`parent_id`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

CREATE TABLE IF NOT EXISTS `sys_role` (
    `id`                  bigint(20)   AUTO_INCREMENT        COMMENT 'ID',
    `name`                varchar(30)  NOT NULL              COMMENT '名称',
    `code`                varchar(30)  NOT NULL              COMMENT '编码',
    `data_scope`          tinyint(1)   NOT NULL DEFAULT 4    COMMENT '数据权限（1：全部数据权限；2：本部门及以下数据权限；3：本部门数据权限；4：仅本人数据权限；5：自定义数据权限）',
    `description`         varchar(200) DEFAULT NULL          COMMENT '描述',
    `sort`                int          NOT NULL DEFAULT 999  COMMENT '排序',
    `is_system`           bit(1)       NOT NULL DEFAULT b'0' COMMENT '是否为系统内置数据',
    `menu_check_strictly` bit(1)       DEFAULT b'1'          COMMENT '菜单选择是否父子节点关联',
    `dept_check_strictly` bit(1)       DEFAULT b'1'          COMMENT '部门选择是否父子节点关联',
    `create_user`         bigint(20)   NOT NULL              COMMENT '创建人',
    `create_time`         datetime     NOT NULL              COMMENT '创建时间',
    `update_user`         bigint(20)   DEFAULT NULL          COMMENT '修改人',
    `update_time`         datetime     DEFAULT NULL          COMMENT '修改时间',
    `deleted`             bigint(20)   NOT NULL DEFAULT 0    COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_name`(`name`, `deleted`),
    UNIQUE INDEX `uk_code`(`code`, `deleted`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

CREATE TABLE IF NOT EXISTS `sys_user` (
    `id`             bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `username`       varchar(64)  NOT NULL                    COMMENT '用户名',
    `nickname`       varchar(30)  NOT NULL                    COMMENT '昵称',
    `password`       varchar(255) DEFAULT NULL                COMMENT '密码',
    `gender`         tinyint(1)   UNSIGNED NOT NULL DEFAULT 0 COMMENT '性别（0：未知；1：男；2：女）',
    `email`          varchar(255) DEFAULT NULL                COMMENT '邮箱',
    `phone`          varchar(255) DEFAULT NULL                COMMENT '手机号码',
    `avatar`         longtext     DEFAULT NULL                COMMENT '头像',
    `description`    varchar(200) DEFAULT NULL                COMMENT '描述',
    `status`         tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `is_system`      bit(1)       NOT NULL DEFAULT b'0'       COMMENT '是否为系统内置数据',
    `pwd_reset_time` datetime     DEFAULT NULL                COMMENT '最后一次修改密码时间',
    `dept_id`        bigint(20)   NOT NULL                    COMMENT '部门ID',
    `create_user`    bigint(20)   DEFAULT NULL                COMMENT '创建人',
    `create_time`    datetime     NOT NULL                    COMMENT '创建时间',
    `update_user`    bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time`    datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`        bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_username`(`username`, `deleted`),
    UNIQUE INDEX `uk_email`(`email`, `deleted`),
    UNIQUE INDEX `uk_phone`(`phone`, `deleted`),
    INDEX `idx_dept_id`(`dept_id`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

CREATE TABLE IF NOT EXISTS `sys_user_password_history` (
    `id`          bigint(20)   AUTO_INCREMENT COMMENT 'ID',
    `user_id`     bigint(20)   NOT NULL       COMMENT '用户ID',
    `password`    varchar(255) NOT NULL       COMMENT '密码',
    `create_time` datetime     NOT NULL       COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_user_id`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户历史密码表';

CREATE TABLE IF NOT EXISTS `sys_user_social` (
    `id`              bigint(20)   AUTO_INCREMENT     COMMENT 'ID',
    `source`          varchar(255) NOT NULL           COMMENT '来源',
    `open_id`         varchar(255) NOT NULL           COMMENT '开放ID',
    `user_id`         bigint(20)   NOT NULL           COMMENT '用户ID',
    `meta_json`       text         DEFAULT NULL       COMMENT '附加信息',
    `last_login_time` datetime     DEFAULT NULL       COMMENT '最后登录时间',
    `create_time`     datetime     NOT NULL           COMMENT '创建时间',
    `update_time`     datetime     DEFAULT NULL       COMMENT '修改时间',
    `deleted`         bigint(20)   NOT NULL DEFAULT 0 COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_source_open_id`(`source`, `open_id`, `deleted`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户社会化关联表';

CREATE TABLE IF NOT EXISTS `sys_user_preference` (
    `id`          bigint(20)   AUTO_INCREMENT COMMENT 'ID',
    `user_id`     bigint(20)   NOT NULL       COMMENT '用户ID',
    `ui_json`     text         NOT NULL       COMMENT '界面配置JSON',
    `create_time` datetime     NOT NULL       COMMENT '创建时间',
    `update_time` datetime     DEFAULT NULL   COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_user_id`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户界面偏好表';

CREATE TABLE IF NOT EXISTS `sys_user_role` (
    `id`      bigint(20) AUTO_INCREMENT COMMENT 'ID',
    `user_id` bigint(20) NOT NULL       COMMENT '用户ID',
    `role_id` bigint(20) NOT NULL       COMMENT '角色ID',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_user_id_role_id`(`user_id`, `role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户和角色关联表';

CREATE TABLE IF NOT EXISTS `sys_role_menu` (
    `role_id` bigint(20) NOT NULL COMMENT '角色ID',
    `menu_id` bigint(20) NOT NULL COMMENT '菜单ID',
    PRIMARY KEY (`role_id`, `menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色和菜单关联表';

CREATE TABLE IF NOT EXISTS `sys_role_dept` (
    `role_id` bigint(20) NOT NULL COMMENT '角色ID',
    `dept_id` bigint(20) NOT NULL COMMENT '部门ID',
    PRIMARY KEY (`role_id`, `dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色和部门关联表';

CREATE TABLE IF NOT EXISTS `sys_option` (
    `id`            bigint(20)   AUTO_INCREMENT COMMENT 'ID',
    `category`      varchar(50)  NOT NULL       COMMENT '类别',
    `name`          varchar(50)  NOT NULL       COMMENT '名称',
    `code`          varchar(100) NOT NULL       COMMENT '键',
    `value`         longtext     DEFAULT NULL   COMMENT '值',
    `default_value` longtext     DEFAULT NULL   COMMENT '默认值',
    `description`   varchar(200) DEFAULT NULL   COMMENT '描述',
    `update_user`   bigint(20)   DEFAULT NULL   COMMENT '修改人',
    `update_time`   datetime     DEFAULT NULL   COMMENT '修改时间',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_category_code`(`category`, `code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='参数表';

CREATE TABLE IF NOT EXISTS `sys_dict` (
    `id`          bigint(20)   AUTO_INCREMENT        COMMENT 'ID',
    `name`        varchar(30)  NOT NULL              COMMENT '名称',
    `code`        varchar(30)  NOT NULL              COMMENT '编码',
    `description` varchar(200) DEFAULT NULL          COMMENT '描述',
    `is_system`   bit(1)       NOT NULL DEFAULT b'0' COMMENT '是否为系统内置数据',
    `create_user` bigint(20)   NOT NULL              COMMENT '创建人',
    `create_time` datetime     NOT NULL              COMMENT '创建时间',
    `update_user` bigint(20)   DEFAULT NULL          COMMENT '修改人',
    `update_time` datetime     DEFAULT NULL          COMMENT '修改时间',
    `deleted`     bigint(20)   NOT NULL DEFAULT 0    COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_name`(`name`, `deleted`),
    UNIQUE INDEX `uk_code`(`code`, `deleted`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典表';

CREATE TABLE IF NOT EXISTS `sys_dict_item` (
    `id`          bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `label`       varchar(30)  NOT NULL                    COMMENT '标签',
    `value`       varchar(30)  NOT NULL                    COMMENT '值',
    `color`       varchar(30)  DEFAULT NULL                COMMENT '标签颜色',
    `sort`        int          NOT NULL DEFAULT 999        COMMENT '排序',
    `description` varchar(200) DEFAULT NULL                COMMENT '描述',
    `status`      tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `dict_id`     bigint(20)   NOT NULL                    COMMENT '字典ID',
    `create_user` bigint(20)   NOT NULL                    COMMENT '创建人',
    `create_time` datetime     NOT NULL                    COMMENT '创建时间',
    `update_user` bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time` datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`     bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_value_dict_id`(`value`, `dict_id`, `deleted`),
    INDEX `idx_dict_id`(`dict_id`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典项表';

CREATE TABLE IF NOT EXISTS `sys_log` (
    `id`               bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `trace_id`         varchar(255) DEFAULT NULL                COMMENT '链路ID',
    `description`      varchar(255) NOT NULL                    COMMENT '日志描述',
    `module`           varchar(100) NOT NULL                    COMMENT '所属模块',
    `request_url`      varchar(512) NOT NULL                    COMMENT '请求URL',
    `request_method`   varchar(10)  NOT NULL                    COMMENT '请求方式',
    `request_headers`  text         DEFAULT NULL                COMMENT '请求头',
    `request_body`     text         DEFAULT NULL                COMMENT '请求体',
    `status_code`      int          NOT NULL                    COMMENT '状态码',
    `response_headers` text         DEFAULT NULL                COMMENT '响应头',
    `response_body`    mediumtext   DEFAULT NULL                COMMENT '响应体',
    `time_taken`       bigint(20)   NOT NULL                    COMMENT '耗时（ms）',
    `ip`               varchar(100) DEFAULT NULL                COMMENT 'IP',
    `address`          varchar(255) DEFAULT NULL                COMMENT 'IP归属地',
    `browser`          varchar(100) DEFAULT NULL                COMMENT '浏览器',
    `os`               varchar(100) DEFAULT NULL                COMMENT '操作系统',
    `status`           tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：成功；2：失败）',
    `error_msg`        text         DEFAULT NULL                COMMENT '错误信息',
    `create_user`      bigint(20)   DEFAULT NULL                COMMENT '创建人',
    `create_time`      datetime     NOT NULL                    COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_module`(`module`),
    INDEX `idx_ip`(`ip`),
    INDEX `idx_address`(`address`),
    INDEX `idx_create_time`(`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统日志表';

CREATE TABLE IF NOT EXISTS `sys_message` (
    `id`          bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `title`       varchar(50)  NOT NULL                    COMMENT '标题',
    `content`     text         DEFAULT NULL                COMMENT '内容',
    `type`        tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '类型（1：系统消息；2：安全消息）',
    `path`        varchar(255) DEFAULT NULL                COMMENT '跳转路径',
    `scope`       tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '通知范围（1：所有人；2：指定用户）',
    `users`       json         DEFAULT NULL                COMMENT '通知用户',
    `create_time` datetime     NOT NULL                    COMMENT '创建时间',
    `update_time` datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`     bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

CREATE TABLE IF NOT EXISTS `sys_message_log` (
    `message_id` bigint(20) NOT NULL     COMMENT '消息ID',
    `user_id`    bigint(20) NOT NULL     COMMENT '用户ID',
    `read_time`  datetime   DEFAULT NULL COMMENT '读取时间',
    PRIMARY KEY (`message_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息日志表';

CREATE TABLE IF NOT EXISTS `sys_notice` (
    `id`             bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `title`          varchar(150) NOT NULL                    COMMENT '标题',
    `content`        mediumtext   NOT NULL                    COMMENT '内容',
    `type`           varchar(30)  NOT NULL                    COMMENT '分类',
    `notice_scope`   tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '通知范围（1：所有人；2：指定用户）',
    `notice_users`   json         DEFAULT NULL                COMMENT '通知用户',
    `notice_methods` json         DEFAULT NULL                COMMENT '通知方式（1：系统消息；2：登录弹窗）',
    `is_timing`      bit(1)       NOT NULL DEFAULT b'0'       COMMENT '是否定时',
    `publish_time`   datetime     DEFAULT NULL                COMMENT '发布时间',
    `is_top`         bit(1)       NOT NULL DEFAULT b'0'       COMMENT '是否置顶',
    `status`         tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：草稿；2：待发布；3：已发布）',
    `create_user`    bigint(20)   NOT NULL                    COMMENT '创建人',
    `create_time`    datetime     NOT NULL                    COMMENT '创建时间',
    `update_user`    bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time`    datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`        bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告表';

CREATE TABLE IF NOT EXISTS `sys_notice_log` (
    `notice_id` bigint(20) NOT NULL     COMMENT '公告ID',
    `user_id`   bigint(20) NOT NULL     COMMENT '用户ID',
    `read_time` datetime   DEFAULT NULL COMMENT '读取时间',
    PRIMARY KEY (`notice_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='公告日志表';

CREATE TABLE IF NOT EXISTS `sys_storage` (
    `id`                  bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `name`                varchar(100) NOT NULL                    COMMENT '名称',
    `code`                varchar(30)  NOT NULL                    COMMENT '编码',
    `type`                tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '类型（1：本地存储；2：对象存储）',
    `access_key`          varchar(255) DEFAULT NULL                COMMENT 'Access Key',
    `secret_key`          varchar(255) DEFAULT NULL                COMMENT 'Secret Key',
    `endpoint`            varchar(255) DEFAULT NULL                COMMENT 'Endpoint',
    `bucket_name`         varchar(255) NOT NULL                    COMMENT 'Bucket',
    `domain`              varchar(255) DEFAULT NULL                COMMENT '域名',
    `recycle_bin_enabled` bit(1)       NOT NULL DEFAULT b'1'       COMMENT '启用回收站',
    `recycle_bin_path`    varchar(255) DEFAULT NULL                COMMENT '回收站路径',
    `description`         varchar(200) DEFAULT NULL                COMMENT '描述',
    `is_default`          bit(1)       NOT NULL DEFAULT b'0'       COMMENT '是否为默认存储',
    `sort`                int          NOT NULL DEFAULT 999        COMMENT '排序',
    `status`              tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `create_user`         bigint(20)   NOT NULL                    COMMENT '创建人',
    `create_time`         datetime     NOT NULL                    COMMENT '创建时间',
    `update_user`         bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time`         datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`             bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_code`(`code`, `deleted`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='存储表';

CREATE TABLE IF NOT EXISTS `sys_file` (
    `id`                 bigint(20)    AUTO_INCREMENT              COMMENT 'ID',
    `name`               varchar(255)  NOT NULL                    COMMENT '名称',
    `original_name`      varchar(255)  NOT NULL                    COMMENT '原始名称',
    `size`               bigint(20)    DEFAULT NULL                COMMENT '大小（字节）',
    `parent_path`        varchar(512)  NOT NULL DEFAULT '/'        COMMENT '上级目录',
    `path`               varchar(512)  NOT NULL                    COMMENT '路径',
    `extension`          varchar(32)   DEFAULT NULL                COMMENT '扩展名',
    `content_type`       varchar(255)  DEFAULT NULL                COMMENT '内容类型',
    `type`               tinyint(1)    UNSIGNED NOT NULL DEFAULT 1 COMMENT '类型（0: 目录；1：其他；2：图片；3：文档；4：视频；5：音频）',
    `file_digest`        varchar(256)  DEFAULT NULL                COMMENT '文件指纹（统一 SM3）',
    `metadata`           text          DEFAULT NULL                COMMENT '元数据',
    `thumbnail_name`     varchar(255)  DEFAULT NULL                COMMENT '缩略图名称',
    `thumbnail_size`     bigint(20)    DEFAULT NULL                COMMENT '缩略图大小（字节)',
    `thumbnail_metadata` text          DEFAULT NULL                COMMENT '缩略图元数据',
    `storage_id`         bigint(20)    NOT NULL                    COMMENT '存储ID',
    `create_user`        bigint(20)    NOT NULL                    COMMENT '创建人',
    `create_time`        datetime      NOT NULL                    COMMENT '创建时间',
    `update_user`        bigint(20)    DEFAULT NULL                COMMENT '修改人',
    `update_time`        datetime      DEFAULT NULL                COMMENT '修改时间',
    `deleted`            bigint(20)    NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    INDEX `idx_type`(`type`),
    INDEX `idx_file_digest`(`file_digest`),
    INDEX `idx_storage_id`(`storage_id`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='文件表';

CREATE TABLE IF NOT EXISTS `sys_client` (
    `id`             bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `client_id`      varchar(50)  NOT NULL                    COMMENT '客户端ID',
    `client_type`    varchar(50)  NOT NULL                    COMMENT '客户端类型',
    `auth_type`      json         NOT NULL                    COMMENT '认证类型',
    `active_timeout` bigint(20)   DEFAULT -1                  COMMENT 'Token最低活跃频率（单位：秒，-1：不限制，永不冻结）',
    `timeout`        bigint(20)   DEFAULT 2592000             COMMENT 'Token有效期（单位：秒，-1：永不过期）',
    `status`         tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `create_user`    bigint(20)   NOT NULL                    COMMENT '创建人',
    `create_time`    datetime     NOT NULL                    COMMENT '创建时间',
    `update_user`    bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time`    datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`        bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_client_id`(`client_id`, `deleted`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客户端表';

-- ========== main_data.sql ==========

-- validCheckSum: ANY
-- 初始化默认菜单
INSERT INTO `sys_menu`
(`id`, `title`, `parent_id`, `type`, `path`, `name`, `component`, `redirect`, `icon`, `is_external`, `is_cache`, `is_hidden`, `permission`, `sort`, `status`, `create_user`, `create_time`)
VALUES
(1000, '系统管理', 0, 1, '/system', 'System', 'Layout', '/system/user', 'settings', b'0', b'0', b'0', NULL, 1, 1, 1, NOW()),
(1010, '用户管理', 1000, 2, '/system/user', 'SystemUser', 'system/user/index', NULL, 'user', b'0', b'0', b'0', NULL, 1, 1, 1, NOW()),
(1011, '列表', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:list', 1, 1, 1, NOW()),
(1012, '详情', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:get', 2, 1, 1, NOW()),
(1013, '新增', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:create', 3, 1, 1, NOW()),
(1014, '修改', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:update', 4, 1, 1, NOW()),
(1015, '删除', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:delete', 5, 1, 1, NOW()),
(1016, '导出', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:export', 6, 1, 1, NOW()),
(1017, '导入', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:import', 7, 1, 1, NOW()),
(1018, '重置密码', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:resetPwd', 8, 1, 1, NOW()),
(1019, '分配角色', 1010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:user:updateRole', 9, 1, 1, NOW()),

(1030, '角色管理', 1000, 2, '/system/role', 'SystemRole', 'system/role/index', NULL, 'user-management', b'0', b'0', b'0', NULL, 2, 1, 1, NOW()),
(1031, '列表', 1030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:role:list', 1, 1, 1, NOW()),
(1032, '详情', 1030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:role:get', 2, 1, 1, NOW()),
(1033, '新增', 1030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:role:create', 3, 1, 1, NOW()),
(1034, '修改', 1030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:role:update', 4, 1, 1, NOW()),
(1035, '删除', 1030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:role:delete', 5, 1, 1, NOW()),
(1036, '修改权限', 1030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:role:updatePermission', 6, 1, 1, NOW()),
(1037, '分配', 1030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:role:assign', 7, 1, 1, NOW()),
(1038, '取消分配', 1030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:role:unassign', 8, 1, 1, NOW()),

(1050, '菜单管理', 1000, 2, '/system/menu', 'SystemMenu', 'system/menu/index', NULL, 'menu', b'0', b'0', b'0', NULL, 3, 1, 1, NOW()),
(1051, '列表', 1050, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:menu:list', 1, 1, 1, NOW()),
(1052, '详情', 1050, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:menu:get', 2, 1, 1, NOW()),
(1053, '新增', 1050, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:menu:create', 3, 1, 1, NOW()),
(1054, '修改', 1050, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:menu:update', 4, 1, 1, NOW()),
(1055, '删除', 1050, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:menu:delete', 5, 1, 1, NOW()),
(1056, '清除缓存', 1050, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:menu:clearCache', 6, 1, 1, NOW()),

(1070, '部门管理', 1000, 2, '/system/dept', 'SystemDept', 'system/dept/index', NULL, 'mind-mapping', b'0', b'0', b'0', NULL, 4, 1, 1, NOW()),
(1071, '列表', 1070, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dept:list', 1, 1, 1, NOW()),
(1072, '详情', 1070, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dept:get', 2, 1, 1, NOW()),
(1073, '新增', 1070, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dept:create', 3, 1, 1, NOW()),
(1074, '修改', 1070, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dept:update', 4, 1, 1, NOW()),
(1075, '删除', 1070, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dept:delete', 5, 1, 1, NOW()),
(1076, '导出', 1070, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dept:export', 6, 1, 1, NOW()),

(1090, '通知公告', 1000, 2, '/system/notice', 'SystemNotice', 'system/notice/index', NULL, 'notification', b'0', b'0', b'0', NULL, 5, 1, 1, NOW()),
(1091, '列表', 1090, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:notice:list', 1, 1, 1, NOW()),
(1092, '详情', 1090, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:notice:get', 2, 1, 1, NOW()),
(1093, '查看公告', 1090, 2, '/system/notice/view', 'SystemNoticeView', 'system/notice/view/index', NULL, NULL, b'0', b'0', b'1', 'system:notice:view', 3, 1, 1, NOW()),
(1094, '发布公告', 1090, 2, '/system/notice/add', 'SystemNoticeAdd', 'system/notice/add/index', NULL, NULL, b'0', b'0', b'1', 'system:notice:create', 4, 1, 1, NOW()),
(1095, '修改', 1090, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:notice:update', 5, 1, 1, NOW()),
(1096, '删除', 1090, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:notice:delete', 6, 1, 1, NOW()),

(1110, '文件管理', 1000, 2, '/system/file', 'SystemFile', 'system/file/index', NULL, 'file', b'0', b'0', b'0', NULL, 6, 1, 1, NOW()),
(1111, '列表', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:list', 1, 1, 1, NOW()),
(1112, '详情', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:get', 2, 1, 1, NOW()),
(1113, '上传', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:upload', 3, 1, 1, NOW()),
(1114, '修改', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:update', 4, 1, 1, NOW()),
(1115, '删除', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:delete', 5, 1, 1, NOW()),
(1116, '下载', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:download', 6, 1, 1, NOW()),
(1117, '创建文件夹', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:createDir', 7, 1, 1, NOW()),
(1118, '计算文件夹大小', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:calcDirSize', 8, 1, 1, NOW()),
(1119, '回收站文件列表', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:fileRecycle:list', 9, 1, 1, NOW()),
(1120, '还原回收站文件', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:fileRecycle:restore', 10, 1, 1, NOW()),
(1121, '删除回收站文件', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:fileRecycle:delete', 11, 1, 1, NOW()),
(1122, '清空回收站', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:fileRecycle:clean', 12, 1, 1, NOW()),
(1123, '校验文件', 1110, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:file:check', 13, 1, 1, NOW()),

(1130, '字典管理', 1000, 2, '/system/dict', 'SystemDict', 'system/dict/index', NULL, 'bookmark', b'0', b'0', b'0', NULL, 7, 1, 1, NOW()),
(1131, '列表', 1130, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dict:list', 1, 1, 1, NOW()),
(1132, '详情', 1130, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dict:get', 2, 1, 1, NOW()),
(1133, '新增', 1130, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dict:create', 3, 1, 1, NOW()),
(1134, '修改', 1130, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dict:update', 4, 1, 1, NOW()),
(1135, '删除', 1130, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dict:delete', 5, 1, 1, NOW()),
(1136, '清除缓存', 1130, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dict:clearCache', 6, 1, 1, NOW()),
(1140, '字典项管理', 1000, 2, '/system/dict/item', 'SystemDictItem', 'system/dict/item/index', NULL, 'bookmark', b'0', b'0', b'1', NULL, 8, 1, 1, NOW()),
(1141, '列表', 1140, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dictItem:list', 1, 1, 1, NOW()),
(1142, '详情', 1140, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dictItem:get', 2, 1, 1, NOW()),
(1143, '新增', 1140, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dictItem:create', 3, 1, 1, NOW()),
(1144, '修改', 1140, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dictItem:update', 4, 1, 1, NOW()),
(1145, '删除', 1140, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:dictItem:delete', 5, 1, 1, NOW()),

(1150, '系统配置', 1000, 2, '/system/config', 'SystemConfig', 'system/config/index', NULL, 'config', b'0', b'0', b'0', NULL, 999, 1, 1, NOW()),
(1160, '网站配置', 1150, 2, '/system/config?tab=site', 'SystemSiteConfig', 'system/config/site/index', NULL, 'apps', b'0', b'0', b'1', NULL, 1, 1, 1, NOW()),
(1161, '查询', 1160, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:siteConfig:get', 1, 1, 1, NOW()),
(1162, '修改', 1160, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:siteConfig:update', 2, 1, 1, NOW()),
(1170, '安全配置', 1150, 2, '/system/config?tab=security', 'SystemSecurityConfig', 'system/config/security/index', NULL, 'safe', b'0', b'0', b'1', NULL, 2, 1, 1, NOW()),
(1171, '查询', 1170, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:securityConfig:get', 1, 1, 1, NOW()),
(1172, '修改', 1170, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:securityConfig:update', 2, 1, 1, NOW()),
(1180, '登录配置', 1150, 2, '/system/config?tab=login', 'SystemLoginConfig', 'system/config/login/index', NULL, 'lock', b'0', b'0', b'1', NULL, 3, 1, 1, NOW()),
(1181, '查询', 1180, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:loginConfig:get', 1, 1, 1, NOW()),
(1182, '修改', 1180, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:loginConfig:update', 2, 1, 1, NOW()),
(1190, '邮件配置', 1150, 2, '/system/config?tab=mail', 'SystemMailConfig', 'system/config/mail/index', NULL, 'email', b'0', b'0', b'1', NULL, 4, 1, 1, NOW()),
(1191, '查询', 1190, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:mailConfig:get', 1, 1, 1, NOW()),
(1192, '修改', 1190, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:mailConfig:update', 2, 1, 1, NOW()),
(1230, '存储配置', 1150, 2, '/system/config?tab=storage', 'SystemStorage', 'system/config/storage/index', NULL, 'storage', b'0', b'0', b'1', NULL, 6, 1, 1, NOW()),
(1231, '列表', 1230, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:storage:list', 1, 1, 1, NOW()),
(1232, '详情', 1230, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:storage:get', 2, 1, 1, NOW()),
(1233, '新增', 1230, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:storage:create', 3, 1, 1, NOW()),
(1234, '修改', 1230, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:storage:update', 4, 1, 1, NOW()),
(1235, '删除', 1230, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:storage:delete', 5, 1, 1, NOW()),
(1236, '修改状态', 1230, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:storage:updateStatus', 6, 1, 1, NOW()),
(1237, '设为默认存储', 1230, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:storage:setDefault', 7, 1, 1, NOW()),
(1250, '客户端配置', 1150, 2, '/system/config?tab=client', 'SystemClient', 'system/config/client/index', NULL, 'mobile', b'0', b'0', b'1', NULL, 7, 1, 1, NOW()),
(1251, '列表', 1250, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:client:list', 1, 1, 1, NOW()),
(1252, '详情', 1250, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:client:get', 2, 1, 1, NOW()),
(1253, '新增', 1250, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:client:create', 3, 1, 1, NOW()),
(1254, '修改', 1250, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:client:update', 4, 1, 1, NOW()),
(1255, '删除', 1250, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'system:client:delete', 5, 1, 1, NOW()),

(2000, '系统监控', 0, 1, '/monitor', 'Monitor', 'Layout', '/monitor/online', 'computer', b'0', b'0', b'0', NULL, 2, 1, 1, NOW()),
(2010, '在线用户', 2000, 2, '/monitor/online', 'MonitorOnline', 'monitor/online/index', NULL, 'user', b'0', b'0', b'0', NULL, 1, 1, 1, NOW()),
(2011, '列表', 2010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'monitor:online:list', 1, 1, 1, NOW()),
(2012, '强退', 2010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'monitor:online:kickout', 2, 1, 1, NOW()),

(2030, '系统日志', 2000, 2, '/monitor/log', 'MonitorLog', 'monitor/log/index', NULL, 'history', b'0', b'0', b'0', NULL, 2, 1, 1, NOW()),
(2031, '列表', 2030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'monitor:log:list', 1, 1, 1, NOW()),
(2032, '详情', 2030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'monitor:log:get', 2, 1, 1, NOW()),
(2033, '导出', 2030, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'monitor:log:export', 3, 1, 1, NOW());

-- 初始化默认部门（一级总公司 / 二级总经办）
INSERT INTO `sys_dept`
(`id`, `name`, `parent_id`, `ancestors`, `description`, `sort`, `status`, `is_system`, `create_user`, `create_time`)
VALUES
(1, '总公司', 0, '0', '一级部门', 1, 1, b'1', 1, NOW()),
(2, '总经办', 1, '0,1', '二级部门', 1, 1, b'0', 1, NOW());

-- 初始化默认角色
INSERT INTO `sys_role`
(`id`, `name`, `code`, `data_scope`, `description`, `sort`, `is_system`, `create_user`, `create_time`)
VALUES
(1, '超级管理员', 'super_admin', 1, '系统初始角色', 0, b'1', 1, NOW()),
(2, '系统管理员', 'sys_admin', 1, NULL, 1, b'0', 1, NOW()),
(3, '普通角色', 'general', 4, NULL, 2, b'0', 1, NOW());

-- 初始化默认用户（口令哈希 SM3；明文口令禁止写入仓库；pwd_reset_time 置旧以配合密码有效期强制首登改密）
INSERT INTO `sys_user`
(`id`, `username`, `nickname`, `password`, `gender`, `email`, `phone`, `avatar`, `description`, `status`, `is_system`, `pwd_reset_time`, `dept_id`, `create_user`, `create_time`)
VALUES
(1, 'admin', '超级管理员', '{sm3}v1$ef4114fbfe4881f4710b626429c97c04$bd43c9a531b4cc2705aaff6d1a2f9563906c254cc3ffe05fbb21c2456bd86d99', 1, NULL, NULL, NULL, '系统初始用户', 1, b'1', '2000-01-01 00:00:00', 1, 1, NOW()),
(547889293968801822, 'test', '测试用户', '{sm3}v1$cfa6968c5df393377b04ff6e33f6f90c$025649846502c230dbfcff724d5724a2aa0af1c2a97defc84da59c70b9df24c8', 2, NULL, NULL, NULL, '系统测试账号', 1, b'0', '2000-01-01 00:00:00', 2, 1, NOW());

-- 初始化默认参数
INSERT INTO `sys_option`
(`id`, `category`, `name`, `code`, `value`, `default_value`, `description`)
VALUES
(1, 'SITE', '系统名称', 'SITE_TITLE', NULL, 'LS-Aegis 雷铄御警安全应用构建平台', '显示在浏览器标题栏和登录页顶栏的产品/项目名称'),
(2, 'SITE', '系统描述', 'SITE_DESCRIPTION', NULL, 'LS Aegis 前后端分离中后台平台', '用于 SEO 的网站元描述'),
(3, 'SITE', '版权声明', 'SITE_COPYRIGHT', NULL, '© 2026 雷铄科技 · LS-Aegis 雷铄御警安全应用构建平台', '显示在页面底部的版权声明文本'),
(4, 'SITE', 'ICP备案号', 'SITE_BEIAN', NULL, '冀ICP备 00000000 号', '工信部 ICP 备案编号（如：冀ICP备00000000号）'),
(5, 'SITE', '系统图标', 'SITE_FAVICON', NULL, '/favicon.ico', '浏览器标签页显示的网站图标（建议 .ico 格式）'),
(6, 'SITE', '系统LOGO', 'SITE_LOGO', NULL, '/logo.svg', '显示在登录页面和系统导航栏的网站图标（建议 .svg 格式）'),
(7, 'SITE', '公司名称', 'SITE_COMPANY', NULL, '雷铄科技', '显示在登录页顶栏的公司名称'),
(8, 'SITE', '公安备案号', 'SITE_BEIAN_GONGAN', NULL, '冀公网安备 00000000000000 号', '显示在登录页底部的公安备案编号'),
(9, 'SITE', '公安备案图标', 'SITE_BEIAN_GONGAN_ICON', NULL, '/beian-gongan.png', '公安备案号左侧图标（建议小尺寸 PNG）'),
(10, 'PASSWORD', '密码错误锁定阈值', 'PASSWORD_ERROR_LOCK_COUNT', NULL, '5', '连续登录失败次数达到该值将锁定账号（0-10次，0表示禁用锁定）'),
(11, 'PASSWORD', '账号锁定时长（分钟）', 'PASSWORD_ERROR_LOCK_MINUTES', NULL, '5', '账号锁定后自动解锁的时间（1-1440分钟，即24小时）'),
(12, 'PASSWORD', '密码有效期（天）', 'PASSWORD_EXPIRATION_DAYS', NULL, '90', '密码强制修改周期（0-999天，0表示永不过期；默认90天，种子账号首登须改密）'),
(13, 'PASSWORD', '密码到期提醒（天）', 'PASSWORD_EXPIRATION_WARNING_DAYS', NULL, '0', '密码过期前的提前提醒天数（0表示不提醒）'),
(14, 'PASSWORD', '历史密码重复校验次数', 'PASSWORD_REPETITION_TIMES', NULL, '3', '禁止使用最近 N 次的历史密码（3-32次）'),
(15, 'PASSWORD', '密码最小长度', 'PASSWORD_MIN_LENGTH', NULL, '8', '密码最小字符长度要求（8-32个字符）'),
(16, 'PASSWORD', '是否允许密码包含用户名', 'PASSWORD_ALLOW_CONTAIN_USERNAME', NULL, '1', '是否允许密码包含正序或倒序的用户名字符'),
(17, 'PASSWORD', '密码是否必须包含特殊字符', 'PASSWORD_REQUIRE_SYMBOLS', NULL, '0', '是否要求密码必须包含特殊字符（如：!@#$%）'),
(18, 'SITE', '系统名称简称', 'SITE_TITLE_SHORT', NULL, '雷铄御警', '显示在左侧栏 Logo 旁的系统简称（必填，最多 8 个字）'),
(19, 'SITE', '公司简称', 'SITE_COMPANY_SHORT', NULL, '雷铄', '公司名称简称（必填，最多 8 个字）'),
(20, 'MAIL', '邮件协议', 'MAIL_PROTOCOL', NULL, 'smtp', '邮件发送协议类型'),
(21, 'MAIL', '服务器地址', 'MAIL_HOST', NULL, NULL, '邮件服务器地址'),
(22, 'MAIL', '服务器端口', 'MAIL_PORT', NULL, '465', '邮件服务器连接端口'),
(23, 'MAIL', '邮箱账号', 'MAIL_USERNAME', NULL, 'support@ls-aegis.local', '发件人邮箱地址'),
(24, 'MAIL', '邮箱密码', 'MAIL_PASSWORD', NULL, NULL, '服务授权密码/客户端专用密码'),
(25, 'MAIL', '启用SSL加密', 'MAIL_SSL_ENABLED', NULL, '1', '是否启用SSL/TLS加密连接'),
(26, 'MAIL', 'SSL端口号', 'MAIL_SSL_PORT', NULL, '465', 'SSL加密连接的备用端口（通常与主端口一致）'),
(27, 'LOGIN', '是否启用验证码', 'LOGIN_CAPTCHA_ENABLED', NULL, '1', NULL);

-- 初始化默认字典
INSERT INTO `sys_dict`
(`id`, `name`, `code`, `description`, `is_system`, `create_user`, `create_time`)
VALUES
(1, '公告分类', 'notice_type', NULL, b'1', 1, NOW()),
(2, '客户端类型', 'client_type', NULL, b'1', 1, NOW());

INSERT INTO `sys_dict_item`
(`id`, `label`, `value`, `color`, `sort`, `description`, `status`, `dict_id`, `create_user`, `create_time`)
VALUES
(1, '通知公告', '1', 'primary', 1, '日常行政通知、会议通知、放假调休、制度宣贯', 1, 1, 1, NOW()),
(2, '政策文件', '2', 'primary', 2, '新规发布、政策解读、上级下发文件', 1, 1, 1, NOW()),
(6, '新闻动态', '3', 'default', 3, '公司动态、项目进展、行业资讯', 1, 1, 1, NOW()),
(7, '人事公告', '4', 'success', 4, '任免、招聘、入职离职、考勤、绩效考核公示', 1, 1, 1, NOW()),
(8, '财务公示', '5', 'warning', 5, '预算、采购招标、中标结果、费用公示', 1, 1, 1, NOW()),
(9, '安全通告', '6', 'error', 6, '网络安全预警、系统维护、漏洞提示、版本升级', 1, 1, 1, NOW()),
(10, '运维公告', '7', 'warning', 7, '服务器停机、系统更新、功能变更、接口下线', 1, 1, 1, NOW()),
(11, '公示通告', '8', 'default', 8, '结果公示、评选、申诉、公开征求意见', 1, 1, 1, NOW()),
(12, '紧急通告', '9', 'error', 9, '突发事件、应急通知、重要紧急事项', 1, 1, 1, NOW()),
(3, '桌面端', 'PC', 'primary', 1, NULL, 1, 2, 1, NOW()),
(4, '安卓', 'ANDROID', 'success', 2, NULL, 1, 2, 1, NOW()),
(5, '小程序', 'XCX', 'warning', 3, NULL, 1, 2, 1, NOW());

-- 初始化默认用户和角色关联数据
INSERT INTO `sys_user_role`
(`id`, `user_id`, `role_id`)
VALUES
(1, 1, 1),
(2, 547889293968801822, 3);

-- 初始化默认存储
INSERT INTO `sys_storage`
(`id`, `name`, `code`, `type`, `access_key`, `secret_key`, `endpoint`, `bucket_name`, `domain`, `recycle_bin_enabled`, `recycle_bin_path`, `description`, `is_default`, `sort`, `status`, `create_user`, `create_time`)
VALUES
(1, '开发环境', 'local_dev', 1, NULL, NULL, NULL, 'data/file/', 'http://localhost:8080/api/file/', b'1', '.RECYCLE.BIN/', '本地存储', b'1', 1, 1, 1, NOW()),
(2, '生产环境', 'local_prod', 1, NULL, NULL, NULL, 'data/file/', 'http://localhost:8080/api/file/', b'1', '.RECYCLE.BIN/', '本地存储', b'0', 2, 2, 1, NOW());

-- 初始化客户端数据
INSERT INTO `sys_client`
(`id`, `client_id`, `client_type`, `auth_type`, `active_timeout`, `timeout`, `status`, `create_user`, `create_time`)
VALUES
(1, 'ef51c9a3e9046c4f2ea45142c8a8344a', 'PC', '["ACCOUNT", "EMAIL"]', 1800, 86400, 1, 1, NOW());

-- 初始化仪表盘公告种子（20 条已发布）
INSERT INTO `sys_notice`
(`id`, `title`, `content`, `type`, `notice_scope`, `notice_users`, `notice_methods`, `is_timing`, `publish_time`, `is_top`, `status`, `create_user`, `create_time`, `deleted`)
VALUES
(910000000000000001, '系统维护窗口通知', '<p>本周六 22:00-24:00 进行系统例行维护，期间登录可能短暂中断，请提前保存工作内容。</p>', '7', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 1 DAY), b'1', 3, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), 0),
(910000000000000002, '密码策略已更新', '<p>新密码需满足长度与复杂度要求，下次登录时请按提示完成修改。</p>', '6', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 2 DAY), b'1', 3, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), 0),
(910000000000000003, '国密传输链路启用说明', '<p>平台默认启用 SM2/SM3/SM4 国密能力，浏览器需支持现代加密套件。</p>', '6', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 3 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), 0),
(910000000000000004, '工作总览公告滚动上线', '<p>工作总览与运营数据中枢已支持公告无缝滚动展示，欢迎体验并提出反馈。</p>', '3', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 4 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 4 DAY), 0),
(910000000000000005, '本周五下午例行巡检', '<p>运维将于周五 14:00-16:00 巡检核心服务，如遇异常请联系值班人员。</p>', '7', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 5 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), 0),
(910000000000000006, '关于国庆假期值班安排', '<p>假期值班表已发布，请各部门负责人及时查阅并转发至组内成员。</p>', '1', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 6 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 6 DAY), 0),
(910000000000000007, '文件存储容量扩容完成', '<p>对象存储与本地存储容量已扩容，大文件上传超时问题已优化。</p>', '7', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 7 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 7 DAY), 0),
(910000000000000008, '角色权限模型调整公告', '<p>部分菜单权限码已整理，如发现菜单缺失请联系管理员重新授权。</p>', '1', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 8 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 8 DAY), 0),
(910000000000000009, '登录双因素验证试行', '<p>高权限账号将逐步启用二次验证，请提前绑定可用邮箱。</p>', '6', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 9 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 9 DAY), 0),
(910000000000000010, '运营数据中枢视觉升级', '<p>大屏动效与面板样式已对齐运维大屏规范，刷新页面即可体验。</p>', '3', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 10 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 10 DAY), 0),
(910000000000000011, '接口限流策略说明', '<p>公开接口增加频率限制，异常调用将被短暂熔断，请勿短时间高频请求。</p>', '7', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 11 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 11 DAY), 0),
(910000000000000012, '新员工入职资料清单', '<p>请人事与部门管理员按清单完成账号开通、角色分配与培训确认。</p>', '4', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 12 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 12 DAY), 0),
(910000000000000013, '数据库备份演练通知', '<p>本月备份恢复演练定于周日凌晨执行，演练期间只读查询不受影响。</p>', '7', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 13 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 13 DAY), 0),
(910000000000000014, '浏览器兼容性建议', '<p>推荐使用 Chrome / Edge / 国产信创浏览器最新版本访问管理后台。</p>', '1', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 14 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 14 DAY), 0),
(910000000000000015, '消息中心未读提醒优化', '<p>未读公告与站内信角标刷新频率已优化，减少无效轮询。</p>', '3', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 15 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 15 DAY), 0),
(910000000000000016, '季度安全意识培训', '<p>请全体员工于本月底前完成在线安全培训并提交测验结果。</p>', '6', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 16 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 16 DAY), 0),
(910000000000000017, '定时任务监控告警上线', '<p>调度中心失败任务将同步推送到消息中心，请相关负责人关注。</p>', '7', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 17 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 17 DAY), 0),
(910000000000000018, '客户满意度调研邀请', '<p>本季度调研已开启，欢迎提交使用体验与改进建议。</p>', '8', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 18 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 18 DAY), 0),
(910000000000000019, '日志留存周期调整', '<p>操作日志默认留存周期调整为 180 天，超期数据将按策略归档。</p>', '2', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 19 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 19 DAY), 0),
(910000000000000020, '信创环境适配进展同步', '<p>已完成主流国产 OS 与浏览器兼容验证，问题反馈请提交工单。</p>', '3', 1, NULL, '[1]', b'0', DATE_SUB(NOW(), INTERVAL 20 DAY), b'0', 3, 1, DATE_SUB(NOW(), INTERVAL 20 DAY), 0);

-- ========== plugin\plugin_open.sql ==========

-- 初始化表结构
CREATE TABLE IF NOT EXISTS `sys_app`  (
    `id`          bigint(20)   NOT NULL     AUTO_INCREMENT COMMENT 'ID',
    `name`        varchar(100) NOT NULL                    COMMENT '名称',
    `access_key`  varchar(255) NOT NULL                    COMMENT 'Access Key（访问密钥）',
    `secret_key`  varchar(255) NOT NULL                    COMMENT 'Secret Key（私有密钥）',
    `expire_time` datetime     DEFAULT NULL                COMMENT '失效时间',
    `description` varchar(200) DEFAULT NULL                COMMENT '描述',
    `status`      tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `create_user` bigint(20)   NOT NULL                    COMMENT '创建人',
    `create_time` datetime     NOT NULL                    COMMENT '创建时间',
    `update_user` bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time` datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`     bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_access_key`(`access_key`, `deleted`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='应用表';

-- 初始化默认菜单
INSERT INTO `sys_menu`
(`id`, `title`, `parent_id`, `type`, `path`, `name`, `component`, `redirect`, `icon`, `is_external`, `is_cache`, `is_hidden`, `permission`, `sort`, `status`, `create_user`, `create_time`)
VALUES
(7000, '能力开放', 0, 1, '/open', 'Open', 'Layout', '/open/app', 'expand', b'0', b'0', b'0', NULL, 4, 1, 1, NOW()),
(7010, '应用管理', 7000, 2, '/open/app', 'OpenApp', 'open/app/index', NULL, 'common', b'0', b'0', b'0', NULL, 1, 1, 1, NOW()),
(7011, '列表', 7010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'open:app:list', 1, 1, 1, NOW()),
(7012, '详情', 7010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'open:app:get', 2, 1, 1, NOW()),
(7013, '新增', 7010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'open:app:create', 3, 1, 1, NOW()),
(7014, '修改', 7010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'open:app:update', 4, 1, 1, NOW()),
(7015, '删除', 7010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'open:app:delete', 5, 1, 1, NOW()),
(7016, '导出', 7010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'open:app:export', 6, 1, 1, NOW()),
(7017, '查看密钥', 7010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'open:app:secret', 7, 1, 1, NOW()),
(7018, '重置密钥', 7010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'open:app:resetSecret', 8, 1, 1, NOW());

-- ========== plugin\plugin_tenant.sql ==========

-- 初始化表结构
CREATE TABLE IF NOT EXISTS `tenant` (
    `id`             bigint(20)   AUTO_INCREMENT              COMMENT 'ID',
    `name`           varchar(30)  NOT NULL                    COMMENT '名称',
    `code`           varchar(30)  NOT NULL                    COMMENT '编码',
    `domain`         varchar(255) DEFAULT NULL                COMMENT '域名',
    `expire_time`    datetime     DEFAULT NULL                COMMENT '过期时间',
    `description`    varchar(200) DEFAULT NULL                COMMENT '描述',
    `status`         tinyint(1)   UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `admin_user`     bigint(20)   DEFAULT NULL                COMMENT '管理员用户',
    `admin_username` varchar(64)  DEFAULT NULL                COMMENT '管理员用户名',
    `package_id`     bigint(20)   NOT NULL                    COMMENT '套餐ID',
    `create_user`    bigint(20)   NOT NULL                    COMMENT '创建人',
    `create_time`    datetime     NOT NULL                    COMMENT '创建时间',
    `update_user`    bigint(20)   DEFAULT NULL                COMMENT '修改人',
    `update_time`    datetime     DEFAULT NULL                COMMENT '修改时间',
    `deleted`        bigint(20)   NOT NULL DEFAULT 0          COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uk_code`(`code`, `deleted`),
    INDEX `idx_admin_user`(`admin_user`),
    INDEX `idx_package_id`(`package_id`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租户表';

CREATE TABLE IF NOT EXISTS `tenant_package` (
    `id`                  bigint(20)    AUTO_INCREMENT              COMMENT 'ID',
    `name`                varchar(30)   NOT NULL                    COMMENT '名称',
    `sort`                int           NOT NULL DEFAULT 999        COMMENT '排序',
    `menu_check_strictly` bit(1)        DEFAULT b'1'                COMMENT '菜单选择是否父子节点关联',
    `description`         varchar(200)  DEFAULT NULL                COMMENT '描述',
    `status`              tinyint       UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态（1：启用；2：禁用）',
    `create_user`         bigint(20)    NOT NULL                    COMMENT '创建人',
    `create_time`         datetime      NOT NULL                    COMMENT '创建时间',
    `update_user`         bigint(20)    DEFAULT NULL                COMMENT '修改人',
    `update_time`         datetime      DEFAULT NULL                COMMENT '修改时间',
    `deleted`             bigint(20)   NOT NULL DEFAULT 0           COMMENT '是否已删除（0：否；id：是）',
    PRIMARY KEY (`id`),
    INDEX `idx_create_user`(`create_user`),
    INDEX `idx_update_user`(`update_user`),
    INDEX `idx_deleted`(`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租户套餐表';

CREATE TABLE IF NOT EXISTS `tenant_package_menu` (
    `package_id` bigint(20) NOT NULL COMMENT '套餐ID',
    `menu_id`    bigint(20) NOT NULL COMMENT '菜单ID',
    PRIMARY KEY (`package_id`, `menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='租户套餐和菜单关联表';

-- 为已有表增加租户字段
ALTER TABLE `sys_dept`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_role`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_user`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_user_password_history`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_user_social`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_user_role`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_role_menu`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_role_dept`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_log`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_message`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_message_log`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_notice`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_notice_log`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_file`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);
ALTER TABLE `sys_app`
    ADD COLUMN `tenant_id` BIGINT NOT NULL DEFAULT 0 COMMENT '租户ID',
    ADD INDEX `idx_tenant_id` (`tenant_id`);

-- 调整唯一索引
ALTER TABLE `sys_dept`
    DROP INDEX `uk_name_parent_id`,
    ADD UNIQUE INDEX `uk_name_parent_id` (`name`, `parent_id`, `deleted`, `tenant_id`);
ALTER TABLE `sys_role`
    DROP INDEX `uk_name`,
    DROP INDEX `uk_code`,
    ADD UNIQUE INDEX `uk_name` (`name`, `deleted`, `tenant_id`),
    ADD UNIQUE INDEX `uk_code` (`code`, `deleted`, `tenant_id`);
ALTER TABLE `sys_user`
    DROP INDEX `uk_username`,
    DROP INDEX `uk_email`,
    DROP INDEX `uk_phone`,
    ADD UNIQUE INDEX `uk_username` (`username`, `deleted`, `tenant_id`),
    ADD UNIQUE INDEX `uk_email` (`email`, `deleted`, `tenant_id`),
    ADD UNIQUE INDEX `uk_phone` (`phone`, `deleted`, `tenant_id`);
ALTER TABLE `sys_user_social`
    DROP INDEX `uk_source_open_id`,
    ADD UNIQUE INDEX `uk_source_open_id` (`source`, `open_id`, `deleted`, `tenant_id`);
ALTER TABLE `sys_app`
    DROP INDEX `uk_access_key`,
    ADD UNIQUE INDEX `uk_access_key` (`access_key`, `deleted`, `tenant_id`);

-- 初始化默认菜单
INSERT INTO `sys_menu`
(`id`, `title`, `parent_id`, `type`, `path`, `name`, `component`, `redirect`, `icon`, `is_external`, `is_cache`, `is_hidden`, `permission`, `sort`, `status`, `create_user`, `create_time`)
VALUES
(3000, '租户管理', 0, 1, '/tenant', 'Tenant', 'Layout', '/tenant/management', 'user-group', b'0', b'0', b'0', NULL, 3, 1, 1, NOW()),

(3010, '租户管理', 3000, 2, '/tenant/management', 'TenantManagement', 'tenant/management/index', NULL, 'user-group', b'0', b'0', b'0', NULL, 1, 1, 1, NOW()),
(3011, '列表', 3010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:management:list', 1, 1, 1, NOW()),
(3012, '详情', 3010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:management:get', 2, 1, 1, NOW()),
(3013, '新增', 3010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:management:create', 3, 1, 1, NOW()),
(3014, '修改', 3010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:management:update', 4, 1, 1, NOW()),
(3015, '删除', 3010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:management:delete', 5, 1, 1, NOW()),
(3016, '修改租户管理员密码', 3010, 3, NULL, NULL, NULL, NULL, NULL, b'0', b'0', b'0', 'tenant:management:updateAdminUserPwd', 6, 1, 1, NOW()),

(3020, '套餐管理', 3000, 2, '/tenant/package', 'TenantPackage', 'tenant/package/index', NULL, 'project', b'0', b'0', b'0', NULL, 2, 1, 1, NOW()),
(3021, '列表', 3020, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:package:list', 1, 1, 1, NOW()),
(3022, '详情', 3020, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:package:get', 2, 1, 1, NOW()),
(3023, '新增', 3020, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:package:create', 3, 1, 1, NOW()),
(3024, '修改', 3020, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:package:update', 4, 1, 1, NOW()),
(3025, '删除', 3020, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'tenant:package:delete', 5, 1, 1, NOW());

-- ========== plugin\plugin_schedule.sql ==========

-- 初始化默认菜单
INSERT INTO `sys_menu`
(`id`, `title`, `parent_id`, `type`, `path`, `name`, `component`, `redirect`, `icon`, `is_external`, `is_cache`, `is_hidden`, `permission`, `sort`, `status`, `create_user`, `create_time`)
VALUES
(8000, '任务调度', 0, 1, '/schedule', 'Schedule', 'Layout', '/schedule/job', 'schedule', b'0', b'0', b'0', NULL, 5, 1, 1, NOW()),
(8010, '任务管理', 8000, 2, '/schedule/job', 'ScheduleJob', 'schedule/job/index', NULL, 'select-all', b'0', b'0', b'0', NULL, 1, 1, 1, NOW()),
(8011, '列表', 8010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:job:list', 1, 1, 1, NOW()),
(8012, '详情', 8010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:job:get', 2, 1, 1, NOW()),
(8013, '新增', 8010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:job:create', 3, 1, 1, NOW()),
(8014, '修改', 8010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:job:update', 4, 1, 1, NOW()),
(8015, '删除', 8010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:job:delete', 5, 1, 1, NOW()),
(8016, '执行', 8010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:job:trigger', 6, 1, 1, NOW()),

(8020, '任务日志', 8000, 2, '/schedule/log', 'ScheduleLog', 'schedule/log/index', NULL, 'find-replace', b'0', b'0', b'0', NULL, 2, 1, 1, NOW()),
(8021, '列表', 8020, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:log:list', 1, 1, 1, NOW()),
(8022, '停止', 8020, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:log:stop', 3, 1, 1, NOW()),
(8023, '重试', 8020, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'schedule:log:retry', 4, 1, 1, NOW());

-- ========== plugin\plugin_generator.sql ==========

-- 初始化表结构
CREATE TABLE IF NOT EXISTS `gen_config` (
    `table_name`    varchar(64)  NOT NULL              COMMENT '表名称',
    `module_name`   varchar(60)  NOT NULL              COMMENT '模块名称',
    `package_name`  varchar(60)  NOT NULL              COMMENT '包名称',
    `business_name` varchar(50)  NOT NULL              COMMENT '业务名称',
    `author`        varchar(100) NOT NULL              COMMENT '作者',
    `table_prefix`  varchar(20)  DEFAULT NULL          COMMENT '表前缀',
    `is_override`   bit(1)       NOT NULL DEFAULT b'0' COMMENT '是否覆盖',
    `create_time`   datetime     NOT NULL              COMMENT '创建时间',
    `update_time`   datetime     DEFAULT NULL          COMMENT '修改时间',
    PRIMARY KEY (`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='生成配置表';

CREATE TABLE IF NOT EXISTS `gen_field_config` (
    `id`            bigint(20)   NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `table_name`    varchar(64)  NOT NULL                COMMENT '表名称',
    `column_name`   varchar(64)  NOT NULL                COMMENT '列名称',
    `column_type`   varchar(25)  NOT NULL                COMMENT '列类型',
    `column_size`   bigint(20)   DEFAULT NULL            COMMENT '列大小',
    `field_name`    varchar(64)  NOT NULL                COMMENT '字段名称',
    `field_type`    varchar(25)  NOT NULL                COMMENT '字段类型',
    `field_sort`    int          NOT NULL DEFAULT 999    COMMENT '字段排序',
    `comment`       varchar(512) DEFAULT NULL            COMMENT '注释',
    `is_required`   bit(1)       NOT NULL DEFAULT b'1'   COMMENT '是否必填',
    `show_in_list`  bit(1)       NOT NULL DEFAULT b'1'   COMMENT '是否在列表中显示',
    `show_in_form`  bit(1)       NOT NULL DEFAULT b'1'   COMMENT '是否在表单中显示',
    `show_in_query` bit(1)       NOT NULL DEFAULT b'1'   COMMENT '是否在查询中显示',
    `form_type`     tinyint(1)   UNSIGNED DEFAULT NULL   COMMENT '表单类型',
    `query_type`    tinyint(1)   UNSIGNED DEFAULT NULL   COMMENT '查询方式',
    `dict_code`     varchar(30)  DEFAULT NULL            COMMENT '字典编码',
    `create_time`   datetime NOT NULL COMMENT '创建时间',
    PRIMARY KEY (`id`),
    INDEX `idx_table_name`(`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字段配置表';

-- 初始化默认菜单
INSERT INTO `sys_menu`
(`id`, `title`, `parent_id`, `type`, `path`, `name`, `component`, `redirect`, `icon`, `is_external`, `is_cache`, `is_hidden`, `permission`, `sort`, `status`, `create_user`, `create_time`)
VALUES
(9000, '开发工具', 0, 1, '/code', 'Code', 'Layout', '/code/generator', 'code-release-managment', b'0', b'0', b'0', NULL, 6, 1, 1, NOW()),
(9010, '代码生成', 9000, 2, '/code/generator', 'CodeGenerator', 'code/generator/index', NULL, 'code', b'0', b'0', b'0', NULL, 1, 1, 1, NOW()),
(9011, '列表', 9010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'code:generator:list', 1, 1, 1, NOW()),
(9012, '配置', 9010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'code:generator:config', 2, 1, 1, NOW()),
(9013, '预览', 9010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'code:generator:preview', 3, 1, 1, NOW()),
(9014, '生成', 9010, 3, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'code:generator:generate', 4, 1, 1, NOW());

SET FOREIGN_KEY_CHECKS = 1;
