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
      <div class="ops-screen__status">
        <span class="dot" />
        <span>系统运行中</span>
        <span class="sep" />
        <span>CPU {{ cpuUsage }}%</span>
        <span class="sep" />
        <span>MEM {{ memUsage }}%</span>
      </div>
      <div class="ops-screen__title-wrap">
        <span class="ops-screen__title-dot">·</span>
        <h1 class="ops-screen__title">{{ screenTitle }}</h1>
        <span class="ops-screen__title-dot">·</span>
      </div>
      <div class="ops-screen__clock">
        <span class="current-time">{{ nowText }}</span>
        <a-button size="mini" class="fs-btn" @click="toggle">
          <template #icon>
            <icon-fullscreen-exit v-if="isFullscreen" />
            <icon-fullscreen v-else />
          </template>
          全屏
        </a-button>
      </div>
    </header>

    <div class="ops-screen__toolbar anim-fade-down" style="--delay: 0.08s">
      <div class="toolbar-left">
        <span class="label">统计周期</span>
        <a-radio-group v-model="trendDays" type="button" size="small">
          <a-radio :value="7">近7天</a-radio>
          <a-radio :value="30">近30天</a-radio>
        </a-radio-group>
      </div>
      <div class="toolbar-right">
        <a-button size="small" type="primary" :loading="refreshing" @click="refreshAll">
          <template #icon><icon-refresh /></template>
          刷新
        </a-button>
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
          <icon-eye v-if="item.key === 'pv'" :size="22" />
          <icon-location v-else-if="item.key === 'ip'" :size="22" />
          <icon-apps v-else-if="item.key === 'module'" :size="22" />
          <icon-desktop v-else :size="22" />
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
                  :value-style="{ color: item.valueColor, fontSize: '22px', fontWeight: 700 }"
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
          class="notice-ticker"
          @mouseenter="noticePaused = true"
          @mouseleave="noticePaused = false"
        >
          <div
            class="notice-ticker__track"
            :class="{ paused: noticePaused, scroll: noticeNeedScroll }"
            :style="noticeNeedScroll ? { animationDuration: `${Math.max(noticeTickerList.length * 3, 6)}s` } : undefined"
          >
            <div
              v-for="(item, idx) in noticeDisplayList"
              :key="`${item.id}-${idx}`"
              class="notice-ticker__item"
              @click="openNotice(item.id)"
            >
              <span class="notice-ticker__dot" :class="`level-${item.level}`" />
              <span class="notice-ticker__label" :class="`level-${item.level}`">{{ item.label }}：</span>
              <span class="notice-ticker__text" :title="item.title">{{ item.title }}</span>
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

defineOptions({ name: 'Analysis' })

const router = useRouter()
const screenRef = ref<HTMLElement | null>(null)
const { isFullscreen, toggle } = useFullscreen(screenRef)

const trendDays = ref<7 | 30>(7)
const nowText = ref(dayjs().format('YYYY-MM-DD HH:mm:ss'))
const updatedAt = ref(dayjs().format('HH:mm:ss'))
const refreshing = ref(false)
const loading = ref(false)
const cpuUsage = ref(28)
const memUsage = ref(57)

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

const noticeTickerList = computed(() => noticeList.value)

const noticeNeedScroll = computed(() => noticeTickerList.value.length > 1)

const noticeDisplayList = computed(() => {
  if (!noticeNeedScroll.value) {
    return noticeTickerList.value
  }
  return [...noticeTickerList.value, ...noticeTickerList.value]
})

let clockTimer: ReturnType<typeof setInterval> | undefined

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
  refreshing.value = true
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

    cpuUsage.value = 20 + Math.floor(Math.random() * 25)
    memUsage.value = 40 + Math.floor(Math.random() * 30)
    updatedAt.value = dayjs().format('HH:mm:ss')
  } finally {
    loading.value = false
    setTimeout(() => {
      refreshing.value = false
    }, 300)
  }
}

onMounted(() => {
  refreshAll()
  clockTimer = setInterval(() => {
    nowText.value = dayjs().format('YYYY-MM-DD HH:mm:ss')
  }, 1000)
})

watch(trendDays, () => {
  loadTrend()
})

onBeforeUnmount(() => {
  if (clockTimer) clearInterval(clockTimer)
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
  overflow: hidden;
}

.notice-ticker__empty {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(126, 163, 204, 0.55);
  letter-spacing: 2px;
  font-size: 14px;
}

.notice-ticker__track {
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
  height: 36px;
  gap: 8px;
  cursor: pointer;
  padding: 0 20px;
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
  letter-spacing: 0.5px;

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
  transition: color 0.2s;
}

.notice-ticker__tag {
  flex-shrink: 0;
  padding: 0 6px;
  height: 18px;
  line-height: 18px;
  border-radius: 2px;
  font-size: 11px;
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
