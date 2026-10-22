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

      /**
       * LiaScript version string for local checks ...
       */
      version: string

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

      /**
       * Error handler
       */
      fetchError: (tag: string, src: string) => void

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

      /**
       * Go to the next animation step, if there is no one left, this will
       * switch to the next slide. In Textbook mode this will result in a
       * slide change.
       */
      gotoNext: () => void

      /**
       * Go to the previous animation step, if there is no one, this will
       * switch to the previous slide. In Textbook mode this will result in a
       * slide change.
       */
      gotoPrevious: () => void

      /** This is only used by the editor, to open the slide, which contains
       * linenumber.
       */
      gotoLine: (linenumber: number) => void

      /** This is the opposite to gotoLine. It is function that is called to
       * force a jump onto a line, within a possible editor.
       *
       * __It needs to be changed!__
       */
      lineGoto: (linenumber: number) => void

      /** This is experimental feature, used by an editor to send code, which
       * is translated and updated just in time
       */
      jit?: (code: string) => void

      /** This function shall be overwritten, it will be automatically called
       * if the course has been parsed and is ready. The value that is passed
       * back is the entire definition sector, which means all meta data,
       * including title, comment, logo, macro, etc...
       */
      onReady: (params: any) => void

      /** This function is used to upload course contents from files.
       */
      fileUpload: (event: any, uri?: string) => void

      /** This function can be used by external editors to make use of the
       * dynamic code-injection for responsivevoice. A key from the website
       * is require. If such a key is not present, responsivevoice will not
       * be used, which speeds up the loading process.
       */
      injectResposivevoice: (key: string) => void

      /**
       * Narrator hook for templates: register a custom element as narrator
       * avatar and observe the `lia-narrator` events on `window`, which
       * report the start, stop, pause, word boundaries, etc. of the
       * narrator comments (see `service/Narrator.ts`).
       */
      narrator: import('../service/Narrator').API

      /**
       * Steal the focus and highlight the header on the main section.
       * This can be switched of within editors. By default it is `true`.
       */
      focusOnMain: boolean

      /**
       * Prevent scrolling to top on slides, which can be used in conjunction
       * with `focusOnMain` to prevent scrolling on every edit.
       * By default it is `true`.
       */
      scrollUpOnMain: boolean

      /** A fetch implementation that can be overwritten to provide custom
       * fetching capabilities, e.g. for environments that do not provide a
       * native fetch implementation.
       */
      fetch: (
        resource: RequestInfo | URL,
        options?: RequestInit
      ) => Promise<Response>

      /** To send log information to other functions, this function can be
       * overwritten. All debug-messages will then be passed to this function
       * as well. (window.LIA.debug has to be set to true)
       */
      log?: (type: 'log' | 'warn' | 'error', ...args: any) => void

      settings: Lia.Settings

      classroom: {
        connected: boolean

        /** me, also without a classroom */
        me: Lia.ClassroomPerson
        /** am I the owner of the classroom */
        owner: boolean
        /** null without a classroom */
        mode: 'shared' | 'summary' | 'details' | null
        /** everybody in the classroom right now, including me */
        peers: () => Lia.ClassroomPerson[]

        /** `from` is claimed by the sender, not verified, and missing for
         * messages of older LiaScript versions */
        subscribe: (
          topic: string,
          callback: (message: any, from?: Lia.ClassroomPerson) => void,
        ) => number
        unsubscribe: (id: number) => void
        publish: (topic: string, message: any) => void

        on: {
          (event: 'connect' | 'disconnect', callback: () => void): void
          /** joined, left, renamed or a new owner, called at once as well */
          (
            event: 'peers',
            callback: (peers: Lia.ClassroomPerson[]) => void,
          ): void
        }

        /** Own layer per peer, stored locally and mirrored into the
         * classroom. Visibility follows the classroom mode like quizzes.
         */
        layer: (name: string) => {
          push: (value: any) => void
          /** without `id` the own layer, with `id` the layer of another
           * peer, which only the classroom owner may change */
          set: (values: any[], id?: string) => void
          get: () => any[]
          on: (
            callback: (
              layers: {
                id: string
                name: string
                me: boolean
                editable: boolean
                /** the same color and emoji the peer has in the chat */
                color: string
                symbol: string
                values: any[]
              }[],
              /** remote: the own layer was changed by someone else */
              info: { remote: boolean },
            ) => void,
          ) => void
        }

        /** Shared Yjs types for everyone in the room (undefined if not
         * connected), readable and writable by all peers in every mode.
         */
        array: (name: string) => any
        map: (name: string) => any
        text: (name: string) => any
      }
    }
  }
}

export {}
