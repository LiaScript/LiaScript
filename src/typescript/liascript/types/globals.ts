import Lia from './lia.d'

declare global {
  interface Window {
    debug__?: boolean;
    event_semaphore: number;

    playback: (_: Lia.Event) => void;
    showFootnote: (_: any) => void
  }
}

export { }
