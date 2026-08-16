/*
 * Copyright (c) 2022-present Charles7c Authors. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.ls.aegis.rbac.service.impl;

import cn.hutool.core.map.MapUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.ls.aegis.common.constant.GlobalConstants;
import com.ls.aegis.rbac.constant.ModuleOptionConstants;
import com.ls.aegis.rbac.enums.OptionCategoryEnum;
import com.ls.aegis.rbac.service.ModuleService;
import com.ls.aegis.rbac.service.OptionService;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * 功能模块总开关
 *
 * @author ls
 * @since 2026/8/16
 */
@Service
@RequiredArgsConstructor
public class ModuleServiceImpl implements ModuleService {

    private final OptionService optionService;

    /** 与环境配置 snail-job.enabled 对齐；未启用时不展示任务调度菜单，避免接口占位报错 */
    @Value("${snail-job.enabled:false}")
    private boolean snailJobEnabled;

    @Override
    public boolean isTenantEnabled() {
        return isEnabled(ModuleOptionConstants.TENANT_ENABLED, true);
    }

    @Override
    public boolean isOpenEnabled() {
        return isEnabled(ModuleOptionConstants.OPEN_ENABLED, true);
    }

    @Override
    public boolean isScheduleEnabled() {
        // 默认关闭：依赖 snail-job 基础设施；配置开关与运行时 enabled 同时满足才开放
        return snailJobEnabled && isEnabled(ModuleOptionConstants.SCHEDULE_ENABLED, false);
    }

    @Override
    public Set<Long> disabledMenuRootIds() {
        Set<Long> roots = new HashSet<>(3);
        if (!isTenantEnabled()) {
            roots.add(ModuleOptionConstants.MENU_ROOT_TENANT);
        }
        if (!isOpenEnabled()) {
            roots.add(ModuleOptionConstants.MENU_ROOT_OPEN);
        }
        if (!isScheduleEnabled()) {
            roots.add(ModuleOptionConstants.MENU_ROOT_SCHEDULE);
        }
        return roots;
    }

    private boolean isEnabled(String code, boolean defaultEnabled) {
        Map<String, String> map = optionService.getByCategory(OptionCategoryEnum.MODULE);
        String fallback = defaultEnabled
            ? String.valueOf(GlobalConstants.Boolean.YES)
            : String.valueOf(GlobalConstants.Boolean.NO);
        String value = MapUtil.getStr(map, code, fallback);
        return String.valueOf(GlobalConstants.Boolean.YES).equals(value);
    }
}
