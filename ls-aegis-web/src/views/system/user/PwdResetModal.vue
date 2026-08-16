<template>
  <a-modal
    v-model:visible="visible"
    title="重置密码"
    :mask-closable="false"
    :esc-to-close="false"
    :width="width >= 500 ? 500 : '100%'"
    draggable
    @before-ok="save"
    @close="reset"
  >
    <!-- 供浏览器/密码管理器关联账号，避免 DOM 无提示 -->
    <input
      type="text"
      name="username"
      autocomplete="username"
      :value="username"
      tabindex="-1"
      aria-hidden="true"
      class="pwd-reset-username"
      readonly
    >
    <GiForm ref="formRef" v-model="form" :columns="columns" />
  </a-modal>
</template>

<script setup lang="ts">
import { Message } from '@arco-design/web-vue'
import { useWindowSize } from '@vueuse/core'
import { resetUserPwd } from '@/apis/system'
import { type ColumnItem, GiForm } from '@/components/GiForm'
import { useResetReactive } from '@/hooks'
import { encryptTransport } from '@/utils/encrypt'

const emit = defineEmits<{
  (e: 'save-success'): void
}>()

const { width } = useWindowSize()
const dataId = ref('')
const username = ref('')
const visible = ref(false)
const formRef = ref<InstanceType<typeof GiForm>>()

const [form, resetForm] = useResetReactive({})

const columns: ColumnItem[] = reactive([
  {
    label: '密码',
    field: 'newPassword',
    type: 'input-password',
    span: 24,
    required: true,
    props: {
      autocomplete: 'new-password',
    },
  },
])

// 重置
const reset = () => {
  formRef.value?.formRef?.resetFields()
  resetForm()
  username.value = ''
}

// 保存
const save = async () => {
  try {
    const isInvalid = await formRef.value?.formRef?.validate()
    if (isInvalid) return false
    await resetUserPwd({ newPassword: await encryptTransport(form.newPassword) || '' }, dataId.value)
    Message.success('重置成功，用户下次登录须修改密码')
    emit('save-success')
    return true
  } catch (error) {
    return false
  }
}

// 打开
const onOpen = (id: string, name?: string) => {
  reset()
  dataId.value = id
  username.value = name || ''
  visible.value = true
}

defineExpose({ onOpen })
</script>

<style scoped lang="scss">
.pwd-reset-username {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
</style>
