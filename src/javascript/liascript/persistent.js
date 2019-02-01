"use strict";


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

export { storePersitent, loadPersistent };
