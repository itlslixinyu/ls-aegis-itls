<template>
  <a-card title="第三方账号" bordered class="gradient-card">
    <a-alert type="warning" :show-icon="true">
      社交账号绑定默认关闭（justauth.enabled=false）。如需启用，请在服务端配置 JustAuth 并设置环境变量后重启。
    </a-alert>
  </a-card>
</template>

<script setup lang="ts">
defineOptions({ name: 'UserSocial' })
</script>

<style scoped lang="scss"></style>
