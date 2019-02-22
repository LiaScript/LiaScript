"use strict";

import { lia } from "./logger";

class LiaDB {
    constructor (uidDB, versionDB, send=null, channel=null, init=null) {
        this.channel = channel;
        this.send = send;
        this.versionDB = parseInt(versionDB);

        if (!this.versionDB || channel) return;

        this.indexedDB = window.indexedDB || window.mozIndexedDB || window.webkitIndexedDB || window.msIndexedDB || window.shimIndexedDB;

        if (!this.indexedDB) {
            lia.warn("your browser does not support indexedDB");
            return;
        }

        this.uidDB = uidDB;
        this.versionDB = versionDB;


        let request = this.indexedDB.open(this.uidDB, this.versionDB);
        request.onupgradeneeded = function(event) {
            lia.log("creating tables");

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
                    lia.log("table", init.table, item.result);
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
        if (!this.versionDB) return;

        if(this.channel) {
            this.channel.push("party", {
              store: event.topic,
              slide: event.section,
              data: event.message })
            .receive("ok",    e => { lia.log("ok", e); })
            .receive("error", e => { lia.log("error", e); });

            return;
        }

        lia.log(`liaDB: event(store), table(${event.topic}), id(${event.section}), data(${event.message})`)
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
                lia.log("stored data ...");
            };
        };
    }

    load(event) {
        if (!this.versionDB) return;

        let send = this.send;

        if (this.channel) {
            this.channel.push("party", {load: event.topic, slide: event.section})
            .receive("ok",    e => {
                event.message = {topic: "restore", section: -1, message: e.date}
                send(event);
            })
            .receive("error", e => { lia.error(e); });

            return;
        }

        if (!this.indexedDB) return;

        lia.log("loading => ", event.topic, event.section);

        let request = this.indexedDB.open(this.uidDB, this.versionDB);
        request.onsuccess = function(e) {
            try {
                let db = request.result;
                let tx = db.transaction(event.topic, 'readonly');
                let store = tx.objectStore(event.topic);

                let item = store.get(event.section);

                item.onsuccess = function() {
                    lia.log("restore table", event.topic, item.result);
                    if (item.result) {
                        event.message = {
                          topic:"restore",
                          section: -1,
                          message: item.result.data };

                        send(event);
                    }
                };
                item.onerror = function() {
                    lia.warn("data not found ...");
                    if (event.topic == "code") {
                        event.message = {
                          topic:"restore",
                          section: -1,
                          message: null };
                        send(event);
                    }
                };
            }
            catch (e) { lia.error(e); }
        };
    }

    del() {
        if (!this.versionDB) return;

        if (this.channel) return;

        if (!this.indexedDB) return;

        let request = this.indexedDB.deleteDatabase(this.uidDB);
        request.onerror = function(e) {
            lia.error("error deleting database:", this.uidDB);
        };
        request.onsuccess = function(e) {
            lia.log("database deleted: ", this.uidDB);
            lia.log(e.result); // should be undefined
        };
    }

    update(event, slide) {
        if (!this.versionDB) return;

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
                        let project = vector.data[event.section];

                        switch (event.topic) {
                            case "flip": {
                                if(event.message.topic == "view")
                                    project.file[event.message.section].visible = event.message.message;
                                else if(event.message.topic == "fullscreen")
                                    project.file[event.message.section].fullscreen = event.message.message;
                                break;
                            }
                            case "load": {
                                let e_ = event.message;
                                project.version_active = e_.version_active;
                                project.log = e_.log;
                                project.file = e_.file;
                                break;
                            }
                            case "version_update": {
                                let e_ = event.message;
                                project.version_active = e_.version_active;
                                project.log = e_.log;
                                project.version[e_.version_active] = e_.version;
                                break;
                            }
                            case "version_append": {
                                let e_ = event.message;
                                project.version_active = e_.version_active;
                                project.log = e_.log;
                                project.file = e_.file;
                                project.version.push(e_.version);
                                project.repository = {...project.repository, ...e_.repository};
                                break;
                            }
                            default: {
                                lia.warn("unknown update cmd: ", event);
                            }
                        }
                        vector.data[event[1]] = project;
                        store.put(vector);
                    }
                };
                item.onerror = function() {
                    lia.error("data not found ...");
                };
            }
            catch (e) { lia.error(e); }
        };
    }
};


export { LiaDB };
