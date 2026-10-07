// node --test tests/tts-voices/
//
// A voice must never get the wrong gender; voices that have no gender (neutral
// novelty voices, MMS, mixed multi-speaker models, …) must stay unknown. Not
// detecting a gender is allowed, the coverage is printed per engine. Voices
// whose gender is unknown only because the research found none ("unknown",
// "inferred") are not checked.

import { test } from 'node:test'
import assert from 'node:assert/strict'
import fs from 'node:fs'
import path from 'node:path'

import { detectGender } from '../../src/typescript/liascript/service/helper/voice-gender.ts'

type Voice = {
  name: string
  voiceURI?: string
  lang: string
  gender: 'female' | 'male' | 'neutral' | 'unknown'
  engine: string
  browser?: string[]
  confidence?: string
}

const dir = import.meta.dirname

for (const file of fs
  .readdirSync(dir)
  .filter(f => /^[a-z-]+\.json$/.test(f) && f !== 'sources.json')) {
  const voices: Voice[] = JSON.parse(
    fs.readFileSync(path.join(dir, file), 'utf8')
  )

  test(file, () => {
    const wrong: string[] = []
    const stats: Record<
      string,
      { voices: number; detected: number; gendered: number }
    > = {}

    for (const v of voices) {
      const expected =
        v.gender === 'female' || v.gender === 'male' ? v.gender : 'unknown'
      const got = detectGender(v.name, v.voiceURI ?? v.name)
      const s = (stats[v.engine] ??= { voices: 0, detected: 0, gendered: 0 })
      s.voices++
      if (expected !== 'unknown') s.gendered++
      if (got === expected && expected !== 'unknown') s.detected++
      const unchecked = v.gender === 'unknown' && v.confidence === 'inferred'
      if (got !== 'unknown' && got !== expected && !unchecked) {
        wrong.push(
          `${v.name} | ${v.voiceURI ?? ''}: ${v.gender}${v.confidence ? ' (' + v.confidence + ')' : ''}, got ${got}`
        )
      }
    }

    console.log(`\n${file}`)
    console.table(
      Object.fromEntries(
        Object.entries(stats).map(([engine, s]) => [
          engine,
          {
            ...s,
            coverage: s.gendered
              ? Math.round((100 * s.detected) / s.gendered) + '%'
              : '-',
          },
        ])
      )
    )
    assert.deepEqual(wrong, [], `${wrong.length} voices with the wrong gender`)
  })
}

test('requested voice names', () => {
  for (const [name, gender] of [
    ['German Female', 'female'],
    ['German Male', 'male'],
    ['Deutsch Female', 'female'],
    ['UK English Male', 'male'],
    ['US English Female', 'female'],
    ['German', 'unknown'],
  ] as const) {
    assert.equal(detectGender(name), gender, name)
  }
})
