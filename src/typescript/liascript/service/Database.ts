import log from '../log'

import Lia from '../../liascript/types/lia.d'
import { Connector } from '../../connectors/Base/index'
import { Settings } from '../../connectors/Base/settings'
import TTS from './TTS'
import Script from './Script'

var connector: Connector | null = null
var elmSend: Lia.Send | null

const Service = {
  PORT: 'db',

  init: function (elmSend_: Lia.Send, connector_: Connector) {
    connector = connector_
    elmSend = elmSend_

    elmSend({
      reply: true,
      track: [[Settings.PORT, -1]],
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
        // the reply must contain the id as the url ... such that
        // LiaScript knows, what to do ...
        event.message.param = (await connector.getFromIndex(param)) || {
          id: param,
        }

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
          try {
            Script.exec(param.definition.onload, 350)
          } catch (e) {
            console.warn('could not execute onload script', e)
          }
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

        if (window.LIA.onReady) {
          window.LIA.onReady(param.definition)
        }

        // this will add the font definition
        if (param.definition.macro.font) {
          try {
            const r = document.querySelector<HTMLElement>(':root')
            const rs = getComputedStyle(r)
            const fontSettings = ['family', 'mono', 'headline']

            fontSettings.forEach((val) => {
              const key = '--global-font-' + val

              r.style.setProperty(
                key,
                rs.getPropertyValue(key) + ',' + param.definition.macro.font
              )
            })
          } catch (e) {
            console.warn('could not load font')
          }
        }

        break
      }

      case 'settings': {
        try {
          Settings.updateClassName(event.message.param.config)

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

/**
 * **private helper:** defines a couple of transaction only for the data stored
 * in the "code" table.
 *
 * @param def
 * @returns a function that modifies a certain sub-entry within the database
 */
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
    // change the active version of the project
    case 'active':
      return (project: any) => {
        project[def.id].version_active = def.data.version_active
        project[def.id].log = def.data.log
        project[def.id].file = def.data.file

        return project
      }

    case 'flip_view':
      return (project: any) => {
        project[def.id].file[def.data.file_id].visible = def.data.value
        return project
      }

    case 'flip_fullscreen':
      return (project: any) => {
        project[def.id].file[def.data.file_id].fullscreen = def.data.value
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
