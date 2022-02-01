import Lia from './lia.d'

declare global {
  interface Window {
    playback: (_: Lia.Event) => void
    showFootnote: (_: any) => void

    img_: (src: string, width: number, height: number) => void
    img_Click: (url: string) => void
    img_Zoom: (_: MouseEvent) => void

    googleTranslateElementInit: () => void

    LIA: {
      // Will print out a hole bunch of event-messages in the console
      debug?: boolean

      // Can be used to manually overwrite the course URL that should be loaded
      defaultCourseURL?: string

      // Used to count the number of loading javascript resources, thus only if
      // all resources have been loaded, the semaphore is equal to 0. A higher
      // value prevents all dynamically scripts from their execution.
      eventSemaphore: number

      // port to send messages to the internal LiaScript, should only be used
      // for very seldomly, since it offers a direct port
      send: Lia.Send
    }
  }
}

export {}
