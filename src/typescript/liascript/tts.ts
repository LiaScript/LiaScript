import './types/responsiveVoice'


const TTS = {
  inject: function(key: string) {
    if (typeof key === "string") {
      let script = document.createElement("script")

      script.src = "https://code.responsivevoice.org/responsivevoice.js?key=" + key
      document.body.appendChild(script)

      script.onload = () => {
        window.responsiveVoice.init()
      }
    }
  },

  cancel: function() {
    window.responsiveVoice.cancel()
  },

  speak: function(text: string, voice: string,
    onstart?: (() => void),
    onend?: (() => void),
    onerror?: ((_:any) => void)) {
    window.responsiveVoice.speak(
      text,
      voice, {
        onstart: onstart,
        onend: onend,
        onerror: onerror
      })
  }
}

export default TTS
