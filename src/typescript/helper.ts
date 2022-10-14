type RequestIdleCallbackHandle = any
type RequestIdleCallbackOptions = {
  timeout: number
}
type RequestIdleCallbackDeadline = {
  readonly didTimeout: boolean
  timeRemaining: () => number
}

declare global {
  interface Window {
    requestIdleCallback: (
      callback: (deadline: RequestIdleCallbackDeadline) => void,
      opts?: RequestIdleCallbackOptions
    ) => RequestIdleCallbackHandle
    cancelIdleCallback: (handle: RequestIdleCallbackHandle) => void
  }
}

export function debounce(func: any) {
  // this is required since, safari and opera do not provide this interfaces ...
  if (!window.cancelIdleCallback || !window.requestIdleCallback) return func

  let token: any
  return function () {
    const later = () => {
      token = null
      func.apply(null, arguments)
    }
    window.cancelIdleCallback(token)
    token = window.requestIdleCallback(later)
  }
}

export function allowedProtocol(url: string) {
  return (
    url.startsWith('https://') ||
    url.startsWith('http://') ||
    url.startsWith('file://') ||
    url.startsWith('hyper://') ||
    url.startsWith('dat://') ||
    url.startsWith('ipfs://') ||
    url.startsWith('ipns://') ||
    url.startsWith('blob:')
  )
}

export const PROXY = 'https://api.allorigins.win/get?url='
