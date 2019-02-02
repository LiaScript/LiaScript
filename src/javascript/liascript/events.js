"use strict";

import { lia } from "./logger";

// Basic class for handline Code-Errors
class LiaError extends Error {
    constructor (message, files,...params) {
        super(...params);
        if (Error.captureStackTrace)
            Error.captureStackTrace(this, LiaError);
        this.message = message;
        this.details = [];
        for(var i=0; i<files; i++)
            this.details.push([]);
    }

    add_detail (file_id, msg, type, line, column) {
        this.details[file_id].push(
            { row : line,
              column : column,
              text : msg,
              type : type } );
    }

    get_detail(msg, type, line, column=0) {
      return { row : line, column : column, text : msg, type : type };
    }

    // sometimes you need to adjust the compile messages to fit into the
    // editor ... use this function to adapt the row parameters ...
    // file_id with 0 will apply the correction value to all files
    correct_lines (file_id, by) {
      if(file_id == null)
        for(let i=0; i<this.details.length; i++) {
          this.correct_lines(i, by);
        }
      else
        this.details[file_id] = this.details[file_id].map((e) => {e.line = e.line + by});
    }
};



class LiaEvents {

    constructor () {
        this.event = {};
        this.input = {};
    }

    register (name, fn) {
        this.event[name] = fn;
    }

    register_input (id1, id2, name, fn) {
        if (this.input[id1] == undefined) {
            this.input[id1] = {};
        }
        if (this.input[id1][id2] == undefined) {
            this.input[id1][id2] = {};
        }

        this.input[id1][id2][name] = fn;
    }

    dispatch_input (event) {//id1, id2, name, msg) {
        try {
            this.input[event.section][event.message.section][event.message.topic](event.message.message);
        } catch(e) {
            lia.error("unable to dispatch message", msg);
        }
    }

    dispatch (name, data) {
        if (this.event.hasOwnProperty(name)) {
            this.event[name](data);
        }
    }

    remove (name) {
        delete this.event[name];
    }
};

function getLineNumber(error) {
  try {
    // firefox
    const firefoxRegex = /<anonymous>:(\d+):\d+/;
    if (error.stack.match(firefoxRegex)) {
      const res = error.stack.match(firefoxRegex);
      return parseInt(res[1], 10);
    }

    // chrome
    const chromeRegex = /<anonymous>.+:(\d+):\d+/;
    if (error.stack.match(chromeRegex)) {
      const res = error.stack.match(chromeRegex);
      return parseInt(res[1], 10);
    }

  } catch (e) {
    return;
  }

  // We found nothing
  return;
};

function lia_eval(code, send) {
    try {
      send.lia(String(eval(code+"\n", send)));
    } catch (e) {
        if (e instanceof LiaError )
            send.lia(e.message, e.details, false);
        else
            send.lia(e.message, [], false);
    }
};

function lia_eval_event(send, channel, event) {
    lia_eval(
        event.message.message,
        { lia: (result, details=[], ok=true) => {
            event.message.message = { result: result, details: details, ok: ok};
            send(event);
          },
          service: websocket(channel),
          handle: (name, fn) => { events.register_input(event.section, e[1], name, fn) }
        }
    )
};

function lia_execute_event(event) {
    try {
        setTimeout(() => { eval(event.code) }, event.delay);
    } catch (e) {
        lia.error("exec => ", e);
    }
};

function websocket(channel = null) {
    if (channel) {
        return function(event_id, message) {
            return channel.push("party", {event_id: event_id, message: message});
        };
    }
};

export { LiaEvents, lia_execute_event, lia_eval_event };
