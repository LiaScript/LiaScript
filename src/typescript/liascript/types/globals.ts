import Lia from './lia.d'

declare global {
  interface Window {
    googleTranslateElementInit: () => void

    LIA: {
      /** Will print out a hole bunch of event-messages in the console
       */
      debug?: boolean

      /** Can be used to manually overwrite the course URL that should be
       * loaded
       */
      defaultCourseURL?: string

      /** Used to count the number of loading javascript resources, thus only
       * if all resources have been loaded, the semaphore is equal to 0. A
       * higher value prevents all dynamically scripts from their execution.
       */
      eventSemaphore: number

      /** port to send messages to the internal LiaScript, should only be used
       * for very seldomly, since it offers a direct port
       */
      send: Lia.Send

      /** All interface functions required by LiaScript
       *
       * __Only for internal usage__
       */
      img: {
        /** submit the image dimensions to LiaScript after an image has been
         * loaded this is required to calculate the optimal placement
         */
        load: (src: string, width: number, height: number) => void

        /** external handler to open an image as Modal in LiaScript
         */
        click: (url: string) => void

        /** zoom handler for dealing with mouse hovers
         *
         * TODO: touch events to not work yet
         */
        zoom: (_: MouseEvent) => void
      }

      /** reference function to TTS functionality, this is mostly used, to
       * define `onclick` handlers so enable speech from inline elements from
       * within LiaScript
       */
      playback: (_: Lia.Event) => void

      /** callback used by Inline elements to circumvent the message handling
       * and to add on-click events for __FOOTNOTES__
       */
      showFootnote: (key: string) => void

      /** release an event that triggers LiaScript to switch to a specific
       * slide number
       */
      goto: (slide: number) => void

      /** This is only used by the editor, to open the slide, which contains
       * linenumber.
       */
      gotoLine?: (linenumber: number) => void

      /** This is experimental feature, used by an editor to send code, which
       * is translated and updated just in time
       */
      jit?: (code: string) => void

      /** This function shall be overwritten, it will be automatically called
       * if the course has been parsed and is ready...
       */
      onReady?: () => void
    }
  }
}

export {}
