import log from './log'
import './types/globals'
import Lia from './types/lia.d'
import Port from './types/ports'

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

type JSEvent = JSEval | JSExec

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

window.event_semaphore = 0
let lia_queue: JSEvent[] = []

// Basic class for handling Code-Errors
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

function lia_wait() {
  if (window.event_semaphore > 0) {
    setTimeout(lia_wait, 100)
  } else {
    let event
    while ((event = lia_queue.pop())) {
      switch (event.type) {
        case JS.eval: {
          lia_eval(event.code, event.send)
          break
        }
        case JS.exec: {
          lia_execute_event(event.event, event.send, event.section)
          break
        }
        default:
          log.warn('lia_queue => unknown event => ', JSON.stringify(event))
      }
    }
  }
}

function lia_eval(code: string, send: SendEval) {
  if (window.event_semaphore > 0) {
    lia_queue.push({
      type: JS.eval,
      code: code,
      send: send,
    })

    if (lia_queue.length === 1) {
      lia_wait()
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

export function lia_eval_event(
  send: Lia.Send,
  handler: LiaEvents,
  event: Lia.Event
) {
  lia_eval(event.message, {
    lia: (result: string, details = [], ok = true) => {
      event.track[1][0] = JS.eval
      event.message = {
        result: result,
        details: details,
        ok: ok,
      }
      send(event)
    },
    log: (topic: string, sep: string, ...args: any) => {
      event.track[1][0] = topic
      event.message = list_to_string(sep, args)
      send(event)
    },
    // service: websocket(channel),
    handle: (name: string, fn: any) => {
      const e1 = event.track[0][1]
      const e2 = event.track[1][1]
      handler.register_input(e1, e2, name, fn)
    },
    register: (name: string, fn: any) => {
      handler.register(name, fn)
    },
    dispatch: (name: string, data: any) => {
      handler.dispatch(name, data)
    },
  })
}

function list_to_string(sep: string, list: any) {
  let str = ''

  for (let i = 0; i < list[0].length; i++) {
    str += list[0][i].toString() + ' '
  }

  return str.slice(0, -1) + sep
}

function execute_response(
  topic: string,
  event_id: number,
  send: Lia.Send,
  section?: number
) {
  return (msg: any, details: Lia.ErrMessage[][] = [], ok = true) => {
    if (typeof msg !== 'string') {
      msg = JSON.stringify(msg)
    }

    send({
      reply: false,
      track: [
        [Port.EFFECT, section === undefined ? -1 : section],
        [topic, event_id],
      ],
      service: null,
      message: {
        ok: ok,
        result: msg,
        details: details,
      },
    })
  }
}

export function lia_execute_event(
  event: { code: string; delay: number; id?: number },
  sender?: Lia.Send,
  section?: number
) {
  if (window.event_semaphore > 0) {
    lia_queue.push({
      type: JS.exec,
      event: event,
      send: sender,
      section: section || -1,
    })

    if (lia_queue.length === 1) {
      lia_wait()
    }
    return
  }

  setTimeout(() => {
    let send: SendExec | undefined

    if (sender && event.id != null && section !== undefined) {
      const id = event.id
      send = {
        lia: execute_response('code', id, sender, section),
        output: execute_response('codeX', id, sender, section),
        wait: () => {
          execute_response('code', id, sender, section)('LIA: wait')
        },
        stop: () => {
          execute_response('code', id, sender, section)('LIA: stop')
        },
        clear: () => {
          execute_response('code', id, sender, section)('LIA: clear')
        },
        html: (msg: string) => {
          execute_response('code', id, sender, section)('HTML: ' + msg)
        },
        liascript: (msg: string) => {
          execute_response('code', id, sender, section)('LIASCRIPT: ' + msg)
        },
      }
    }

    try {
      const result = eval(event.code)

      if (
        send != undefined &&
        section != null &&
        typeof event.id === 'number'
      ) {
        send.lia(result === undefined ? 'LIA: stop' : result)
      }
    } catch (e: any) {
      log.error('exec => ', e.message)
      if (!!send) send.lia(e.message, [], false)
    }
  }, event.delay)
}

function websocket(channel?: any[]) {
  if (channel) {
    return function (eventID: string, message: string) {
      return channel.push('lia', {
        event_id: eventID,
        message: message,
      })
    }
  }
}
