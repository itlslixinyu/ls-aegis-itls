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

package com.ls.aegis.biz.open.service.impl;

import cn.hutool.core.codec.Base64;
import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import org.springframework.stereotype.Service;
import com.ls.aegis.mybatis.base.service.BaseServiceImpl;
import com.ls.aegis.biz.open.mapper.AppMapper;
import com.ls.aegis.biz.open.model.entity.AppDO;
import com.ls.aegis.biz.open.model.query.AppQuery;
import com.ls.aegis.biz.open.model.req.AppReq;
import com.ls.aegis.biz.open.model.resp.AppDetailResp;
import com.ls.aegis.biz.open.model.resp.AppResp;
import com.ls.aegis.biz.open.model.resp.AppSecretResp;
import com.ls.aegis.biz.open.service.AppService;
import top.continew.starter.core.constant.StringConstants;
import top.continew.starter.core.util.validation.CheckUtils;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

/**
 * 应用业务实现
 *
 * @author chengzi
 * @author Charles7c
 * @since 2024/10/17 16:03
 */
@Service
public class AppServiceImpl extends BaseServiceImpl<AppMapper, AppDO, AppResp, AppDetailResp, AppQuery, AppReq> implements AppService {

    @Override
    public void beforeCreate(AppReq req) {
        this.checkExpireTime(req.getExpireTime(), null);
        req.setAccessKey(Base64.encode(IdUtil.fastSimpleUUID())
            .replace(StringConstants.SLASH, StringConstants.EMPTY)
            .replace(StringConstants.PLUS, StringConstants.EMPTY)
            .substring(0, 30));
        req.setSecretKey(this.generateSecret());
    }

    @Override
    public void beforeUpdate(AppReq req, Long id) {
        AppDO app = super.getById(id);
        this.checkExpireTime(req.getExpireTime(), app.getExpireTime());
    }

    /**
     * 校验失效时间：新增必须为未来；修改允许保留原已过期值，不允许改为新的过去时间
     *
     * @param expireTime    请求失效时间
     * @param oldExpireTime 原失效时间（新增时为 null）
     */
    private void checkExpireTime(LocalDateTime expireTime, LocalDateTime oldExpireTime) {
        if (expireTime == null) {
            return;
        }
        if (expireTime.isAfter(LocalDateTime.now())) {
            return;
        }
        CheckUtils.throwIf(oldExpireTime == null || !isSameDateTime(expireTime, oldExpireTime), "失效时间必须是未来时间");
    }

    private boolean isSameDateTime(LocalDateTime left, LocalDateTime right) {
        return left.truncatedTo(ChronoUnit.SECONDS).equals(right.truncatedTo(ChronoUnit.SECONDS));
    }

    @Override
    public AppSecretResp getSecret(Long id) {
        AppDO app = super.getById(id);
        AppSecretResp appSecretResp = new AppSecretResp();
        appSecretResp.setAccessKey(app.getAccessKey());
        appSecretResp.setSecretKey(app.getSecretKey());
        return appSecretResp;
    }

    @Override
    public void resetSecret(Long id) {
        super.getById(id);
        AppDO app = new AppDO();
        app.setSecretKey(this.generateSecret());
        baseMapper.update(app, Wrappers.lambdaQuery(AppDO.class).eq(AppDO::getId, id));
    }

    @Override
    public AppDO getByAccessKey(String accessKey) {
        return baseMapper.selectByAccessKey(accessKey);
    }

    /**
     * 生成密钥
     *
     * @return 密钥
     */
    private String generateSecret() {
        return Base64.encode(IdUtil.fastSimpleUUID())
            .replace(StringConstants.SLASH, StringConstants.EMPTY)
            .replace(StringConstants.PLUS, StringConstants.EMPTY);
    }
}