/**
 * MD5 of a string's UTF-8 bytes, as lowercase hex.
 *
 * Elm keys a code project's versions by `MD5.hex code`. A project rebuilt from
 * suspend_data uses the same keys, so the next run does not add a version.
 */

const S = [
  7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 5, 9, 14, 20, 5,
  9, 14, 20, 5, 9, 14, 20, 5, 9, 14, 20, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11,
  16, 23, 4, 11, 16, 23, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15,
  21,
]

const K = Array.from({ length: 64 }, (_, i) =>
  Math.floor(Math.abs(Math.sin(i + 1)) * 0x100000000) >>> 0
)

export function md5(text: string): string {
  const input = new TextEncoder().encode(text)
  const length = input.length

  // message + 0x80 + zero padding + 64-bit little-endian bit length
  const padded = new Uint8Array((((length + 8) >> 6) + 1) * 64)
  padded.set(input)
  padded[length] = 0x80

  const view = new DataView(padded.buffer)
  view.setUint32(padded.length - 8, (length * 8) >>> 0, true)
  view.setUint32(padded.length - 4, Math.floor(length / 0x20000000), true)

  let a0 = 0x67452301
  let b0 = 0xefcdab89
  let c0 = 0x98badcfe
  let d0 = 0x10325476

  const M = new Uint32Array(16)

  for (let offset = 0; offset < padded.length; offset += 64) {
    for (let i = 0; i < 16; i++) M[i] = view.getUint32(offset + i * 4, true)

    let a = a0
    let b = b0
    let c = c0
    let d = d0

    for (let i = 0; i < 64; i++) {
      let f: number
      let g: number

      if (i < 16) {
        f = (b & c) | (~b & d)
        g = i
      } else if (i < 32) {
        f = (d & b) | (~d & c)
        g = (5 * i + 1) % 16
      } else if (i < 48) {
        f = b ^ c ^ d
        g = (3 * i + 5) % 16
      } else {
        f = c ^ (b | ~d)
        g = (7 * i) % 16
      }

      const sum = (a + f + K[i] + M[g]) >>> 0
      a = d
      d = c
      c = b
      b = (b + ((sum << S[i]) | (sum >>> (32 - S[i])))) >>> 0
    }

    a0 = (a0 + a) >>> 0
    b0 = (b0 + b) >>> 0
    c0 = (c0 + c) >>> 0
    d0 = (d0 + d) >>> 0
  }

  const out = new DataView(new ArrayBuffer(16))
  out.setUint32(0, a0, true)
  out.setUint32(4, b0, true)
  out.setUint32(8, c0, true)
  out.setUint32(12, d0, true)

  return Array.from(new Uint8Array(out.buffer), (byte) =>
    byte.toString(16).padStart(2, '0')
  ).join('')
}
