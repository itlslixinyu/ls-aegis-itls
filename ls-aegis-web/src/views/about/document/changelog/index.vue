<template>
  <a-card title="更新日志" :bordered="false">
    <a-typography-paragraph>
      LS Aegis 平台版本记录将在此维护。当前版本：1.0.0-SNAPSHOT。
    </a-typography-paragraph>
    <a-timeline>
      <a-timeline-item label="1.0.0-SNAPSHOT">完成平台骨架、模块拆分与本地联调。</a-timeline-item>
    </a-timeline>
  </a-card>
</template>

<script lang="ts" setup>
defineOptions({ name: 'AboutDocumentChangelog' })
</script>
