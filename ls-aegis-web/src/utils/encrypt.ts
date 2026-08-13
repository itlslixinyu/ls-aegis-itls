import Base64 from 'crypto-js/enc-base64'
import UTF8 from 'crypto-js/enc-utf8'
import CryptoJS from 'crypto-js'
import { sm2, sm3, sm4 } from 'sm-crypto'
import { getGmPublicKey } from '@/apis/auth'

export function encodeByBase64(txt: string) {
  return UTF8.parse(txt).toString(Base64)
}

export function decodeByBase64(txt: string) {
  return Base64.parse(txt).toString(UTF8)
}

/** SM3 摘要（小写十六进制） */
export function encryptBySm3(txt: string) {
  return sm3(txt)
}

/** @deprecated 请使用 encryptBySm3 */
export function encryptByMd5(txt: string) {
  return encryptBySm3(txt)
}

/** SM2 公钥十六进制（含 04），由后端下发 */
let sm2PublicKeyHex = ''
/** 与后端 gm.enable 同步，决定行为验证码用 SM4 还是 AES */
let gmEnabled = false

function utf8ToHex(str: string) {
  return Array.from(new TextEncoder().encode(str))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

function hexToBase64(hex: string) {
  const bytes = hex.match(/.{1,2}/g)?.map((h) => Number.parseInt(h, 16)) ?? []
  let binary = ''
  for (const b of bytes) {
    binary += String.fromCharCode(b)
  }
  return btoa(binary)
}

/** 拉取并缓存国密公钥与启用状态 */
export async function loadGmPublicKey() {
  try {
    const { data: body } = await getGmPublicKey()
    const payload = (body as any)?.data ?? body
    gmEnabled = !!payload?.enable
    if (payload?.enable && payload.publicKeyHex) {
      sm2PublicKeyHex = payload.publicKeyHex
      return true
    }
    sm2PublicKeyHex = ''
  } catch {
    sm2PublicKeyHex = ''
    gmEnabled = false
  }
  return false
}

/** 当前是否启用国密（依赖 loadGmPublicKey） */
export function isGmEnabled() {
  return gmEnabled
}

/** 确保公钥已加载，失败抛错 */
export async function ensureGmPublicKey() {
  if (sm2PublicKeyHex) {
    return
  }
  const ok = await loadGmPublicKey()
  if (!ok || !sm2PublicKeyHex) {
    throw new Error('国密公钥加载失败，请刷新页面重试')
  }
}

/**
 * SM2 传输加密（C1C3C2）
 * sm-crypto 输出不含未压缩点前缀 04，BouncyCastle SM2Engine 解密需要带 04，此处统一补齐。
 */
export function encryptBySm2(txt: string) {
  if (!sm2PublicKeyHex) {
    console.error('国密 SM2 公钥未加载，无法加密传输')
    return ''
  }
  const cipher = sm2.doEncrypt(txt, sm2PublicKeyHex, 1)
  if (!cipher) {
    return ''
  }
  return cipher.startsWith('04') ? cipher : `04${cipher}`
}

/** 异步：先确保公钥再 SM2 加密（登录/改密请用此方法） */
export async function encryptTransport(txt: string) {
  await ensureGmPublicKey()
  const cipher = encryptBySm2(txt)
  if (!cipher) {
    throw new Error('国密加密失败')
  }
  return cipher
}

/** @deprecated 兼容旧调用名，实际为 SM2 */
export function encryptByRsa(txt: string) {
  return encryptBySm2(txt)
}

/**
 * 行为验证码坐标加密：整体国密下 SM4/ECB/PKCS7（Base64）；仅 gm.enable=false 时回退 AES。
 */
export function encryptByCaptcha(word: string, keyWord: string) {
  if (!keyWord) {
    return word
  }
  if (gmEnabled) {
    return encryptBySm4Ecb(word, keyWord)
  }
  console.warn('国密未启用，行为验证码回退 AES')
  return encryptByAes(word, keyWord)
}

/** SM4/ECB，密钥为 UTF-8 的 16 字节 secretKey，输出 Base64 */
export function encryptBySm4Ecb(word: string, keyWord: string) {
  const cipherHex = sm4.encrypt(word, utf8ToHex(keyWord))
  return hexToBase64(cipherHex)
}

const defaultKeyWork = 'XwKsGlMcdPMEhR1B'

/**
 * AES/ECB（仅 gm.enable=false 时行为验证码回退使用）
 */
export function encryptByAes(word: string, keyWord = defaultKeyWork) {
  const key = CryptoJS.enc.Utf8.parse(keyWord)
  const arcs = CryptoJS.enc.Utf8.parse(word)
  const encrypted = CryptoJS.AES.encrypt(arcs, key, {
    mode: CryptoJS.mode.ECB,
    padding: CryptoJS.pad.Pkcs7,
  })
  return encrypted.toString()
}
