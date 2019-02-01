"use strict";

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


export { LiaDB };
