var _user$project$Native_Tts = (function () {

    function speak(voice, lang, text)
    {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
            try {
                var tts = new SpeechSynthesisUtterance(text);
                tts.lang = lang;
                for(var i=0; i<speechSynthesis.getVoices().length; i++) {
                    if (speechSynthesis.getVoices()[i].name == voice) {
                        tts.voice = speechSynthesis.getVoices()[i];
                        break;
                    }
                }

                tts.onend = function () {
                    if (callback) {
                        callback(_elm_lang$core$Native_Scheduler.succeed());
                    }
                };

                tts.onerror = function (e) {
                    if (callback) {
                        callback(_elm_lang$core$Native_Scheduler.fail(e.message));
                    }
                };

                speechSynthesis.speak(tts);

            } catch (e) {
                callback(_elm_lang$core$Native_Scheduler.fail(e.message));
            }
        })
    };

    function listen (continuous, interimResults, lang) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
            try {
                var recognition = new webkitSpeechRecognition();
                recognition.continuous = continuous;
                recognition.interimResults = interimResults;

                recognition.lang = lang;

                recognition.onend = function (e) {
                    if (callback) {
                        callback(_elm_lang$core$Native_Scheduler.fail("no results"));
                    }
                };

                recognition.onresult = function (e) {
                    // cancel onend handler
                    recognition.onend = null;
                    if (callback) {
                        callback(_elm_lang$core$Native_Scheduler.succeed(e.results[0][0].transcript));
                    }
                };

                // start listening
                recognition.start();
            } catch (e) {
                callback(_elm_lang$core$Native_Scheduler.fail(e.message));
            }
        });
    };

    function voices () {
        try {
            let name_list = [];
            let voice_list = speechSynthesis.getVoices();

            for (var i=0; i<voice_list.length; i++) {
                name_list.push (voice_list[i].name);
            }

            return {
                ctor: "Ok",
                _0: name_list.sort()
            };
        } catch (e) {
            return {
                ctor: "Err",
                _0: e.message
            };
        }
    };

    function languages () {
        try {
            let lang_list = [];
            let voice_list = speechSynthesis.getVoices();

            for (var i=0; i<voice_list.length; i++) {
                lang_list.push (voice_list[i].lang);
            }

            return {
                ctor: "Ok",
                _0: lang_list.sort()
            };
        } catch (e) {
            return {
                ctor: "Err",
                _0: e.message
            };
        }
    };


    return {
        speak: F3(speak),
        listen: F3(listen),
        voices: voices,
        languages: languages
    };
})();
