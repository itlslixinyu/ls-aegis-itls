<template>
  <a-card
    class="general-card"
    title="帮助文档"
    :header-style="{ paddingBottom: 0 }"
    :body-style="{ paddingTop: '5px' }"
    style="height: 166px"
  >
    <a-row>
      <a-col v-for="link in links" :key="link.text" :span="12">
        <a-link :href="link.url">
          {{ link.text }}
        </a-link>
      </a-col>
    </a-row>
  </a-card>
</template>

<script setup lang="ts">
const links = [
  { text: '接口文档', url: '/about/document/api' },
  { text: '更新日志', url: '/about/document/changelog' },
  { text: '项目结构', url: '/about/document/api' },
  { text: 'Arco 组件', url: 'https://arco.design/vue/docs/start' },
]
</script>

<style lang="less" scoped>
.arco-card-body .arco-link {
  margin: 5px 0;
  color: rgb(var(--gray-8));
}
</style>
