<template>
  <VCharts ref="chart" :option="option" :autoresize="autoResize" :style="{ width, height }" />
</template>

<script setup lang="ts">
import VCharts from 'vue-echarts'

defineProps({
  option: {
    type: Object,
    default() {
      return {}
    },
  },
  autoResize: {
    type: Boolean,
    default: true,
  },
  width: {
    type: String,
    default: '100%',
  },
  height: {
    type: String,
    default: '100%',
  },
})

const chart = ref(null)
defineExpose({
  chart,
})
</script>

<style scoped lang="less"></style>
