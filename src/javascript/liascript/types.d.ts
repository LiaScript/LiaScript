export as namespace Lia;

declare global {
  interface Window {
    debug__?: boolean;
    event_semaphore: number;
  }
}

export type ErrType = 'error' | 'warning' | 'info'

export type ErrMessage = {
  row: number,
  column?: number,
  text: string,
  type: ErrType
}


export type Event = {
  topic: string,
  section: number,
  message: Event | any
}
