import log from '../log'

const Service = {
  PORT: 'console',

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'log':
        log.info(event.message.param)
        break
      case 'warn':
        log.warn(event.message.param)
        break

      case 'error':
        log.error(event.message.param)
        break

      default:
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
    }
  },
}

export default Service
