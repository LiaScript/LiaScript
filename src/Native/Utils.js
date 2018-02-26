const hljs = require("highlight.js");

// katex is an umd module that only support CommonJS, AMD and globals but not brunch modules
//  -> we have to use globals by setting katex as a static ressource in brunch...

var _user$project$Native_Utils = (function () {
    function highlight (language, code) {
        try {
            if (language != "")
                return hljs.highlight(language, code).value;
            else
                return hljs.highlightAuto(code, hljs.listLanguages()).value;
        } catch (e) {
            return "<b><font color=\"red\">"+e.message+"</font></b><br>"+code;
        }
    };

    function highlightAuto (code) {
        try {
            return hljs.highlightAuto(code).language;
        } catch (e) {
            return "bash";
        }
    };

    function formula(dMode, str) {
        try{
            return katex.renderToString(str, {displayMode: dMode});
        } catch(e) {
            return "<b><font color=\"red\">"+e.message+"</font></b><br>";
        }
    }

    function evaluate(code)
    {
        try { var rslt = String(eval(code));
              return {
                  ctor: "Ok",
                  _0: rslt
              };
        } catch (e) {
            return {
                ctor: "Err",
                _0: e.message
            };
        }
    };

    function execute(delay, code)
    {
        setTimeout(function(){
          try {
              var rslt = String(eval(code));
          }
          catch (e) { }
        }, delay);

    };

    function toUnixNewline(code)
    {
        var pos = code.search("\n");

        if (code[pos+1] != "\r")
            return code
        else
            return code.replace(/\r/g, "");
    }

    function string_replace(s, r, string)
    {
        return string.replace(new RegExp(s, 'g'), r);
    }

/*
    function wait(ms) {
        var start = new Date().getTime();
        var end = start;
        while(end < start + ms) {
            end = new Date().getTime();
        }
    }
*/
    var lib_js_counter = -1;

    function load_js(url)
    {
        lib_js_counter += 1;

        console.log("url: ", lib_js_counter, url);


        setTimeout( function () {
          try {
              var scriptTag = document.createElement('script');
              scriptTag.src = url;
              document.head.appendChild(scriptTag);

          } catch (e) {
              console.log(e.message);
          }
      }, lib_js_counter * 100);

      return {
          ctor: "Ok",
          _0: ""
      };
    };


    function evaluate2 (id, code) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
            setTimeout(function() {
                var evalJS = new Promise (
                    function (resolve, reject) {
                        try {
                            resolve({id: id, result: String(eval(code))});
                        }
                        catch (e) {
                            reject({id: id, result: e.message});
                        }
                    }
                );

                evalJS
                    .then(function(rslt) {
                        callback(_elm_lang$core$Native_Scheduler.succeed(rslt));
                    })
                    .catch(function(rslt) {
                        callback(_elm_lang$core$Native_Scheduler.fail(rslt));
                    });
            }, 10);
        });
    };

    function get_local (key) {
        try {
            var value = localStorage.getItem(key);

            if (typeof(value) === "string") {
                return { ctor : "Just", _0:  value };
            }
        } catch (e) {

        }

        return { ctor: "Nothing" };
    };

    function set_local (key, value) {
        try {
            localStorage.setItem(key, value);
            return value;
        } catch (e) {
            return value;
        }
    };

    function set_title (title) {
        document.title = title;
    };

    return {
        highlight: F2(highlight),
        highlightAuto: highlightAuto,
        formula: F2(formula),
        evaluate: evaluate,
        evaluate2: F2(evaluate2),
        execute: F2(execute),
        load_js: load_js,
        get_local: get_local,
        set_local: F2(set_local),
        toUnixNewline: toUnixNewline,
        set_title: set_title,
        string_replace: F3(string_replace)
    };
})();
