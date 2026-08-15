package com.ls.aegis.rbac.model.resp;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

/**
 * 运营中枢实时天气
 */
@Data
@Schema(description = "运营中枢实时天气")
public class WeatherNowResp implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    @Schema(description = "城市", example = "北京")
    private String city;

    @Schema(description = "天气现象编码", example = "sunny")
    private String kind;

    @Schema(description = "天气现象名称", example = "晴")
    private String label;

    @Schema(description = "气温（℃）", example = "26")
    private Integer temp;

    @Schema(description = "相对湿度（%）", example = "48")
    private Integer humidity;

    @Schema(description = "风力等级（蒲福 0–12）", example = "3")
    private Integer windLevel;

    @Schema(description = "实际数据来源：mock / qweather", example = "qweather")
    private String provider;
}
