type Beaker = {
  // capabilities: any;
  // contacts: any;
  // hyperdrive: any;
  // markdown: any;
  // panes: any;
  peersockets: Peersockets;
  // shell: any;
  // terminal: any;
};

type Peersockets = {
  join: (topic: string) => UserEvent;
  watch: () => Event;
};

type Message = {
  peerId: number;
  target: Event;
  type: string;
  message?: any;
};

interface UserEvent extends Event {
  send: (peerID: number, message: Uint8Array) => void;
}

interface Event {
  addEventListener: (topic: string, callback: (event: Message) => void) => void;
  close: any;
  dispatchEvents: any;
  removeEventListener: any;
  Symbol: object;
}

declare global {
  interface Window {
    beaker?: Beaker;
  }
}

export { Beaker, Message, Event, UserEvent };
