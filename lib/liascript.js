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

function dbCheck() {
    if (!indexedDB) {
        console.log("your browser does not support indexedDB");
        return false;
    }
    return true;
}

function dbInit(uid) {
    indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB || window.shimIndexedDB;

    if (!dbCheck()) return;

    let request = indexedDB.open(uid, versionDB);

    request.onupgradeneeded = function(event) {
        console.log("creating tables");

        // The database did not previously exist, so create object stores and indexes.
        let settings = {keyPath: "id", autoIncrement: false};

        let db = request.result;
        db.createObjectStore("quiz",   settings);
        db.createObjectStore("code",   settings);
        db.createObjectStore("survey", settings);
    };

    request.error = function() {
        console.log("Error loading database: ", uid);
    };
};

function dbStore(uid, table, id, data) {
    if (!dbCheck()) return;

    let request = indexedDB.open(uid, versionDB);

    request.onsuccess = function(event) {
        console.log("database loaded: ", uid);

        let db = request.result;

        let tx = db.transaction(table, 'readwrite');
        let store = tx.objectStore(table);

        let item = {
          id:      id,
          data:    data,
          created: new Date().getTime()
        };

        store.put(item);

        tx.oncomplete = function() {
          // All requests have succeeded and the transaction has committed.
          console.log("stored data ...");
        };
    };
};

function dbLoad(uid, table, id, send) {
  if (!dbCheck()) return;

  let request = indexedDB.open(uid, versionDB);

  request.onsuccess = function(event) {
      console.log("database loaded: ", uid, table);

      let db = request.result;

      let tx = db.transaction(table, 'readonly');
      let store = tx.objectStore(table);

      let item = store.get(id);

      item.onsuccess = function() {
          console.log("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
          if (item.result) {
              console.log(item.result.data);
              send([table, id, item.result.data]);
          }
      };

      item.onerror = function() {
          console.log("data not found ...");
      };
  };
}

function dbDelete(uid) {
    if (!dbCheck()) return;

    let request = indexedDB.deleteDatabase(uid);

    request.onerror = function(event) {
        console.log("error deleting database:", uid);
    };

    request.onsuccess = function(event) {
        console.log("database deleted: ", uid);
        console.log(event.result); // should be undefined
    };
};

const SETTINGS = "settings";
var indexedDB  = null;
var versionDB  = 1;

function initSettings(app) {
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
    } else {
        local = JSON.parse(local);
    }

    app.ports.log2elm.send([SETTINGS, -1, local]);
};


class LiaScript {
    constructor(elem, script, url="") {
        this.app = Elm.Main.embed(elem, {url: url, script: script });

        this.initSpeech2JS();
        this.initEval2JS();
        this.initLogging();

        initSettings(this.app);
    }

    reset() {
        this.app.ports.log2elm.send(["reset", -1, null]);
    }

    initLogging() {
        let app = this.app;


        app.ports.log2js.subscribe(function(cmd) {
            console.log("initLogging", cmd);

            let uid = cmd[0];

            cmd = cmd[1];

            switch (cmd[0]) {
              case "load": {
                  console.log("DDDDDDDDDDDDDDDDDDDDDD", cmd);
                  dbLoad(uid, cmd[2], cmd[1], app.ports.log2elm.send);
                  break;
              }
              case "code" : {
                  dbStore(uid, "code", cmd[1], cmd[2]);
                  break;
              }
              case "quiz" : {
                  dbStore(uid, "quiz", cmd[1], cmd[2]);
                  break;
              }
              case "survey" : {
                  dbStore(uid, "survey", cmd[1], cmd[2]);
                  break;
              }
              case "init": {
                  console.log("UID", uid);
                  dbInit(uid);
                  break;
              }
              case "update_settings": {
                  localStorage.setItem(SETTINGS, JSON.stringify(cmd[2]));
                  break;
              }
              case "reset": {
                  dbDelete(uid);
                  localStorage.removeItem(SETTINGS);
                  initSettings(app);
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
