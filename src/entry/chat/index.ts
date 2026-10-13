// has to come first, dependencies use `globalThis` on import
import '../../typescript/liascript/globalThis'

// @ts-ignore
import { Elm } from '../../elm/Chat.elm'

import * as GLOBALS from '../../typescript/liascript/init'
import Lia from '../../typescript/liascript/types/lia.d'
import { Connector } from '../../typescript/connectors/Memory/index'

import Console from '../../typescript/liascript/service/Console'
import Database, {
  transaction,
} from '../../typescript/liascript/service/Database'
import { Service as Resource } from '../../typescript/liascript/service/Resource'
import Script from '../../typescript/liascript/service/Script'
import Slide from '../../typescript/liascript/service/Slide'
import * as TTS from '../../typescript/liascript/service/TTS'

import '../../typescript/webcomponents/preview-lia'
import '../../typescript/webcomponents/embed/index'
import '../../typescript/webcomponents/tooltip/index'
import '../../typescript/webcomponents/editor'
import '../../typescript/webcomponents/formula/index'
import '../../typescript/webcomponents/chart'
import '../../typescript/webcomponents/format'
import '../../typescript/webcomponents/terminal'

GLOBALS.initGlobals()

type Message = {
  user: string // the name of the sender
  color: string
  message: string
  icon?: string // url (or data-url) of an avatar
  self?: boolean // own messages are right aligned
  time?: number // ms since 1970, shown as local time
}

// all messages, as they have been send by the host (used for the export), the
// index is the id, messages can only be appended
let messages: Message[] = []

const toHost = (msg: any) => window.parent.postMessage(msg, '*')

const connector = new Connector(record => toHost({ type: 'store', record }))

const app = Elm.Chat.init({
  node: document.getElementById('lia-chat'),
  flags: {
    base: new URLSearchParams(location.search).get('base') || location.href,
    screen: { width: window.innerWidth, height: window.innerHeight },
  },
})

const elmSend = (event: Lia.Event) => {
  if (event.reply) app.ports.event2elm.send(event)
}
window.LIA.send = elmSend

const toElm = (cmd: string, param: any) =>
  app.ports.event2elm.send({
    reply: true,
    track: [],
    service: 'chat',
    message: { cmd, param },
  })

Database.init(elmSend, connector)
TTS.Service.init(elmSend)
Script.init(elmSend)

app.ports.copyToClipboard?.subscribe((text: string) =>
  navigator.clipboard.writeText(text).catch(console.warn)
)

app.ports.event2js.subscribe((event: Lia.Event) => {
  const param = event.message.param

  switch (event.service) {
    // `@onload` of templates and message headers
    case 'chat':
      Script.exec(param, 10)
      break

    case Database.PORT:
      // chat ids are timestamps, Database.handle only stores ids < 10000
      if (event.message.cmd === 'store') connector.store(param)
      else if (event.message.cmd === 'update')
        connector.update(
          { table: param.table, id: param.id },
          transaction(param.data)
        )
      else Database.handle(event)
      break

    case Script.PORT:
      Script.handle(event)
      break

    case Slide.PORT:
      Slide.handle(event)
      break

    case Console.PORT:
      Console.handle(event)
      break

    case Resource.PORT:
      Resource.handle(event)
      break

    case TTS.Service.PORT:
      TTS.Service.handle(event)
      break

    // no classroom
    case 'sync':
      break

    default:
      console.warn('Unknown Service => ', event)
  }
})

function add(list: Partial<Message>[]) {
  const start = messages.length
  const added = list.map(
    ({ user = '', color = '', message = '', ...rest }) => ({
      ...rest,
      user,
      color,
      message,
    })
  )
  messages.push(...added)
  toElm(
    'add',
    added.map((msg, i) => ({
      ...msg,
      id: start + i,
      clock: msg.time
        ? new Date(msg.time).toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit',
          })
        : '',
    }))
  )
  setTimeout(() => window.scrollTo(0, document.body.scrollHeight), 100)
}

function clear() {
  messages = []
  toElm('clear', null)
}

window.addEventListener('message', ({ source, data }) => {
  if (source !== window.parent || !data) return

  switch (data.cmd) {
    case 'add':
      add(data.param)
      break

    case 'clear':
      clear()
      break

    case 'load':
      clear()
      connector.fromJSON(data.param.db)
      add(data.param.messages || [])
      break

    case 'export':
      toHost({
        type: 'export',
        ref: data.ref,
        param: { version: 1, messages, db: connector.toJSON() },
      })
      break
  }
})

document.addEventListener(
  'click',
  e => {
    const link = (e.target as HTMLElement).closest?.('a[href^="agent:"]')
    if (link) {
      e.preventDefault()
      toHost({ type: 'agent', href: link.getAttribute('href') })
    }
  },
  true
)

toHost({ type: 'ready' })
