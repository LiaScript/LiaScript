import log from '../log'

import Lia from '../../liascript/types/lia.d'
import { Connector } from '../../connectors/Base/index'
import { updateClassName } from '../../connectors/Base/settings'
import TTS from './TTS'

var connector: Connector | null = null
var elmSend: Lia.Send | null

const Service = {
  PORT: 'db',

  init: function (elmSend_: Lia.Send, connector_: Connector) {
    connector = connector_
    elmSend = elmSend_

    elmSend({
      reply: true,
      track: [['settings', -1]],
      service: 'db',
      message: {
        cmd: 'init',
        param: connector.initSettings(connector.getSettings(), false),
      },
    })
  },

  handle: async function (event: Lia.Event) {
    if (!connector) return

    switch (event.message.cmd) {
      case 'load':
        //connector.load(event)
        break

      case 'store':
        //connector.store(event)
        break

      case 'index_get':
        event.message.param = await connector.getFromIndex(event.message.param)
        sendReply(event)
        break

      case 'index_list':
        // this might be necessary to stop talking, if the user switches back
        // from a course to the home screen
        try {
          TTS.mute()
        } catch (e) {}
        event.message.param = await connector.getIndex()
        sendReply(event)
        break

      case 'index_reset':
        connector.reset(event.message.param.url, event.message.param.version)
        break

      case 'index_delete':
        connector.deleteFromIndex(event.message.param)
        break

      case 'index_restore':
        event.message.param = connector.restoreFromIndex(
          event.message.param.url,
          event.message.param.version
        )
        sendReply(event)
        break

      case 'settings': {
        try {
          updateClassName(event.message.param.config)

          const conf = connector.getSettings()

          setTimeout(function () {
            window.dispatchEvent(new Event('resize'))
          }, 333)

          let style = document.getElementById('lia-custom-style')

          if (typeof event.message.param.custom === 'string') {
            if (style == null) {
              style = document.createElement('style')
              style.id = 'lia-custom-style'
              document.head.appendChild(style)
            }

            style.innerHTML = ':root {' + event.message.param.custom + '}'
          } else if (style !== null) {
            style.innerHTML = ''
          }
        } catch (e: any) {
          log.warn('DB: settings => ', e.message)
        }

        connector.setSettings(event.message.param.config)

        break
      }

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
