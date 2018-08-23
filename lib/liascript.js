class LiaError extends Error {
    constructor(message, files,...params) {
        super(...params);
        if (Error.captureStackTrace)
            Error.captureStackTrace(this, LiaError);
        this.message = message;
        this.details = [];
        for(var i=0; i<files; i++)
            this.details.push([]);
    }

    add_detail(file_id, msg, type, line, column) {
        this.details[file_id].push(
            { row : line,
              column : column,
              text : msg,
              type : type } );
    }
};

function evalOk(app, id, message) {
    app.ports.eval2elm.send([true, id, message, []]);
};

function evalErr(app, id, message, details=[]) {
    app.ports.eval2elm.send([false, id, message, details]);
};


class LiaScript {
    constructor(elem, script, url="") {
        this.app = Elm.Main.embed(elem, {url: url, script: script });
        this.initSpeech2JS();
        this.initEval2JS();
    }

    initSpeech2JS() {
      let app = this.app;

      this.app.ports.speech2js.subscribe(function(cmd) {
          try {
              switch (cmd[0]) {
                  case "speak":
                      responsiveVoice.speak( cmd[2], cmd[1],
                                             {  onend: e => { app.ports.speech2elm.send(["end", ""]); },
                                              onerror: e => { app.ports.speech2elm.send(["error", e]);}}
                                            );
                      break;
                  case "cancel":
                      app.ports.speech2elm.send(["end", ""]);
                      responsiveVoice.cancel();
                      break;
                  default:
                      console.log(cmd);
                  }
          } catch (e) {
              app.ports.speech2elm.send(["error", e.toString()]);
          }
      });
    }

    initEval2JS() {
        let app = this.app;

        this.app.ports.eval2js.subscribe(function(cmd) {
            let id = cmd[0];
            let code = cmd[1];
            try {
                  evalOk(app, id, String(eval(code)));
            }
            catch (e) {
                if (e instanceof LiaError ) {
                    evalErr(app, id, e.message, e.details);
                } else {
                    evalErr(app, id, e.message);
                }
            }
        });
    }
};
