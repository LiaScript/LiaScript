// Builds src/typescript/webcomponents/formula/a11y/unicode.json from KaTeX's
// symbol table, so that a formula typed as "x ≤ 2" is read like "x \le 2":
//
//   node tests/formula-a11y/generate.mjs
//
// Run it again after updating KaTeX.

import fs from 'node:fs'
import path from 'node:path'
import { createRequire } from 'node:module'

const dir = path.dirname(new URL(import.meta.url).pathname)
const target = path.join(
  dir,
  '../../src/typescript/webcomponents/formula/a11y/unicode.json'
)

const katex = createRequire(import.meta.url).resolve('katex/dist/katex.mjs')
const source = fs.readFileSync(katex, 'utf8')

// defineSymbol(math, main, rel, "≤", "\\leq", true);
const unicode = {}
for (const [, char, name] of source.matchAll(
  /defineSymbol\(math, \w+, \w+, ("(?:[^"\\]|\\.)*"), ("(?:[^"\\]|\\.)*")/g
)) {
  const c = JSON.parse(char)
  const n = JSON.parse(name)
  if (c && c !== n && [...c].length === 1 && c.charCodeAt(0) > 127) {
    ;(unicode[c] ??= []).includes(n) || unicode[c].push(n)
  }
}

// names that are characters themselves, as "·" for "⋅"
for (const names of Object.values(unicode)) {
  for (const n of names) {
    if ([...n].length === 1 && n.charCodeAt(0) > 127 && !unicode[n]) {
      unicode[n] = names.filter((x) => x !== n)
    }
  }
}

const entries = Object.entries(unicode)
  .sort(([a], [b]) => a.codePointAt(0) - b.codePointAt(0))
  .map(([c, names]) => `  ${JSON.stringify(c)}: ${JSON.stringify(names)}`)

// JSON, not a TS object literal: the minifier unquotes keys like "℘", which
// Firefox 48 (KaiOS) rejects as identifiers; Parcel keeps JSON as a string
fs.writeFileSync(target, `{\n${entries.join(',\n')}\n}\n`)

console.log(entries.length, 'characters ->', path.relative(process.cwd(), target))
