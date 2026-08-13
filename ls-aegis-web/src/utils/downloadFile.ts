import { assertSafeDownloadUrl } from '@/utils/safeUrl'

/**
 * 根据文件url获取文件名
 * @param url 文件url
 */
function getFileName(url: string) {
  const num = url.lastIndexOf('/') + 1
  let fileName = url.substring(num)
  // 把参数和文件名分割开
  fileName = decodeURI(fileName.split('?')[0])
  return fileName
}

/**
 * 根据文件地址下载文件
 * @param {*} sUrl
 */
export function downloadByUrl({
  url,
  target = '_blank',
  fileName,
}: {
  url: string
  target?: '_self' | '_blank'
  fileName?: string
}): Promise<boolean> {
  const parsed = assertSafeDownloadUrl(url)
  const safeUrl = parsed.href
  // 是否同源
  const isSameHost = parsed.host === location.host
  return new Promise<boolean>((resolve, reject) => {
    if (isSameHost) {
      // 同源资源，直接使用 <a> 标签下载
      const link = document.createElement('a')
      link.href = safeUrl
      link.target = target
      link.rel = 'noopener noreferrer'

      if (link.download !== undefined) {
        link.download = fileName || getFileName(safeUrl)
      }

      if (document.createEvent) {
        const e = document.createEvent('MouseEvents')
        e.initEvent('click', true, true)
        link.dispatchEvent(e)
        return resolve(true)
      }

      let openUrl = safeUrl
      if (!openUrl.includes('?')) {
        openUrl += '?download'
      }

      window.open(openUrl, target, 'noopener,noreferrer')
      return resolve(true)
    } else {
      // 跨域资源，使用 fetch 获取文件并下载（仅 http/https）
      fetch(safeUrl)
        .then((response) => response.blob())
        .then((blob) => {
          const link = document.createElement('a')
          link.href = URL.createObjectURL(blob)
          link.download = fileName || getFileName(safeUrl)
          link.style.display = 'none'
          document.body.appendChild(link)
          link.click()
          document.body.removeChild(link)
          URL.revokeObjectURL(link.href)
          resolve(true)
        })
        .catch((err) => {
          reject(err)
        })
    }
  })
}
