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
            const param = event.message.param
            const fileUrls = param.files || []

            const filePromises = fileUrls.map((url: string) =>
              fetch(url)
                .then((response) => response.blob())
                .then((blob) => {
                  // Extract the filename from the URL or use a default name
                  const filename =
                    url.substring(url.lastIndexOf('/') + 1) || 'file'

                  // Create a new File object from the Blob
                  return new File([blob], filename, { type: blob.type })
                })
            )

            Promise.all(filePromises)
              .then((files) => {
                // Prepare the data for sharing
                const shareData = {
                  title: param.title,
                  text: param.text,
                  url: param.url,
                  files: files,
                }

                // Use the Web Share API to share the data
                navigator
                  .share(shareData)
                  .then(() => console.log('Share was successful.'))
                  .catch((error) => console.log('Sharing failed', error))
              })
              .catch((error) => {
                console.error('Error preparing files for sharing:', error)
              })
          } else {
            navigator.clipboard.writeText(event.message.param.url)
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
