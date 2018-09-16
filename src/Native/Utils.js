// katex is an umd module that only support CommonJS, AMD and globals but not brunch modules
//  -> we have to use globals by setting katex as a static ressource in brunch...


var _user$project$Native_Utils = (function () {

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
        setTimeout(() => {eval(code)}, delay);
    };

    function toUnixNewline(code)
    {
        var pos = code.search("\n");

        if (code[pos+1] == "\r")
            code = code.replace(/\r/g, "");

        return code.replace(/\\\n/g, "\\ \n")
    }

    function string_replace(s, r, string)
    {
        return string.replace(new RegExp(s, 'g'), r);
    }

    function load(elem, url)
    {
        console.log(elem, ":", url);

        try {
            var tag = document.createElement(elem);
            if(elem == "link") {
              tag.href = url;
              tag.rel  = "stylesheet";
            }
            else
              tag.src = url;
            document.head.appendChild(tag);

        } catch (e) {
            console.log(e.message);
        }

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
                            resolve({id: id, message: String(eval(code)), details: []});
                        }
                        catch (e) {
                            if (e instanceof LiaError ) {
                                reject({id: id, message: e.message, details: e.details});
                            } else {
                                reject({id: id, message: e.message, details: []});
                            }
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

    function set_title (title) {
        document.title = title;
    };

    function scrollIntoView (id) {
        setTimeout(function(e){
            try {
                document.getElementById(id).scrollIntoView({behavior: "smooth"});
            } catch (e) {}
        }, 500);
    };

    return {
        formula: F2(formula),
        evaluate: evaluate,
        evaluate2: F2(evaluate2),
        execute: F2(execute),
        load: F2(load),
        toUnixNewline: toUnixNewline,
        set_title: set_title,
        string_replace: F3(string_replace),
        scrollIntoView: scrollIntoView
    };
})();
