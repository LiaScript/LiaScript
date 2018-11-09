//import Elm from './app';

function liaLog (string) {
    //if(window.debug__)
        console.log(string);
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class LiaStorage {
    constructor (channel = null) {
        if (!channel)
            return;

        this.channel = channel;
        this._init();
    }

    _init () {
        if(!this.channel)
            return;

        let store = this._set_local;

        this.channel.push("party", {get_local_storage: []})
          .receive("ok",    (e) => { store(e); })
          .receive("error", (e) => { console.log("error: ", e); });
    }

    getItems (keys = []) {
        if(typeof key == "string")
            key = [key];

        let rslt = {};
        for (let i=0; i<key.length; i++) {
            let value = localStorage.getItem(key[i]);

            rslt[key[i]] = value ? JSON.parse(value) : value;
        }

        return rslt;
    }

    setItems (dict) {
        if(this.channel)
            this.channel.push("party", {set_local_storage: dict});

        this._set_local(dict);
    }

    _set_local (dict) {
        if (typeof dict == "object") {
            for (const [key, value] of Object.entries(dict)) {
                localStorage.setItem(key, JSON.stringify(value));
            }
        }
    }
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

    dispatch_input (id1, id2, name, msg) {
        try {
            this.input[id1][id2][name](msg);
        } catch(e) {
            console.log("unable to dispatch message", msg);
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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function websocket(channel = null) {
    if (channel) {
        return function(event_id, message) {
            return channel.push("party", {event_id: event_id, message: message});
        };
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
      send.lia("eval", String(eval(code+"\n", send)));
    } catch (e) {
        if (e instanceof LiaError )
            send.lia("eval", e.message, e.details, false);
        else
            send.lia("eval", e.message, [], false);
    }
};

function lia_eval_event(send, id1, id2, source) {
    return function(event_, message, details=[], ok=true) {
        send([source, id1, event_, [ok, id2, message, details]]);
    };
};

function lia_execute(code, delay, send) {
    try {
        setTimeout(() => { eval(code) }, delay);
    } catch (e) {
        console.log("exec - error: ", e);
    }
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

function scrollIntoView (id, delay) {
    setTimeout( function (e) {
        try {
            document.getElementById(id).scrollIntoView({behavior: "smooth"});
        } catch (e) {}
    }, delay);
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

class LiaDB {
    constructor (uidDB, versionDB, send=null, channel=null, init=null) {
        this.channel = channel;
        this.send = send;

        if (channel) return;

        this.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB || window.shimIndexedDB;

        if (!this.indexedDB) {
            console.log("your browser does not support indexedDB");
            return;
        }

        this.uidDB = uidDB;
        this.versionDB = versionDB;


        let request = this.indexedDB.open(this.uidDB, this.versionDB);
        request.onupgradeneeded = function(event) {
            console.log("creating tables");

            // The database did not previously exist, so create object stores and indexes.
            let settings = {keyPath: "id", autoIncrement: false};

            let db = request.result;
            db.createObjectStore("quiz",   settings);
            db.createObjectStore("code",   settings);
            db.createObjectStore("survey", settings);

            if(init)
                send([init.table, init.id, "restore", null]);
        };
        request.onsuccess = function(e) {
            if(init) {
                let db = request.result;
                let tx = db.transaction(init.table, 'readonly');
                let store = tx.objectStore(init.table);

                let item = store.get(init.id);

                item.onsuccess = function() {
                    //console.log("table", init.table, item.result);
                    if (item.result) {
                        send([init.table, init.id, "restore", item.result.data]);
                    }
                    else {
                        send([init.table, init.id, "restore", null]);
                    }
                };
                item.onerror = function() {
                    send([init.table, init.id, "restore", null]);
                };
            }
        };
    }

    store(table, id, data) {
        if(this.channel) {
            this.channel.push("party", {store: table, slide: id, data: data})
            .receive("ok",    e => { console.log("ok", e); })
            .receive("error", e => { console.log("error", e); });

            return;
        }


        liaLog(`liaDB: event(store), table(${table}), id(${id}), data(${data})`)
        if (!this.indexedDB) return;

        let request = this.indexedDB.open(this.uidDB, this.versionDB);
        request.onsuccess = function(e) {
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
    }

    load(table, id) {
        let send = this.send;

        if (this.channel) {
            this.channel.push("party", {load: table, slide: id})
            .receive("ok",    e => {
                send([e.table, e.slide, "restore", e.data]);
            })
            .receive("error", e => { console.log("error", e); });

            return;
        }

        if (!this.indexedDB) return;

        //console.log("loading", table, id);

        let request = this.indexedDB.open(this.uidDB, this.versionDB);
        request.onsuccess = function(e) {
            try {
                let db = request.result;
                let tx = db.transaction(table, 'readonly');
                let store = tx.objectStore(table);

                let item = store.get(id);

                item.onsuccess = function() {
                    //console.log("table", table, item.result);
                    if (item.result) {
                        send([table, id, "restore", item.result.data]);
                    }
                };
                item.onerror = function() {
                    console.log("data not found ...");
                    if (table == "code")
                        send([table, id, "restore", null]);
                };
            }
            catch (e) { console.log("Error: ", e); }
        };
    }

    del() {
        if (this.channel) return;

        if (!this.indexedDB) return;

        let request = this.indexedDB.deleteDatabase(this.uidDB);
        request.onerror = function(e) {
            console.log("error deleting database:", this.uidDB);
        };
        request.onsuccess = function(e) {
            console.log("database deleted: ", this.uidDB);
            console.log(e.result); // should be undefined
        };
    }

    update(event, slide) {
        if (this.channel) {
            this.channel.push("party", { update: event, slide: slide } );
            return;
        }
        if (!this.indexedDB) return;

        let request = this.indexedDB.open(this.uidDB, this.versionDB);
        request.onsuccess = function(e) {
            try {
                let db = request.result;
                let tx = db.transaction("code", 'readwrite');
                let store = tx.objectStore("code");

                let item = store.get(slide);

                item.onsuccess = function() {
                    let vector = item.result

                    if (vector) {
                        let project = vector.data[event[1]];
                        switch (event[0]) {
                            case "flip_view": {
                                project.file[event[2]].visible = event[3];
                                break;
                            }
                            case "fullscreen": {
                                project.file[event[2]].fullscreen = event[3];
                                break;
                            }
                            case "load": {
                                let e_ = event[2];
                                project.version_active = e_.version_active;
                                project.log = e_.log;
                                project.file = e_.file;
                                break;
                            }
                            case "version_update": {
                                let e_ = event[2];
                                project.version_active = e_.version_active;
                                project.log = e_.log;
                                project.version[e_.version_active] = e_.version;
                                break;
                            }
                            case "version_append": {
                                let e_ = event[2];
                                project.version_active = e_.version_active;
                                project.log = e_.log;
                                project.file = e_.file;
                                project.version.push(e_.version);
                                break;
                            }
                            default: {
                                console.log("unknown update cmd: ", event);
                            }
                        }
                        vector.data[event[1]] = project;
                        store.put(vector);
                    }
                };
                item.onerror = function() {
                    console.log("data not found ...");
                };
            }
            catch (e) { console.log("Error: ", e); }
        };
    }
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

const PREFERENCES = "preferences";

function initPreferences(send, data, local=false) {

    if (data == null) {
        data = { loc:         true,
                 mode:        "Slides",
                 theme:       "default",
                 theme_light: "light",
                 ace:         "dreamweaver",
                 font_size:   100,
                 sound:       true
                };
    }

    if (local) {
        localStorage.setItem(PREFERENCES, JSON.stringify(data));
    }

    send([PREFERENCES, -1, "", data]);
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

var events = undefined;
var liaStorage = undefined;

class LiaScript {
    constructor(elem, script, url="", slide=0, channel=null) {
        events     = new LiaEvents();

        this.app = Elm.Main.embed(elem, {url: url, script: script, slide: slide });

        this.initSpeech2JS(this.app.ports.speech2js.subscribe, this.app.ports.speech2elm.send);
        this.initChannel(channel, this.app.ports.event2elm.send);
        this.initEventSystem(this.app.ports.event2js.subscribe, this.app.ports.event2elm.send);


        liaStorage = new LiaStorage(channel);
    }

    initChannel(channel, send) {
        if(!channel)
            return;

        this.channel = channel;
        channel.on("service", e => { events.dispatch(e.event_id, e.message); });

        channel.join()
        .receive("ok", (e) => { initPreferences(send, e); })
        .receive("error", e => { console.log("Error channel join: ", e); });
    }

    reset() {
        this.app.ports.event2elm.send(["reset", -1, "", null]);
    }

    initEventSystem(jsSubscribe, elmSend) {
        //console.log("initEventSystem");

        let self = this;

        jsSubscribe(function(cmd) {
            //console.log("elm2js", cmd);

            switch (cmd[0]) {
                case "slide": {
                    if(self.channel)
                        self.channel.push("party", { slide: cmd[1] + 1 })
                    break;
                }
                case "load": {
                    self.db.load(cmd[2], cmd[1]);
                    break;
                }
                case "code" : {
                    cmd[2].forEach(function(e) {
                        switch(e[0]) {
                            case "store": {
                                self.db.store("code", cmd[1], e[1]);
                                break;
                            }
                            case "eval": {
                                lia_eval(
                                  e[2],
                                  { lia: lia_eval_event(elmSend, cmd[1], e[1], "code"),
                                    service: websocket(self.channel),
                                    handle: (name, fn) => { events.register_input(cmd[1], e[1], name, fn) }
                                  }
                                );
                                break;
                            }
                            case "input": {
                                events.dispatch_input(cmd[1], e[1], "input", e[2]);
                                break;
                            }
                            case "stop": {
                                events.dispatch_input(cmd[1], e[1], "stop", e[2]);
                                break;
                            }
                            default: {
                                //console.log("handling Event: ", e, cmd[1]);
                                self.db.update(e, cmd[1]);
                            }
                        }});

                    break;
                }
                case "quiz" : {
                    self.db.store("quiz", cmd[1], cmd[2]);
                    break;
                }
                case "survey" : {
                    self.db.store("survey", cmd[1], cmd[2]);
                    break;
                }
                case "effect" : {
                    cmd[2].forEach(function(e) {
                      switch(e[0]) {
                          case "execute": {
                              lia_execute( e[2], e[1],
                                         { lia: lia_eval_event(elmSend, cmd[1], e[1], "effect"),
                                           service: websocket(self.channel),
                                         });
                              break;
                          }
                          case "focus": {
                              scrollIntoView(e[2], e[1]);
                              break;
                          }
                          default: {
                              console.log("effect missed", cmd, e);
                          }
                      }});

                    break;
                }
                case PREFERENCES: {
                    if (self.channel) {
                        self.channel.push("party", {preferences: cmd[2]});
                    } else {
                        localStorage.setItem(PREFERENCES, JSON.stringify(cmd[2]));
                    }
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
                        else {
                            tag.src = url;
                            tag.async = false;
                        }
                        document.head.appendChild(tag);

                    } catch (e) {
                        console.log(e.message);
                    }
                    break;
                }
                case "init": {
                    self.db = new LiaDB(cmd[2][1],
                                        1,
                                        elmSend,
                                        self.channel,
                                        { table: "code", id: cmd[1] });

                    document.title = cmd[2][0];

                    if (!self.channel) {
                        let prefs = localStorage.getItem(PREFERENCES);
                        initPreferences(elmSend, prefs ? JSON.parse(prefs) : prefs, true);
                    }

                    break;
                }
                case "reset": {
                    self.db.del();
                    if(!self.channel) {
                        initPreferences(elmSend, null, true);
                    }
                    break;
                }
                default:
                    console.log("Command not found: ", cmd);
              }
        });
    }


    initSpeech2JS(jsSubscribe, elmSend) {
       jsSubscribe(function(cmd) {
          try {
              switch (cmd[0]) {
                  case "speak":
                      responsiveVoice.speak( cmd[2], cmd[1],
                                             {  onend: e => { elmSend(["end", ""]); },
                                              onerror: e => { elmSend(["error", e.toString()]);}}
                                            );
                      break;
                  case "cancel":
                      elmSend(["end", ""]);
                      responsiveVoice.cancel();
                      break;
                  default:
                      console.log(cmd);
                  }
          } catch (e) {
              elmSend(["error", e.toString()]);
          }
      });
    }
};

/*
module.exports = {
    LiaError,
    LiaScript
};
*/
