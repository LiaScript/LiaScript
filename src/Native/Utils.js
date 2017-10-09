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
        try {
              setTimeout( function () {
                  console.log(url);
                  var scriptTag = document.createElement('script');
                  scriptTag.src = url;
                  document.head.appendChild(scriptTag);
              }, lib_js_counter * 100);
              //wait(100);

          return {
                ctor: "Ok",
                  _0: ""
          };
        } catch (e) {
            return {
                ctor: "Err",
                _0: e.message
            };
        }
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

    return {
        highlight: F2(highlight),
        formula: F2(formula),
        evaluate: evaluate,
        evaluate2: F2(evaluate2),
        load_js: load_js
    };
})();
