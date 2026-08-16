<template>
  <GiTable
    ref="giTableRef"
    v-bind="forwardAttrs"
    :class="['base-table', attrs.class]"
    :columns="normalizedColumns"
    :scroll="mergedScroll"
  >
    <template v-for="(_, name) in slots" :key="name" #[name]="scope">
      <slot :name="name" v-bind="scope || {}" />
    </template>
  </GiTable>
</template>

<script setup lang="ts">
import { computed, useAttrs, useSlots, useTemplateRef } from 'vue'
import type { TableColumnData } from '@arco-design/web-vue'
import { mergeTableScroll, normalizeTableColumns, sumTableColumnsWidth } from '@/utils/tableHelper'

defineOptions({ name: 'BaseTable', inheritAttrs: false })

const props = defineProps<{
  columns?: TableColumnData[]
  scroll?: { x?: number | string; y?: number | string; minWidth?: number }
}>()

const attrs = useAttrs()
const slots = useSlots()
const giTableRef = useTemplateRef('giTableRef')

const normalizedColumns = computed(() => normalizeTableColumns((props.columns || []) as any))

const mergedScroll = computed(() => mergeTableScroll(props.scroll, normalizedColumns.value as any))

const tableWidthCss = computed(() => `${sumTableColumnsWidth(normalizedColumns.value as any)}px`)

const forwardAttrs = computed(() => {
  const rest = { ...attrs } as Record<string, unknown>
  delete rest.columns
  delete rest.scroll
  delete rest.class
  return rest
})

defineExpose({
  /** 透传底层 a-table，供 expandAll 等调用 */
  get tableRef() {
    return giTableRef.value?.tableRef
  },
})
</script>

<style scoped lang="scss">
.base-table {
  width: 100%;

  // 容器更宽时右侧留白，不把空白均分进各列
  :deep(.arco-table-element) {
    width: v-bind(tableWidthCss) !important;
  }

  :deep(.arco-table-td) {
    vertical-align: middle;
  }
}
</style>
