// https://gun.eco/docs/API

type Gun = {
  get: (key: string) => Gun
  put: (data: Object, callback?: () => void) => Gun
  set: (data: Object, callback?: () => void) => Gun
  on: (
    callback: (data: { msg: string }, key: string) => void,
    option?: Object
  ) => void
  once: (
    callback: (data: { msg: string }, key: string) => void,
    option?: Object
  ) => void
}

declare global {
  interface Window {
    Gun?: ({
      peers,
      radisk,
      localStorage,
      uuid,
    }?: {
      peers?: string[]
      radisk?: boolean
      localStorage?: boolean
      uuid?: () => number
    }) => Gun
  }
}

export { Gun }
