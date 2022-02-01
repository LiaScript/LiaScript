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
      service: this.PORT,
      message: {
        cmd: 'init',
        param: connector.initSettings(connector.getSettings(), false),
      },
    })
  },

  handle: async function (event: Lia.Event) {
    if (!connector) return

    const param = event.message.param

    switch (event.message.cmd) {
      case 'load':
        event.message.param = await connector.load(param)
        sendReply(event)
        break

      case 'store':
        connector.store(param)
        break

      case 'update':
        connector.update(
          { table: param.table, id: param.id },
          transaction(param.data)
        )
        break

      case 'index_get':
        event.message.param = await connector.getFromIndex(param)
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
        connector.reset(param.url, param.version)
        break

      case 'index_delete':
        connector.deleteFromIndex(param)
        break

      case 'index_restore':
        event.message.param = await connector.restoreFromIndex(
          param.url,
          param.version
        )

        sendReply(event)
        break

      case 'index_store': {
        let isPersistent = true

        try {
          isPersistent = !(
            param.definition.macro['persistent'].trim().toLowerCase() ===
            'false'
          )
        } catch (e) {}

        if (isPersistent) {
          connector.open(param.readme, param.version, param.section_active)
        }

        if (param.definition.onload !== '') {
          // TODO
          //lia_execute_event({
          //  code: data.definition.onload,
          //  delay: 350,
          //})
        }

        document.documentElement.lang = param.definition.language

        meta('author', param.definition.author)
        meta('og:description', param.comment)
        meta('og:title', param.str_title)
        meta('og:type', 'website')
        meta('og:url', '')
        meta('og:image', param.definition.logo)

        // store the basic info in the offline-repositories
        if (isPersistent) {
          connector.storeToIndex(param)
        }

        break
      }

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
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
    }
  },
}

/** let project = vector.data[event.track[0][1]]

        switch (event.track[0][0]) {
          case 'flip': {
            if (event.track[1][0] === 'view') {
              project.file[event.track[1][1]].visible = event.message
            } else if (
              event.track[1][0] === 'fullscreen' &&
              event.track[1][1] !== -1
            ) {
              project.file[event.track[1][1]].fullscreen = event.message
            }
            break
          }
          case 'load': {
            let e_ = event.message
            project.version_active = e_.version_active
            project.log = e_.log
            project.file = e_.file
            break
          }
          
          default: {
            log.warn('unknown update cmd: ', event)
          }
        }

        vector.data[event.track[0][1]] = project */

function transaction(def: {
  cmd: string
  id: number
  data: any
}): (project: any) => any {
  switch (def.cmd) {
    // update the current version and logs
    case 'version':
      return (project: any) => {
        project[def.id].version_active = def.data.version_active
        project[def.id].log = def.data.log
        project[def.id].version[def.data.version_active] = def.data.version

        return project
      }

    // append a new version of files and logs
    case 'append':
      return (project: any) => {
        project[def.id].version_active = def.data.version_active
        project[def.id].log = def.data.log
        project[def.id].file = def.data.file
        project[def.id].version.push(def.data.version)
        project[def.id].repository = {
          ...project[def.id].repository,
          ...def.data.repository,
        }

        return project
      }

    default:
      log.warn('unknown update cmd: ', def.cmd)

      return (project: any) => {
        return project
      }
  }
}

function meta(name: string, content: string) {
  if (content !== '') {
    let meta = document.createElement('meta')
    meta.name = name
    meta.content = content
    document.getElementsByTagName('head')[0].appendChild(meta)
  }
}

function sendReply(event: Lia.Event) {
  if (elmSend) {
    elmSend(event)
  }
}

export default Service