declare global {
  interface Window {
    debug__?: boolean;
    event_semaphore: number;
  }
}

export {}
