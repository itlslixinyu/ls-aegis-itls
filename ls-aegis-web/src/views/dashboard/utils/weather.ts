/** 运营中枢顶栏天气（城市等由系统配置 WEATHER 驱动；暂用占位数据） */

/**
 * 天气现象（含可独立预警的灾害性天气）
 * 晴/多云/雨为常规；暴雨、雷电、冰雹、雪、雾、沙尘等可触发现象预警
 */
export type WeatherKind =
  | 'sunny'
  | 'cloudy'
  | 'rainy'
  | 'storm'
  | 'thunder'
  | 'hail'
  | 'snow'
  | 'fog'
  | 'sand'

/**
 * 国家气象灾害预警等级（国务院应急 / 中国气象局）
 * 蓝 → 黄 → 橙 → 红，由低到高
 */
export type WeatherAlertLevel = 'none' | 'blue' | 'yellow' | 'orange' | 'red'

/** 分项预警（各自独立，互不合成） */
export interface WeatherAlerts {
  /** 天气现象预警（冰雹、暴雨、雷电等） */
  weather: WeatherAlertLevel
  /** 气温预警（高温 / 低温） */
  temp: WeatherAlertLevel
  /** 湿度预警（高湿 / 干燥） */
  humidity: WeatherAlertLevel
  /** 风力预警（大风） */
  wind: WeatherAlertLevel
}

export interface DashboardWeather {
  city: string
  kind: WeatherKind
  label: string
  /** 本地天气图标路径（public/weather-icons） */
  iconSrc: string
  temp: number
  /** 相对湿度 0–100 */
  humidity: number
  /** 风力等级（蒲福风级 0–12） */
  windLevel: number
  /** 分项预警等级 */
  alerts: WeatherAlerts
}

/** 顶栏展示用的单条预警 */
export interface ActiveWeatherAlert {
  key: keyof WeatherAlerts
  level: Exclude<WeatherAlertLevel, 'none'>
  /** 如：冰雹橙色预警、高温黄色预警 */
  label: string
}

export interface WeatherRuntimeConfig {
  enabled: boolean
  city: string
  cityMode: 'auto' | 'fixed'
  /** 刷新间隔（秒） */
  refreshInterval: number
  provider: 'mock' | 'qweather' | string
}

const KIND_META: Record<
  WeatherKind,
  { label: string, icon: string, /** 现象默认预警（占位；接真接口后以服务端为准） */ alert: WeatherAlertLevel }
> = {
  sunny: { label: '晴', icon: '/weather-icons/sunny.svg', alert: 'none' },
  cloudy: { label: '多云', icon: '/weather-icons/cloudy.svg', alert: 'none' },
  rainy: { label: '雨', icon: '/weather-icons/rainy.svg', alert: 'none' },
  storm: { label: '暴雨', icon: '/weather-icons/storm.svg', alert: 'orange' },
  thunder: { label: '雷电', icon: '/weather-icons/thunder.svg', alert: 'yellow' },
  hail: { label: '冰雹', icon: '/weather-icons/hail.svg', alert: 'orange' },
  snow: { label: '暴雪', icon: '/weather-icons/snow.svg', alert: 'yellow' },
  fog: { label: '大雾', icon: '/weather-icons/fog.svg', alert: 'yellow' },
  sand: { label: '沙尘', icon: '/weather-icons/sand.svg', alert: 'yellow' },
}

/** 现象预警名称（无预警时不展示） */
const WEATHER_ALERT_NAME: Partial<Record<WeatherKind, string>> = {
  storm: '暴雨',
  thunder: '雷电',
  hail: '冰雹',
  snow: '暴雪',
  fog: '大雾',
  sand: '沙尘',
}

export const ALERT_LEVEL_LABEL: Record<WeatherAlertLevel, string> = {
  none: '无预警',
  blue: '蓝色预警',
  yellow: '黄色预警',
  orange: '橙色预警',
  red: '红色预警',
}

const ALERT_COLOR_LABEL: Record<Exclude<WeatherAlertLevel, 'none'>, string> = {
  blue: '蓝色',
  yellow: '黄色',
  orange: '橙色',
  red: '红色',
}

const DEFAULT_CITY = '北京'

const ALERT_RANK: Record<WeatherAlertLevel, number> = {
  none: 0,
  blue: 1,
  yellow: 2,
  orange: 3,
  red: 4,
}

/** 环境变量兜底城市 */
export const getEnvWeatherCity = (): string => {
  const fromEnv = (import.meta.env.VITE_DASHBOARD_WEATHER_CITY as string | undefined)?.trim()
  return fromEnv || DEFAULT_CITY
}

export const defaultWeatherRuntimeConfig = (): WeatherRuntimeConfig => ({
  enabled: true,
  city: getEnvWeatherCity(),
  cityMode: 'auto',
  refreshInterval: 600,
  provider: 'mock',
})

/** 浏览器定位（失败返回 null，不弹错） */
export const tryBrowserGeolocation = (): Promise<{ lat: number, lon: number } | null> => {
  return new Promise((resolve) => {
    if (typeof navigator === 'undefined' || !navigator.geolocation) {
      resolve(null)
      return
    }
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        resolve({ lat: pos.coords.latitude, lon: pos.coords.longitude })
      },
      () => resolve(null),
      { enableHighAccuracy: false, timeout: 5000, maximumAge: 10 * 60 * 1000 },
    )
  })
}

/** 取更高等级（仅用于展示排序，不合成业务预警） */
export const higherAlertLevel = (a: WeatherAlertLevel, b: WeatherAlertLevel): WeatherAlertLevel =>
  ALERT_RANK[a] >= ALERT_RANK[b] ? a : b

/**
 * 气温独立预警（占位规则，对齐高温/低温预警量级）
 * 高温：蓝≥35 / 黄≥37 / 橙≥39 / 红≥40
 * 低温：蓝≤4 / 黄≤0 / 橙≤-8 / 红≤-12
 */
export const resolveTempAlert = (temp: number): { level: WeatherAlertLevel, kind: 'high' | 'low' | 'none' } => {
  if (temp >= 40) return { level: 'red', kind: 'high' }
  if (temp >= 39) return { level: 'orange', kind: 'high' }
  if (temp >= 37) return { level: 'yellow', kind: 'high' }
  if (temp >= 35) return { level: 'blue', kind: 'high' }
  if (temp <= -12) return { level: 'red', kind: 'low' }
  if (temp <= -8) return { level: 'orange', kind: 'low' }
  if (temp <= 0) return { level: 'yellow', kind: 'low' }
  if (temp <= 4) return { level: 'blue', kind: 'low' }
  return { level: 'none', kind: 'none' }
}

/**
 * 湿度独立预警（占位规则）
 * 高湿：蓝≥85 / 黄≥90 / 橙≥95 / 红≥98
 * 干燥：蓝≤20 / 黄≤15 / 橙≤10 / 红≤5
 */
export const resolveHumidityAlert = (
  humidity: number,
): { level: WeatherAlertLevel, kind: 'high' | 'low' | 'none' } => {
  if (humidity >= 98) return { level: 'red', kind: 'high' }
  if (humidity >= 95) return { level: 'orange', kind: 'high' }
  if (humidity >= 90) return { level: 'yellow', kind: 'high' }
  if (humidity >= 85) return { level: 'blue', kind: 'high' }
  if (humidity <= 5) return { level: 'red', kind: 'low' }
  if (humidity <= 10) return { level: 'orange', kind: 'low' }
  if (humidity <= 15) return { level: 'yellow', kind: 'low' }
  if (humidity <= 20) return { level: 'blue', kind: 'low' }
  return { level: 'none', kind: 'none' }
}

/**
 * 风力独立预警（占位规则，对齐大风预警量级）
 * 蓝≥6 / 黄≥8 / 橙≥10 / 红≥12
 */
export const resolveWindAlert = (windLevel: number): WeatherAlertLevel => {
  if (windLevel >= 12) return 'red'
  if (windLevel >= 10) return 'orange'
  if (windLevel >= 8) return 'yellow'
  if (windLevel >= 6) return 'blue'
  return 'none'
}

/** 天气现象独立预警（按 kind；接真接口后以服务端等级为准） */
export const resolveWeatherAlert = (kind: WeatherKind): WeatherAlertLevel => KIND_META[kind].alert

/** 汇总分项预警 */
export const resolveWeatherAlerts = (
  kind: WeatherKind,
  temp: number,
  humidity: number,
  windLevel: number,
): WeatherAlerts => ({
  weather: resolveWeatherAlert(kind),
  temp: resolveTempAlert(temp).level,
  humidity: resolveHumidityAlert(humidity).level,
  wind: resolveWindAlert(windLevel),
})

/** 将后端实时天气归一为顶栏展示模型 */
export const mapWeatherNowToDashboard = (data: {
  city: string
  kind: string
  label?: string
  temp: number
  humidity: number
  windLevel: number
}): DashboardWeather => {
  const kind = (Object.prototype.hasOwnProperty.call(KIND_META, data.kind)
    ? data.kind
    : 'cloudy') as WeatherKind
  const meta = KIND_META[kind]
  const temp = Number(data.temp) || 0
  const humidity = Number(data.humidity) || 0
  const windLevel = Number(data.windLevel) || 0
  return {
    city: data.city || getEnvWeatherCity(),
    kind,
    label: data.label || meta.label,
    iconSrc: meta.icon,
    temp,
    humidity,
    windLevel,
    alerts: resolveWeatherAlerts(kind, temp, humidity, windLevel),
  }
}

/** 列出当前生效的独立预警（用于顶栏文案） */
export const listActiveWeatherAlerts = (weather: DashboardWeather): ActiveWeatherAlert[] => {
  const result: ActiveWeatherAlert[] = []
  const { alerts, kind, temp, humidity } = weather

  if (alerts.weather !== 'none') {
    const name = WEATHER_ALERT_NAME[kind] || weatherKindLabel(kind)
    result.push({
      key: 'weather',
      level: alerts.weather,
      label: `${name}${ALERT_COLOR_LABEL[alerts.weather]}预警`,
    })
  }

  if (alerts.temp !== 'none') {
    const tempKind = resolveTempAlert(temp).kind
    const name = tempKind === 'low' ? '低温' : '高温'
    result.push({
      key: 'temp',
      level: alerts.temp,
      label: `${name}${ALERT_COLOR_LABEL[alerts.temp]}预警`,
    })
  }

  if (alerts.humidity !== 'none') {
    const humidityKind = resolveHumidityAlert(humidity).kind
    const name = humidityKind === 'low' ? '干燥' : '高湿'
    result.push({
      key: 'humidity',
      level: alerts.humidity,
      label: `${name}${ALERT_COLOR_LABEL[alerts.humidity]}预警`,
    })
  }

  if (alerts.wind !== 'none') {
    result.push({
      key: 'wind',
      level: alerts.wind,
      label: `大风${ALERT_COLOR_LABEL[alerts.wind]}预警`,
    })
  }

  return result
}

/** 演示用占位天气（后续替换为接口结果即可） */
export const createMockWeather = (city = getEnvWeatherCity()): DashboardWeather => {
  const kinds = Object.keys(KIND_META) as WeatherKind[]
  const kind = kinds[Math.floor(Math.random() * kinds.length)]
  const meta = KIND_META[kind]
  // 扩大温湿风随机范围，便于演示分项预警
  const temp = -15 + Math.floor(Math.random() * 58)
  const humidity = 3 + Math.floor(Math.random() * 97)
  const windLevel = Math.floor(Math.random() * 13)
  return {
    city,
    kind,
    label: meta.label,
    iconSrc: meta.icon,
    temp,
    humidity,
    windLevel,
    alerts: resolveWeatherAlerts(kind, temp, humidity, windLevel),
  }
}

export const weatherKindLabel = (kind: WeatherKind): string => KIND_META[kind].label
