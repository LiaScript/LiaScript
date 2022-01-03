import log from '../log'

const Service = {
  PORT: 'share',

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'link':
        try {
          if (navigator.share) {
            navigator.share(event.message.param)
          }
        } catch (e) {
          log.error('sharing was not possible => ', event.message, e)
        }

        break

      default:
        log.warn('(Service Share) unknown message =>', event.message)
    }
  },
}

export default Service
