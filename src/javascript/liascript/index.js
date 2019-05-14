'use strict';

import { Elm } from "../../elm/App.elm";
import { LiaDB } from "./database";
import { LiaStorage } from "./storage";
import { LiaEvents, lia_execute_event, lia_eval_event } from "./events";
import { SETTINGS, initSettings } from "./settings";
import { persistent } from "./persistent";
import { lia } from "./logger";

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
    case "persistent":
      setTimeout((e) => { persistent.load(event.section) }, 10);
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
      lia.warn("effect missed", event);
  }
};

function meta(name, content) {
  if(content != "") {
    let meta = document.createElement('meta');
    meta.name = name;
    meta.content = content;
    document.getElementsByTagName('head')[0].appendChild(meta);
  }
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

var eventHandler = undefined;
var liaStorage   = undefined;


class LiaScript {
    constructor(elem, debug = false, course = null, script = null, url="", slide=0, spa = true, channel=null) {

        if(debug)
            window.debug__ = true;

        eventHandler = new LiaEvents();

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
          lia.log("event2elm => ", msg);
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
        channel.on("service", e => { eventHandler.dispatch(e.event_id, e.message); });

        channel.join()
        .receive("ok", (e) => { lia.log("joined to channel", e) }) //initSettings(send, e); })
        .receive("error", e => { lia.error("channel join => ", e); });
    }

    reset() {
        this.app.ports.event2elm.send({ topic: "reset", section: -1, message: null});
    }

    initEventSystem(jsSubscribe, elmSend) {
        lia.log("initEventSystem");

        let self = this;

        jsSubscribe(function(event) {
            lia.log("elm2js => ", event);

            switch (event.topic) {
                case "slide": {
                    //if(self.channel)
                    //    self.channel.push("lia", { slide: event.section + 1 });

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
                          lia_eval_event(elmSend, self.channel, eventHandler, event);
                          break;
                      case "store":
                          event.message = event.message.message;
                          self.db.store(event);
                          break;
                      case "input":
                          eventHandler.dispatch_input(event);
                          break;
                      case "stop":
                          eventHandler.dispatch_input(event);
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
                        lia_eval_event(elmSend, self.channel, eventHandler, event);
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
                  //if (self.channel) {
                  //  self.channel.push("lia", {settings: event.message});
                  //} else {
                    localStorage.setItem(SETTINGS, JSON.stringify(event.message));
                  //}
                  break;
                }
                case "resource" : {
                    let elem = event.message[0];
                    let url  = event.message[1];

                    lia.log("loading resource => ", elem, ":", url);

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
                        lia.error("loading resource => ", e.msg);
                    }
                    break;
                }
                case "persistent": {
                    if(event.message == "store") {
                        persistent.store(event.section);
                        elmSend({topic: "load", section: -1, message: null});
                    }

                    break;
                }
                case "init": {

                  let [title, readme, version, onload, author, comment, logo] = event.message;

                    self.db = new LiaDB (
                      readme, version, elmSend, null, //self.channel,
                      {
                        topic: "code",
                        section: event.section,
                        message: {
                          topic:"restore",
                          section: -1,
                          message: null }
                      });

                    if(onload != "")
                        lia_execute_event( {code: onload, delay: 350});

                    meta("author",         author);
                    meta("og:description", comment);
                    meta("og:title",       title);
                    meta("og:type",        "website");
                    meta("og:url",         "");
                    meta("og:image",       logo);

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
                    window.location.reload();
                    break;
                }
                default:
                    lia.error("Command not found => ", event);
              }
        });
    }
};

export { LiaScript };
