/** Courses supplied by the page that embeds LiaScript (`?parent:<id>`).
 *
 * Instead of downloading the course, LiaScript asks its parent window for the
 * text. This lets an embedding page (e.g. edrys-labs/module-liascript) pass a
 * course of any size, which a `data:` URL in the query cannot do: servers
 * reject URLs longer than a few KB.
 *
 *     LiaScript -> parent: {cmd: 'lia-course', param: {uri}}
 *     parent -> LiaScript: {cmd: 'lia-course', param: {uri, ok: true, body: <markdown>}}
 *                      or: {cmd: 'lia-course', param: {uri, ok: false, body: <reason>}}
 *
 * The `<id>` is up to the embedding page; LiaScript keeps stored state per
 * course address, so it should identify the content (e.g. a hash of it).
 */

var elmSend: Lia.Send | null

const TIMEOUT_MS = 10000

const Service = {
  PORT: 'parent',

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
  },

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'load': {
        const uri: string = event.message.param.uri

        if (window.parent === window) {
          reply(
            event,
            false,
            'This course is supplied by the page that embeds LiaScript, it cannot be opened on its own.',
          )
          return
        }

        const listener = (e: MessageEvent) => {
          if (e.source !== window.parent) return

          const { cmd, param } = e.data || {}
          if (cmd !== 'lia-course' || !param || param.uri !== uri) return

          window.removeEventListener('message', listener)
          clearTimeout(timeout)

          if (param.ok && typeof param.body === 'string') {
            reply(event, true, param.body)
          } else {
            reply(
              event,
              false,
              typeof param.body === 'string'
                ? param.body
                : 'The embedding page could not provide the course.',
            )
          }
        }

        const timeout = setTimeout(() => {
          window.removeEventListener('message', listener)
          reply(
            event,
            false,
            'The page that embeds LiaScript did not provide the course.',
          )
        }, TIMEOUT_MS)

        window.addEventListener('message', listener)
        window.parent.postMessage({ cmd: 'lia-course', param: { uri } }, '*')
        break
      }

      default:
        console.warn('Parent: unknown command', event.message.cmd)
    }
  },
}

function reply(event: Lia.Event, ok: boolean, body: string) {
  event.message.param.data = { ok, body }

  if (elmSend) {
    elmSend(event)
  }
}

export default Service
