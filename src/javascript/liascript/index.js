'use strict';

import { Elm } from "../../elm/App.elm";
import { LiaDB } from "./database";
import { LiaStorage } from "./storage";
import { LiaEvents, lia_execute_event, lia_eval_event } from "./events";
import { SETTINGS, initSettings } from "./settings";
import { storePersitent, loadPersistent } from "./persistent";

function liaLog (string) {
    //if(window.debug__)
        console.log(string);
};


function scrollIntoView (id, delay) {
    setTimeout( function (e) {
        try {
            document.getElementById(id).scrollIntoView({behavior: "smooth"});
        } catch (e) {}
    }, delay);
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
                      case "eval":
                          lia_eval_event(elmSend, self.channel, event);
                          break;
                      case "store":
                          event.message = event.message.message;
                          self.db.store(event);
                          break;
                      case "input":
                      case "stop":
                          events.dispatch_input(event);
                          break;
                      default: {
                          self.db.update(event.message, event.section);
                      }
                    }
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
};

export { LiaScript };
