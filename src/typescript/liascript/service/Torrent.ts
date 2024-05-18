import log from '../log'
import { loadScript } from './Resource'

var elmSend: Lia.Send | null

const Service = {
  PORT: 'torrent',

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
  },

  handle: async function (event: Lia.Event) {
    if (!window['WebTorrent']) {
      loadScript(
        'https://cdn.jsdelivr.net/webtorrent/latest/webtorrent.min.js',
        true,
        (ok: boolean) => {
          if (ok) {
            this.handle(event)
          } else {
            console.error('webtorrent failed to load')
          }
        }
      )
      return
    }

    switch (event.message.cmd) {
      case 'load': {
        const client = new WebTorrent()

        client.add(event.message.param.uri, (torrent) => {
          // Got torrent metadata!
          console.log('Client is downloading:', torrent.infoHash)

          let readme = torrent.files.filter((file) =>
            file.name.toLocaleLowerCase().endsWith('readme.md')
          )

          if (readme.length === 0) {
            readme = torrent.files.filter((file) => file.name.endsWith('.md'))
          }

          if (readme.length === 0) {
            console.warn('No markdown files found')
            return
          }

          readme = readme[0]

          readme.getBlobURL(function callback(err, url) {
            if (url) {
              fetch(url)
                .then((response) => {
                  return response.text()
                })
                .then((data) => {
                  console.warn(data)
                  event.message.param.data = { ok: true, body: data }
                  if (elmSend) {
                    elmSend(event)
                  }
                })
            }
          })

          for (const file of torrent.files) {
            console.warn(file.path)
            file.getBlobURL(function callback(err, url) {
              console.warn('asdasadfdadf', err, url)
            })
            //event.message.param.data = { ok: true, body: data }
          }
        })
        break
      }

      default:
        console.warn('torrent: unknown event =>', event)
    }
  },
}

export default Service
