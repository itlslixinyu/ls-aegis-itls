<template>
  <a-carousel
    indicator-type="slider"
    show-arrow="hover"
    auto-play
    style="width: 100%; height: 150px; border-radius: 4px; overflow: hidden"
  >
    <a-carousel-item v-for="(item, idx) in dataList" :key="idx">
      <div class="banner-item" :style="{ background: item.bg }">
        <div class="title">{{ item.name }}</div>
        <div class="desc">{{ item.desc }}</div>
      </div>
    </a-carousel-item>
  </a-carousel>
</template>

<script setup lang="ts">
const dataList = [
  {
    name: 'LS Aegis',
    desc: '前后端分离中后台平台',
    bg: 'linear-gradient(135deg, rgb(var(--primary-6)), rgb(var(--primary-4)))',
  },
  {
    name: '模块化扩展',
    desc: 'rbac / file / sms / notice / tenant / schedule',
    bg: 'linear-gradient(135deg, rgb(var(--success-6)), rgb(var(--success-4)))',
  },
]
</script>

<style scoped lang="less">
.banner-item {
  width: 100%;
  height: 150px;
  color: #fff;
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 0 24px;
  box-sizing: border-box;
  .title {
    font-size: 22px;
    font-weight: 600;
  }
  .desc {
    margin-top: 8px;
    opacity: 0.9;
  }
}
</style>
