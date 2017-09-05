var _user$project$Native_Responsive = (function () {

    function cancel() {
        try {
            responsiveVoice.cancel();
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
    }

    function getVoices() {
        try {
            var voices = responsiveVoice.getVoices();
            var names = [];

            for (var i=0; i<voices.length; i++) {
                names.push ( voices[i].name );
            }

            return {
                ctor: "Ok",
                _0: names
            };
        } catch (e) {
            return {
                ctor: "Err",
                _0: e.message
            };
        }
    };


    function speak (voice, text) {
        return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback){
            try {
                responsiveVoice.speak(text,
                                      voice,
                                      {onend: function () {
                                                  if (callback)
                                                      callback(_elm_lang$core$Native_Scheduler.succeed());
                                              },
                                      onerror: function () {
                                                  if (callback)
                                                      callback(_elm_lang$core$Native_Scheduler.fail("error"));
                                              },
                                      });
            } catch (e) {
                callback(_elm_lang$core$Native_Scheduler.fail(e.message));
            }
        })
    };


    function voiceSupport() {
        try {
            if(responsiveVoice.voiceSupport()) {
                return true;
            }
            return false;
        } catch (e) {
            return false;
        }
    };



    return {
        cancel: cancel,
        getVoices: getVoices,
        speak: F2(speak),
        voiceSupport: voiceSupport
    };
})();
