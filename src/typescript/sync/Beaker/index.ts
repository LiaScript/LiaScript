import Lia from "../../liascript/types/lia.d";
import Beaker from "./beaker.d";

import { Sync as Base } from "../Base/index";

function encode(json: object) {
  return new TextEncoder().encode(JSON.stringify(json));
}

function decode(message: Uint8Array) {
  let string = new TextDecoder().decode(message);

  return JSON.parse(string);
}

export class Sync extends Base {
  private peerIds?: Set<number>;

  private peerEvent?: Beaker.Event;
  private slideEvent?: Beaker.UserEvent;

  private section?: number;

  isSupported() {
    return window.beaker && window.location.protocol === "hyper" ? true : false;
  }

  connect(send: Lia.Send, topic: string) {
    this.send = send;

    if (!window.beaker) {
      return;
    }

    let peerIds = new Set();
    this.peerIds = peerIds;

    let self = this;

    this.peerEvent = window.beaker.peersockets.watch();

    this.peerEvent.addEventListener("join", (e: Beaker.Message) => {
      peerIds.add(e.peerId);
    });
    this.peerEvent.addEventListener("leave", (e: Beaker.Message) => {
      peerIds.delete(e.peerId);
    });

    this.slideEvent = window.beaker.peersockets.join("slide");
    this.slideEvent.addEventListener(
      "message",
      function (event: Beaker.Message) {
        let message = decode(event.message);

        if (
          message.slide &&
          typeof message.slide == "number" &&
          message.slide !== self.section
        ) {
          send({
            topic: "goto",
            section: message.slide,
            message: null,
          });
        }
      }
    );
  }

  slide(slide: number, effect: number) {
    if (slide !== this.section) {
      this.section = slide;
      this.publish({ slide: slide });
    }
  }

  publish(message: Object) {
    if (this.slideEvent && this.peerIds) {
      let msg = encode(message);
      for (let peerId of this.peerIds) {
        this.slideEvent.send(peerId, msg);
      }
    }
  }
}
