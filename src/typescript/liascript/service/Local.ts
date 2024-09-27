import '../types/lia.d'
import log from '../log'

interface ExtendedFile extends File {
  _path?: string
  path?: string
}

var elmSend: Lia.Send | null
var db = null
var Files: null | Array<ExtendedFile> = null
var uri = ''
var JSZip: any = null

function getFileMimeType(fileName: string) {
  const extension = (fileName.split('.').pop() || '').toLowerCase()
  const mimeTypes = {
    // Text files
    txt: 'text/plain',
    html: 'text/html',
    htm: 'text/html',
    css: 'text/css',
    js: 'application/javascript',
    json: 'application/json',
    xml: 'application/xml',
    csv: 'text/csv',

    // Image files
    jpg: 'image/jpeg',
    jpeg: 'image/jpeg',
    png: 'image/png',
    gif: 'image/gif',
    bmp: 'image/bmp',
    webp: 'image/webp',
    svg: 'image/svg+xml',
    ico: 'image/vnd.microsoft.icon',

    // Audio files
    mp3: 'audio/mpeg',
    wav: 'audio/wav',
    ogg: 'audio/ogg',
    flac: 'audio/flac',
    aac: 'audio/aac',
    m4a: 'audio/x-m4a',

    // Video files
    mp4: 'video/mp4',
    m4v: 'video/x-m4v',
    webm: 'video/webm',
    avi: 'video/x-msvideo',
    mov: 'video/quicktime',
    wmv: 'video/x-ms-wmv',
    flv: 'video/x-flv',
    mkv: 'video/x-matroska',

    // Font files
    ttf: 'font/ttf',
    otf: 'font/otf',
    woff: 'font/woff',
    woff2: 'font/woff2',

    // Document files
    pdf: 'application/pdf',
    doc: 'application/msword',
    docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    ppt: 'application/vnd.ms-powerpoint',
    pptx: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    xls: 'application/vnd.ms-excel',
    xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',

    // Archive files
    zip: 'application/zip',
    rar: 'application/vnd.rar',
    '7z': 'application/x-7z-compressed',
    tar: 'application/x-tar',
    gz: 'application/gzip',

    // Binary files
    exe: 'application/vnd.microsoft.portable-executable',
    bin: 'application/octet-stream',
    dll: 'application/octet-stream',

    // Miscellaneous
    md: 'text/markdown',
    rtf: 'application/rtf',
    eot: 'application/vnd.ms-fontobject',
    jsonld: 'application/ld+json',
    torrent: 'application/x-bittorrent',
  }

  return mimeTypes[extension] || 'application/octet-stream' // Default to binary if unknown
}

function LOG(arg: any) {
  log.info('local:', ...arg)
}

async function hash(readme: File) {
  // @ts-ignore
  const crypto = window.crypto || window.msCrypto

  const arrayBuffer = await readme.arrayBuffer()
  const hashBuffer = await crypto.subtle.digest('SHA-256', arrayBuffer)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  const hashHex = hashArray.map((b) => b.toString(16).padStart(2, '0')).join('')
  return hashHex
}

function findReadme(files: any) {
  // Step 1: Sort the files by the depth of their path (shallow folder first)
  const sortedFiles = files.sort((a: any, b: any) => {
    const pathA = (a.webkitRelativePath || a.path || '').split('/').length
    const pathB = (b.webkitRelativePath || b.path || '').split('/').length
    return pathA - pathB // Sort shallower paths first
  })

  // Step 2: If webkitpath or path exists, look for 'readme.md' in the shallowest folder
  let readmeFiles = sortedFiles.filter((file: any) =>
    file.name.toLowerCase().endsWith('readme.md')
  )

  // Step 3: If no 'readme.md' file is found, look for any other '.md' file in the shallowest folder
  if (readmeFiles.length === 0) {
    readmeFiles = sortedFiles.filter((file: any) =>
      file.name.toLowerCase().endsWith('.md')
    )
  }

  // Step 4: If no markdown file is found, return undefined
  if (readmeFiles.length === 0) {
    return undefined
  }

  // Step 5: Return the first markdown file found in the shallowest folder
  return readmeFiles[0]
}

function cleanPathsIn(files: Array<ExtendedFile>) {
  for (let i in files) {
    let folder = files[i].webkitRelativePath || files[i].path || ''

    if (folder) {
      files[i]._path = folder.split('/').slice(1).join('/')
    } else {
      files[i]._path = ''
    }
  }

  return files
}

const Service = {
  PORT: 'local',

  init: function (elmSend_: Lia.Send, db_: any) {
    elmSend = elmSend_

    db = db_
    if (db) {
      // @ts-ignore
      db.onReady(() => {
        if (uri && Files) {
          log.info('')
          storeFiles(Files)
        }
      })
    }

    window.LIA.fileUpload = (event: any) => {
      let files: Array<File> = Array.from(event.target.files)

      if (files.length === 1 && files[0].type === 'application/zip') {
        LOG("ZIP file detected, let's extract it")
        // JSZip is only loaded if it is required
        if (!JSZip) {
          import('jszip').then((module) => {
            // @ts-ignore
            JSZip = module
            LOG('JSZip loaded at first')
            window.LIA.fileUpload(event)
          })
          return
        }

        let self = this
        // Load the ZIP file using JSZip
        JSZip()
          .loadAsync(files[0].arrayBuffer())
          .then(async function (zip) {
            // Iterate over the files inside the ZIP
            const extractedFiles: Array<ExtendedFile> = []

            let base: string | null = null

            let allInBase = true
            for (const fileName in zip.files) {
              if (base === null) {
                base = fileName.split('/')[0]
              } else if (!fileName.startsWith(base)) {
                allInBase = false
                break
              }
            }

            let trim = allInBase && base ? base.length + 1 : 0

            // Loop through each file in the zip
            for (const fileName in zip.files) {
              const file = zip.files[fileName]
              if (!file.dir) {
                // If it's not a directory
                // Extract the content of each file as an ArrayBuffer (or other formats)
                const content = await file.async('blob')

                // Create a new File object for each extracted file
                const extractedFile = new File(
                  [content],
                  allInBase ? fileName.slice(trim) : fileName,
                  {
                    type:
                      getFileMimeType(fileName) || 'application/octet-stream',
                  }
                )

                extractedFile['_path'] = allInBase
                  ? fileName.slice(trim)
                  : fileName

                LOG(['Extracting file ->', extractedFile['_path']])
                extractedFiles.push(extractedFile) // Add the file to an array
              }
            }

            self.store(extractedFiles) // Array of File objects
          })
          .catch((error: any) => {
            logError(
              `Could not extracting ZIP file (${files[0].name}) --> ${error.message}`
            )
          })

        return
      }

      this.store(cleanPathsIn(files))
    }

    uri = window.location.search.slice(1)

    if (uri.startsWith('local://')) {
      window.LIA.fetchError = (tag: string, src: string) => {
        LOG(['trying to fetch', tag, src])
        if (db) {
          // @ts-ignore
          db.getMisc(uri, null, src).then((data: any) => {
            if (data) {
              inject(tag, src, URL.createObjectURL(data[1]))
            } else if (!src.startsWith('/')) {
              window.LIA.fetchError(tag, '/' + src)
            }
          })
        }
      }
    }
  },

  store: async function (files: Array<ExtendedFile>) {
    Files = files

    const readme = findReadme(files)

    if (!readme) {
      let msg = 'No markdown files found! These are the only files i got ... ('

      for (let i in files) {
        msg += files[i].name + ', '
      }

      logError(msg.slice(0, -2) + ')')
      return
    }

    uri = 'local://' + (await hash(readme))

    const decoder = new TextDecoder('utf-8')

    // Decode the ArrayBuffer into a string
    const body = decoder.decode(await readme.arrayBuffer())

    let event = {
      reply: true,
      service: 'local',
      track: [],
      message: {
        cmd: 'load',
        param: {
          template: false,
          uri: uri,
          data: { ok: true, body },
        },
      },
    }

    if (elmSend) {
      elmSend(event)
    }

    window.LIA.fetchError = (tag: string, src: string) => {
      if (!Files) {
        LOG(['no files found'])
        return
      }

      let file = Files.filter((file) => file._path?.endsWith(src))

      if (file.length === 0) {
        LOG(['file not found', src])

        return
      }
      const url = URL.createObjectURL(file[0])

      if (url) {
        inject(tag, src, url)
      }
    }
  },

  handle: async function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'clear': {
        uri = ''
        Files = null
        break
      }
      default:
        console.warn('local: unknown event =>', event)
    }
  },
}

async function storeFiles(files: Array<File>) {
  if (db && uri) {
    for (let i in files) {
      let file = files[i]

      // @ts-ignore
      await db.addMisc(uri, null, file._path || file.name, [
        file.type,
        new Blob([file], { type: file.type }),
        i,
      ])
    }
  }
}

function inject(tag: string, src: string, url: string) {
  let sources = [src, window.location.origin + '/' + src]

  // this adds normalized URLs to the source list as well, sometimes the URL
  // from a video.src might changed, if a timestamp is detected, which leads
  // to different upper and lowercase characters.
  try {
    let helperURL = new URL(src)
    sources.push(helperURL.href)
    sources.push(window.location.origin + '/' + helperURL.href)
  } catch (e) {}

  switch (tag) {
    case 'img': {
      const images = document.querySelectorAll('img,picture')

      for (let i = 0; i < images.length; i++) {
        let image: HTMLImageElement = images[i] as HTMLImageElement
        let image_src = image.getAttribute('src') || image.src

        if (sources.includes(image_src)) {
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
        let elem_src = elem.getAttribute('src') || elem.src
        if (sources.includes(elem_src)) {
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
        let elem_src = elem.getAttribute('src') || elem.src

        if (sources.includes(elem_src)) {
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

function logError(msg: string) {
  console.warn(msg)
  if (elmSend) {
    elmSend({
      reply: true,
      service: 'local',
      track: [['index', -1]],
      message: {
        cmd: 'loading_error',
        param: msg,
      },
    })
  }
}

export default Service
