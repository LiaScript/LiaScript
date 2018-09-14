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

function local_update(uid, cmd) {
    let address =  uid+"_"+cmd[0];

    let local = localStorage.getItem(address);

    if (local != null) {
        local = JSON.parse(local);
        local[cmd[1]] = cmd[2];
    }

    localStorage.setItem(address, JSON.stringify(local));
};

function local_init(app, uid, what, i) {
    let address =  uid+"_"+what;

    if (localStorage.getItem(address) == null)
        localStorage.setItem(address, JSON.stringify(Array(i)));
    else
        restore(app, uid, what);
};

function restore(app, uid, what) {
    console.log(what);

    let address =  uid+"_"+what;
    let local = localStorage.getItem(address);

    if (local == null)
        return;

    local = JSON.parse(local);

    for (let i = 0; i < local.length; i++) {
        let entry = local[i];

        console.log("DDDDDDDDDDDDD", entry);
        if(entry != null)
            app.ports.rx_log.send([what, i, entry]);
    }
};



function initDB(name, version, uid) {
    var indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB || window.shimIndexedDB;

    if (!indexedDB) {
        console.log("your browser does not support indexedDB");
    }

     var db = indexedDB.open(name, version,
        function(e) {
            console.log('making a new object store');
            if (!e.objectStoreNames.contains(uid)) {
                e.createObjectStore(uid);
            }
        });

};

class LiaScript {
    constructor(elem, script, url="") {
        this.app = Elm.Main.embed(elem, {url: url, script: script });

        this.initSettings();

        this.initSpeech2JS();
        this.initEval2JS();
        this.initLogging();
    }

    initSettings() {
        let local = localStorage.getItem("settings");

        if (local == null) {
            local = { "loc":          true,
                      "mode":         "Slides",
                      "theme":        "default",
                      "theme_light":  "light",
                      "ace":          "dreamweaver",
                      "font_size":    100,
                      "sound":        true
                    };

            localStorage.setItem("settings", JSON.stringify(local));
        }
        else {
            this.app.ports.log2elm.send(["settings", -1, JSON.parse(local)]);
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
                  //initDB("Lia", 1, uid);

                  break;
              }
              case "update_settings": {
                  localStorage.setItem("settings", JSON.stringify(cmd[2]));
                  break;
              }
              default:
                console.log(cmd);
            }

        });
    }

    initLoggings() {
        let app = this.app;

        app.ports.log2js.subscribe(function(cmd) {
            console.log(cmd);

            let uid = cmd[0];

            cmd = cmd[1];

            switch (cmd[0]) {
              case "init": {
                  //restore(app, uid, "quiz");
                  //restore(app, uid, "code");
                  //restore(app, uid, "survey");
                  break;
              }
              case "code": {
                  local_update(uid, cmd);
                  break;
              }
              case "quiz": {
                  local_update(uid, cmd);
                  break;
              }
              case "survey": {
                  local_update(uid, cmd);
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
