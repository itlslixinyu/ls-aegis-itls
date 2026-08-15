import { viteMockServe } from 'vite-plugin-mock'

export default function createMock(env, isBuild) {
  const { VITE_BUILD_MOCK, VITE_LOCAL_MOCK } = env
  // 本地默认关闭；显式 VITE_LOCAL_MOCK=true 才启用，避免误走 mock
  const localEnabled = VITE_LOCAL_MOCK === 'true'
  return viteMockServe({
    mockPath: 'src/mock', // 目录位置
    logger: !isBuild, // 是否在控制台显示请求日志
    supportTs: true, // 是否读取 ts 文件模块
    localEnabled,
    prodEnabled: isBuild && VITE_BUILD_MOCK === 'true', // 是否打包启用 mock
    // 关闭 mock 时不让 mock 打进最终产物
    injectCode: `
          import { setupProdMockServer } from '../src/mock/index';
          setupProdMockServer();
        `,
  })
}
