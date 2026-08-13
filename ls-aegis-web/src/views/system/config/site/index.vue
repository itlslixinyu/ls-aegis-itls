<template>
  <div class="gi_page site-config">
    <a-spin :loading="loading" class="site-config__spin">
      <a-form
        ref="formRef"
        :model="form"
        :rules="rules"
        size="medium"
        layout="vertical"
        :disabled="!isUpdate"
        class="form"
      >
        <!-- 图片配置 -->
        <section class="block block--icons">
          <header class="block__head">
            <h3 class="block__title">图片配置</h3>
            <span class="block__sub">网站图标、系统 Logo、公安备案图标</span>
          </header>
          <a-row :gutter="15" class="block__body block__body--icons">
            <a-col :xs="24" :sm="8">
              <a-form-item field="SITE_FAVICON" label="网站图标" hide-asterisk>
                <div class="icon-slot">
                  <a-upload
                    :file-list="faviconFile ? [faviconFile] : []"
                    accept="image/*"
                    :show-file-list="false"
                    :custom-request="handleUploadFavicon"
                    @change="handleChangeFavicon"
                  >
                    <template #upload-button>
                      <div :class="['icon-slot__preview', { 'is-error': faviconFile?.status === 'error' }]">
                        <template v-if="faviconFile?.url">
                          <img :src="faviconFile.url" alt="favicon" />
                          <div v-if="isUpdate" class="icon-slot__mask"><IconEdit /></div>
                        </template>
                        <icon-upload v-else class="icon-slot__empty" />
                      </div>
                    </template>
                  </a-upload>
                  <span class="icon-slot__tip">浏览器页签</span>
                </div>
              </a-form-item>
            </a-col>
            <a-col :xs="24" :sm="8">
              <a-form-item field="SITE_LOGO" label="系统 Logo" hide-asterisk>
                <div class="icon-slot">
                  <a-upload
                    :file-list="logoFile ? [logoFile] : []"
                    accept="image/*"
                    :show-file-list="false"
                    :custom-request="handleUploadLogo"
                    @change="handleChangeLogo"
                  >
                    <template #upload-button>
                      <div :class="['icon-slot__preview', { 'is-error': logoFile?.status === 'error' }]">
                        <template v-if="logoFile?.url">
                          <img :src="logoFile.url" alt="Logo" />
                          <div v-if="isUpdate" class="icon-slot__mask"><IconEdit /></div>
                        </template>
                        <icon-upload v-else class="icon-slot__empty" />
                      </div>
                    </template>
                  </a-upload>
                  <span class="icon-slot__tip">系统主体</span>
                </div>
              </a-form-item>
            </a-col>
            <a-col :xs="24" :sm="8">
              <a-form-item field="SITE_BEIAN_GONGAN_ICON" label="公安备案图标" hide-asterisk>
                <div class="icon-slot">
                  <a-upload
                    :file-list="gonganIconFile ? [gonganIconFile] : []"
                    accept="image/*"
                    :show-file-list="false"
                    :custom-request="handleUploadGonganIcon"
                    @change="handleChangeGonganIcon"
                  >
                    <template #upload-button>
                      <div :class="['icon-slot__preview', { 'is-error': gonganIconFile?.status === 'error' }]">
                        <template v-if="gonganIconFile?.url">
                          <img :src="gonganIconFile.url" alt="公安备案图标" />
                          <div v-if="isUpdate" class="icon-slot__mask"><IconEdit /></div>
                        </template>
                        <icon-upload v-else class="icon-slot__empty" />
                      </div>
                    </template>
                  </a-upload>
                  <span class="icon-slot__tip">备案查询</span>
                </div>
              </a-form-item>
            </a-col>
          </a-row>
        </section>

        <!-- 系统信息 -->
        <section class="block block--brand">
          <header class="block__head">
            <h3 class="block__title">系统信息</h3>
            <span class="block__sub">名称、公司与页面文案</span>
          </header>
          <div class="block__body fields-grid">
            <a-row :gutter="56" class="fields-grid__row">
              <a-col :xs="24" :md="12">
                <a-form-item field="SITE_TITLE" label="系统名称">
                  <a-input v-model="form.SITE_TITLE" placeholder="浏览器标题栏、登录页顶栏，最多 48 字" :max-length="48" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :md="12">
                <a-form-item field="SITE_TITLE_SHORT" label="系统简称">
                  <a-input v-model="form.SITE_TITLE_SHORT" placeholder="侧栏 Logo 旁，最多 8 字" :max-length="8" />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="56" class="fields-grid__row">
              <a-col :xs="24" :md="12">
                <a-form-item field="SITE_COMPANY" label="公司名称">
                  <a-input v-model="form.SITE_COMPANY" placeholder="登录页等处显示，最多 32 字" :max-length="32" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :md="12">
                <a-form-item field="SITE_COMPANY_SHORT" label="公司简称">
                  <a-input v-model="form.SITE_COMPANY_SHORT" placeholder="最多 8 字" :max-length="8" />
                </a-form-item>
              </a-col>
            </a-row>
            <a-row :gutter="56" class="fields-grid__row">
              <a-col :xs="24" :md="12">
                <a-form-item field="SITE_DESCRIPTION" label="系统描述">
                  <a-input v-model="form.SITE_DESCRIPTION" placeholder="用于 SEO" allow-clear />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :md="12">
                <a-form-item field="SITE_COPYRIGHT" label="版权声明">
                  <a-input v-model="form.SITE_COPYRIGHT" placeholder="页面底部显示" allow-clear />
                </a-form-item>
              </a-col>
            </a-row>
          </div>
        </section>

        <!-- 合规备案 -->
        <section class="block block--beian">
          <header class="block__head">
            <h3 class="block__title">合规备案</h3>
            <span class="block__sub">登录页底部备案信息</span>
          </header>
          <div class="block__body fields-grid">
            <a-row :gutter="56" class="fields-grid__row">
              <a-col :xs="24" :md="12">
                <a-form-item field="SITE_BEIAN" label="ICP 备案号">
                  <a-input v-model="form.SITE_BEIAN" placeholder="工信部备案编号，最多 40 字" :max-length="40" />
                </a-form-item>
              </a-col>
              <a-col :xs="24" :md="12">
                <a-form-item field="SITE_BEIAN_GONGAN" label="公安备案号">
                  <a-input v-model="form.SITE_BEIAN_GONGAN" placeholder="登录页底部显示，最多 48 字" :max-length="48" />
                </a-form-item>
              </a-col>
            </a-row>
          </div>
        </section>

        <div class="actions">
          <a-space size="medium">
            <a-button v-if="!isUpdate" v-permission="['system:siteConfig:update']" type="primary" @click="onUpdate">
              <template #icon><icon-edit /></template>修改
            </a-button>
            <a-button v-if="!isUpdate" v-permission="['system:siteConfig:update']" @click="onResetValue">
              <template #icon><icon-undo /></template>恢复默认
            </a-button>
            <a-button v-if="isUpdate" type="primary" @click="handleSave">
              <template #icon><icon-save /></template>保存
            </a-button>
            <a-button v-if="isUpdate" @click="reset">
              <template #icon><icon-refresh /></template>重置
            </a-button>
            <a-button v-if="isUpdate" @click="handleCancel">
              <template #icon><icon-undo /></template>取消
            </a-button>
          </a-space>
        </div>
      </a-form>
    </a-spin>
  </div>
</template>

<script setup lang="ts">
import { type FileItem, type FormInstance, Message, Modal, type RequestOption } from '@arco-design/web-vue'
import {
  type OptionResp,
  type SiteConfig,
  listOption,
  resetOptionValue,
  updateOption,
} from '@/apis/system'
import { useAppStore } from '@/stores'
import { useResetReactive } from '@/hooks'
import { fileToBase64 } from '@/utils'

defineOptions({ name: 'SystemSiteConfig' })

const loading = ref<boolean>(false)
const formRef = ref<FormInstance>()
const [form] = useResetReactive({
  SITE_FAVICON: '',
  SITE_LOGO: '',
  SITE_TITLE: '',
  SITE_TITLE_SHORT: '',
  SITE_COMPANY: '',
  SITE_COMPANY_SHORT: '',
  SITE_DESCRIPTION: '',
  SITE_COPYRIGHT: '',
  SITE_BEIAN: '',
  SITE_BEIAN_GONGAN: '',
  SITE_BEIAN_GONGAN_ICON: '',
})
const rules: FormInstance['rules'] = {
  SITE_TITLE: [{ required: true, message: '请输入系统名称' }],
  SITE_TITLE_SHORT: [
    { required: true, message: '请输入系统名称简称' },
    { maxLength: 8, message: '系统名称简称最多 8 个字' },
  ],
  SITE_COMPANY: [{ required: true, message: '请输入公司名称' }],
  SITE_COMPANY_SHORT: [
    { required: true, message: '请输入公司简称' },
    { maxLength: 8, message: '公司简称最多 8 个字' },
  ],
  SITE_DESCRIPTION: [{ required: true, message: '请输入系统描述' }],
  SITE_COPYRIGHT: [{ required: true, message: '请输入版权声明' }],
}

const siteConfig = ref<SiteConfig>({
  SITE_FAVICON: {},
  SITE_LOGO: {},
  SITE_TITLE: {},
  SITE_TITLE_SHORT: {},
  SITE_COMPANY: {},
  SITE_COMPANY_SHORT: {},
  SITE_DESCRIPTION: {},
  SITE_COPYRIGHT: {},
  SITE_BEIAN: {},
  SITE_BEIAN_GONGAN: {},
  SITE_BEIAN_GONGAN_ICON: {},
})
const faviconFile = ref<FileItem>({ uid: '-1' })
const logoFile = ref<FileItem>({ uid: '-2' })
const gonganIconFile = ref<FileItem>({ uid: '-3' })

const reset = () => {
  formRef.value?.resetFields()
  form.SITE_FAVICON = siteConfig.value.SITE_FAVICON?.value || ''
  form.SITE_LOGO = siteConfig.value.SITE_LOGO?.value || ''
  form.SITE_TITLE = siteConfig.value.SITE_TITLE?.value || ''
  form.SITE_TITLE_SHORT = siteConfig.value.SITE_TITLE_SHORT?.value || ''
  form.SITE_COMPANY = siteConfig.value.SITE_COMPANY?.value || ''
  form.SITE_COMPANY_SHORT = siteConfig.value.SITE_COMPANY_SHORT?.value || ''
  form.SITE_DESCRIPTION = siteConfig.value.SITE_DESCRIPTION?.value || ''
  form.SITE_COPYRIGHT = siteConfig.value.SITE_COPYRIGHT?.value || ''
  form.SITE_BEIAN = siteConfig.value.SITE_BEIAN?.value || ''
  form.SITE_BEIAN_GONGAN = siteConfig.value.SITE_BEIAN_GONGAN?.value || ''
  form.SITE_BEIAN_GONGAN_ICON = siteConfig.value.SITE_BEIAN_GONGAN_ICON?.value || ''
  faviconFile.value.url = siteConfig.value.SITE_FAVICON?.value
  logoFile.value.url = siteConfig.value.SITE_LOGO?.value
  gonganIconFile.value.url = siteConfig.value.SITE_BEIAN_GONGAN_ICON?.value || '/beian-gongan.png'
}

const isUpdate = ref(false)
const onUpdate = () => {
  isUpdate.value = true
}

const handleCancel = () => {
  reset()
  isUpdate.value = false
}

const queryForm = reactive({ category: 'SITE' })

const getDataList = async () => {
  loading.value = true
  const { data } = await listOption(queryForm)
  siteConfig.value = data.reduce((obj: SiteConfig, option: OptionResp) => {
    obj[option.code] = { ...option }
    return obj
  }, {})
  handleCancel()
  loading.value = false
}

const appStore = useAppStore()
const handleSave = async () => {
  const isInvalid = await formRef.value?.validate()
  if (isInvalid) return false
  await updateOption(
    Object.entries(form)
      .filter(([key]) => siteConfig.value[key as keyof SiteConfig]?.id)
      .map(([key, value]) => ({
        id: siteConfig.value[key as keyof SiteConfig].id,
        code: key,
        value,
      })),
  )
  appStore.setSiteConfig(form)
  await getDataList()
  Message.success('保存成功')
}

const handleResetValue = async () => {
  await resetOptionValue(queryForm)
  Message.success('恢复成功')
  await getDataList()
  appStore.setSiteConfig(form)
}
const onResetValue = () => {
  Modal.warning({
    title: '警告',
    content: '确认恢复基础配置为默认值吗？',
    hideCancel: false,
    maskClosable: false,
    onOk: handleResetValue,
  })
}

const handleUploadFavicon = (options: RequestOption) => {
  const controller = new AbortController()
  ;(async function requestWrap() {
    const { onProgress, onError, onSuccess, fileItem } = options
    onProgress(20)
    if (!fileItem.file) return
    fileToBase64(fileItem.file)
      .then((res) => {
        onSuccess()
        form.SITE_FAVICON = res
        Message.success('上传成功')
      })
      .catch((error) => onError(error))
  })()
  return { abort() { controller.abort() } }
}
const handleChangeFavicon = (_: any, currentFile: any) => {
  faviconFile.value = { ...currentFile }
}

const handleUploadLogo = (options: RequestOption) => {
  const controller = new AbortController()
  ;(async function requestWrap() {
    const { onProgress, onError, onSuccess, fileItem } = options
    onProgress(20)
    if (!fileItem.file) return
    fileToBase64(fileItem.file)
      .then((res) => {
        onSuccess()
        form.SITE_LOGO = res
        Message.success('上传成功')
      })
      .catch((error) => onError(error))
  })()
  return { abort() { controller.abort() } }
}
const handleChangeLogo = (_: any, currentFile: any) => {
  logoFile.value = { ...currentFile }
}

const handleUploadGonganIcon = (options: RequestOption) => {
  const controller = new AbortController()
  ;(async function requestWrap() {
    const { onProgress, onError, onSuccess, fileItem } = options
    onProgress(20)
    if (!fileItem.file) return
    fileToBase64(fileItem.file)
      .then((res) => {
        onSuccess()
        form.SITE_BEIAN_GONGAN_ICON = res
        Message.success('上传成功')
      })
      .catch((error) => onError(error))
  })()
  return { abort() { controller.abort() } }
}
const handleChangeGonganIcon = (_: any, currentFile: any) => {
  gonganIconFile.value = { ...currentFile }
}

onMounted(() => {
  getDataList()
})
</script>

<style scoped lang="scss">
.site-config {
  display: flex;
  flex-direction: column;
  width: 100%;
  height: 100%;
  min-height: 0;
  overflow: hidden !important;
  box-sizing: border-box;

  :deep(> .arco-spin),
  :deep(.site-config__spin) {
    display: flex;
    flex: 1;
    flex-direction: column;
    width: 100%;
    min-height: 0;
  }

  :deep(.arco-spin-children) {
    display: flex;
    flex: 1;
    flex-direction: column;
    width: 100%;
    min-height: 0;
  }

  .form {
    display: flex;
    flex: 1;
    flex-direction: column;
    width: 100%;
    min-height: 0;
    max-width: none;
    box-sizing: border-box;
    gap: 0;
  }
}

.block {
  width: 100%;
  flex: 0 0 auto;
  margin: 0;
  padding: 14px 20px 12px;
  border: 1px solid var(--color-border-2);
  border-radius: 10px;
  background: var(--color-bg-1);
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02);
  box-sizing: border-box;

  & + & {
    margin-top: 20px;
  }

  &--brand {
    flex: 0 0 auto;
  }

  &--icons {
    display: flex;
    flex-direction: column;
    height: 258px;
    padding-bottom: 14px;

    :deep(.arco-form-item) {
      margin-bottom: 0;
    }

    :deep(.arco-form-item-layout-vertical > .arco-form-item-label-col) {
      margin-bottom: 15px;
      height: 22px;
    }
  }

  &--beian {
    flex: 0 0 auto;
    padding-bottom: 37px;

    :deep(.arco-form-item) {
      margin-bottom: 0;
    }
  }

  &__head {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    flex: 0 0 auto;
    gap: 8px 12px;
    margin-bottom: 15px;
    padding-bottom: 15px;
    border-bottom: 1px solid var(--color-border-2);
  }

  &__title {
    position: relative;
    margin: 0;
    padding-left: 10px;
    font-size: 18px;
    font-weight: 600;
    color: var(--color-text-1);
    line-height: 1.3;

    &::before {
      content: '';
      position: absolute;
      left: 0;
      top: 50%;
      transform: translateY(-50%);
      width: 3px;
      height: 16px;
      border-radius: 2px;
      background: rgb(var(--primary-6));
    }
  }

  &__sub {
    font-size: 12px;
    color: var(--color-text-3);
    line-height: 1.3;
  }

  &__body {
    width: 100%;

    &--icons {
      flex: 1;
      display: flex;
      align-items: center;
      min-height: 0;
    }
  }
}

.fields-grid {
  width: 100%;
  max-width: 1024px;
  margin: 0 auto;

  &__row {
    width: 100%;
  }

  :deep(.arco-form-item-label-col),
  :deep(.arco-form-item-label) {
    justify-content: center;
    text-align: center;
  }

  :deep(.arco-input) {
    text-align: center;
  }
}

.icon-slot {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;

  &__preview {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 99px;
    height: 99px;
    border: 1px solid var(--color-border-2);
    border-radius: 12px;
    background: var(--color-fill-2);
    overflow: hidden;
    cursor: pointer;
    transition: border-color 0.15s ease, box-shadow 0.15s ease;

    &:hover {
      border-color: rgb(var(--primary-6));
      box-shadow: 0 0 0 2px rgba(var(--primary-6), 0.12);
    }

    &.is-error {
      border-color: rgb(var(--danger-6));
    }

    img {
      width: 100%;
      height: 100%;
      object-fit: contain;
      display: block;
    }
  }

  &__mask {
    position: absolute;
    inset: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #fff;
    background: rgba(0, 0, 0, 0.45);
    opacity: 0;
    transition: opacity 0.15s ease;
  }

  &__preview:hover &__mask {
    opacity: 1;
  }

  &__empty {
    font-size: 22px;
    color: var(--color-text-3);
  }

  &__tip {
    font-size: 12px;
    color: var(--color-text-3);
    line-height: 1.3;
    text-align: center;
  }
}

.block__body--icons {
  :deep(.arco-form-item) {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  :deep(.arco-form-item-label-col),
  :deep(.arco-form-item-label) {
    width: 100%;
    justify-content: center;
    text-align: center;
  }

  :deep(.arco-form-item-wrapper-col),
  :deep(.arco-form-item-content) {
    display: flex;
    justify-content: center;
    width: 100%;
  }
}

.actions {
  flex: 0 0 auto;
  display: flex;
  justify-content: flex-end;
  margin-top: auto;
  padding-top: 2px;
}

:deep(.form .arco-input-wrapper),
:deep(.form .arco-textarea-wrapper) {
  width: 100%;
  border-radius: 8px;
  background: var(--color-fill-2);
}

:deep(.form .arco-input-wrapper:hover),
:deep(.form .arco-input-wrapper.arco-input-focus) {
  background: var(--color-bg-1);
}

:deep(.arco-form-item) {
  margin-bottom: 15px;
}

:deep(.arco-form-item-layout-vertical > .arco-form-item-label-col) {
  margin-bottom: 15px;
  padding-bottom: 0;
}

:deep(.arco-form-item-label-col > .arco-form-item-label) {
  font-weight: 500;
  line-height: 1.3;
  color: var(--color-text-2);
}

:deep(.arco-row) {
  width: 100%;
}

:deep(.arco-col) {
  min-width: 0;
}
</style>
