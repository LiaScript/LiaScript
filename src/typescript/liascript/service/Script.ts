import log from '../log'

type ErrType = 'error' | 'warning' | 'info'

export type ErrMessage = {
  row: number
  column?: number
  text: string
  type: ErrType
}

type SendEval = {
  lia: (result: string, details?: ErrMessage[][], ok?: boolean) => void
  log: (topic: string, sep: string, ...args: any) => void
  handle: (name: string, fn: any) => void
  register: (name: string, fn: any) => void
  dispatch: (name: string, data: any) => void
}

type SendExec = {
  lia: (result: string, details?: ErrMessage[][], ok?: boolean) => void
  output: (result: string, details?: ErrMessage[][], ok?: boolean) => void
  wait: () => void
  stop: () => void
  clear: () => void
  html: (msg: string) => void
  liascript: (msg: string) => void
}

enum JS {
  exec = 'exec',
  eval = 'eval',
}

type JSEval = {
  type: JS.eval
  code: string
  send: SendEval
}

type JSExec = {
  type: JS.exec
  section: number
  event: {
    code: string
    delay: number
    id?: number
  }
  send?: Lia.Send
}

class LiaError extends Error {
  public details: ErrMessage[][]

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
    type: ErrType,
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

  get_detail(msg: string, type: ErrType, line: number, column = 0) {
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
  private input: { [track: string]: any }

  constructor() {
    this.event = {}
    this.input = {}
  }

  register(name: string, fn: any) {
    this.event[name] = fn
  }

  register_input(track: Lia.TRACK, name: string, fn: any) {
    const id = JSON.stringify(track)

    if (this.input[id] === undefined) {
      this.input[id] = {}
    }

    this.input[id][name] = fn
  }

  dispatch_input(event: Lia.Event) {
    const id = JSON.stringify(event.track)

    try {
      if (this.input[id]) this.input[id][event.message.cmd](event.message.param)
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
var lia_queue = []
var elmSend: Lia.Send | null

const Service = {
  PORT: 'script',

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
  },

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'eval':
        liaEval(event)
        break

      case 'exec':
        console.warn('EXEC', event)
        break

      case 'input':
        eventHandler.dispatch_input(event)
        break

      case 'stop':
        eventHandler.dispatch_input(event)
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

function liaEval(event: Lia.Event) {
  liaEvalCode(event.message.param, {
    lia: (result: string, details = [], ok = true) => {
      event.message.cmd = 'eval'
      event.message.param = {
        result: result,
        details: details,
        ok: ok,
      }
      sendReply(event)
    },
    log: (topic: string, sep: string, ...args: any) => {
      event.message.cmd = 'log'
      event.message.param = [topic, list_to_string(sep, args)]
      sendReply(event)
    },
    handle: (name: string, fn: any) => {
      eventHandler.register_input(event.track, name, fn)
    },
    register: (name: string, fn: any) => {
      eventHandler.register(name, fn)
    },
    dispatch: (name: string, data: any) => {
      eventHandler.dispatch(name, data)
    },
  })
}

function sendReply(event: Lia.Event) {
  if (elmSend) {
    elmSend(event)
  }
}

function liaEvalCode(code: string, send: SendEval) {
  if (window.event_semaphore > 0) {
    lia_queue.push({
      type: JS.eval,
      code: code,
      send: send,
    })

    if (lia_queue.length === 1) {
      wait()
    }
    return
  }

  try {
    const console = {
      debug: (...args: any) => {
        return send.log('debug', '\n', args)
      },
      log: (...args: any) => {
        return send.log('info', '\n', args)
      },
      warn: (...args: any) => {
        return send.log('warn', '\n', args)
      },
      error: (...args: any) => {
        return send.log('error', '\n', args)
      },
      stream: (...args: any) => {
        return send.log('stream', '', args)
      },
      html: (...args: any) => {
        return send.log('html', '\n', args)
      },
      clear: () => send.lia('LIA: clear'),
    }

    console.clear()

    send.lia(String(eval(code + '\n'))) //, send, console)))
  } catch (e: any) {
    if (e instanceof LiaError) {
      send.lia(e.message, e.details, false)
    } else {
      send.lia(e.message, [], false)
    }
  }
}

function wait() {
  if (window.event_semaphore > 0) {
    setTimeout(wait, 100)
  } else {
    let event
    while ((event = lia_queue.pop())) {
      switch (event.type) {
        case JS.eval: {
          liaEvalCode(event.code, event.send)
          break
        }
        case JS.exec: {
          //lia_execute_event(event.event, event.send, event.section)
          break
        }
        default:
          log.warn('lia_queue => unknown event => ', JSON.stringify(event))
      }
    }
  }
}

function list_to_string(sep: string, list: any) {
  let str = ''

  for (let i = 0; i < list[0].length; i++) {
    str +=
      typeof list[0][i] === 'string' ? list[0][i] : JSON.stringify(list[0][i])
    str += ' '
  }

  return str.slice(0, -1) + sep
}

export default Service
