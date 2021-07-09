import './types/responsiveVoice'

const TTS = {
  inject: function (key: string) {
    if (typeof key === 'string') {
      setTimeout(function () {
        const script = document.createElement('script')
        script.src =
          'https://code.responsivevoice.org/responsivevoice.js?key=' + key
        script.async = true
        script.defer = true
        document.head.appendChild(script)

        script.onload = () => {
          window.responsiveVoice.init()
        }
      }, 250)
    }
  },

  cancel: function () {
    window.responsiveVoice.cancel()
  },

  speak: function (
    text: string,
    voice: string,
    onstart?: () => void,
    onend?: () => void,
    onerror?: (_: any) => void
  ) {
    window.responsiveVoice.speak(text, voice, {
      onstart: onstart,
      onend: onend,
      onerror: onerror,
    })
  },
}

export default TTS
