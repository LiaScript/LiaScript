# TTS voices with gender

Test data for the voice gender detection in
`src/typescript/liascript/service/helper/voice-gender.ts`: how voices show
up in `speechSynthesis.getVoices()` across browsers and engines, and their
gender. Collected 2026-10-07.

```bash
node --test tests/tts-voices/          # no voice may get the wrong gender
node tests/tts-voices/generate.mjs     # rebuild the tables in voice-gender.ts
```

One record per line:

```json
{
  "name": "...",
  "voiceURI": "...",
  "lang": "de-DE",
  "gender": "female",
  "engine": "piper",
  "browser": ["firefox"],
  "confidence": "inferred"
}
```

- `name`: exactly as `SpeechSynthesisVoice.name`
- `voiceURI`: omitted if equal to `name`
- `gender`: `female` | `male` | `neutral` (novelty/robot voices) | `unknown`
  (no gender information exists, e.g. MMS, Android Chrome, mixed models);
  `neutral` and `unknown` must not be detected as male or female
- `browser`: omitted if not browser specific
- `confidence`: omitted if documented by a source, `inferred` if derived from
  the name, a speaker code or the measured pitch of a sample; `unknown` +
  `inferred` means no source was found, these are not checked

Source URLs per engine are in `sources.json`. Only names and gender labels
are taken from these sources.

| file                 | engines                                                                                               |
| -------------------- | ----------------------------------------------------------------------------------------------------- |
| `apple-google.json`  | Apple (Safari, Chrome on macOS), Google Chrome desktop, Android, ChromeOS                             |
| `microsoft.json`     | Windows SAPI desktop, OneCore, Edge online (natural) voices                                           |
| `linux-speechd.json` | speech-dispatcher: espeak-ng (+ variants), mbrola, RHVoice, festival, flite, pico, mimic3, MaryTTS, … |
| `piper-mms.json`     | Piper, Meta MMS-TTS (`mms-<iso639-3>`), Kokoro                                                        |

## Name formats

- **Firefox, Linux (speechd)**: only voices of the default speechd module,
  `name` = speechd voice name (`German+Annie`, `de_DE-thorsten-high`,
  `et_EE-news-medium#Mari`), `voiceURI` =
  `urn:moz-tts:speechd:<name, spaces and non-ASCII %-escaped>?<lang>`
  (SpeechDispatcherService.cpp)
- **Chrome, Linux (speechd)**: all modules, `name` = `voiceURI` =
  `<speechd name> <module>`, e.g. `German+Annie espeak-ng`
  (tts_linux.cc, needs `--enable-speech-dispatcher`)
- **Firefox, Windows**: `voiceURI` = `urn:moz-tts:sapi:<name>?<locale>`
- **Chrome/Edge, Windows**: OneCore names, `Microsoft Katja - German (Germany)`;
  Edge online: `Microsoft Katja Online (Natural) - German (Germany)`
- **Safari**: plain `name` (`Anna`), `voiceURI` like
  `com.apple.voice.compact.de-DE.Anna`; Chrome on macOS appends the language
  in the UI language for voices in several languages:
  `Eddy (Deutsch (Deutschland))`
- **Chrome, Android**: only language names (`Deutsch Deutschland`), no gender
- **ChromeOS**: `Chrome OS Deutsch 1`, `Google Deutsch 2 (Natural)`,
  `Android Speech Recognition and Synthesis from Google de-de-x-dea-network`
- speech-dispatcher voice types (`MALE1`, `FEMALE1`) never reach the browser
