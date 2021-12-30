import log from '../log'

const Service = {
  PORT: 'resource',

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'script': {
        let url = event.message.param

        log.info('loading resource => script :', url)

        try {
          let tag = document.createElement('script')

          window.event_semaphore++

          tag.src = url
          tag.async = false
          tag.defer = true
          tag.onload = function () {
            window.event_semaphore--
            log.info('successfully loaded =>', url)
          }
          tag.onerror = function (e: any) {
            window.event_semaphore--
            log.warn('could not load =>', url, e)
          }

          document.head.appendChild(tag)
        } catch (e) {
          log.error('loading resource => ', e)
        }
        break
      }

      case 'link': {
        let url = event.message.param

        log.info('loading resource => link :', url)

        try {
          let tag = document.createElement('link')
          tag.href = url
          tag.rel = 'stylesheet'

          document.head.appendChild(tag)
        } catch (e) {
          log.error('loading resource => ', e)
        }
        break
      }

      default:
        log.warn('(Service Resource) unknown message =>', event.message)
    }
  },
}

export default Service
