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

function lia_eval(app, id1, id2, code) {
    try {
        lia_eval_event(app, true, id1, id2, String(eval(code)));
    }
    catch (e) {
        if (e instanceof LiaError ) {
            lia_eval_event(app, false, id1, id2, e.message, e.details);
        } else {
            lia_eval_event(app, false, id1, id2, e.message);
        }
    }
};

function lia_eval_event(app, ok, id1, id2, message, details=[]) {
    app.ports.event2elm.send(["code", id1, "eval", [ok, id2, message, details]]);
};


function dbCheck() {
    if (!indexedDB) {
        console.log("your browser does not support indexedDB");
        return false;
    }
    return true;
}

function dbInit() {
    indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB || window.shimIndexedDB;

    if (!dbCheck()) return;

    let request = indexedDB.open(uidDB, versionDB);

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
        console.log("Error loading database: ", uidDB);
    };
};

function dbStore(table, id, data) {
    if (!dbCheck()) return;

    let request = indexedDB.open(uidDB, versionDB);

    request.onsuccess = function(event) {
        console.log("database loaded: ", uidDB);

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

function dbLoad(table, id, send) {
  if (!dbCheck()) return;

  let request = indexedDB.open(uidDB, versionDB);

  request.onsuccess = function(event) {
      console.log("database loaded: ", uidDB, table);

      let db = request.result;

      try {
          let tx = db.transaction(table, 'readonly');
          let store = tx.objectStore(table);

          let item = store.get(id);

          item.onsuccess = function() {
              console.log("table", table, item.result);
              if (item.result) {
                  send([table, id, "restore", item.result.data]);
              }
          };

          item.onerror = function() {
              console.log("data not found ...");
          };
      }
    catch (e) {
       console.log("Error: ", e);
    }
  };
}

function dbDelete() {
    if (!dbCheck()) return;

    let request = indexedDB.deleteDatabase(uidDB);

    request.onerror = function(event) {
        console.log("error deleting database:", uidDB);
    };

    request.onsuccess = function(event) {
        console.log("database deleted: ", uidDB);
        console.log(event.result); // should be undefined
    };
};

const PREFERENCES = "preferences";
var indexedDB  = null;
var versionDB  = 1;
var uidDB      = "default";


function initPreferences(send) {
    let local = localStorage.getItem(PREFERENCES);

    if (local == null) {
        console.log("NOT FOUND");
        local = { loc:          true,
                  mode:         "Slides",
                  theme:        "default",
                  theme_light:  "light",
                  ace:          "dreamweaver",
                  font_size:    100,
                  sound:        true
                };

        localStorage.setItem(PREFERENCES, JSON.stringify(local));
    } else {
        local = JSON.parse(local);
    }

    send([PREFERENCES, -1, "", local]);
};


class LiaScript {
    constructor(elem, script, url="", slide=0) {
        this.app = Elm.Main.embed(elem, {url: url, script: script, slide: slide });

        this.initSpeech2JS(this.app);
        this.initEventSystem(this.app);
    }

    reset() {
        this.app.ports.event2elm.send(["reset", -1, "", null]);
    }

    initEventSystem(app) {
        console.log("initEventSystem");

        app.ports.event2js.subscribe(function(cmd) {
            //console.log("elm2js", cmd);

            switch (cmd[0]) {
              case "slide": {
                  break;
              }
              case "eval": {
                  console.log("eval", cmd);
                  break;
              }
              case "load": {
                  dbLoad(cmd[2], cmd[1], app.ports.event2elm.send);
                  break;
              }
              case "code" : {
                  cmd[2].forEach(function(e) {
                      if(e[0] == "store") {
                          dbStore("code", cmd[1], e[1]);
                      }
                      else if(e[0] == "eval") {
                          lia_eval(app, cmd[1], e[1], e[2]);
                      }
                  });

                  break;
              }
              case "quiz" : {
                  dbStore("quiz", cmd[1], cmd[2]);
                  break;
              }
              case "survey" : {
                  dbStore("survey", cmd[1], cmd[2]);
                  break;
              }
              case "init": {
                  console.log("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");
                  document.title = cmd[2][0];
                  uidDB = cmd[2][1];
                  dbInit();
                  setTimeout(function(){initPreferences(app.ports.event2elm.send);},0);                  
                  break;
              }
              case PREFERENCES: {
                  localStorage.setItem(PREFERENCES, JSON.stringify(cmd[2]));
                  break;
              }
              case "ressource" : {
                  let elem = cmd[2][0];
                  let url  = cmd[2][1];

                  console.log(elem, ":", url);

                  try {
                      var tag = document.createElement(elem);
                      if(elem == "link") {
                          tag.href = url;
                          tag.rel  = "stylesheet";
                      }
                      else
                          tag.src = url;
                      document.head.appendChild(tag);

                  } catch (e) {
                      console.log(e.message);
                  }
                  break;
              }
              case "reset": {
                  dbDelete();
                  localStorage.removeItem(PREFERENCES);
                  initPreferences(app.ports.event2elm.send);
                  break;
              }
              default:
                console.log("Command not found: ", cmd);
            }

        });
    }



    initSpeech2JS(app) {
      app.ports.speech2js.subscribe(function(cmd) {
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
};
