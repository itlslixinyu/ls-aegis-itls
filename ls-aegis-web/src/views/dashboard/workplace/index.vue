<template>
  <div class="gi_page container">
    <div class="panel">
      <Welcome />
    </div>
    <div style="margin-top: 14px">
      <LatestActivity />
    </div>
  </div>
</template>

<script setup lang="ts">
import Welcome from './components/Welcome.vue'
import LatestActivity from './components/LatestActivity.vue'

defineOptions({ name: 'Workplace' })
</script>

<style scoped lang="scss">
.panel {
  background-color: var(--color-bg-2);
  border-radius: 4px;
  overflow: auto;
}
</style>
