import Lia from './lia.d'

declare global {
  interface Window {
    showFootnote: (_: any) => void

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

      // All interface functions required by LiaScript
      // Only for internal usage
      img: {
        // submit the image dimensions to LiaScript after an image has been loaded
        // this is required to calculate the optimal placement
        load: (src: string, width: number, height: number) => void

        // external handler to open an image as Modal in LiaScript
        click: (url: string) => void

        // zoom handler for dealing with mouse hovers
        // TODO: touch events to not work yet
        zoom: (_: MouseEvent) => void
      }

      // reference function to TTS functionality, this is mostly used, to
      // define `onclick` handlers so enable speech from inline elements from
      // within LiaScript
      playback: (_: Lia.Event) => void
    }
  }
}

export {}
