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
    function evaluate2 (id, code) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
            try {
                var rslt = String(eval(code));
                callback(_elm_lang$core$Native_Scheduler.succeed(id, rslt);

            } catch (e) {
                callback(_elm_lang$core$Native_Scheduler.fail(e.message));
            }
        })
    };
*/
    return {
        highlight: F2(highlight),
        formula: F2(formula),
        evaluate: evaluate
    };
})();
