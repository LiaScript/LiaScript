import log from '../log'

import { Connector } from '../../connectors/Base/index'

var connector: Connector | null = null

const Service = {
  PORT: 'db',

  init: function (elmSend: Lia.Send, con: Connector) {
    connector = con
    connector.connect(elmSend)
  },

  handle: function (event: Lia.Event) {
    if (!connector) return

    switch (event.message.cmd) {
      case 'load':
        connector.load(event)
        break

      case 'store':
        connector.store(event)
        break

      case 'index_list':
        connector.getIndex(event)
        break

      default:
        log.warn('(Service DB) unknown message =>', event.message)
    }
  },
}

export default Service
