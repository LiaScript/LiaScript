import log from '../log'

import Script from './Script.d'
import { htmlTableLog } from './helper/htmlTableLog'

export enum JS {
  exec = 'exec',
  eval = 'eval',
}

export type Eval = {
  type: JS.eval
  code: string
  send: Script.SendEval
}

export type Exec = {
  type: JS.exec
  event: Lia.Event
}

class LiaError extends Error {
  public details: Script.ErrMessage[][]

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
    type: Script.ErrType,
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

  get_detail(msg: string, type: Script.ErrType, line: number, column = 0) {
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

const worker = new Worker(new URL('Worker.js', import.meta.url), {
  type: 'module',
})

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

// This var is used to store the ID of a setTimeout, to prevent it from being
// called multiple times.
var delayID: any = null

// This is a backup for all JavaScript code, to be evaluated. All scripts are
// delayed until all JavaScript resources have been loaded.
var lia_queue: (Eval | Exec)[] = []

var onload = false

var elmSend: Lia.Send | null

const Service = {
  PORT: 'script',

  init: function (elmSend_: Lia.Send) {
    elmSend = elmSend_
    worker.onmessage = (event) => {
      sendReply(event.data)
    }
  },

  /** This is a little helper, which allows to execute some code snippets,
   * actually from the `@onload` macro.
   *
   * @param code - a string with valid JavaScript
   * @param delay - delay in milliseconds
   */
  exec: function (code: string, delay: number = 0) {
    if (code) {
      onload = true
      code = `window.LIA.eventSemaphore++
          try {
            ${code}
          } catch (e) {
            console.warn('failed to execute onload =>', e.message)
          }
          window.LIA.eventSemaphore--
          onload = false`

      liaExec({
        reply: false,
        track: [],
        service: this.PORT,
        message: {
          cmd: 'exec',
          param: { code, delay },
        },
      })
    }
  },

  handle: function (event: Lia.Event) {
    switch (event.message.cmd) {
      case 'eval':
        liaEval(event)
        break

      case 'exec':
        liaExec(event)
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

function liaEvalCode(code: string, send: Script.SendEval) {
  if (window.LIA.eventSemaphore > 0) {
    lia_queue.push({
      type: JS.eval,
      code: code,
      send: send,
    })

    if (lia_queue.length === 1) {
      delayExecution()
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
      table: (data: any, config: any) => {
        return send.log('html', '\n', [htmlTableLog(data, config)])
      },
      clear: () => send.lia('LIA: clear'),
    }

    send.lia(String(eval(code + '\n'))) //, send, console)))
  } catch (e: any) {
    if (e instanceof LiaError) {
      send.lia(e.message, e.details, false)
    } else {
      send.lia(e.message, [], false)
    }
  }
}

export function liaExec(event: Lia.Event) {
  if (window.LIA.eventSemaphore > 0) {
    lia_queue.push({
      type: JS.exec,
      event: event,
    })

    if (lia_queue.length === 1) {
      delayExecution()
    }
    return
  }

  liaExecCode(event)
}

function liaExecCode(event: Lia.Event) {
  if (event.message.param.worker) {
    worker.postMessage(event)
    return
  }
  setTimeout(() => {
    const send = {
      lia: execute_response(event, 'exec'),
      output: execute_response(event, 'async'),
      wait: () => {
        execute_response(event)('LIA: wait')
      },
      stop: () => {
        execute_response(event)('LIA: stop')
      },
      clear: () => {
        execute_response(event)('LIA: clear')
      },
      html: (msg: string) => {
        execute_response(event)('HTML: ' + msg)
      },
      liascript: (msg: string) => {
        execute_response(event)('LIASCRIPT: ' + msg)
      },
    }

    try {
      const result = eval(event.message.param.code)
      send.lia(result === undefined ? 'LIA: stop' : result)
    } catch (e: any) {
      if (window.LIA.debug) {
        evalError('exec', event.message.param.code, e)
      }
      send.lia(e.message, false, [])
    }
  }, event.message.param.delay)
}

export function evalError(customIdentifier: string, code: string, err: any) {
  let line = err.lineNumber || err.line || null
  let column = err.columnNumber || err.column || null
  // Try to extract line/column from error.stack if not present
  if ((!line || !column) && err.stack) {
    const match = err.stack.match(/<anonymous>:(\d+):(\d+)/)
    if (match) {
      line = parseInt(match[1], 10)
      column = parseInt(match[2], 10)
    }
  }

  const codeLines = code.split('\n')
  let formatted = '\n--- JS Error ---\n'
  let styles: string[] = []
  let args: any[] = []
  codeLines.forEach((l, idx) => {
    const ln = idx + 1
    // Line number in gray, code in default
    formatted += '%c' + ln + ':%c ' + l + '\n'
    styles.push('color: gray; font-family: monospace;')
    styles.push('color: white; font-family: monospace;')
    if (line && ln === line) {
      // Caret and error message in red
      formatted +=
        '%c' +
        '    ' +
        ' '.repeat(column ? column - 1 : 0) +
        '^' +
        err.message +
        '\n'
      styles.push('color: red; font-weight: bold; font-family: monospace;')
    }
  })

  formatted += '--- End ---\n'
  console.error(
    '%c' + customIdentifier + ' => ' + err.message,
    'color: red; font-weight: bold;'
  )

  console.error(formatted, ...styles)
}

function execute_response(event: Lia.Event, cmd?: string) {
  return (msg: any, ok = true, details: Script.ErrMessage[][] = []) => {
    if (typeof msg !== 'string') {
      msg = JSON.stringify(msg)
    }

    if (cmd) {
      event.message.cmd = cmd
    }
    event.message.param = {
      ok: ok,
      result: msg,
      details: details,
    }
    sendReply(event)
  }
}

function delayExecution() {
  if (window.LIA.eventSemaphore > 0 && !delayID) {
    // the timer should be started only once, that is why, the id of it is
    // stored in a global variable
    delayID = setTimeout(function () {
      delayID = null

      delayExecution()
    }, 250)

    console.warn(window.LIA.eventSemaphore, delayID)
  } else if (onload && window.LIA.eventSemaphore === 0) {
    const onloadEvent = lia_queue.shift()

    if (onloadEvent?.type === JS.exec) {
      liaExecCode(onloadEvent.event)
    }

    onload = false

    setTimeout(delayExecution, 50)
  } else if (!delayID) {
    let event: Eval | Exec | undefined

    while ((event = lia_queue.shift())) {
      switch (event.type) {
        case JS.eval: {
          liaEvalCode(event.code, event.send)
          break
        }
        case JS.exec: {
          liaExecCode(event.event)
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
