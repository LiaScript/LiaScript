import Lia from './lia.d'

declare global {
  interface Window {
    debug__?: boolean
    event_semaphore: number

    playback: (_: Lia.Event) => void
    showFootnote: (_: any) => void

    img_: (src: string, width: number, height: number) => void
    img_Click: (url: string) => void
    img_Zoom: (_: MouseEvent) => void

    googleTranslateElementInit: () => void
  }
}

export {}
