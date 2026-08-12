<template>
  <a-card class="general-card" title="我的项目">
    <a-row :gutter="[14, 14]">
      <a-col
        v-for="(item, index) in list"
        :key="index"
        :xs="24"
        :sm="24"
        :md="12"
        :lg="12"
        :xl="8"
        :xxl="8"
      >
        <a-card :bordered="true" hoverable>
          <div class="badge badge-right" :style="`background-color: ${item.statusColor}`">{{ item.status }}</div>
          <a-card-meta>
            <template #title>
              <a-space>
                <a-avatar :size="25" :style="{ backgroundColor: item.avatarColor }">{{ item.short }}</a-avatar>
                <a-typography-paragraph
                  :ellipsis="{
                    rows: 1,
                    showTooltip: true,
                    css: true,
                  }"
                >
                  {{ item.alias }}
                </a-typography-paragraph>
              </a-space>
            </template>
            <template #description>
              <a-typography-paragraph
                :ellipsis="{
                  rows: 2,
                  showTooltip: true,
                  css: true,
                }"
              >
                <a-typography-text type="secondary">
                  {{ item.desc }}
                </a-typography-text>
              </a-typography-paragraph>
            </template>
          </a-card-meta>
        </a-card>
      </a-col>
    </a-row>
  </a-card>
</template>

<script setup lang="ts">
const list = [
  {
    alias: 'LS Aegis Platform',
    short: 'P',
    desc: '后端 Maven 多模块工程：权限、安全、业务扩展与启动入口。',
    status: '迭代',
    statusColor: 'rgb(var(--primary-6))',
    avatarColor: 'rgb(var(--primary-6))',
  },
  {
    alias: 'LS Aegis Web',
    short: 'W',
    desc: '前端 Vue3 + Arco Design 管理端，与后端同级独立部署。',
    status: '迭代',
    statusColor: 'rgb(var(--primary-6))',
    avatarColor: 'rgb(var(--success-6))',
  },
  {
    alias: '业务扩展模块',
    short: 'B',
    desc: '文件、短信、通知、租户、调度等 biz-* 模块，按需启用。',
    status: '迭代',
    statusColor: 'rgb(var(--primary-6))',
    avatarColor: 'rgb(var(--warning-6))',
  },
]
</script>

<style scoped lang="less">
:deep(.arco-card-body) {
  position: relative;
  overflow: hidden;
  .badge {
    position: absolute;
    font-size: 11px;
    height: 18px;
    line-height: 18px;
    text-align: center;
    width: 74px;
    color: #fff;
  }
  .badge-right {
    right: -20px;
    top: 8px;
    transform: rotate(45deg);
  }
}
</style>
