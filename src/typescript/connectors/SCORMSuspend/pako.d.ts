// pako ships without typings; only the two functions the codec uses.
declare module 'pako' {
  export function deflateRaw(
    data: Uint8Array | string,
    options?: { level?: number }
  ): Uint8Array
  export function inflateRaw(data: Uint8Array): Uint8Array
}
