<template>
  <a-drawer
    v-model:visible="visible"
    :title="title"
    :mask-closable="false"
    :esc-to-close="false"
    :width="width >= 500 ? 500 : '100%'"
    @before-ok="save"
    @close="reset"
  >
    <a-alert v-if="isSystemUser" type="info" style="margin-bottom: 16px">
      系统内置用户：角色与状态不可变更；昵称、手机号、邮箱、性别、部门、描述可修改
    </a-alert>
    <GiForm ref="formRef" v-model="form" :columns="columns" />
  </a-drawer>
</template>

<script setup lang="ts">
import { Message, type TreeNodeData } from '@arco-design/web-vue'
import { useWindowSize } from '@vueuse/core'
import { addUser, getUser, updateUser } from '@/apis/system/user'
import { type ColumnItem, GiForm } from '@/components/GiForm'
import type { Gender, LabelValueState, Status } from '@/types/global'
import { GenderList } from '@/constant/common'
import { useResetReactive } from '@/hooks'
import { useDept, useRole } from '@/hooks/app'
import { encryptTransport } from '@/utils/encrypt'

const emit = defineEmits<{
  (e: 'save-success'): void
}>()

const { width } = useWindowSize()

const dataId = ref('')
const visible = ref(false)
const isUpdate = computed(() => !!dataId.value)
const title = computed(() => (isUpdate.value ? '修改用户' : '新增用户'))
const formRef = ref<InstanceType<typeof GiForm>>()
const { roleList, getRoleList } = useRole()
const { deptList, getDeptList } = useDept()

const [form, resetForm] = useResetReactive({
  nickname: undefined as string | undefined,
  username: undefined as string | undefined,
  password: undefined as string | undefined,
  phone: undefined as string | undefined,
  email: undefined as string | undefined,
  gender: 1 as Gender,
  deptId: undefined as string | number | undefined,
  roleIds: [] as Array<string | number>,
  description: undefined as string | undefined,
  status: 1 as Status,
  isSystem: false,
})

/** 系统内置用户（如 admin） */
const isSystemUser = computed(() => !!form.isSystem)

const columns: ColumnItem[] = reactive([
  {
    label: '昵称',
    field: 'nickname',
    type: 'input',
    span: 24,
    required: true,
    props: {
      maxLength: 30,
    },
  },
  {
    label: '用户名',
    field: 'username',
    type: 'input',
    span: 24,
    required: true,
    props: {
      maxLength: 64,
    },
    disabled: () => isUpdate.value,
  },
  {
    label: '密码',
    field: 'password',
    type: 'input-password',
    span: 24,
    required: true,
    props: {
      maxLength: 32,
      showWordLimit: true,
    },
    hide: () => isUpdate.value,
  },
  {
    label: '手机号码',
    field: 'phone',
    type: 'input',
    span: 24,
    props: {
      maxLength: 11,
      allowClear: true,
    },
  },
  {
    label: '邮箱',
    field: 'email',
    type: 'input',
    span: 24,
    props: {
      maxLength: 255,
      allowClear: true,
    },
  },
  {
    label: '性别',
    field: 'gender',
    type: 'radio-group',
    span: 24,
    props: {
      options: GenderList,
    },
  },
  {
    label: '所属部门',
    field: 'deptId',
    type: 'tree-select',
    span: 24,
    required: true,
    props: {
      data: deptList,
      allowClear: true,
      allowSearch: true,
      fallbackOption: false,
      filterTreeNode(searchKey: string, nodeData: TreeNodeData) {
        if (nodeData.title) {
          return nodeData.title.toLowerCase().includes(searchKey.toLowerCase())
        }
        return false
      },
    },
  },
  {
    label: '角色',
    field: 'roleIds',
    type: 'select',
    span: 24,
    required: true,
    props: {
      options: roleList,
      multiple: true,
      allowClear: true,
      allowSearch: true,
    },
    disabled: () => isSystemUser.value,
  },
  {
    label: '描述',
    field: 'description',
    type: 'textarea',
    span: 24,
  },
  {
    label: '状态',
    field: 'status',
    type: 'switch',
    span: 24,
    props: {
      type: 'round',
      checkedValue: 1,
      uncheckedValue: 2,
      checkedText: '启用',
      uncheckedText: '禁用',
    },
    disabled: () => isSystemUser.value,
  },
])

/** 角色字典会排除超级管理员等内置角色，编辑时需补回已选角色，否则下拉只显示 ID */
const mergeSelectedRoles = (roleIds?: Array<string | number>, roleNames?: string[]) => {
  if (!roleIds?.length) return
  const exist = new Set(roleList.value.map((item) => String(item.value)))
  roleIds.forEach((roleId, index) => {
    const key = String(roleId)
    if (exist.has(key)) return
    const option: LabelValueState = {
      label: roleNames?.[index] || key,
      value: roleId,
    }
    roleList.value.push(option)
    exist.add(key)
  })
}

/** 密文/非法手机号不回填，避免无法编辑且提交校验失败 */
const normalizePhone = (phone?: string | null) => {
  if (!phone) return undefined
  return /^1\d{10}$/.test(phone) ? phone : undefined
}

/** 非法邮箱不回填 */
const normalizeEmail = (email?: string | null) => {
  if (!email) return undefined
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ? email : undefined
}

// 重置
const reset = () => {
  formRef.value?.formRef?.resetFields()
  resetForm()
}

// 保存
const save = async () => {
  const rawPassword = form.password
  try {
    const isInvalid = await formRef.value?.formRef?.validate()
    if (isInvalid) return false
    const payload = {
      nickname: form.nickname,
      username: form.username,
      password: form.password,
      phone: form.phone || null,
      email: form.email || null,
      gender: form.gender,
      deptId: form.deptId,
      roleIds: form.roleIds,
      description: form.description,
      status: form.status,
    }
    if (isUpdate.value) {
      await updateUser(payload, dataId.value)
      Message.success('修改成功')
    } else {
      if (rawPassword) {
        payload.password = await encryptTransport(rawPassword) || ''
      }
      await addUser(payload)
      Message.success('新增成功')
    }
    emit('save-success')
    return true
  } catch (error) {
    form.password = rawPassword
    return false
  }
}

// 新增
const onAdd = async () => {
  reset()
  if (!deptList.value.length) {
    await getDeptList()
  }
  if (!roleList.value.length) {
    await getRoleList()
  }
  dataId.value = ''
  visible.value = true
}

// 修改
const onUpdate = async (id: string) => {
  reset()
  dataId.value = id
  if (!deptList.value.length) {
    await getDeptList()
  }
  if (!roleList.value.length) {
    await getRoleList()
  }
  const { data } = await getUser(id)
  // 只写入可编辑字段，绝不带入 disabled（否则整表会被禁用）
  form.nickname = data.nickname
  form.username = data.username
  form.phone = normalizePhone(data.phone)
  form.email = normalizeEmail(data.email)
  form.gender = data.gender as Gender
  form.deptId = data.deptId
  form.roleIds = data.roleIds || []
  form.description = data.description
  form.status = data.status
  form.isSystem = !!data.isSystem
  mergeSelectedRoles(data.roleIds, data.roleNames)
  visible.value = true
}

defineExpose({ onAdd, onUpdate })
</script>

<style scoped lang="scss"></style>
