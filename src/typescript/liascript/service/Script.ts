import log from '../log'

type SendEval = {
  lia: (result: string, details?: Lia.ErrMessage[][], ok?: boolean) => void
  log: (topic: string, sep: string, ...args: any) => void
  handle: (name: string, fn: any) => void
  register: (name: string, fn: any) => void
  dispatch: (name: string, data: any) => void
}

type SendExec = {
  lia: (result: string, details?: Lia.ErrMessage[][], ok?: boolean) => void
  output: (result: string, details?: Lia.ErrMessage[][], ok?: boolean) => void
  wait: () => void
  stop: () => void
  clear: () => void
  html: (msg: string) => void
  liascript: (msg: string) => void
}

class LiaError extends Error {
  public details: Lia.ErrMessage[][]

  constructor(message: string, files: number, ...params: any) {
    super(...params)
    if (Error.captureStackTrace) {
      Error.captureStackTrace(this, LiaError)
    }

    this.message = message
    this.details = []

    for (let i = 0; i < files; i++) {
      this.details.push([])
    }
  }

  add_detail(
    fileId: number,
    msg: string,
    type: Lia.ErrType,
    line: number,
    column?: number
  ) {
    this.details[fileId].push({
      row: line,
      column: column,
      text: msg,
      type: type,
    })
  }

  get_detail(msg: string, type: Lia.ErrType, line: number, column = 0) {
    return {
      row: line,
      column: column,
      text: msg,
      type: type,
    }
  }

  // sometimes you need to adjust the compile messages to fit into the
  // editor ... use this function to adapt the row parameters ...
  // file_id with 0 will apply the correction value to all files
  correct_lines(fileId: number, by: number) {
    if (fileId == null) {
      for (let i = 0; i < this.details.length; i++) {
        this.correct_lines(i, by)
      }
    } else {
      this.details[fileId].map((e) => {
        e.row = e.row + by
      })
    }
  }
}

export class LiaEvents {
  private event: { [key: string]: any }
  private input: { [key: number]: { [key: number]: any } }

  constructor() {
    this.event = {}
    this.input = {}
  }

  register(name: string, fn: any) {
    this.event[name] = fn
  }

  register_input(id1: number, id2: number, name: string, fn: any) {
    if (this.input[id1] === undefined) {
      this.input[id1] = {}
    }
    if (this.input[id1][id2] === undefined) {
      this.input[id1][id2] = {}
    }

    this.input[id1][id2][name] = fn
  }

  dispatch_input(event: Lia.Event) {
    try {
      if (event.track[0][1] !== -1 && event.track[1][1] !== -1)
        this.input[event.track[0][1]][event.track[1][1]][event.track[1][0]](
          event.message
        )
    } catch (e) {
      log.error('unable to dispatch message', event.message)
    }
  }

  dispatch(name: string, data: any) {
    if (this.event.hasOwnProperty(name)) {
      this.event[name](data)
    }
  }

  remove(name: string) {
    delete this.event[name]
  }
}

var eventHandler = new LiaEvents()
window.event_semaphore = 0
//var lia_queue: JSEvent[] = []

const Service = {
  PORT: 'script',

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'eval':
        console.warn('EVAL', event)

        break

      case 'exec':
        console.warn('EXEC', event)
        break

      case 'input':
        console.warn('INPUT', event)
        break

      case 'stop':
        console.warn('STOP', event)
        break

      default:
        log.warn('(Service ', this.PORT, ') unknown message =>', event.message)
    }
  },
}

/**
 * This helper function can be used in conjunction with an `eval` function, to
 * extract the faulty line number, if `eval` fails, depending on the used
 * browser.
 *
 * @param error - the entire error
 * @returns - null or the correct line number
 */
function getLineNumber(error: Error): number | null {
  if (error.stack) {
    // firefox
    const firefoxRegex = /<anonymous>:(\d+):\d+/
    if (error.stack.match(firefoxRegex)) {
      const res = error.stack.match(firefoxRegex)
      return res ? parseInt(res[1], 10) : null
    }

    // chrome
    const chromeRegex = /<anonymous>.+:(\d+):\d+/
    if (error.stack && error.stack.match(chromeRegex)) {
      const res = error.stack.match(chromeRegex)
      return res ? parseInt(res[1], 10) : null
    }
  }

  return null
}

export default Service
