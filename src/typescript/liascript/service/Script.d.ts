export as namespace Script

export type ErrType = 'error' | 'warning' | 'info'

export type ErrMessage = {
  row: number
  column?: number
  text: string
  type: ErrType
}

export type SendEval = {
  lia: (result: string, details?: ErrMessage[][], ok?: boolean) => void
  log: (topic: string, sep: string, ...args: any) => void
  handle: (name: string, fn: any) => void
  register: (name: string, fn: any) => void
  dispatch: (name: string, data: any) => void
}

export type SendExec = {
  lia: (result: string, details?: ErrMessage[][], ok?: boolean) => void
  output: (result: string, details?: ErrMessage[][], ok?: boolean) => void
  wait: () => void
  stop: () => void
  clear: () => void
  html: (msg: string) => void
  liascript: (msg: string) => void
}
