-- liquibase formatted sql

-- changeset ls:remove_sms_menus
-- comment 停用短信：软删除短信配置/短信日志菜单及权限，清理角色关联与短信配置数据
SET NAMES utf8mb4;

-- 角色菜单关联
DELETE FROM `sys_role_menu`
WHERE `menu_id` IN (1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 2050, 2051, 2052, 2053);

-- 软删除菜单（含按钮权限）
UPDATE `sys_menu`
SET `deleted` = `id`, `update_user` = 1, `update_time` = NOW()
WHERE `id` IN (1210, 1211, 1212, 1213, 1214, 1215, 1216, 1217, 2050, 2051, 2052, 2053)
  AND `deleted` = 0;

-- 清空短信配置与日志（已停用）
UPDATE `sys_sms_config` SET `deleted` = `id`, `update_user` = 1, `update_time` = NOW() WHERE `deleted` = 0;
DELETE FROM `sys_sms_log`;
