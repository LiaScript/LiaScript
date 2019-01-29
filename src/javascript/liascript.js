'use strict';

//import Elm from './app';

import { Elm } from "../elm/App.elm";


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

    getItems (key = []) {
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
      send.lia(String(eval(code+"\n", send)));
    } catch (e) {
        if (e instanceof LiaError )
            send.lia(e.message, e.details, false);
        else
            send.lia(e.message, [], false);
    }
};

/*
function lia_eval_event(send, id1, id2, source) {
    return function(event_, message, details=[], ok=true) {
        send([source, id1, event_, [ok, id2, message, details]]);
    };
};
*/

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
                send(init);

        };
        request.onsuccess = function(e) {
            if(init) {
                let db = request.result;
                let tx = db.transaction(init.topic, 'readonly');
                let store = tx.objectStore(init.topic);

                let item = store.get(init.section);

                item.onsuccess = function() {
                    //console.log("table", init.table, item.result);
                    if (item.result)
                        init.message.message = item.result.data;

                    send(init);
                };
                item.onerror = function() {
                    send(init);
                };
            }
        };
    }

    store(event) {
        if(this.channel) {
            this.channel.push("party", {
              store: event.topic,
              slide: event.section,
              data: event.message })
            .receive("ok",    e => { console.log("ok", e); })
            .receive("error", e => { console.log("error", e); });

            return;
        }


        liaLog(`liaDB: event(store), table(${event.topic}), id(${event.section}), data(${event.message})`)
        if (!this.indexedDB) return;

        let request = this.indexedDB.open(this.uidDB, this.versionDB);
        request.onsuccess = function(e) {
            let db = request.result;
            let tx = db.transaction(event.topic, 'readwrite');
            let store = tx.objectStore(event.topic);

            let item = {
                id:      event.section,
                data:    event.message,
                created: new Date().getTime()
            };

            store.put(item);

            tx.oncomplete = function() {
                // All requests have succeeded and the transaction has committed.
                console.log("stored data ...");
            };
        };
    }

    load(event) {
        let send = this.send;

        if (this.channel) {
            this.channel.push("party", {load: event.topic, slide: event.section})
            .receive("ok",    e => {
                event.message = {topic: "restore", section: -1, message: e.date}
                send(event);
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
                let tx = db.transaction(event.topic, 'readonly');
                let store = tx.objectStore(event.topic);

                let item = store.get(event.section);

                item.onsuccess = function() {
                    console.log("restore table", event.topic, item.result);
                    if (item.result) {
                        event.message = {
                          topic:"restore",
                          section: -1,
                          message: item.result.data };

                        send(event);
                    }
                };
                item.onerror = function() {
                    console.log("data not found ...");
                    if (event.topic == "code") {
                        event.message = {
                          topic:"restore",
                          section: -1,
                          message: null };
                        send(event);
                    }
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

var bag = document.createElement("div");

function storePersitent() {
    let elements = document.getElementsByClassName("persistent");

    for (var e of elements) {
        bag.appendChild(e);
    }
};

function loadPersistent() {
    let elements = document.getElementsByClassName("persistent");

    for (var e of elements) {
        for(var b of bag.childNodes) {
            if(b.id == e.id) {
                e.replaceWith(b);
                break;
            }
        }
    }
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

const SETTINGS = "settings";

function initSettings(send, data, local=false) {

  if (data == null) {
    data = {
      table_of_contents: true,
      mode:              "Slides",
      theme:             "default",
      light:             true,
      editor:            "dreamweaver",
      font_size:         100,
      sound:             true,
      land:              "en"
    };
  }

  if (local) {
    localStorage.setItem(SETTINGS, JSON.stringify(data));
  }

  send( {topic: SETTINGS, section: -1, message: data} );
};


function handleEffects(event, elmSend) {
  switch (event.topic) {
    case "scrollTo":
      scrollIntoView( event.message, 350 );
      break;
    case "execute":
      lia_execute_event( event.message );
      break;
    case "speak" : {
      let msg = {
        topic: "effect",
        section: -1,
        message: {
          topic: "speak_end",
          section: -1,
          message: ""
        }
      };

      try {
        if ( event.message == "cancel" ) {
          responsiveVoice.cancel();
          elmSend( msg );
        }
        else if (event.message == "repeat") {
          msg.message = event;
          elmSend( msg );
        }
        else {
          responsiveVoice.speak(
            event.message[1],
            event.message[0],
            { onend: e => {
                elmSend( msg );
              },
              onerror: e => {
                msg.message.message = e.toString();
                elmSend(msg);
              }});
        }
      } catch (e) {
        msg.message.message = e.toString();
        elmSend(msg);
      }
      break;
    }
    default:
      console.log("effect missed", event);
  }
};

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

var events = undefined;
var liaStorage = undefined;

class LiaScript {
    constructor(elem, course = null, script = null, url="", slide=0, spa = true, debug = false, channel=null) {

        events     = new LiaEvents();

        this.app = Elm.App.init({
            node: elem,
            flags: {
                course: course,
                script: script,
                debug: debug,
                spa: spa
            }
        });

        let send_to = this.app.ports.event2elm.send;

        let sender = function(msg) {
          console.log("event2elm :- ", msg);
          send_to(msg);
        };

        let settings = localStorage.getItem(SETTINGS);
        initSettings(this.app.ports.event2elm.send, settings ? JSON.parse(settings) : settings, true);

        this.initChannel(channel, sender);
        this.initEventSystem(this.app.ports.event2js.subscribe, sender);

        liaStorage = new LiaStorage(channel);
    }

    initChannel(channel, send) {
        if(!channel)
            return;

        this.channel = channel;
        channel.on("service", e => { events.dispatch(e.event_id, e.message); });

        channel.join()
        .receive("ok", (e) => { initSettings(send, e); })
        .receive("error", e => { console.log("Error channel join: ", e); });
    }

    reset() {
        this.app.ports.event2elm.send({ topic: "reset", section: -1, message: null});
    }

    initEventSystem(jsSubscribe, elmSend) {
        //console.log("initEventSystem");

        let self = this;

        jsSubscribe(function(event) {
            console.log("elm2js", event);

            switch (event.topic) {
                case "slide": {
                    if(self.channel)
                        self.channel.push("party", { slide: event.section + 1 });

                    let sec = document.getElementsByTagName("section")[0];
                    if(sec) {
                        sec.scrollTo(0,0);
                    }
                    break;
                }
                case "load": {
                    self.db.load({
                      topic: event.message,
                      section: event.section,
                      message: null });
                    break;
                }
                case "code" : {
                    switch (event.message.topic) {
                      case "store":
                          event.message = event.message.message;
                          self.db.store(event);
                          break;
                      default: {
                          console.log("unknown code: ", event.message);
                      }

                    }
                /*    event.message.forEach(function(e) {
                        switch(e[0]) {
                            case "store": {
                                self.db.store({topic: "code", section: event.section, message: e[1]});
                                break;
                            }
                            case "eval": {
                                lia_eval(
                                  e[2],
                                  { lia: lia_eval_event(elmSend, event.section, e[1], "code"),
                                    service: websocket(self.channel),
                                    handle: (name, fn) => { events.register_input(event.section, e[1], name, fn) }
                                  }
                                );
                                break;
                            }
                            case "input": {
                                events.dispatch_input(event.section, e[1], "input", e[2]);
                                break;
                            }
                            case "stop": {
                                events.dispatch_input(event.section, e[1], "stop", e[2]);
                                break;
                            }
                            default: {
                                //if (e[0] == "load") {
                                //    events.dispatch_input(cmd[1], e[1], "load_version", null);
                                //}
                                //console.log("handling Event: ", e, cmd[1]);
                                self.db.update(e, event.section);

                            }
                        }});
*/
                    break;
                }
                case "quiz" : {
                    if (event.message.topic == "store") {
                        event.message = event.message.message;
                        self.db.store(event);
                    } else if (event.message.topic == "eval") {
                        lia_eval_event(elmSend, self.channel, event);
                    }

                    break;
                }
                case "survey" : {
                    if (event.message.topic == "store") {
                        event.message = event.message.message;
                        self.db.store(event);
                    }
                    break;
                }
                case "effect" :
                  handleEffects(event.message, elmSend);
                  break;
                case SETTINGS: {
                  if (self.channel) {
                    self.channel.push("party", {settings: event.message});
                  } else {
                    localStorage.setItem(SETTINGS, JSON.stringify(event.message));
                  }
                  break;
                }
                case "ressource" : {
                    let elem = event.message[0];
                    let url  = event.message[1];

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
                        console.log(e.msg);
                    }
                    break;
                }
                case "persistent": {
                    if(event.message == "store") {
                        storePersitent();
                        elmSend({topic: "load", section: event.section, message: null});
                    }
                    else {
                        setTimeout( (e) => { loadPersistent() }, 150 );
                    }

                    break;
                }
                case "init": {
                    self.db = new LiaDB (
                      event.message[0], 1, elmSend, self.channel,
                      {
                        topic: "code",
                        section: event.section,
                        message: {
                          topic:"restore",
                          section: -1,
                          message: null }
                      });

                    if(event.message[1] != "") {
                        lia_execute_event( event.message[1], 350, {});
                    }

                    if (!self.channel) {
                        let settings = localStorage.getItem(SETTINGS);
                        initSettings(elmSend, settings ? JSON.parse(settings) : settings, true);
                    }

                    break;
                }
                case "reset": {
                    self.db.del();
                    if(!self.channel) {
                        initSettings(elmSend, null, true);
                    }
                    break;
                }
                default:
                    console.log("Command not found: ", event);
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

export { LiaScript };
