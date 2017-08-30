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

    return {
        highlight: F2(highlight),
        formula: F2(formula),
        evaluate: evaluate
    };
})();
