// Builds the name lists in src/typescript/liascript/service/helper/voice-gender.ts
// from the records in this folder:
//
//   node tests/tts-voices/generate.mjs
//
// Name words are taken from the place where each platform puts the voice name
// (see candidates below). A word is only listed if all voices containing it
// have the same gender, so "tom" (also "mms-tom") or "whisper" (also Apple's
// neutral "Whisper") are left out.

import { execFileSync } from 'node:child_process'
import fs from 'node:fs'
import path from 'node:path'

import {
  GOOGLE_NAME,
  voiceWords,
} from '../../src/typescript/liascript/service/helper/voice-gender.ts'

const dir = path.dirname(new URL(import.meta.url).pathname)
const target = path.join(
  dir,
  '../../src/typescript/liascript/service/helper/voice-gender.ts'
)

const voices = [
  'apple-google.json',
  'microsoft.json',
  'linux-speechd.json',
  'piper-mms.json',
].flatMap(f => JSON.parse(fs.readFileSync(path.join(dir, f), 'utf8')))

const gender = v =>
  v.gender === 'female' || v.gender === 'male' ? v.gender : 'unknown'

// "unknown" + "inferred" means that no source was found, not that the voice
// has no gender
const unchecked = v => v.gender === 'unknown' && v.confidence === 'inferred'

const split = s => s.toLowerCase().split(/[^a-zÀ-￿]+/)

// The words of a voice that are its name
function candidates(v) {
  let m
  switch (v.engine) {
    case 'apple': {
      // "Anna (Enhanced)", "com.apple.voice.compact.de-DE.Anna",
      // "com.apple.ttsbundle.siri_Helena_de-DE_compact"
      const words = split(v.name.split(' (')[0])
      if ((m = (v.voiceURI || '').match(/^com\.apple\..*\.([^.]+)$/))) {
        words.push(
          ...split(
            m[1]
              .replace(/^siri_/, '')
              .replace(/(_[a-z]{2,3}-[A-Za-z]{2,4})?[_-](compact|premium)$/, '')
          )
        )
      }
      return words
    }
    case 'microsoft-sapi':
    case 'microsoft-onecore':
    case 'microsoft-online':
      // "Microsoft Katja Online (Natural) - German (Germany)"
      m = v.name.match(/^Microsoft (\S+?)(?:Multilingual)?(?:\s|$)/)
      return m ? split(m[1]) : []
    case 'rhvoice':
    case 'pico':
    case 'cepstral-swift':
    case 'epos':
      // "Anna rhvoice"
      return split(v.name.split(/[\s-]/)[0])
    case 'espeak-ng':
      // "German+Annie"
      m = v.name.match(/\+([A-Za-z][\w-]*)/)
      return m ? split(m[1]) : []
    case 'google-android':
      // "… de-de-x-dea-network"
      m = v.name.match(/-x-([a-z]{3})(?:-|$)/)
      return m ? [m[1]] : []
    case 'piper':
    case 'mimic3':
      // "de_DE-thorsten-high", "et_EE-news-medium#Mari", "de_DE/thorsten_low"
      m = v.name.match(
        /^[a-z]{2,3}(?:_[A-Za-z]{2,3}[-/]|\/)([^\s#?]+?)[-_](?:x_low|low|medium|high)(?:#(\S+))?/
      )
      return m ? split(m[1] + ' ' + (m[2] || '')) : []
  }
  return []
}

// Descriptive words from model, speaker or variant names that could also be
// part of other voices ("thorsten_emotional#sleepy", "fast_test")
const NO_NAMES = new Set(
  (
    'amused angry croak demonic disgusted drunk emotion emotional fast female ' +
    'half hifi hours institut male multi neutral serious single sleepy storm ' +
    'surprised test tweaky'
  ).split(' ')
)

// word -> genders of all voices containing it
const seen = {}
for (const v of voices) {
  if (unchecked(v)) continue
  for (const word of new Set(voiceWords(v.name, v.voiceURI ?? v.name))) {
    ;(seen[word] ??= new Set()).add(gender(v))
  }
}

const names = { female: new Set(), male: new Set() }
for (const v of voices) {
  for (const word of candidates(v)) {
    const genders = seen[word]
    if (
      word.length >= 3 &&
      !NO_NAMES.has(word) &&
      genders &&
      genders.size === 1 &&
      !genders.has('unknown')
    ) {
      names[[...genders][0]].add(word)
    }
  }
}

// Chrome desktop and ChromeOS: "deutsch 2" -> genders
const google = {}
for (const v of voices) {
  const m = v.name.replace(/\s+/g, ' ').toLowerCase().match(GOOGLE_NAME)
  if (m) (google[m[1]] ??= new Set()).add(gender(v))
}
const googleNames = { female: [], male: [] }
for (const [key, genders] of Object.entries(google)) {
  if (genders.size > 1) {
    console.warn(`google: "${key}" is ${[...genders].join(' and ')}, left out`)
  } else if (!genders.has('unknown')) {
    googleNames[[...genders][0]].push(key)
  }
}

// --- write ---------------------------------------------------------------------

const escape = s => s.replace(/[.*+?^${}()|[\]\\\/-]/g, '\\$&')

// Words as one regular expression with shared prefixes merged:
// "dea deb deg" -> /^de[abg]$/
function regex(words) {
  words = [...words].sort()
  if (!words.length) return '/(?!)/'
  const root = {}
  for (const word of words) {
    let node = root
    for (const c of word) node = node[c] ??= {}
    node[''] = {}
  }
  const emit = node => {
    const end = '' in node
    const alts = Object.keys(node)
      .filter(c => c)
      .sort()
      .map(c => escape(c) + emit(node[c]))
    if (!alts.length) return ''
    // a single character, a class or a group can take a "?" directly
    let body = alts[0]
    let atom = /^\\?.$/.test(body)
    if (alts.length > 1) {
      atom = true
      body = alts.every(a => /^\\?.$/.test(a))
        ? '[' + alts.join('') + ']'
        : '(?:' + alts.join('|') + ')'
    }
    if (!end) return body
    return atom ? body + '?' : '(?:' + body + ')?'
  }
  const source = '^' + emit(root) + '$'
  const re = new RegExp(source)
  for (const word of words) {
    if (!re.test(word)) throw new Error(`regex does not match "${word}"`)
  }
  return '/' + source + '/'
}

const block = [
  '// <generated> by tests/tts-voices/generate.mjs, do not edit',
  `const NAMES_FEMALE = ${regex(names.female)}`,
  `const NAMES_MALE = ${regex(names.male)}`,
  `const GOOGLE_FEMALE = ${regex(googleNames.female)}`,
  `const GOOGLE_MALE = ${regex(googleNames.male)}`,
  '// </generated>',
].join('\n')

const source = fs.readFileSync(target, 'utf8')
fs.writeFileSync(
  target,
  source.replace(/\/\/ <generated>[\s\S]*?\/\/ <\/generated>/, block)
)
execFileSync('npx', ['prettier', '--write', target], { stdio: 'ignore' })
console.log(
  `names ${names.female.size} female, ${names.male.size} male,`,
  `google ${googleNames.female.length + googleNames.male.length},`,
  `${Buffer.byteLength(block)} bytes`
)
