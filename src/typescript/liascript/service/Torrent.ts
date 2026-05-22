import { loadScript } from './Resource'
var elmSend: Lia.Send | null
var db: any = null
var JSZip: any = null

type ZipFileMap = { [key: string]: File }

function normalizePath(path: string) {
  return path.replace(/^\/+/, '').replace(/\\/g, '/').toLowerCase()
}

function trimCommonBase(paths: string[]) {
  let base: string | null = null
  let allInBase = true

  for (const path of paths) {
    const root = path.split('/')[0]
    if (base === null) {
      base = root
    } else if (root !== base) {
      allInBase = false
      break
    }
  }

  if (!allInBase || !base) {
    return 0
  }

  return base.length + 1
}

async function loadZipLibrary() {
  if (JSZip) return JSZip

  const module = await import('jszip')
  JSZip = module.default || module
  return JSZip
}

async function blobFromTorrentFile(file: any): Promise<Blob | null> {
  return new Promise((resolve) => {
    file.getBlobURL(function callback(err: any, url: string) {
      if (err || !url) {
        resolve(null)
        return
      }

      fetch(url)
        .then((response) => response.blob())
        .then((blob) => resolve(blob))
        .catch(() => resolve(null))
    })
  })
}

async function textFromTorrentFile(file: any): Promise<string | null> {
  const blob = await blobFromTorrentFile(file)
  if (!blob) return null
  return blob.text()
}

async function extractZipFiles(torrentFiles: any[]): Promise<ZipFileMap> {
  const zipCandidates = torrentFiles.filter((file) =>
    file.name.toLowerCase().endsWith('.zip')
  )

  if (zipCandidates.length === 0) {
    return {}
  }

  const JSZipCtor = await loadZipLibrary()

  for (const zipFile of zipCandidates) {
    try {
      const blob = await blobFromTorrentFile(zipFile)
      if (!blob) continue

      const zip = await JSZipCtor().loadAsync(await blob.arrayBuffer())
      const result: ZipFileMap = {}

      const fileNames = Object.keys(zip.files).filter(
        (fileName) => !zip.files[fileName].dir
      )

      const trim = trimCommonBase(fileNames)

      for (const fileName of fileNames) {
        const entry = zip.files[fileName]
        const path = (trim > 0 ? fileName.slice(trim) : fileName) || fileName
        const content = await entry.async('blob')
        result[normalizePath(path)] = new File([content], path)
      }

      if (Object.keys(result).length > 0) {
        return result
      }
    } catch (error) {
      console.warn('failed to extract zip from torrent file', zipFile.name)
    }
  }

  return {}
}

function findReadmeInTorrentFiles(torrentFiles: any[]) {
  let readme = torrentFiles.filter((file) =>
    file.name.toLocaleLowerCase().endsWith('readme.md')
  )

  if (readme.length === 0) {
    readme = torrentFiles.filter((file) =>
      file.name.toLocaleLowerCase().endsWith('.md')
    )
  }

  return readme[0]
}

function findReadmeInZipFiles(zipFiles: ZipFileMap): File | undefined {
  const files = Object.values(zipFiles).sort((a, b) => {
    const depthA = a.name.split('/').length
    const depthB = b.name.split('/').length
    return depthA - depthB
  })

  let readme = files.find((file) =>
    file.name.toLocaleLowerCase().endsWith('readme.md')
  )

  if (!readme) {
    readme = files.find((file) => file.name.toLocaleLowerCase().endsWith('.md'))
  }

  return readme
}

function findTorrentAsset(torrentFiles: any[], src: string) {
  const source = normalizePath(src)
  return torrentFiles.find((file) => {
    const filePath = normalizePath(file.path || file.name || '')
    return filePath.endsWith(source)
  })
}

function findZipAsset(zipFiles: ZipFileMap, src: string): File | null {
  const source = normalizePath(src)
  if (zipFiles[source]) {
    return zipFiles[source]
  }

  for (const path of Object.keys(zipFiles)) {
    if (path.endsWith(source)) {
      return zipFiles[path]
    }
  }

  return null
}

const Service = {
  PORT: 'torrent',
  init: function (elmSend_: Lia.Send, db_: any) {
    elmSend = elmSend_
    db = db_
  },
  handle: async function (event: Lia.Event, reload = false) {
    if (!(window as any)['WebTorrent']) {
      loadScript(
        'https://cdn.jsdelivr.net/webtorrent/latest/webtorrent.min.js',
        true,
        false,
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
        const client = new WebTorrent({
          tracker: {
            rtcConfig: {
              iceServers: [
                { urls: 'stun:stun.l.google.com:19302' }, // Google's public STUN server
                { urls: 'stun:global.stun.twilio.com:3478' },
              ],
            },
          },
        })
        if (reload) {
          client.add(event.message.param.uri, serve(event, true))
        } else {
          // @ts-ignore
          const data = await db.getMisc(event.message.param.uri, null)
          const files = toFileList(data || {})
          if (files.length > 0) {
            client.seed(files, serve(event, false))
          } else {
            client.add(event.message.param.uri, serve(event, true))
          }
        }
        break
      }
      default:
        console.warn('torrent: unknown event =>', event)
    }
  },
}
function serve(event: Lia.Event, doStore: boolean) {
  return async (torrent: any) => {
    let zipFiles: ZipFileMap = {}

    if (!doStore && !event.message.param.uri.match(torrent.infoHash)) {
      console.warn('torrent not fully loaded')
      Service.handle(event, true)
      return
    }

    const readme = findReadmeInTorrentFiles(torrent.files)

    let body: string | null = null
    if (readme) {
      body = await textFromTorrentFile(readme)
    } else {
      zipFiles = await extractZipFiles(torrent.files)
      const zipReadme = findReadmeInZipFiles(zipFiles)
      if (zipReadme) {
        body = await zipReadme.text()
      }
    }

    if (!body) {
      console.warn('No markdown files found')
      return
    }

    event.message.param.data = { ok: true, body }
    if (elmSend) {
      elmSend(event)
      if (doStore) {
        setTimeout(() => {
          storeFiles(event.message.param.uri, torrent.files)
        }, 1000)
      }
    }

    window.LIA.fetchError = (tag: string, src: string) => {
      const file = findTorrentAsset(torrent.files, src)
      if (file) {
        file.getBlobURL(function callback(err: any, url: string) {
          if (url) {
            inject(tag, window.location.origin + src, url)
          }
        })
        return
      }

      const zipFile = findZipAsset(zipFiles, src)
      if (!zipFile) {
        console.warn('file not found', src)
        return
      }

      const zipUrl = URL.createObjectURL(zipFile)
      inject(tag, window.location.origin + src, zipUrl)
    }
  }
}
// add a dictionary type to the files object
function toFileList(files: { [key: string]: [string, ArrayBuffer, number] }) {
  // sort the object by the index i
  return Object.entries(files)
    .sort((a, b) => a[1][2] - b[1][2])
    .map(
      ([filename, [type, buffer, i]]) => new File([buffer], filename, { type })
    )
}

function storeFiles(uri: string, files: any) {
  for (let i in files) {
    let file = files[i]
    file.getBlobURL(function callback(err: any, url: string) {
      if (url) {
        fetch(url)
          .then((response) => response.arrayBuffer())
          .then((data) => {
            console.log('store file =>', i, file.path, file._getMimeType())
            if (db)
              // @ts-ignore
              db.addMisc(uri, null, file.path, [file._getMimeType(), data, i])
          })
      }
    })
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
