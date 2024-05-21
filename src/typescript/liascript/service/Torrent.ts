import log from '../log'
import { loadScript } from './Resource'

var elmSend: Lia.Send | null
var db = null

const Service = {
  PORT: 'torrent',

  init: function (elmSend_: Lia.Send, db_: any) {
    elmSend = elmSend_
    db = db_
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
        // @ts-ignore
        const client = new WebTorrent()

        const data = await db.getMisc(event.message.param.uri, null)

        if (data) {
          const files = toFileList(data)

          client.seed(files, serve(event, true))
        } else {
          client.add(event.message.param.uri, serve(event, false))
        }
        break
      }

      default:
        console.warn('torrent: unknown event =>', event)
    }
  },
}

function serve(event, doStore: boolean) {
  return (torrent) => {
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
            event.message.param.data = { ok: true, body: data }
            if (elmSend) {
              elmSend(event)
            }
          })
      }
    })

    window.LIA.fetchError = (tag: string, src: string) => {
      let file = torrent.files.filter((file) => file.path.endsWith(src))

      if (file.length === 0) {
        console.warn('file not found', src)
        return
      }

      file[0].getBlobURL(function callback(err, url) {
        if (url) {
          inject(tag, window.location.origin + src, url)
        }
      })
    }

    if (doStore) {
      for (let i in torrent.files) {
        let file = torrent.files[i]
        file.getBlobURL(function callback(err, url) {
          if (url) {
            fetch(url)
              .then((response) => response.arrayBuffer())
              .then((data) => {
                storeFile(event.message.param.uri, file.path, [
                  file._getMimeType(),
                  data,
                  i,
                ])
              })
          }
        })
      }
    }
  }
}

function toFileList(files: any) {
  // sort the object by the index i
  return Object.entries(files)
    .sort((a, b) => a[1][2] - b[1][2])
    .map(
      ([filename, [type, buffer, i]]) => new File([buffer], filename, { type })
    )
}

function storeFile(uri: string, name: string, data: any) {
  if (db) {
    db.addMisc(uri, null, name, data)
  }
}

function inject(tag: string, src: string, url: string) {
  switch (tag) {
    case 'img': {
      const images = document.querySelectorAll('img,picture')

      for (let i = 0; i < images.length; i++) {
        let image: HTMLImageElement = images[i] as HTMLImageElement

        if (image.src == src) {
          image.src = url

          if (image.onclick) {
            image.onclick = function () {
              window.LIA.img.click(url)
            }
          }

          break
        }
      }

      break
    }

    case 'audio': {
      const nodes = document.querySelectorAll('source')

      for (let i = 0; i < nodes.length; i++) {
        let elem = nodes[i]
        if (elem.src == src) {
          elem.src = url
          elem.removeAttribute('onerror')

          const parent: HTMLMediaElement = elem.parentNode as HTMLMediaElement
          // this forces the player to reload
          parent.innerHTML = elem.outerHTML
          parent.play()

          break
        }
      }

      break
    }

    case 'video': {
      const nodes = document.querySelectorAll('source')
      for (let i = 0; i < nodes.length; i++) {
        let elem = nodes[i]
        if (elem.src == src) {
          const parent = elem.parentNode as HTMLMediaElement
          parent.src = url
          parent.load()
          parent.onloadeddata = function () {
            parent.play()
          }
          break
        }
      }

      break
    }

    case 'script': {
      const tag = document.createElement('script')
      tag.src = url
      document.head.appendChild(tag)

      break
    }

    case 'link': {
      const tag = document.createElement('link')
      tag.href = url
      tag.rel = 'stylesheet'
      document.head.appendChild(tag)

      break
    }

    default: {
      console.warn('could not handle tag =>', tag, url)
    }
  }
}

export default Service
