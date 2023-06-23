import log from '../log'

var elmSend: Lia.Send | null

var pako

const Service = {
  PORT: 'zip',

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
  },

  handle: async function (event: Lia.Event) {
    if (!pako) {
      import('pako').then((e) => {
        pako = e
        Service.handle(event)
      })

      return
    }

    switch (event.message.cmd) {
      case 'unzip': {
        try {
          const data = pako.ungzip(
            atob(event.message.param.data)
              .split('')
              .map(function (c) {
                return c.charCodeAt(0)
              }),
            { to: 'string' }
          )

          event.message.param.data = { ok: true, body: data }
        } catch (e) {
          event.message.param.data = { ok: false, body: e.message }
        }

        if (elmSend) {
          elmSend(event)
        }
        break
      }

      default: {
        log.warn('zip: unknown event =>', event)
      }
    }
  },
}

export default Service
