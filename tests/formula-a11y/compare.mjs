// Compares the speech of our formula walker with the Speech Rule Engine
// (ClearSpeak), for all formulas of a Markdown file:
//
//   node tests/formula-a11y/compare.mjs static/README.md "Read-Aloud Tests" > report.md
//
// The optional heading limits it to that section (up to the next heading of
// the same or a higher level). SRE is only the yardstick, not the expected
// value. The ratio counts words, pauses are the commas of our text (SRE has
// none).

import fs from 'node:fs'
import { createRequire } from 'node:module'
import katex from 'katex'
import 'katex/contrib/mhchem/mhchem.js'

import renderA11yString from '../../src/typescript/webcomponents/formula/a11y/index.ts'

const sre = createRequire(import.meta.url)('speech-rule-engine')

const section = (text, heading) => {
  if (!heading) return text
  const lines = text.split('\n')
  const start = lines.findIndex((l) => /^#+ /.test(l) && l.includes(heading))
  if (start < 0) throw new Error('heading not found: ' + heading)
  const level = lines[start].match(/^#+/)[0].length
  const end = lines.findIndex(
    (l, i) => i > start && /^#+ /.test(l) && l.match(/^#+/)[0].length <= level
  )
  return lines.slice(start, end < 0 ? undefined : end).join('\n')
}

const md = section(fs.readFileSync(process.argv[2], 'utf8'), process.argv[3])
  .replace(/```[\s\S]*?```/g, '')
  .replace(/`[^`\n]*`/g, '')
const display = [...md.matchAll(/\$\$\n([\s\S]*?)\n\$\$/g)].map((m) => [m[1], true])
const inline = [
  ...md.replace(/\$\$[\s\S]*?\$\$/g, '').matchAll(/\$([^$\n]+)\$/g),
].map((m) => [m[1], false])
const formulas = [...inline, ...display]

const mathml = (tex, displayMode) =>
  katex
    .renderToString(tex, { output: 'mathml', displayMode, throwOnError: false, trust: true })
    .replace(/^<span class="katex">/, '')
    .replace(/<\/span>$/, '')

const ours = (tex, displayMode, lang) => {
  try {
    return renderA11yString(tex, { displayMode, trust: true }, lang)
  } catch (e) {
    return 'ERROR ' + e.message
  }
}

const speech = {}
for (const locale of ['en', 'de']) {
  await sre.setupEngine({ locale, domain: 'clearspeak', modality: 'speech' })
  await sre.engineReady()
  speech[locale] = formulas.map(([tex, d]) => {
    try {
      return sre.toSpeech(mathml(tex, d))
    } catch (e) {
      return 'ERROR ' + e.message
    }
  })
}

const words = (s) => s.split(/[\s,]+/).filter(Boolean).length
const pauses = (s) => (s.match(/,/g) || []).length
const cell = (s) => s.replace(/\|/g, '\\|').replace(/\n/g, ' ')
const median = (a) => a.sort((x, y) => x - y)[Math.floor(a.length / 2)]

const ratios = { en: [], de: [] }
const rows = formulas.map(([tex, d], i) => {
  const out = {}
  for (const lang of ['en', 'de']) {
    out[lang] = ours(tex, d, lang)
    ratios[lang].push(words(out[lang]) / Math.max(1, words(speech[lang][i])))
  }
  return `| \`${cell(tex)}\` | ${cell(out.en)} | ${cell(speech.en[i])} | ${cell(out.de)} | ${cell(speech.de[i])} | ${ratios.en[i].toFixed(1)} / ${ratios.de[i].toFixed(1)} | ${pauses(out.en)} |`
})

console.log(`# Formula speech: ours vs. SRE ClearSpeak

${formulas.length} formulas from \`${process.argv[2]}\`.
Median word ratio (ours / SRE): en ${median([...ratios.en]).toFixed(2)}, de ${median([...ratios.de]).toFixed(2)}.
Pauses (commas) in total, en: ${rows.reduce((n, _, i) => n + pauses(ours(...formulas[i], 'en')), 0)}.

| LaTeX | ours en | SRE en | ours de | SRE de | words en / de | pauses |
|---|---|---|---|---|---|---|
${rows.join('\n')}`)
