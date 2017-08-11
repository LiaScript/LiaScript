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

    function mathjax () {
        try {
            setTimeout(function(){
                var mjax = document.getElementsByClassName("mjx-chtml")
                for (var i = 0; i < mjax.length; ++i) {
                    mjax[i].remove();
                }

                MathJax.Hub.Queue(["Typeset", MathJax.Hub]);
            }, 10);
        } catch (e) {
            console.log(e.message);
        }
    }

    return {
        highlight: F2(highlight),
        mathjax: mathjax
    };
})();
