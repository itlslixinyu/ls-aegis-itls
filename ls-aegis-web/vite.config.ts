import { URL, fileURLToPath } from 'node:url'
import { defineConfig, loadEnv } from 'vite'
import createVitePlugins from './config/plugins'

export default defineConfig(({ command, mode }) => {
  const env = loadEnv(mode, process.cwd()) as ImportMetaEnv
  const apiPrefix = env.VITE_API_PREFIX || '/api'

  return {
    // 开发或生产环境服务的公共基础路径
    base: env.VITE_BASE,
    // 路径别名
    resolve: {
      alias: {
        '~': fileURLToPath(new URL('./', import.meta.url)),
        '@': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },
    // 引入sass全局样式变量
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: `@use "@/styles/var.scss" as *;`,
          api: 'modern-compiler',
        },
      },
    },
    // 依赖预构建：加快冷启动与 HMR
    optimizeDeps: {
      include: [
        'vue',
        'vue-router',
        'pinia',
        'axios',
        'dayjs',
        'lodash-es',
        'echarts',
        '@arco-design/web-vue',
        '@arco-design/web-vue/es/icon',
        'vue-draggable-plus',
        '@vueuse/core',
        'query-string',
        'nprogress',
      ],
    },
    server: {
      host: true,
      port: 5173,
      strictPort: false,
      open: true,
      // 热更新
      hmr: {
        overlay: true,
      },
      // /api → Docker 后端 18000（见 .env.development）
      proxy: {
        [apiPrefix]: {
          target: env.VITE_API_BASE_URL,
          changeOrigin: true,
          secure: false,
          rewrite: (path) => path.replace(new RegExp(`^${apiPrefix}`), ''),
        },
      },
    },
    plugins: createVitePlugins(env, command === 'build'),
    // 构建（仅部署上线时执行 npm run build）
    build: {
      outDir: 'dist',
      sourcemap: false,
      // 关闭 gzip 体积统计，加快打包
      reportCompressedSize: false,
      chunkSizeWarningLimit: 2000,
      // esbuild 压缩明显快于 terser
      minify: 'esbuild',
      target: 'es2015',
      cssCodeSplit: true,
      rollupOptions: {
        output: {
          chunkFileNames: 'static/js/[name]-[hash].js',
          entryFileNames: 'static/js/[name]-[hash].js',
          assetFileNames: 'static/[ext]/[name]-[hash].[ext]',
          manualChunks(id) {
            if (!id.includes('node_modules')) {
              return
            }
            if (id.includes('echarts') || id.includes('zrender')) {
              return 'echarts'
            }
            if (id.includes('@arco-design')) {
              return 'arco'
            }
            if (
              id.includes('/vue/')
              || id.includes('/vue-router/')
              || id.includes('/pinia/')
              || id.includes('/@vue/')
            ) {
              return 'vue-vendor'
            }
            if (
              id.includes('lodash-es')
              || id.includes('dayjs')
              || id.includes('axios')
              || id.includes('query-string')
            ) {
              return 'utils'
            }
          },
        },
      },
    },
    esbuild: {
      // 生产构建去掉 console / debugger
      drop: command === 'build' ? ['console', 'debugger'] : [],
    },
    // 以 envPrefix 开头的环境变量会通过 import.meta.env 暴露在你的客户端源码中。
    envPrefix: ['VITE', 'FILE'],
  }
})
