// katex is an umd module that only support CommonJS, AMD and globals but not brunch modules
//  -> we have to use globals by setting katex as a static ressource in brunch...


var _user$project$Native_Utils = (function () {

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

    function toUnixNewline(code)
    {
        var pos = code.search("\n");

        if (code[pos+1] == "\r")
            code = code.replace(/\r/g, "");

        return code.replace(/\\\n/g, "\\ \n")
    }

    function scrollIntoView (id) {
        setTimeout(function(e){
            let elem = document.getElementById(id);
            if (elem)
                elem.scrollIntoView({behavior: "smooth"});
        }, 500);
    };

    return {
        formula: F2(formula),
        evaluate: evaluate,
        toUnixNewline: toUnixNewline,
        scrollIntoView: scrollIntoView
    };
})();
