import log from '../log'

/**
 * Service for sharing links via the browser share-API.
 */
const Service = {
  /**
   * Service identifier 'share', that is used to while service routing.
   */
  PORT: 'share',

  /**
   * Check if the browser offers a share-API.
   * @returns `true` if it does
   */
  isSupported: function (): boolean {
    return !!navigator.share
  },

  /**
   * Event handler for all share events. Currently it is only supported to
   * share links.
   *
   * TODO: The share-API also allows to share files, which could be nice
   * feature in the future.
   *
   * <https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share#shareable_file_types>
   *
   * @param event - LiaScript event
   */
  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'link':
        try {
          if (navigator.share) {
            // the param has the following format:
            // { title: "..."
            // , text: "..."
            // , url: "..."
            // }
            navigator.share(event.message.param)
          }
        } catch (e: any) {
          log.warn('sharing was not possible => ', event.message, e.message)
        }

        break

      default:
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
    }
  },
}

export default Service
