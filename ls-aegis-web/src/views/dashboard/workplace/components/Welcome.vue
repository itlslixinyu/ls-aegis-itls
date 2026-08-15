<template>
  <a-card class="card" :bordered="false">
    <a-row align="center" :gutter="16" class="content">
      <a-col :xs="24" :sm="14" :md="14" :lg="14" :xl="14">
        <a-space size="medium">
          <Avatar :src="userStore.avatar" :name="userStore.nickname" :size="68" />
          <div class="welcome">
            <p class="hello">{{ goodTimeText() }}！{{ userStore.nickname }}</p>
            <p>北海虽赊，扶摇可接；东隅已逝，桑榆非晚。</p>
          </div>
        </a-space>
      </a-col>
      <a-col :xs="24" :sm="10" :md="10" :lg="10" :xl="10">
        <div class="notice-panel">
          <div class="notice-header">
            <span class="notice-title">公&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;告</span>
            <a-link class="notice-more" @click="openMessage">更多</a-link>
          </div>
          <a-skeleton v-if="loading" :loading="loading" :animation="true">
            <a-skeleton-line :rows="2" />
          </a-skeleton>
          <div v-else-if="dataList.length === 0" class="notice-empty">暂无公告</div>
          <div v-else class="notice-viewport" @mouseenter="paused = true" @mouseleave="paused = false">
            <div
              class="notice-track"
              :class="{ paused, scroll: needScroll }"
              :style="needScroll ? { animationDuration: `${Math.max(dataList.length * 3, 6)}s` } : undefined"
            >
              <div
                v-for="(item, idx) in displayList"
                :key="`${item.id}-${idx}`"
                class="notice-item"
                @click="onDetail(item.id)"
              >
                <div class="notice-main">
                  <span class="notice-dot" :class="`level-${item.level}`" />
                  <span class="notice-label" :class="`level-${item.level}`">{{ item.label }}：</span>
                  <span class="notice-text">{{ item.title }}</span>
                  <span v-if="item.isTop" class="notice-tag">置顶</span>
                </div>
                <span
                  v-if="item.timeText"
                  class="notice-time"
                  :title="item.publishTime"
                >{{ item.timeText }}</span>
              </div>
            </div>
          </div>
        </div>
      </a-col>
    </a-row>
  </a-card>
</template>

<script setup lang="ts">
import { listDashboardNotice } from '@/apis'
import { useUserStore } from '@/stores'
import { goodTimeText } from '@/utils'
import {
  mapDashboardNotice,
  pickDashboardNotices,
  type NoticeTickerItem,
} from '../../utils/noticeTicker'

const userStore = useUserStore()
const router = useRouter()

const dataList = ref<NoticeTickerItem[]>([])
const loading = ref(false)
const paused = ref(false)

const needScroll = computed(() => dataList.value.length > 1)

/** 列表复制一份用于无缝滚动 */
const displayList = computed(() => {
  if (!needScroll.value) {
    return dataList.value
  }
  return [...dataList.value, ...dataList.value]
})

const loadNotice = async () => {
  loading.value = true
  try {
    const { data } = await listDashboardNotice()
    dataList.value = pickDashboardNotices(data, 20).map(mapDashboardNotice)
  } finally {
    loading.value = false
  }
}

const onDetail = (id: string | number) => {
  router.push({ path: '/user/notice', query: { id: String(id) } })
}

const openMessage = () => {
  router.push({ path: '/user/message', query: { tab: 'notice' } })
}

onMounted(() => {
  loadNotice()
})
</script>

<style scoped lang="scss">
:deep(.arco-statistic-title) {
  margin-bottom: 0;
}

.card {
  .content {
    padding: 8px 20px;
    .welcome {
      margin: 8px 0;
      color: $color-text-3;
      .hello {
        font-size: 1.25rem;
        color: $color-text-1;
        margin-bottom: 10px;
      }
    }
  }
}

.notice-panel {
  min-height: 68px;
  padding-left: 12px;
  border-left: 1px solid var(--color-border-2);

  .notice-header {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 8px;
    padding: 0 24px;
    box-sizing: border-box;

    .notice-title {
      font-size: 1.25rem;
      font-weight: 600;
      line-height: 1.2;
      color: var(--color-text-1);
    }

    .notice-more {
      position: absolute;
      right: 24px;
      top: 50%;
      transform: translateY(-50%);
    }
  }
}

.notice-empty {
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-text-3);
  font-size: 16px;
}

.notice-viewport {
  height: 56px;
  overflow: hidden;
  width: 100%;
  max-width: 450px;
  margin: 0 auto;
  box-sizing: border-box;
}

.notice-track {
  &.scroll {
    animation-name: notice-scroll;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
  }

  &.paused {
    animation-play-state: paused;
  }
}

.notice-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 28px;
  gap: 12px;
  cursor: pointer;
  padding: 0 8px 0 12px;
  min-width: 0;

  .notice-main {
    display: flex;
    align-items: center;
    gap: 8px;
    min-width: 0;
    flex: 1;
  }

  .notice-dot {
    flex-shrink: 0;
    width: 9px;
    height: 9px;
    border-radius: 2px;

    &.level-primary {
      background: rgb(var(--arcoblue-6));
    }
    &.level-success {
      background: rgb(var(--green-6));
    }
    &.level-warning {
      background: rgb(var(--orangered-6));
    }
    &.level-error {
      background: rgb(var(--red-6));
    }
    &.level-default {
      background: rgb(var(--gray-6));
    }
  }

  .notice-label {
    flex-shrink: 0;
    font-size: 16px;
    font-weight: 600;

    &.level-primary {
      color: rgb(var(--arcoblue-6));
    }
    &.level-success {
      color: rgb(var(--green-6));
    }
    &.level-warning {
      color: rgb(var(--orangered-6));
    }
    &.level-error {
      color: rgb(var(--red-6));
    }
    &.level-default {
      color: rgb(var(--gray-8));
    }
  }

  .notice-text {
    flex: 1;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    color: var(--color-text-1);
    font-size: 16px;
  }

  .notice-tag {
    flex-shrink: 0;
    padding: 0 6px;
    height: 18px;
    line-height: 18px;
    border-radius: 2px;
    font-size: 12px;
    color: rgb(var(--red-6));
    background: rgba(var(--red-6), 0.1);
    border: 1px solid rgba(var(--red-6), 0.35);
  }

  .notice-time {
    flex-shrink: 0;
    font-size: 13px;
    color: var(--color-text-3);
    font-variant-numeric: tabular-nums;
    letter-spacing: 0.2px;
  }

  &:hover {
    .notice-text {
      color: rgb(var(--arcoblue-6));
    }
  }
}

@keyframes notice-scroll {
  0% {
    transform: translateY(0);
  }
  100% {
    transform: translateY(-50%);
  }
}

@media (max-width: 575px) {
  .notice-panel {
    margin-top: 12px;
    padding-left: 0;
    border-left: none;
  }
}
</style>
