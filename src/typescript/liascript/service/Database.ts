import log from '../log'

import Lia from '../../liascript/types/lia.d'
import { Connector } from '../../connectors/Base/index'

var connector: Connector | null = null
var elmSend: Lia.Send | null

const Service = {
  PORT: 'db',

  init: function (elmSend_: Lia.Send, connector_: Connector) {
    connector = connector_
    elmSend = elmSend_
    connector.connect(elmSend)
  },

  handle: async function (event: Lia.Event) {
    if (!connector) return

    switch (event.message.cmd) {
      case 'load':
        connector.load(event)
        break

      case 'store':
        connector.store(event)
        break

      case 'index_get':
        console.warn('#################################', event.message.param)
        event.message.param = await connector.getFromIndex(event.message.param)
        sendReply(event)
        break

      case 'index_list':
        event.message.param = await connector.getIndex()
        sendReply(event)
        break

      case 'index_reset':
        connector.reset(event.message.param.url, event.message.param.version)
        break

      case 'index_delete':
        connector.deleteFromIndex(event.message.param)
        break

      default:
        log.warn('(Service DB) unknown message =>', event.message)
    }
  },
}

function sendReply(event: Lia.Event) {
  if (elmSend) {
    elmSend(event)
  }
}

export default Service
