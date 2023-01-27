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

export function debounce2(
  fn: (...params: any[]) => any,
  ms: number = 1000,
  immed: boolean = false
) {
  let timer: number | undefined = undefined

  return function (this: any, ...args: any[]) {
    if (timer === undefined && immed) {
      fn.apply(this, args)
    }
    clearTimeout(timer)
    return setTimeout(() => fn.apply(this, args), ms)
  }
}

export function throttle(cb: any, delay: number = 500) {
  let wait = false
  let storedArgs: any = null

  function checkStoredArgs() {
    if (storedArgs == null) {
      wait = false
    } else {
      cb(...storedArgs)
      storedArgs = null
      setTimeout(checkStoredArgs, delay)
    }
  }

  return (...args) => {
    if (wait) {
      storedArgs = args
      return
    }

    cb(...args)
    wait = true
    setTimeout(checkStoredArgs, delay)
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
