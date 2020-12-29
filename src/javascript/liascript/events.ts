import log from './log'

enum ErrType {
  error = 'error',
  warning = 'warning',
  info = 'info'
}

type ErrMessage = {
  row: number,
  column?: number,
  text: string,
  type: ErrType
}

window.event_semaphore = 0
let lia_queue = []

// Basic class for handline Code-Errors
class LiaError extends Error {
  public details : ErrMessage [] []

  constructor (message: string, files: number, ...params: any) {
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

  add_detail (fileId: number, msg: string, type: ErrType, line: number, column?: number) {
    this.details[fileId].push({
      row: line,
      column: column,
      text: msg,
      type: type
    })
  }

  get_detail (msg: string, type: ErrType, line: number, column = 0) {
    return {
      row: line,
      column: column,
      text: msg,
      type: type
    }
  }

  // sometimes you need to adjust the compile messages to fit into the
  // editor ... use this function to adapt the row parameters ...
  // file_id with 0 will apply the correction value to all files
  correct_lines (fileId: number, by: number) {
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
};

class LiaEvents {
  constructor () {
    this.event = {}
    this.input = {}
  }

  register (name, fn) {
    this.event[name] = fn
  }

  register_input (id1, id2, name, fn) {
    if (this.input[id1] === undefined) {
      this.input[id1] = {}
    }
    if (this.input[id1][id2] === undefined) {
      this.input[id1][id2] = {}
    }

    this.input[id1][id2][name] = fn
  }

  dispatch_input (event) { // id1, id2, name, msg) {
    try {
      this.input[event.section][event.message.section][event.message.topic](event.message.message)
    } catch (e) {
      log.error('unable to dispatch message', event.message)
    }
  }

  dispatch (name, data) {
    if (this.event.hasOwnProperty(name)) {
      this.event[name](data)
    }
  }

  remove (name) {
    delete this.event[name]
  }
};

function getLineNumber (error: Error) : number | null {
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
};

function lia_wait () {
  if (window.event_semaphore > 0) {
    setTimeout(lia_wait, 100)
  } else {
    while (lia_queue.length) {
      let event = lia_queue.pop()

      if (event.type === 'eval') {
        lia_eval(event.code, event.send)
      } else if (event.type === 'exec') {
        lia_execute_event(event.event, event.send, event.section)
      } else {
        log.warn('lia_queue => unknown event => ', JSON.stringify(event))
      }
    }
  }
}

function lia_eval (code, send) {
  if (window.event_semaphore > 0) {
    lia_queue.push({
      type: 'eval',
      code: code,
      send: send
    })

    if (lia_queue.length === 1) {
      lia_wait()
    }
    return
  }

  try {
    const console = {
      debug: (...args) => send.log('debug', '\n', args),
      log: (...args) => send.log('info', '\n', args),
      warn: (...args) => send.log('warn', '\n', args),
      error: (...args) => send.log('error', '\n', args),
      html: (...args) => send.log('html', '\n', args),
      clear: () => send.lia('LIA: clear')
    }

    console.clear()

    send.lia(String(eval(code + '\n', send, console)))
  } catch (e) {
    if (e instanceof LiaError) {
      send.lia(e.message, e.details, false)
    } else {
      send.lia(e.message, [], false)
    }
  }
};

function lia_eval_event (send, handler, event) {
  lia_eval(
    event.message.message, {
      lia: (result, details = [], ok = true) => {
        event.message.topic = 'eval'
        event.message.message = {
          result: result,
          details: details,
          ok: ok
        }
        send(event)
      },
      log: (topic, sep, ...args) => {
        event.message.topic = topic
        event.message.message = list_to_string(sep, args)
        send(event)
      },
      // service: websocket(channel),
      handle: (name, fn) => {
        const e1 = event.section
        const e2 = event.message.section
        handler.register_input(e1, e2, name, fn)
      },
      register: (name, fn) => {
        handler.register(name, fn)
      },
      dispatch: (name, data) => {
        handler.dispatch(name, data)
      }
    }
  )
};

function list_to_string (sep, list) {
  let str = ''

  for (let i = 0; i < list[0].length; i++) {
    str += list[0][i].toString() + ' '
  }

  return str + sep
};

function execute_response (topic, event_id, sender, section) {
  return (msg, ok = true) => {
    if (typeof msg !== 'string') {
      msg = JSON.stringify(msg)
    }

    sender({
      topic: 'effect',
      section: section,
      message: {
        topic: topic,
        section: event_id,
        message: {
          ok: ok,
          result: msg,
          details: []
        }
      }
    })
  }
}

function lia_execute_event (event, sender = null, section = null) {
  if (window.event_semaphore > 0) {
    lia_queue.push({
      type: 'exec',
      event: event,
      send: sender,
      section: section
    })

    if (lia_queue.length === 1) {
      lia_wait()
    }
    return
  }

  setTimeout(() => {
    let send = {
      lia: execute_response('code', event.id, sender, section),
      output: execute_response('codeX', event.id, sender, section),
      wait: () => {
        (execute_response('code', event.id, sender, section))('LIA: wait')
      },
      stop: () => {
        (execute_response('code', event.id, sender, section))('LIA: stop')
      },
      html: (msg) => {
        (execute_response('code', event.id, sender, section))('HTML: ' + msg)
      },
      liascript: (msg) => {
        (execute_response('code', event.id, sender, section))('LIASCRIPT: ' + msg)
      }
    }

    try {
      const result = eval(event.code)
      if (section != null && typeof event.id === 'number') {
        send.lia(result === undefined ? 'LIA: stop' : result)
      }
    } catch (e) {
      log.error('exec => ', e.message)
      send.lia(e.message, false)
    }
  }, event.delay)
};

function websocket (channel = null) {
  if (channel) {
    return function (eventID, message) {
      return channel.push('lia', {
        event_id: eventID,
        message: message
      })
    }
  }
};

export {
  LiaEvents,
  lia_execute_event,
  lia_eval_event
}
