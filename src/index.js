import { Elm } from "./elm/App.elm";


function lia(elem, course = null, script = null, spa = true, debug = false) {
  return Elm.App.init({
    node: elem,
    flags: {
      course: course,
      script: script,
      debug: debug,
      spa: spa
    }
  });
};

var app = lia(document.body);
