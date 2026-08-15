/** 图形验证码类型 */
export interface ImageCaptchaResp {
  uuid: string
  img: string
  expireTime: number
  isEnabled: boolean
}

/** 仪表盘公告类型 */
export interface DashboardNoticeResp {
  /** 雪花 ID，可能超过 JS 安全整数，后端 FLEXIBLE 模式下为大数时返回 string */
  id: string | number
  title: string
  /** 分类（字典 notice_type：1通知公告…9紧急通告） */
  type: string | number
  isTop: boolean
}

/** 仪表盘访问趋势类型 */
export interface DashboardAccessTrendResp {
  date: string
  pvCount: number
  ipCount: number
}

/** 仪表盘通用总览类型 */
export interface DashboardOverviewCommonResp {
  total: number
  today: number
  growth: number
  dataList: DashboardChartCommonResp[]
}

/** 仪表盘通用图表类型 */
export interface DashboardChartCommonResp {
  name: string
  value: number
}

/* 行为验证码类型 */
export interface BehaviorCaptchaResp {
  originalImageBase64: string
  point: {
    x: number
    y: number
  }
  jigsawImageBase64: string
  token: string
  secretKey: string
  wordList: string[]
}

export interface BehaviorCaptchaReq {
  captchaType?: string
  captchaVerification?: string
  clientUid?: string
}

export interface CheckBehaviorCaptchaResp {
  repCode: string
  repMsg: string
}
