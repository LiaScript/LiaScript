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



function initDB(uid, version, name) {
    var indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB || window.shimIndexedDB;

    if (!indexedDB) {
        console.log("your browser does not support indexedDB");
    }

    var db = indexedDB.open(uid, version,
        function(e) {
            console.log('making a new object store');
            if (!e.objectStoreNames.contains(uid)) {
                e.createObjectStore(name, {keyPath: "id"});
            }
        });

};

class LiaScript {
    const SETTINGS = "settings";


    constructor(elem, script, url="") {
        this.app = Elm.Main.embed(elem, {url: url, script: script });

        this.initSettings();

        this.initSpeech2JS();
        this.initEval2JS();
        this.initLogging();
    }

    initSettings() {
        let local = localStorage.getItem(SETTINGS);

        if (local == null) {
            local = { "loc":          true,
                      "mode":         "Slides",
                      "theme":        "default",
                      "theme_light":  "light",
                      "ace":          "dreamweaver",
                      "font_size":    100,
                      "sound":        true
                    };

            localStorage.setItem(SETTINGS, JSON.stringify(local));
        }
        else {
            this.app.ports.log2elm.send([SETTINGS, -1, JSON.parse(local)]);
        }
    }

    initLogging() {
        let app = this.app;

        app.ports.log2js.subscribe(function(cmd) {
            console.log("initLogging", cmd);

            let uid = cmd[0];

            cmd = cmd[1];

            switch (cmd[0]) {
              case "init": {
                  initDB(uid, 1, "quiz");
                  initDB(uid, 1, "code");
                  initDB(uid, 1, "survey");
                  break;
              }
              case "update_settings": {
                  localStorage.setItem(SETTINGS, JSON.stringify(cmd[2]));
                  break;
              }
              case "reset": {
                  localStorage.removeItem(SETTINGS);
                  initSettings();
              }
              case "quiz" : {
                  console.log(cmd);
                  break;
              }
              default:
                console.log(cmd);
            }

        });
    }



    initSpeech2JS() {
      let app = this.app;

      this.app.ports.speech2js.subscribe(function(cmd) {
          try {
              switch (cmd[0]) {
                  case "speak":
                      responsiveVoice.speak( cmd[2], cmd[1],
                                             {  onend: e => { app.ports.speech2elm.send(["end", ""]); },
                                              onerror: e => { app.ports.speech2elm.send(["error", e.toString()]);}}
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
