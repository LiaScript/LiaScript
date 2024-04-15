onmessage = (e) => {
  liaExecCode(e.data)
}


function liaExecCode(event) {
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
      html: (msg) => {
        execute_response(event)('HTML: ' + msg)
      },
      liascript: (msg) => {
        execute_response(event)('LIASCRIPT: ' + msg)
      },
    }

    try {
      const result = eval(event.message.param.code)

      send.lia(result === undefined ? 'LIA: stop' : result)
    } catch (e) {
      log.error('exec => ', e.message)

      send.lia(e.message, false, [])
    }
  }, event.message.param.delay)
}

function execute_response(event, cmd) {
  return (msg, ok = true, details = []) => {
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
    postMessage(event)
  }
}