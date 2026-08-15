<template>
  <div ref="screenRef" class="ops-screen" :class="{ 'is-fullscreen': isFullscreen }">
    <div class="ops-screen__frame frame-tl" aria-hidden="true" />
    <div class="ops-screen__frame frame-tr" aria-hidden="true" />
    <div class="ops-screen__frame frame-bl" aria-hidden="true" />
    <div class="ops-screen__frame frame-br" aria-hidden="true" />
    <div class="ops-screen__frame frame-t" aria-hidden="true" />
    <div class="ops-screen__frame frame-b" aria-hidden="true" />
    <div class="ops-screen__scan" aria-hidden="true" />

    <header class="ops-screen__header anim-fade-down">
      <div
        v-if="weatherEnabled && weather"
        class="ops-screen__weather"
        :title="weatherTitle"
      >
        <span class="ops-screen__weather-city">{{ weather.city }}</span>
        <span class="ops-screen__weather-pipe">|</span>
        <span
          class="ops-screen__weather-condition"
          :class="weather.alerts.weather !== 'none' ? `alert-${weather.alerts.weather}` : undefined"
        >
          <img
            class="ops-screen__weather-icon-img"
            :src="weather.iconSrc"
            :alt="weather.label"
            width="26"
            height="26"
          >
          <span class="ops-screen__weather-label">{{ weather.label }}</span>
        </span>
        <span class="ops-screen__weather-pipe">|</span>
        <span
          class="ops-screen__weather-temp"
          :class="weather.alerts.temp !== 'none' ? `alert-${weather.alerts.temp}` : undefined"
        >温度{{ weather.temp }}°C</span>
        <span class="ops-screen__weather-pipe">|</span>
        <span
          class="ops-screen__weather-metric"
          :class="weather.alerts.aqi !== 'none' ? `alert-${weather.alerts.aqi}` : undefined"
        >空气质量 {{ weather.aqiCategory }}</span>
        <span class="ops-screen__weather-pipe">|</span>
        <span
          class="ops-screen__weather-metric"
          :class="weather.alerts.wind !== 'none' ? `alert-${weather.alerts.wind}` : undefined"
        >风力 {{ weather.windLevel }}级</span>
      </div>
      <div v-else class="ops-screen__weather ops-screen__weather--empty" aria-hidden="true" />
      <div class="ops-screen__title-wrap">
        <span class="ops-screen__title-dot">·</span>
        <h1 class="ops-screen__title">{{ screenTitle }}</h1>
        <span class="ops-screen__title-dot">·</span>
      </div>
      <div class="ops-screen__clock">
        <span class="current-time-glass">
          <span class="current-time">{{ nowParts.date }}</span>
          <span class="ops-screen__weather-pipe">|</span>
          <span class="current-time">{{ nowParts.time }}</span>
          <span class="ops-screen__weather-pipe">|</span>
          <span class="current-time">{{ nowParts.week }}</span>
        </span>
      </div>
    </header>

    <div class="ops-screen__fs-dock" :class="{ 'is-tipping': showFsTip }">
      <div v-if="showFsTip" class="ops-screen__fs-tip" role="status">
        <span class="ops-screen__fs-tip-title">提示</span>
        <span class="ops-screen__fs-tip-text">
          <span>将鼠标移至</span>
          <span>右下角可显</span>
          <span>示全屏按钮</span>
        </span>
        <span class="fs-tip-decor fs-tip-tl" />
        <span class="fs-tip-decor fs-tip-tr" />
        <span class="fs-tip-decor fs-tip-bl" />
        <span class="fs-tip-decor fs-tip-br" />
      </div>
      <button
        type="button"
        class="ops-screen__fs-fab"
        :title="isFullscreen ? '退出全屏' : '全屏展示'"
        :aria-label="isFullscreen ? '退出全屏' : '全屏展示'"
        @click="toggle"
      >
        <icon-fullscreen-exit v-if="isFullscreen" :size="18" />
        <icon-fullscreen v-else :size="18" />
      </button>
    </div>

    <div class="ops-screen__toolbar anim-fade-down" style="--delay: 0.08s">
      <div class="toolbar-left">
        <span class="label">统计周期</span>
        <a-radio-group v-model="trendDays" type="button" size="small">
          <a-radio :value="7">近7天</a-radio>
          <a-radio :value="30">近30天</a-radio>
        </a-radio-group>
      </div>
      <div class="toolbar-right">
        <div class="ops-screen__status ops-screen__status--inline">
          <span class="dot" :class="`is-${runStatus}`" :title="runStatusLabel" />
          <span>{{ runStatusLabel }}</span>
        </div>
        <span class="updated">数据更新于：<span class="update-time">{{ updatedAt }}</span></span>
      </div>
    </div>

    <section class="ops-screen__kpi">
      <div
        v-for="(item, idx) in kpiList"
        :key="item.key"
        class="kpi-card anim-rise"
        :style="{ '--delay': `${0.05 + idx * 0.08}s` }"
      >
        <div class="kpi-card__icon" :style="{ background: item.iconBg, color: item.iconColor }">
          <icon-eye v-if="item.key === 'pv'" :size="18" />
          <icon-location v-else-if="item.key === 'ip'" :size="18" />
          <icon-apps v-else-if="item.key === 'module'" :size="18" />
          <icon-desktop v-else :size="18" />
        </div>
        <div class="kpi-card__main">
          <div class="kpi-card__title">{{ item.title }}</div>
          <div class="kpi-card__line" />
          <div class="kpi-card__metrics">
            <div v-for="m in item.metrics" :key="m.label" class="metric">
              <div class="metric__value">
                <a-statistic
                  :key="`${item.key}-${m.label}-${updatedAt}`"
                  :value="m.value"
                  :value-from="0"
                  :precision="m.precision ?? 0"
                  :value-style="{ color: item.valueColor, fontSize: '20px', fontWeight: 700 }"
                  animation
                  show-group-separator
                >
                  <template v-if="m.suffix" #suffix>{{ m.suffix }}</template>
                </a-statistic>
              </div>
              <div class="metric__label">{{ m.label }}</div>
            </div>
          </div>
        </div>
        <span class="kc-decor kc-tl" />
        <span class="kc-decor kc-tr" />
        <span class="kc-decor kc-bl" />
        <span class="kc-decor kc-br" />
      </div>
    </section>

    <section class="ops-screen__mid">
      <ScreenPanel title="访问量每日趋势" enter-delay="0.38s" :connectors="false">
        <Chart :option="accessTrendOption" height="100%" />
      </ScreenPanel>
      <ScreenPanel title="热门模块分布" enter-delay="0.46s" :connectors="false">
        <Chart :option="moduleOption" height="100%" />
      </ScreenPanel>
      <ScreenPanel title="访问时段分析" enter-delay="0.54s" :connectors="false">
        <Chart :option="timeslotOption" height="100%" />
      </ScreenPanel>
    </section>

    <section class="ops-screen__bottom">
      <ScreenPanel title="终端系统排行 TOP10" enter-delay="0.62s" :connectors="false">
        <Chart :option="osRankOption" height="100%" />
      </ScreenPanel>
      <ScreenPanel title="最新公告" enter-delay="0.7s" :connectors="false">
        <div v-if="!noticeList.length && !loading" class="notice-ticker__empty">暂无公告</div>
        <div
          v-else
          ref="noticeTickerEl"
          class="notice-ticker"
          @mouseenter="noticePaused = true"
          @mouseleave="noticePaused = false"
        >
          <div
            class="notice-ticker__track"
            :class="{ paused: noticePaused, scroll: noticeNeedScroll }"
            :style="noticeNeedScroll ? { animationDuration: `${noticeScrollDuration}s` } : undefined"
          >
            <div
              v-for="(item, idx) in noticeDisplayList"
              :key="`${item.id}-${idx}`"
              class="notice-ticker__item"
              @click="openNotice(item.id)"
            >
              <span class="notice-ticker__dot" :class="`level-${item.level}`" />
              <span class="notice-ticker__label" :class="`level-${item.level}`">{{ item.label }}：</span>
              <span
                class="notice-ticker__text"
                :title="item.title"
                :style="{ letterSpacing: '0.22em', wordSpacing: '0.35em' }"
              >{{ item.title }}</span>
              <span v-if="item.isTop" class="notice-ticker__tag">置顶</span>
            </div>
          </div>
        </div>
      </ScreenPanel>
      <ScreenPanel title="浏览器分布" enter-delay="0.78s" :connectors="false">
        <Chart :option="browserOption" height="100%" />
      </ScreenPanel>
    </section>
  </div>
</template>

<script setup lang="ts">
import { useFullscreen } from '@vueuse/core'
import dayjs from 'dayjs'
import type { EChartsOption } from 'echarts'
import {
  type DashboardAccessTrendResp,
  type DashboardChartCommonResp,
  getAnalysisBrowser,
  getAnalysisModule,
  getAnalysisOs,
  getAnalysisTimeslot,
  getDashboardAccessTrend,
  getDashboardOverviewIp,
  getDashboardOverviewPv,
  listDashboardNotice,
} from '@/apis'
import Chart from '@/components/Chart/index.vue'
import ScreenPanel from '../components/ScreenPanel.vue'
import {
  mapDashboardNotice,
  pickDashboardNotices,
  type NoticeTickerItem,
} from '../utils/noticeTicker'
import {
  createMockWeather,
  defaultWeatherRuntimeConfig,
  listActiveWeatherAlerts,
  mapWeatherNowToDashboard,
  tryBrowserGeolocation,
  type DashboardWeather,
  type WeatherRuntimeConfig,
} from '../utils/weather'
import { getWeatherNow, listWeatherOptionDict } from '@/apis/system'

defineOptions({ name: 'Analysis' })

const router = useRouter()
const screenRef = ref<HTMLElement | null>(null)
const { isFullscreen, enter: enterFullscreen, toggle } = useFullscreen(screenRef)
const showFsTip = ref(false)
let fsTipTimer: ReturnType<typeof setTimeout> | undefined
let fsHotkeyBound = false

const trendDays = ref<7 | 30>(7)
const WEEK_LABELS = ['日', '一', '二', '三', '四', '五', '六'] as const
const formatNowParts = (d = dayjs()) => ({
  date: d.format('YYYY-MM-DD'),
  time: d.format('HH:mm:ss'),
  week: `星期${WEEK_LABELS[d.day()]}`,
})

const nowParts = ref(formatNowParts())
const updatedAt = ref(dayjs().format('HH:mm:ss'))
const loading = ref(false)
/** 进入大屏先不启用/不展示，等配置加载后再按设置取数，避免本地→联网重影 */
const weatherRuntime = ref<WeatherRuntimeConfig>({
  ...defaultWeatherRuntimeConfig(),
  enabled: false,
})
const weatherEnabled = computed(() => weatherRuntime.value.enabled)
const weather = ref<DashboardWeather | null>(null)
const weatherTitle = computed(() => {
  if (!weather.value) return ''
  const base = `${weather.value.city}|${weather.value.label}|温度${weather.value.temp}°C|空气质量 ${weather.value.aqiCategory}${weather.value.aqi != null ? `(${weather.value.aqi})` : ''}|风力 ${weather.value.windLevel}级`
  const alerts = listActiveWeatherAlerts(weather.value).map((i) => i.label)
  return alerts.length ? `${base}|${alerts.join('|')}` : base
})
let weatherTimer: ReturnType<typeof setInterval> | undefined

const refreshWeather = async () => {
  if (!weatherRuntime.value.enabled) {
    weather.value = null
    weatherNetOk.value = true
    applyRunStatus()
    return
  }
  /** 联网（和风）为最高原则：只展示联网结果，失败不回退本地模拟，避免重影 */
  const needNet = weatherRuntime.value.provider === 'qweather'
  try {
    let lat: number | undefined
    let lon: number | undefined
    if (weatherRuntime.value.cityMode === 'auto') {
      const geo = await tryBrowserGeolocation()
      if (geo) {
        // 和风坐标反查建议最多两位小数
        lat = Math.round(geo.lat * 100) / 100
        lon = Math.round(geo.lon * 100) / 100
      }
    }
    const { data } = await getWeatherNow(lat != null && lon != null ? { lat, lon } : undefined)
    if (data?.city) {
      const fromNet = String(data.provider || '') === 'qweather'
      if (needNet && !fromNet) {
        // 后端因失败回退了模拟数据：不展示，保持空白/上次联网结果
        weatherNetOk.value = false
        applyRunStatus()
        return
      }
      weather.value = mapWeatherNowToDashboard(data)
      weatherNetOk.value = !needNet || fromNet
      applyRunStatus()
      return
    }
  } catch {
    // 静默：联网失败不抛错
  }
  if (needNet) {
    weatherNetOk.value = false
    applyRunStatus()
    return
  }
  weather.value = createMockWeather(weatherRuntime.value.city)
  weatherNetOk.value = true
  applyRunStatus()
}

const restartWeatherTimer = () => {
  if (weatherTimer) clearInterval(weatherTimer)
  weatherTimer = undefined
  if (!weatherRuntime.value.enabled) return
  const ms = Math.max(60, weatherRuntime.value.refreshInterval) * 1000
  weatherTimer = setInterval(() => {
    void refreshWeather()
  }, ms)
}

const loadWeatherConfig = async () => {
  try {
    const { data } = await listWeatherOptionDict()
    const map = Object.fromEntries((data || []).map((i) => [i.label, i.value]))
    weatherRuntime.value = {
      enabled: String(map.WEATHER_ENABLED ?? '1') !== '0',
      city: String(map.WEATHER_CITY || weatherRuntime.value.city || '北京').trim() || '北京',
      cityMode: String(map.WEATHER_CITY_MODE || 'auto') === 'fixed' ? 'fixed' : 'auto',
      refreshInterval: Math.max(60, Number(map.WEATHER_REFRESH_INTERVAL) || 600),
      provider: String(map.WEATHER_PROVIDER || 'mock'),
    }
  } catch {
    weatherRuntime.value = defaultWeatherRuntimeConfig()
  }
  await refreshWeather()
  restartWeatherTimer()
}

/** 系统运行指示灯：正常 / 告警 / 异常 / 离线 / 天气获取失败 */
type RunStatus = 'running' | 'warning' | 'error' | 'offline' | 'weather'
const runStatus = ref<RunStatus>('running')
/** 浏览器网络是否在线 */
const systemOnline = ref(typeof navigator === 'undefined' ? true : navigator.onLine)
/** 仪表盘接口是否可用 */
const dashboardOk = ref(true)
/** 天气互联网数据是否可用（配置本地模拟时视为可用） */
const weatherNetOk = ref(true)
/** 最近一次模拟负载（无真实主机监控时用于告警色） */
const lastCpu = ref(30)
const lastMem = ref(50)

const runStatusLabel = computed(() => {
  const map: Record<RunStatus, string> = {
    running: '系统运行中',
    warning: '系统告警中',
    error: '系统异常',
    offline: '系统离线',
    weather: '天气获取失败',
  }
  return map[runStatus.value]
})

/** 优先级：离线 > 异常 > 告警 > 天气获取失败 > 正常 */
const applyRunStatus = () => {
  if (!systemOnline.value || !dashboardOk.value) {
    runStatus.value = 'offline'
    return
  }
  const cpu = lastCpu.value
  const mem = lastMem.value
  if (cpu >= 90 || mem >= 95) {
    runStatus.value = 'error'
    return
  }
  if (cpu >= 70 || mem >= 80) {
    runStatus.value = 'warning'
    return
  }
  if (weatherRuntime.value.enabled && !weatherNetOk.value) {
    runStatus.value = 'weather'
    return
  }
  runStatus.value = 'running'
}

const onBrowserOnline = () => {
  systemOnline.value = true
  applyRunStatus()
  void refreshWeather()
}

const onBrowserOffline = () => {
  systemOnline.value = false
  weatherNetOk.value = false
  applyRunStatus()
}

const pvTotal = ref(0)
const pvToday = ref(0)
const pvGrowth = ref(0)
const ipTotal = ref(0)
const ipToday = ref(0)
const ipGrowth = ref(0)

const accessTrend = ref<DashboardAccessTrendResp[]>([])
const moduleList = ref<DashboardChartCommonResp[]>([])
const timeslotList = ref<DashboardChartCommonResp[]>([])
const osList = ref<DashboardChartCommonResp[]>([])
const browserList = ref<DashboardChartCommonResp[]>([])
const noticeList = ref<NoticeTickerItem[]>([])
const noticePaused = ref(false)
const noticeTickerEl = ref<HTMLElement | null>(null)
/** 单份列表在半程轨道中的重复次数，保证铺满视口避免空行 */
const noticeHalfRepeats = ref(1)
const NOTICE_ITEM_HEIGHT = 36

const noticeTickerList = computed(() => noticeList.value)

const noticeNeedScroll = computed(() => noticeTickerList.value.length > 1)

/** 两段相同内容做 translateY(-50%) 无缝循环；半程至少铺满面板高度 */
const noticeDisplayList = computed(() => {
  const list = noticeTickerList.value
  if (!list.length) {
    return []
  }
  if (!noticeNeedScroll.value) {
    return list
  }
  const half = Array.from({ length: noticeHalfRepeats.value }, () => list).flat()
  return [...half, ...half]
})

const noticeScrollDuration = computed(() => {
  const halfCount = noticeTickerList.value.length * noticeHalfRepeats.value
  return Math.max(halfCount * 3, 6)
})

const syncNoticeRepeats = () => {
  const el = noticeTickerEl.value
  const len = noticeTickerList.value.length
  if (!el || len <= 0) {
    noticeHalfRepeats.value = 1
    return
  }
  const viewH = el.clientHeight
  const listH = len * NOTICE_ITEM_HEIGHT
  noticeHalfRepeats.value = Math.max(1, Math.ceil(viewH / Math.max(listH, 1)))
}

let clockTimer: ReturnType<typeof setInterval> | undefined
let noticeResizeObserver: ResizeObserver | undefined

const axisText = 'rgba(180, 210, 240, 0.65)'
const splitLine = 'rgba(64, 169, 255, 0.12)'
const chartColors = ['#3fd0ff', '#1677ff', '#36cfc9', '#73d13d', '#ff9f43', '#9254de', '#f759ab', '#597ef7']

const screenTitle = computed(() => {
  return 'LS-Aegis 雷铄御警安全应用运营中枢'
})

const moduleVisitTotal = computed(() => moduleList.value.reduce((sum, i) => sum + (i.value || 0), 0))
const moduleTop = computed(() => [...moduleList.value].sort((a, b) => (b.value || 0) - (a.value || 0))[0])
const osKinds = computed(() => osList.value.filter((i) => (i.value || 0) > 0).length)
const browserKinds = computed(() => browserList.value.filter((i) => (i.value || 0) > 0).length)
const topOsShare = computed(() => {
  const total = osList.value.reduce((sum, i) => sum + (i.value || 0), 0)
  if (!total) return 0
  const top = Math.max(...osList.value.map((i) => i.value || 0), 0)
  return Math.round((top / total) * 1000) / 10
})

const kpiList = computed(() => [
  {
    key: 'pv',
    title: '访问量概览',
    iconBg: 'linear-gradient(135deg, #2a6dd6, #409fff)',
    iconColor: '#fff',
    valueColor: '#409fff',
    metrics: [
      { label: '累计 PV', value: pvTotal.value },
      { label: '今日 PV', value: pvToday.value },
      { label: '环比', value: pvGrowth.value, precision: 1, suffix: '%' },
    ],
  },
  {
    key: 'ip',
    title: '独立访客',
    iconBg: 'linear-gradient(135deg, #0099cc, #00d4ff)',
    iconColor: '#fff',
    valueColor: '#00d4ff',
    metrics: [
      { label: '累计 IP', value: ipTotal.value },
      { label: '今日 IP', value: ipToday.value },
      { label: '环比', value: ipGrowth.value, precision: 1, suffix: '%' },
    ],
  },
  {
    key: 'module',
    title: '模块访问',
    iconBg: 'linear-gradient(135deg, #1a8a6a, #3ad1a8)',
    iconColor: '#fff',
    valueColor: '#3ad1a8',
    metrics: [
      { label: '模块数', value: moduleList.value.length },
      { label: '总访问', value: moduleVisitTotal.value },
      { label: 'TOP1', value: moduleTop.value?.value || 0 },
    ],
  },
  {
    key: 'client',
    title: '终端环境',
    iconBg: 'linear-gradient(135deg, #c7445c, #ff4d6d)',
    iconColor: '#fff',
    valueColor: '#ff9d00',
    metrics: [
      { label: '系统种类', value: osKinds.value },
      { label: '浏览器', value: browserKinds.value },
      { label: 'TOP占比', value: topOsShare.value, precision: 1, suffix: '%' },
    ],
  },
])

const accessTrendOption = computed<EChartsOption>(() => {
  const dates = accessTrend.value.map((i) => i.date)
  return {
    animationDuration: 900,
    animationEasing: 'cubicOut',
    grid: { left: 48, right: 24, top: 40, bottom: 40, containLabel: true },
    tooltip: { trigger: 'axis' },
    legend: {
      top: 0,
      textStyle: { color: axisText },
      data: ['PV', 'IP'],
    },
    xAxis: {
      type: 'category',
      data: dates.length ? dates : ['暂无数据'],
      boundaryGap: false,
      axisLabel: { color: axisText, hideOverlap: true },
      axisLine: { lineStyle: { color: splitLine } },
      axisTick: { show: false },
    },
    yAxis: {
      type: 'value',
      minInterval: 1,
      axisLabel: { color: axisText },
      splitLine: { lineStyle: { color: splitLine, type: 'dashed' } },
    },
    series: [
      {
        name: 'PV',
        type: 'line',
        smooth: true,
        showSymbol: false,
        data: accessTrend.value.map((i) => i.pvCount),
        lineStyle: { width: 2, color: '#3fd0ff' },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: 'rgba(63, 208, 255, 0.35)' },
              { offset: 1, color: 'rgba(63, 208, 255, 0)' },
            ],
          },
        },
      },
      {
        name: 'IP',
        type: 'line',
        smooth: true,
        showSymbol: false,
        data: accessTrend.value.map((i) => i.ipCount),
        lineStyle: { width: 2, color: '#73d13d' },
        itemStyle: { color: '#73d13d' },
      },
    ],
  }
})

const moduleOption = computed<EChartsOption>(() => {
  const data = moduleList.value.length
    ? moduleList.value.slice(0, 8).map((item, idx) => ({
        name: item.name || '未知',
        value: item.value || 0,
        itemStyle: { color: chartColors[idx % chartColors.length] },
      }))
    : [{ name: '暂无数据', value: 1, itemStyle: { color: '#1f4b7a' } }]
  return {
    animationDuration: 900,
    tooltip: { trigger: 'item' },
    legend: {
      type: 'scroll',
      top: '74%',
      left: 'center',
      textStyle: { color: axisText, fontSize: 11 },
      itemWidth: 10,
      itemHeight: 10,
      itemGap: 12,
      pageIconColor: '#7ad7ff',
      pageTextStyle: { color: axisText },
    },
    series: [
      {
        type: 'pie',
        radius: ['32%', '48%'],
        center: ['50%', '38%'],
        label: {
          color: '#e8f4ff',
          formatter: '{d}%',
          fontSize: 11,
        },
        labelLine: { length: 8, length2: 6 },
        data,
      },
    ],
  }
})

const timeslotOption = computed<EChartsOption>(() => {
  const names = timeslotList.value.map((i) => i.name)
  const values = timeslotList.value.map((i) => i.value || 0)
  return {
    animationDuration: 900,
    grid: { left: 48, right: 16, top: 24, bottom: 44, containLabel: true },
    tooltip: { trigger: 'axis' },
    xAxis: {
      type: 'category',
      data: names.length ? names : ['暂无数据'],
      axisLabel: { color: axisText, rotate: names.length > 8 ? 30 : 0, hideOverlap: true },
      axisLine: { lineStyle: { color: splitLine } },
      axisTick: { show: false },
    },
    yAxis: {
      type: 'value',
      minInterval: 1,
      axisLabel: { color: axisText },
      splitLine: { lineStyle: { color: splitLine, type: 'dashed' } },
    },
    series: [
      {
        name: '访问量',
        type: 'bar',
        data: values.length ? values : [0],
        barWidth: 14,
        itemStyle: {
          borderRadius: [4, 4, 0, 0],
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [
              { offset: 0, color: '#3fd0ff' },
              { offset: 1, color: '#1677ff' },
            ],
          },
        },
      },
    ],
  }
})

const osRankOption = computed<EChartsOption>(() => {
  const sorted = [...osList.value].sort((a, b) => (a.value || 0) - (b.value || 0)).slice(-10)
  return {
    animationDuration: 900,
    grid: { left: 16, right: 36, top: 16, bottom: 28, containLabel: true },
    tooltip: { trigger: 'axis', axisPointer: { type: 'shadow' } },
    xAxis: {
      type: 'value',
      minInterval: 1,
      axisLabel: { color: axisText },
      splitLine: { lineStyle: { color: splitLine, type: 'dashed' } },
    },
    yAxis: {
      type: 'category',
      data: sorted.length ? sorted.map((i) => i.name || '未知') : ['暂无数据'],
      axisLabel: { color: axisText },
      axisTick: { show: false },
      axisLine: { lineStyle: { color: splitLine } },
    },
    series: [
      {
        type: 'bar',
        data: sorted.length ? sorted.map((i) => i.value || 0) : [0],
        barWidth: 10,
        itemStyle: {
          borderRadius: 4,
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 1,
            y2: 0,
            colorStops: [
              { offset: 0, color: '#13c2c2' },
              { offset: 1, color: '#5cdbd3' },
            ],
          },
        },
      },
    ],
  }
})

const browserOption = computed<EChartsOption>(() => {
  const data = browserList.value.length
    ? browserList.value.slice(0, 8).map((item, idx) => ({
        name: item.name || '未知',
        value: item.value || 0,
        itemStyle: { color: chartColors[idx % chartColors.length] },
      }))
    : [{ name: '暂无数据', value: 1, itemStyle: { color: '#1f4b7a' } }]
  return {
    animationDuration: 900,
    tooltip: { trigger: 'item' },
    legend: {
      type: 'scroll',
      top: '74%',
      left: 'center',
      textStyle: { color: axisText, fontSize: 11 },
      itemWidth: 10,
      itemHeight: 10,
      itemGap: 12,
      pageIconColor: '#7ad7ff',
      pageTextStyle: { color: axisText },
    },
    series: [
      {
        type: 'pie',
        roseType: 'radius',
        radius: ['12%', '46%'],
        center: ['50%', '38%'],
        label: { color: '#e8f4ff', formatter: '{b}', fontSize: 11 },
        labelLine: { length: 8, length2: 6 },
        data,
      },
    ],
  }
})

const openNotice = (id: string | number) => {
  router.push({ path: '/user/notice', query: { id: String(id) } })
}

const loadTrend = async () => {
  const { data } = await getDashboardAccessTrend(trendDays.value)
  accessTrend.value = data || []
  updatedAt.value = dayjs().format('HH:mm:ss')
}

const refreshAll = async () => {
  loading.value = true
  try {
    const [pvRes, ipRes, trendRes, moduleRes, timeslotRes, osRes, browserRes, noticeRes] = await Promise.all([
      getDashboardOverviewPv(),
      getDashboardOverviewIp(),
      getDashboardAccessTrend(trendDays.value),
      getAnalysisModule(),
      getAnalysisTimeslot(),
      getAnalysisOs(),
      getAnalysisBrowser(),
      listDashboardNotice(),
    ])

    pvTotal.value = pvRes.data?.total || 0
    pvToday.value = pvRes.data?.today || 0
    pvGrowth.value = pvRes.data?.growth || 0
    ipTotal.value = ipRes.data?.total || 0
    ipToday.value = ipRes.data?.today || 0
    ipGrowth.value = ipRes.data?.growth || 0
    accessTrend.value = trendRes.data || []
    moduleList.value = moduleRes.data || []
    timeslotList.value = timeslotRes.data || []
    osList.value = osRes.data || []
    browserList.value = browserRes.data || []
    noticeList.value = pickDashboardNotices(noticeRes.data, 20).map(mapDashboardNotice)

    lastCpu.value = 20 + Math.floor(Math.random() * 25)
    lastMem.value = 40 + Math.floor(Math.random() * 30)
    dashboardOk.value = true
    systemOnline.value = navigator.onLine
    await refreshWeather()
    updatedAt.value = dayjs().format('HH:mm:ss')
  } catch {
    dashboardOk.value = false
    applyRunStatus()
  } finally {
    loading.value = false
    nextTick(syncNoticeRepeats)
  }
}

onMounted(async () => {
  window.addEventListener('online', onBrowserOnline)
  window.addEventListener('offline', onBrowserOffline)
  systemOnline.value = navigator.onLine
  await loadWeatherConfig()
  refreshAll()
  clockTimer = setInterval(() => {
    nowParts.value = formatNowParts()
  }, 1000)
  noticeResizeObserver = new ResizeObserver(() => syncNoticeRepeats())
  if (noticeTickerEl.value) {
    noticeResizeObserver.observe(noticeTickerEl.value)
  }
  tipFullscreenDock()
  bindFsHotkey()
})

onActivated(() => {
  tipFullscreenDock()
  bindFsHotkey()
})

onDeactivated(() => {
  unbindFsHotkey()
})

/** 进入大屏时在右下角提示全屏入口，并短暂点亮按钮 */
function tipFullscreenDock() {
  showFsTip.value = true
  if (fsTipTimer) clearTimeout(fsTipTimer)
  fsTipTimer = setTimeout(() => {
    showFsTip.value = false
  }, 5000)
}

/** 本页回车进入全屏（输入框内不触发） */
function onFsEnterKey(e: KeyboardEvent) {
  if (e.key !== 'Enter' && e.code !== 'NumpadEnter') return
  const el = e.target as HTMLElement | null
  if (el) {
    const tag = el.tagName
    if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT' || el.isContentEditable) return
  }
  if (isFullscreen.value) return
  e.preventDefault()
  void enterFullscreen()
}

function bindFsHotkey() {
  if (fsHotkeyBound) return
  window.addEventListener('keydown', onFsEnterKey)
  fsHotkeyBound = true
}

function unbindFsHotkey() {
  if (!fsHotkeyBound) return
  window.removeEventListener('keydown', onFsEnterKey)
  fsHotkeyBound = false
}

watch(trendDays, () => {
  loadTrend()
})

watch(noticeList, () => {
  nextTick(syncNoticeRepeats)
})

watch(
  noticeTickerEl,
  (el) => {
    noticeResizeObserver?.disconnect()
    if (el && noticeResizeObserver) {
      noticeResizeObserver.observe(el)
      nextTick(syncNoticeRepeats)
    }
  },
  { flush: 'post' },
)

onBeforeUnmount(() => {
  window.removeEventListener('online', onBrowserOnline)
  window.removeEventListener('offline', onBrowserOffline)
  if (clockTimer) clearInterval(clockTimer)
  if (weatherTimer) clearInterval(weatherTimer)
  if (fsTipTimer) clearTimeout(fsTipTimer)
  unbindFsHotkey()
  noticeResizeObserver?.disconnect()
})
</script>

<style scoped lang="scss">
@import '../styles/ops-screen.scss';

.metric__value {
  :deep(.arco-statistic-content) {
    line-height: 1.2;
  }

  :deep(.arco-statistic-suffix) {
    font-size: 14px;
    margin-left: 2px;
  }
}

.notice-ticker {
  flex: 1;
  min-height: 0;
  height: 100%;
  width: 100%;
  overflow: hidden;
}

.notice-ticker__empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(126, 163, 204, 0.55);
  letter-spacing: 0.2em;
  font-size: 14px;
}

.notice-ticker__track {
  margin: 0;
  padding: 0;
  width: 100%;

  &.scroll {
    animation-name: notice-ticker-scroll;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
  }

  &.paused {
    animation-play-state: paused;
  }
}

.notice-ticker__item {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  width: 100%;
  height: 44px;
  box-sizing: border-box;
  gap: 20px;
  cursor: pointer;
  padding: 0 12px 0 16px;
  margin: 0;
  min-width: 0;
  border-bottom: 1px dashed rgba(64, 159, 255, 0.08);

  &:hover {
    .notice-ticker__text {
      color: #00d4ff;
    }
  }
}

.notice-ticker__dot {
  flex-shrink: 0;
  width: 8px;
  height: 8px;
  border-radius: 2px;

  &.level-primary {
    background: #409fff;
    box-shadow: 0 0 6px rgba(64, 159, 255, 0.55);
  }
  &.level-success {
    background: #3ad1a8;
    box-shadow: 0 0 6px rgba(58, 209, 168, 0.55);
  }
  &.level-warning {
    background: #ff9d00;
    box-shadow: 0 0 6px rgba(255, 157, 0, 0.55);
  }
  &.level-error {
    background: #ff4d6d;
    box-shadow: 0 0 6px rgba(255, 77, 109, 0.55);
  }
  &.level-default {
    background: #7ea3cc;
  }
}

.notice-ticker__label {
  flex-shrink: 0;
  font-size: 13px;
  font-weight: 600;
  letter-spacing: 0.18em;

  &.level-primary {
    color: #409fff;
  }
  &.level-success {
    color: #3ad1a8;
  }
  &.level-warning {
    color: #ff9d00;
  }
  &.level-error {
    color: #ff4d6d;
  }
  &.level-default {
    color: #7ea3cc;
  }
}

.notice-ticker__text {
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #cfe2ff;
  font-size: 13px;
  letter-spacing: 0.22em;
  word-spacing: 0.35em;
  transition: color 0.2s;
}

.notice-ticker__tag {
  flex-shrink: 0;
  padding: 0 8px;
  height: 20px;
  line-height: 20px;
  border-radius: 2px;
  font-size: 11px;
  letter-spacing: 0.12em;
  color: #ff4d6d;
  background: rgba(255, 77, 109, 0.12);
  border: 1px solid rgba(255, 77, 109, 0.35);
}

@keyframes notice-ticker-scroll {
  0% {
    transform: translateY(0);
  }
  100% {
    transform: translateY(-50%);
  }
}
</style>
