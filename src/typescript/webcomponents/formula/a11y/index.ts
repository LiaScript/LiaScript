// @flow
/**
 * renderA11yString returns a readable string in the given language.
 *
 * In some cases the string will have the proper semantic math
 * meaning,:
 *   renderA11yString("\\frac{1}{2}"")
 *   -> "start fraction, 1, divided by, 2, end fraction"
 *
 * However, other cases do not:
 *   renderA11yString("f(x) = x^2")
 *   -> "f, left parenthesis, x, right parenthesis, equals, x, squared"
 *
 * The commas in the string aim to increase ease of understanding
 * when read by a screenreader.
 *
 * The words for every language live in ./<lang>.ts, a new language is a new
 * file plus an entry in LANGUAGES.
 */

// NOTE: since we're importing types here these files won't actually be
// included in the build.
import type { Atom } from 'katex/src/symbols.js'
import type { AnyParseNode } from 'katex/src/parseNode.js'
import type { SettingsOptions } from 'katex/src/Settings.js'

// $FlowIgnore: we import the types directly anyways
import katex from 'katex'

import en, { type Dict } from './en.ts'
import de from './de.ts'
import unicode from './unicode.ts'

const LANGUAGES: { [lang: string]: Dict } = { en, de }

// the dictionary of the current call and its language, the walk is synchronous
let t: Dict = en
let locale = 'en'

// "one" or "other" (or "few", ... in other languages) by Intl.PluralRules,
// old browsers (KaiOS) do not have it
const plural = (n: number, type: 'cardinal' | 'ordinal' = 'cardinal') => {
  try {
    return new Intl.PluralRules(locale, { type }).select(n)
  } catch (e) {
    return type === 'cardinal' && n === 1 ? 'one' : 'other'
  }
}

const form = (forms: { one: string; other: string }, n: number) =>
  (forms as any)[plural(n)] ?? forms.other

const entry = <T,>(map: Record<string, T>, key: string): T | undefined =>
  Object.prototype.hasOwnProperty.call(map, key) ? map[key] : undefined

// The units Intl.NumberFormat can read, "2 Stunden", "9,81 Meter pro Sekunde".
// Other units (N, kJ, m^2, ...) are read as they are written. Not "d" for day,
// 2\,\mathrm{d}x is a differential.
const UNITS: Record<string, string> = {
  m: 'meter',
  km: 'kilometer',
  cm: 'centimeter',
  mm: 'millimeter',
  s: 'second',
  ms: 'millisecond',
  min: 'minute',
  h: 'hour',
  g: 'gram',
  kg: 'kilogram',
  l: 'liter',
  L: 'liter',
  ml: 'milliliter',
  mL: 'milliliter',
  ha: 'hectare',
  '°': 'degree',
  '°C': 'celsius',
  '°F': 'fahrenheit',
}

// a number with its unit by Intl.NumberFormat, undefined for unknown units, in
// old browsers (KaiOS) and for numbers it would round
const formatUnit = (number: string, unit: string) => {
  const [integer, fraction = ''] = parseNumber(number)
  if (integer.length + fraction.length > 15) return
  try {
    return new Intl.NumberFormat(locale, {
      style: 'unit',
      unit,
      unitDisplay: 'long',
      useGrouping: false,
      minimumFractionDigits: fraction.length,
      maximumFractionDigits: fraction.length,
    }).format(numberValue(number))
  } catch (e) {}
}

// the decimal mark of the language, "1,5" or "1.5"
const decimalMark = () => {
  try {
    return (1.5).toLocaleString(locale).charAt(1)
  } catch (e) {
    return '.'
  }
}

// A pause of the voice, it becomes a comma. Pauses are only set at boundaries
// (relations, start and end of a structure, cells), "a plus b, gleich, c".
const PAUSE = '\u0001'

// A decimal comma written as 3{,}14. Numbers keep their separators while they
// are built ("12.345\u000267"), formatNumber writes them for the language.
const DECIMAL = '\u0002'
const NUMBER = /^\d[\d.\u0002]*$/

// within sub- and superscripts relations get no pause,
// "Summe von i gleich 1 bis n"
let scriptDepth = 0

// operators whose sub- and superscript are read as "from ... to ..."
const BIG_OPS =
  /^\\(sum|prod|coprod|int|intop|smallint|iint|iiint|oint|oiint|oiiint|bigcup|bigcap|bigoplus|bigotimes|bigodot|biguplus|bigsqcup|bigvee|bigwedge)$/
// operators whose subscript is read as "as ..." or "over ..."
const LIMITS = /^\\(lim|liminf|limsup)$/
const EXTREMA = /^\\(max|min|sup|inf|argmax|argmin)$/

// "\in" -> "∈", to find the negated relation of \not\in
const CHARS: { [name: string]: string } = {}
for (const char in unicode) for (const name of unicode[char]) CHARS[name] ??= char

// ℝ is not in KaTeX's symbol table, it is read like \mathbb{R}
const DOUBLE_STRUCK: { [char: string]: string } = {
  ℕ: 'N',
  ℤ: 'Z',
  ℚ: 'Q',
  ℝ: 'R',
  ℂ: 'C',
}

type NestedArray<T> = Array<T | NestedArray<T>>

const lookup = (map: { [key: string]: string }, str: string) =>
  typeof map[str] === 'string' ? map[str] : undefined

// the plain LaTeX of a node, used to detect x^2, \sqrt[3], \mathbb{R}, ...
const raw = (node: any): string =>
  Array.isArray(node)
    ? node.map(raw).join('')
    : typeof node?.text === 'string'
      ? node.text
      : node?.body
        ? raw(node.body)
        : ''

// letters and spaces only, as in \text{if } or \operatorname{rank}
const plainText = (nodes: AnyParseNode[]): string | undefined => {
  let text = ''
  for (const node of nodes) {
    if (node.type === 'spacing') text += ' '
    else if (node.type === 'textord' || node.type === 'mathord')
      text += node.text
    else return
  }
  return text.replace(/\s+/g, ' ').trim()
}

const buildString = (
  str: string,
  type: Atom | 'normal',
  a11yStrings: NestedArray<string>
) => {
  if (!str) {
    return
  }

  const last = a11yStrings[a11yStrings.length - 1]
  const lastIsNumber = typeof last === 'string' && NUMBER.test(last)

  // a separator within a number: 3.14, 3{,}14 or 1.000.000
  if ((str === '.' || str === DECIMAL) && lastIsNumber) {
    a11yStrings[a11yStrings.length - 1] += str
    return
  }
  if (str === DECIMAL) str = ','

  // 90° and 1°
  const degrees =
    (str === '°' || str === '\\degree') && lastIsNumber && formatUnit(last, 'degree')
  if (degrees) {
    a11yStrings[a11yStrings.length - 1] = degrees
    return
  }

  const find = (s: string) =>
    (type === 'open' || type === 'close' || type === 'bin' || type === 'rel'
      ? lookup(t[type], s)
      : undefined) ?? lookup(t.symbols, s)

  let ret = find(str)
  // "≤" is read like "\le", and \leq like \le, the dictionaries need only one
  // name of a character
  const char = CHARS[str] ?? str
  const names = unicode[char]
  ret ??= find(char)
  if (Array.isArray(names)) for (const name of names) ret ??= find(name)
  ret ??=
    lookup(t.sets, DOUBLE_STRUCK[str] ?? '') ??
    // never let TTS read a backslash
    str.replace(/^\\@?/, '')

  // If the text to add is a number and there is already a string
  // in the list and the last string is a number then we should
  // combine them into a single number
  if (/^\d+$/.test(ret) && lastIsNumber) {
    a11yStrings[a11yStrings.length - 1] += ret
  } else if (ret && type === 'rel' && scriptDepth === 0) {
    // \not= is ≠ and \not\in is ∉ (NFC), otherwise "nicht ..."
    const not = last === t.symbols['\u0338'] && a11yStrings.pop()
    const negated = (char + '\u0338').normalize('NFC')
    const word = !not
      ? ret
      : ([...negated].length === 1 && find(negated)) ||
        `${not} ${ret}`
    a11yStrings.push(PAUSE, word, PAUSE)
  } else if (ret) {
    a11yStrings.push(ret)
  }
}

const buildRegion = (
  a11yStrings: NestedArray<string>,
  callback: (regionStrings: NestedArray<string>) => void
) => {
  const regionStrings: NestedArray<string> = []
  a11yStrings.push(regionStrings)
  callback(regionStrings)
}

// "start <name>", body, "end <name>"
const startEnd = (
  a11yStrings: NestedArray<string>,
  name: string,
  body: AnyParseNode | AnyParseNode[],
  atomType: Atom | 'normal'
) =>
  buildRegion(a11yStrings, (regionStrings) => {
    regionStrings.push(PAUSE, `${t.words.start} ${name}`, PAUSE)
    buildA11yStrings(body, regionStrings, atomType)
    regionStrings.push(PAUSE, `${t.words.end} ${name}`, PAUSE)
  })

// the words of a node, without pauses
const words = (
  node: AnyParseNode | AnyParseNode[],
  atomType: Atom | 'normal'
): string[] =>
  flatten(buildA11yStrings(node, [], atomType)).filter((s) => s !== PAUSE)

// sub- and superscripts are read in a script, see scriptDepth
const inScript = (fn: () => void) => {
  scriptDepth++
  try {
    fn()
  } finally {
    scriptDepth--
  }
}

// \tag{5} is parsed as \text{(5)}, keep only the label itself
const tagLabel = (tag: AnyParseNode[], atomType: Atom | 'normal') => [
  PAUSE,
  t.words.equation,
  ...words(tag, atomType)
    .map((s) => s.replace(/^[()]$|^\((.*)\)$/, '$1'))
    .filter((s) => s && s !== t.symbols['('] && s !== t.symbols[')']),
]

// x with <label> on top / underneath
const decorate = (
  a11yStrings: NestedArray<string>,
  label: AnyParseNode | AnyParseNode[] | undefined | null,
  where: string,
  atomType: Atom | 'normal'
) => {
  if (!label) return
  // a label of letters is a word, as in \stackrel{def}{=}
  const word =
    !Array.isArray(label) &&
    label.type === 'ordgroup' &&
    plainText(label.body)
  const strings = word && word.length > 1 ? [word] : words(label, atomType)
  if (strings.length === 0) return
  a11yStrings.push(PAUSE, t.words.with, ...strings, where, PAUSE)
}

const isEmpty = (
  node: AnyParseNode | AnyParseNode[] | undefined | null,
  atomType: Atom | 'normal'
) => !node || words(node, atomType).length === 0

type ArrayKind =
  | 'matrix'
  | 'determinant'
  | 'cases'
  | 'equations'
  | 'substack'
  | 'array'

// what an array is, from its delimiters (pmatrix, vmatrix, cases, ...) or its
// layout (aligned, gather, \substack, matrix, array)
const arrayKind = (
  tree: any,
  left = '.',
  right = '.'
): ArrayKind | undefined => {
  if (left === '.' && right === '.') {
    if (/^(align|alignat|gather)$/.test(tree.colSeparationType))
      return 'equations'
    if (tree.colSeparationType === 'small') return 'matrix'
    if (tree.arraystretch === 0.5) return 'substack'
    return tree.hskipBeforeAndAfter ? 'array' : 'matrix'
  }
  if (
    (left === '\\{' && right === '.') ||
    (left === '.' && right === '\\}')
  )
    return 'cases'
  if (/^(\||\\vert|\\lvert)$/.test(left)) return 'determinant'
  if (/^(\(|\[|\\\{|\\lbrack|\\lparen)$/.test(left)) return 'matrix'
}

// the first node that is not a group, to find \text{else} in cases
const firstLeaf = (node: any): any =>
  Array.isArray(node)
    ? firstLeaf(node[0])
    : node?.type === 'styling' || node?.type === 'ordgroup'
      ? firstLeaf(node.body)
      : node

const buildArray = (
  tree: any,
  a11yStrings: NestedArray<string>,
  atomType: Atom | 'normal',
  kind: ArrayKind
) => {
  // a trailing \\ adds an empty row
  const rows: [any[], number][] = tree.body
    .map((row: any[], i: number) => [row, i])
    .filter(([row]: [any[]]) => row.some((cell) => !isEmpty(cell, atomType)))

  const cells = (row: any[], strings: NestedArray<string>) =>
    // one region per cell, so numbers in neighbouring cells are not merged
    row.forEach((cell, j) => {
      const condition =
        kind === 'cases' && j === 1 && firstLeaf(cell)?.type !== 'text'
      if (condition) {
        strings.push(PAUSE, t.words.if)
      } else if (kind !== 'substack') {
        strings.push(PAUSE)
      }
      const build = () =>
        buildRegion(strings, (cellStrings) =>
          buildA11yStrings(cell, cellStrings, atomType)
        )
      // "Fall 1, x, falls x größer gleich 0"
      kind === 'cases' ? inScript(build) : build()
    })

  // \sum_{\substack{i < n \\ j < m}}: the conditions joined by "and"
  if (kind === 'substack') {
    buildRegion(a11yStrings, (regionStrings) =>
      rows.forEach(([row], i) => {
        i && regionStrings.push(t.words.and)
        cells(row, regionStrings)
      })
    )
    return
  }

  const name =
    kind === 'matrix' || kind === 'determinant'
      ? `${rows.length} ${t.words.by} ${Math.max(0, ...rows.map(([row]) => row.length))} ${t.words[kind]}`
      : t.words[kind]
  const rowName =
    kind === 'cases'
      ? t.words.case
      : kind === 'equations'
        ? t.words.line
        : t.words.row

  buildRegion(a11yStrings, (regionStrings) => {
    regionStrings.push(PAUSE, `${t.words.start} ${name}`)
    rows.forEach(([row, i], n) => {
      regionStrings.push(PAUSE, `${rowName} ${n + 1}`)
      cells(row, regionStrings)
      // explicit \tag per row (align, gather, ...); auto numbers only exist in CSS
      const tag = tree.tags?.[i]
      if (Array.isArray(tag)) regionStrings.push(tagLabel(tag, atomType))
    })
    regionStrings.push(PAUSE, `${t.words.end} ${t.words[kind]}`, PAUSE)
  })
}

// the words of a single token like x, 12, \pi or -3, these need no
// "start ..." and "end ..." around them
const simple = (
  node: AnyParseNode | AnyParseNode[],
  atomType: Atom | 'normal'
): string[] | undefined => {
  const strings = words(node, atomType)
  if (
    strings.length === 1 ||
    (strings.length === 2 &&
      strings[0] === t.bin['-'] &&
      /^\d/.test(strings[1]))
  ) {
    return strings
  }
}

// up to three ordinary tokens like i \pi or 2n, without operators, these are
// short enough for a sub- or superscript without "start ..." and "end ..."
const isTerm = (node: any): boolean =>
  Array.isArray(node)
    ? node.every(isTerm)
    : /^(mathord|textord|ordgroup|font|styling)$/.test(node?.type) &&
      (typeof node.body !== 'object' || isTerm(node.body))

const term = (
  node: AnyParseNode | AnyParseNode[],
  atomType: Atom | 'normal'
): string[] | undefined => {
  const short = simple(node, atomType)
  if (short || !isTerm(node)) return short
  const strings = words(node, atomType)
  if (strings.length <= 3) return strings
}

// 3{,}14, 3\mathord{,}14, 3\text{,}14 and 3,\!14 are decimal commas
const isDecimalComma = (tree: AnyParseNode[], i: number) => {
  const node: any = tree[i]
  if (/^(ordgroup|mclass|text)$/.test(node.type))
    return node.body.length === 1 && raw(node.body) === ','
  const next: any = tree[i + 1]
  return (
    node.type === 'atom' &&
    node.text === ',' &&
    next?.type === 'kern' &&
    next.dimension?.number < 0
  )
}

// f, g and h in front of parentheses are functions, "f von x"
// \sin, \exp, \operatorname{Var}, \mathop{a}, ..., but not \sum or \int
const isNamedFunction = (node: any): boolean =>
  (node?.type === 'op' &&
    !node.symbol &&
    !node.alwaysHandleSupSub &&
    !!(node.name || node.body)) ||
  node?.type === 'operatorname'

// Letters that are functions in the current formula: u'(x), u \circ v and
// u\colon A \to B. Not ^{-1} (x^{-1} = 1/x) and not a definition like
// a(b+c) = ab + ac, which is the distributive law.
let functionLetters = new Set<string>()

const letter = (node: any) => (node?.type === 'mathord' ? node.text : undefined)

// layout only, \colon is a macro of spaces, an empty mclass and a ":"
const isLayout = (node: any) =>
  /^(spacing|kern|mathchoice)$/.test(node?.type) ||
  (node?.type === 'mclass' && node.body.length === 0)

const collectFunctions = (node: any) => {
  if (Array.isArray(node)) {
    const visible = node.filter((n: any) => !isLayout(n))
    visible.forEach((n: any, i: number) => {
      const next = visible[i + 1]
      const marked =
        (n?.type === 'supsub' &&
          !n.sub &&
          /^(\\prime)+$/.test(raw(n.sup)) &&
          letter(n.base)) ||
        (next?.text === '\\circ' && letter(n)) ||
        (visible[i - 1]?.text === '\\circ' && letter(n)) ||
        // u: A \to B, but not the ratio a : b
        (raw(next) === ':' &&
          visible.slice(i + 2).some((m: any) => /^\\(to|rightarrow)$/.test(m.text)) &&
          letter(n))
      marked && functionLetters.add(marked)
      collectFunctions(n)
    })
  } else if (node && typeof node === 'object') {
    for (const key in node) key === 'loc' || collectFunctions(node[key])
  }
}

// functions of one argument, a comma in \sin(3,14) is a decimal comma
const UNARY =
  /^\\(sin|cos|tan|cot|sec|csc|arcsin|arccos|arctan|arcctg|arctg|sinh|cosh|tanh|coth|sh|ch|th|cth|tg|ctg|cotg|cosec|exp|ln|lg|log)$/

const functionName = (node: any): any =>
  node?.type === 'supsub' && !node.sub ? node.base : node

const isFunctionName = (node: any): boolean => {
  const base = functionName(node)
  // \sin^2(x), but f'(x) only with primes
  if (isNamedFunction(base)) return true
  return (
    base?.type === 'mathord' &&
    (/^[fgh]$/.test(base.text) || functionLetters.has(base.text)) &&
    (base === node || /^(\\prime)+$/.test(raw(node.sup)))
  )
}

// the index of the closing parenthesis of f(x), \sin(x + 1) or \ln\left(x\right)
const functionCall = (tree: AnyParseNode[], i: number) => {
  const open: any = tree[i + 1]
  if (!isFunctionName(tree[i])) return
  if (open?.type === 'leftright' && open.left === '(') return i + 1
  if (open?.type !== 'atom' || open.text !== '(') return
  let depth = 0
  for (let j = i + 1; j < tree.length; j++) {
    const node: any = tree[j]
    if (node.type === 'atom' && node.text === '(') depth++
    if (node.type === 'atom' && node.text === ')' && --depth === 0)
      return j > i + 2 ? j : undefined
  }
}

// the ordinal of a root index: "fifth", "17th" or "nth", if the language has one
const ordinal = (index: string): string | undefined => {
  if (/^[a-z]$/i.test(index)) return t.words.letterOrdinal.replace('{}', index)
  if (!/^\d+$/.test(index)) return
  const suffix = lookup(t.ordinalSuffix, plural(Number(index), 'ordinal'))
  return lookup(t.ordinals, index) ?? (suffix ? index + suffix : undefined)
}

// the units of \mathrm{kg}, \mathrm{s^2}, \mathrm{°C} or \mathrm{m/s}, as
// [symbol, exponent, behind a "/"]
const unitsOf = (node: any): [string, string, boolean][] | undefined => {
  if (node?.type !== 'font' || node.font !== 'mathrm') return
  const body: any[] = node.body.type === 'ordgroup' ? node.body.body : [node.body]
  const units: [string, string, boolean][] = []
  let symbol = ''
  let power = ''
  let per = false
  for (const n of body) {
    if (n.type === 'textord' && n.text === '/' && symbol) {
      units.push([symbol, power, per])
      symbol = power = ''
      per = true
    } else if (n.type === 'mathord' || n.type === 'textord') {
      symbol += n.text
    } else if (
      n.type === 'supsub' &&
      n.base?.type === 'ordgroup' &&
      n.base.body.length === 0 &&
      /^\\(circ|degree)$/.test(raw(n.sup))
    ) {
      symbol += '°'
    } else if (n.type === 'supsub' && !n.sub) {
      symbol += raw(n.base)
      power = raw(n.sup)
    } else {
      return
    }
  }
  return symbol ? [...units, [symbol, power, per]] : undefined
}

// \pu{9,81 m/s} or 5\,\mathrm{kg}: a number with a unit, read by Intl as
// "9,81 Meter pro Sekunde", returns the index of the last unit
const readUnits = (
  tree: AnyParseNode[],
  i: number,
  a11yStrings: NestedArray<string>
): number | undefined => {
  const space: any = tree[i]
  const k = a11yStrings.length - 1
  const number = a11yStrings[k]
  if (
    !/^(spacing|kern)$/.test(space?.type) ||
    typeof number !== 'string' ||
    !NUMBER.test(number)
  )
    return

  const units: [string, string, boolean][] = []
  let per = false
  let end: number | undefined
  for (let j = i + 1; j < tree.length; j++) {
    const node: any = tree[j]
    if (node.type === 'kern' || node.type === 'spacing') continue
    if (node.type === 'textord' && node.text === '/') {
      per = true
      continue
    }
    const found = unitsOf(node)
    if (!found) break
    for (const [symbol, power, slash] of found)
      units.push([symbol, power, per || slash])
    end = j
  }

  // Intl knows single units and "meter-per-second", no products or powers
  const id = (symbol: string) => entry(UNITS, symbol)
  const [a, b] = units
  const unit =
    units.length === 1 && !a[1] && !a[2]
      ? id(a[0])
      : units.length === 2 &&
          !a[1] &&
          !a[2] &&
          (b[2] ? !b[1] : b[1] === '-1') &&
          id(a[0]) &&
          id(b[0])
        ? `${id(a[0])}-per-${id(b[0])}`
        : undefined
  const text = end !== undefined && unit && formatUnit(number, unit)
  if (!text) return
  a11yStrings[k] = text
  return end
}

const handleObject = (
  tree: AnyParseNode,
  a11yStrings: NestedArray<string>,
  atomType: Atom | 'normal'
) => {
  // Everything else is assumed to be an object...
  switch (tree.type) {
    case 'accent': {
      // \vec{v} is "vector v", \bar{x} is "x bar"
      const short = simple(tree.base, atomType)
      const template = lookup(t.accentShort, tree.label)
      if (short && template) {
        a11yStrings.push(template.replace('{}', short.join(' ')))
        break
      }
      buildRegion(a11yStrings, (a11yStrings) => {
        buildA11yStrings(tree.base, a11yStrings, atomType)
        a11yStrings.push(PAUSE, t.words.with)
        buildString(tree.label, 'normal', a11yStrings)
        a11yStrings.push(t.words.onTop, PAUSE)
      })
      break
    }

    case 'accentUnder': {
      buildRegion(a11yStrings, (a11yStrings) => {
        buildA11yStrings(tree.base, a11yStrings, atomType)
        a11yStrings.push(PAUSE, t.words.with)
        buildString(
          lookup(t.accentUnder, tree.label) ?? tree.label,
          'normal',
          a11yStrings
        )
        a11yStrings.push(t.words.underneath, PAUSE)
      })
      break
    }

    case 'accent-token': {
      // Used internally by accent symbols.
      break
    }

    case 'atom': {
      const { text } = tree
      switch (tree.family) {
        case 'bin': {
          buildString(text, 'bin', a11yStrings)
          break
        }
        case 'close': {
          buildString(text, 'close', a11yStrings)
          break
        }
        // TODO(kevinb): figure out what should be done for inner
        case 'inner': {
          buildString(tree.text, 'inner', a11yStrings)
          break
        }
        case 'open': {
          buildString(text, 'open', a11yStrings)
          break
        }
        case 'punct': {
          buildString(text, 'punct', a11yStrings)
          break
        }
        case 'rel': {
          buildString(text, 'rel', a11yStrings)
          break
        }
        default: {
          tree.family.empty
          throw new Error(`"${tree.family}" is not a valid atom type`)
        }
      }
      break
    }

    case 'color': {
      const color = tree.color.replace(/katex-/, '')
      startEnd(a11yStrings, `${t.words.color} ${color}`, tree.body, atomType)
      break
    }

    case 'color-token': {
      // Used by \color, \colorbox, and \fcolorbox but not directly rendered.
      // It's a leaf node and has no children so just break.
      break
    }

    case 'delimsizing': {
      if (tree.delim && tree.delim !== '.') {
        buildString(tree.delim, 'normal', a11yStrings)
      }
      break
    }

    case 'genfrac': {
      buildRegion(a11yStrings, (regionStrings) => {
        // genfrac can have unbalanced delimiters
        const { leftDelim, rightDelim } = tree

        // NOTE: Not sure if this is a safe assumption
        // hasBarLine true -> fraction, false -> binomial
        const plain = tree.hasBarLine && !leftDelim && !rightDelim
        const numer = simple(tree.numer, atomType)
        const denom = simple(tree.denom, atomType)
        const n = words(tree.numer, atomType)
        const d = words(tree.denom, atomType)
        // 3/8 is "3 eighths", like ClearSpeak only for denominators up to 10
        // and numerators below 20
        const count = numer?.join('') ?? ''
        const forms =
          plain &&
          /^\d+$/.test(count) &&
          Number(count) < 20 &&
          entry(t.denominators, denom?.join('') ?? '')
        const name =
          forms &&
          `${count === '1' ? t.words.one : count} ${form(forms, Number(count))}`

        if (name) {
          regionStrings.push(name)
        } else if (plain && numer && denom) {
          regionStrings.push(...numer, t.words.fractionOver, ...denom)
        } else if (
          plain &&
          (n[0] === 'd' || n[0] === t.symbols['\\partial']) &&
          d[0] === n[0]
        ) {
          // \frac{dy}{dx} is "d y nach d x"
          regionStrings.push(...n, t.words.derivativeBy, ...d, PAUSE)
        } else if (tree.hasBarLine) {
          regionStrings.push(PAUSE, `${t.words.start} ${t.words.fraction}`, PAUSE)
          leftDelim && buildString(leftDelim, 'open', regionStrings)
          buildA11yStrings(tree.numer, regionStrings, atomType)
          regionStrings.push(PAUSE, t.words.dividedBy, PAUSE)
          buildA11yStrings(tree.denom, regionStrings, atomType)
          rightDelim && buildString(rightDelim, 'close', regionStrings)
          regionStrings.push(PAUSE, `${t.words.end} ${t.words.fraction}`, PAUSE)
        } else {
          // the parentheses are part of the binomial
          regionStrings.push(PAUSE, `${t.words.start} ${t.words.binomial}`, PAUSE)
          buildA11yStrings(tree.numer, regionStrings, atomType)
          regionStrings.push(PAUSE, t.words.choose, PAUSE)
          buildA11yStrings(tree.denom, regionStrings, atomType)
          regionStrings.push(PAUSE, `${t.words.end} ${t.words.binomial}`, PAUSE)
        }
      })
      break
    }

    case 'hbox': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'kern': {
      // No op: we don't attempt to present kerning information
      // to the screen reader.
      break
    }

    case 'leftright': {
      const array = tree.body.length === 1 && tree.body[0]
      const kind =
        array && array.type === 'array'
          ? arrayKind(array, tree.left, tree.right)
          : undefined
      if (kind) {
        buildArray(array, a11yStrings, atomType, kind)
        break
      }
      buildRegion(a11yStrings, (regionStrings) => {
        buildString(tree.left, 'open', regionStrings)
        buildA11yStrings(tree.body, regionStrings, atomType)
        buildString(tree.right, 'close', regionStrings)
      })
      break
    }

    case 'leftright-right': {
      // TODO: double check that this is a no-op
      break
    }

    case 'lap': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'mathord': {
      buildString(tree.text, 'normal', a11yStrings)
      break
    }

    case 'op': {
      const { body, name } = tree
      if (body) {
        buildA11yStrings(body, a11yStrings, atomType)
      } else if (name) {
        buildString(name, 'normal', a11yStrings)
      }
      break
    }

    case 'op-token': {
      // Used internally by operator symbols.
      buildString(tree.text, atomType, a11yStrings)
      break
    }

    case 'ordgroup': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'overline': {
      const short = simple(tree.body, atomType)
      const template = lookup(t.accentShort, '\\overline')
      if (short && template) {
        a11yStrings.push(template.replace('{}', short.join(' ')))
      } else {
        startEnd(a11yStrings, t.words.overline, tree.body, atomType)
      }
      break
    }

    case 'pmb': {
      a11yStrings.push(t.words.bold)
      break
    }

    case 'phantom': {
      // No op: only used for spacing, e.g. by \ce{^{14}_{6}C}
      break
    }

    case 'raisebox': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'rule': {
      // zero sized rules are struts, as in \vdots
      if (tree.width.number && tree.height.number) {
        a11yStrings.push(t.words.rectangle)
      }
      break
    }

    case 'sizing': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'spacing': {
      // No op: \, \quad, ... are layout, reading "space" is noise
      break
    }

    case 'styling': {
      // We ignore the styling and just pass through the contents
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'sqrt': {
      buildRegion(a11yStrings, (regionStrings) => {
        const { body, index } = tree
        const indexString = index ? raw(index) : '2'
        // \sqrt{x} needs no "end square root"
        const short = simple(body, atomType)
        const radicand = (end: string) => {
          buildA11yStrings(body, regionStrings, atomType)
          short || regionStrings.push(PAUSE, end, PAUSE)
        }

        if (indexString === '2') {
          regionStrings.push(t.words.squareRootOf)
          radicand(t.words.endSquareRoot)
        } else if (indexString === '3') {
          regionStrings.push(t.words.cubeRootOf)
          radicand(t.words.endCubeRoot)
        } else if (ordinal(indexString)) {
          // "fünfte Wurzel aus x", "17th root of x", "nth root of x"
          regionStrings.push(
            t.words.rootOf.replace('{}', ordinal(indexString)!)
          )
          radicand(t.words.endRoot)
        } else {
          regionStrings.push(t.words.rootWithIndex)
          buildA11yStrings(index!, regionStrings, atomType)
          regionStrings.push(t.words.of)
          radicand(t.words.endRoot)
        }
      })
      break
    }

    case 'supsub': {
      const { base } = tree
      const sub = isEmpty(tree.sub, atomType) ? undefined : tree.sub
      const sup = isEmpty(tree.sup, atomType) ? undefined : tree.sup
      const op =
        base?.type === 'op'
          ? base.name || raw(base.body)
          : base?.type === 'operatorname'
            ? '\\' + (plainText(base.body) ?? '')
            : ''

      // \overset{!}{=}, \stackrel{def}{=}, \underset{x}{\min} and the labels of
      // \overbrace{...}^{n} or \underbrace{...}_{n}
      if (
        (base?.type === 'op' && base.alwaysHandleSupSub && base.body) ||
        base?.type === 'horizBrace'
      ) {
        buildA11yStrings(
          base.type === 'op' ? base.body! : base,
          a11yStrings,
          atomType
        )
        inScript(() => {
          decorate(a11yStrings, sup, t.words.onTop, atomType)
          decorate(a11yStrings, sub, t.words.underneath, atomType)
        })
        break
      }

      // \ce{H2O} or \ce{Zn^2+}: mhchem puts indices and charges on an empty
      // \vphantom, they are read as they are, "H 2 O" and "Zn 2 plus"
      if (
        base?.type === 'ordgroup' &&
        base.body.length === 1 &&
        base.body[0].type === 'vphantom'
      ) {
        const plain = (node: AnyParseNode) =>
          buildRegion(a11yStrings, (regionStrings) =>
            inScript(() => buildA11yStrings(node, regionStrings, atomType))
          )
        // "S O 4, 2 minus", mhchem writes index and charge as two nodes
        const index = Array.isArray(a11yStrings[a11yStrings.length - 1])
        sub && plain(sub)
        sup && (sub || index) && a11yStrings.push(PAUSE)
        sup && plain(sup)
        break
      }

      // \left. f \right|_{x=0} or F \Big|_a^b
      if (
        sub &&
        ((base?.type === 'leftright' && base.right === '|') ||
          (base?.type === 'delimsizing' && base.delim === '|'))
      ) {
        if (base.type === 'leftright') {
          buildString(base.left, 'open', a11yStrings)
          buildA11yStrings(base.body, a11yStrings, atomType)
        }
        a11yStrings.push(
          PAUSE,
          sup ? t.words.evaluatedFrom : t.words.evaluatedAt
        )
        inScript(() => {
          buildRegion(a11yStrings, (regionStrings) =>
            buildA11yStrings(sub, regionStrings, atomType)
          )
          if (sup) {
            a11yStrings.push(t.words.to)
            buildRegion(a11yStrings, (regionStrings) =>
              buildA11yStrings(sup, regionStrings, atomType)
            )
          }
        })
        a11yStrings.push(PAUSE)
        break
      }

      if (base) {
        buildA11yStrings(base, a11yStrings, atomType)
      }

      // \sum_{i=1}^{n}, \int_0^1, \lim_{x \to 0}, \max_{x \in A}
      const lead = BIG_OPS.test(op)
        ? t.words.from
        : LIMITS.test(op)
          ? t.words.as
          : EXTREMA.test(op)
            ? t.words.over
            : undefined

      if (lead) {
        inScript(() => {
          if (sub) {
            a11yStrings.push(lead)
            buildRegion(a11yStrings, (regionStrings) =>
              buildA11yStrings(sub, regionStrings, atomType)
            )
          }
          if (sup) {
            a11yStrings.push(t.words.to)
            buildRegion(a11yStrings, (regionStrings) =>
              buildA11yStrings(sup, regionStrings, atomType)
            )
          }
        })
        // "Integral von a bis b, f von x"
        ;(sub || sup) && a11yStrings.push(PAUSE)
        break
      }

      inScript(() => {
        if (sub) {
          const isLog = op === '\\log'
          const short = term(sub, atomType)
          if (short) {
            // a pause after "x Index i j" ends the index
            a11yStrings.push(isLog ? t.words.base : t.words.sub, ...short)
            // "log Basis 2, x"
            ;(isLog || short.length > 1) && a11yStrings.push(PAUSE)
          } else {
            startEnd(
              a11yStrings,
              isLog ? t.words.base : t.words.subscript,
              sub,
              atomType
            )
          }
        }

        if (sup) {
          const power = lookup(t.power, raw(sup))
          const short = term(sup, atomType)
          const last = a11yStrings[a11yStrings.length - 1]
          // 90^\circ is "90 Grad", 1^\circ is "1 degree"
          const degrees =
            /^\\(circ|degree)$/.test(raw(sup)) &&
            typeof last === 'string' &&
            NUMBER.test(last) &&
            formatUnit(last, 'degree')
          if (degrees) {
            a11yStrings[a11yStrings.length - 1] = degrees
          } else if (power) {
            a11yStrings.push(power)
          } else if (short) {
            // "e hoch i pi, plus 1"
            a11yStrings.push(t.words.power, ...short)
            short.length > 1 && a11yStrings.push(PAUSE)
          } else {
            startEnd(a11yStrings, t.words.superscript, sup, atomType)
          }
        }
      })
      break
    }

    case 'text': {
      // TODO: handle other fonts
      // the text is read as it is, without "start text" and "end text"
      const text = plainText(tree.body)
      if (text !== undefined) {
        text && a11yStrings.push(text)
      } else {
        buildA11yStrings(tree.body, a11yStrings, atomType)
      }
      break
    }

    case 'textord': {
      buildString(tree.text, atomType, a11yStrings)
      break
    }

    case 'smash': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'enclose': {
      // TODO: differentiate between a body with a single atom, e.g.
      // "cancel a" instead of "start cancel, a, end cancel"
      const name = /cancel/.test(tree.label)
        ? t.words.cancel
        : /box/.test(tree.label)
          ? t.words.box
          : /sout/.test(tree.label)
            ? t.words.strikeout
            : /phase/.test(tree.label)
              ? t.words.phaseAngle
              : undefined
      if (name) {
        startEnd(a11yStrings, name, tree.body, atomType)
        break
      }
      throw new Error(
        `KaTeX-a11y: enclose node with ${tree.label} not supported yet`
      )
    }

    case 'vcenter': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'vphantom':
    case 'hphantom': {
      // No op: only used for spacing, e.g. by \ce{}
      break
    }

    case 'operatorname': {
      const name = plainText(tree.body)
      if (name) {
        buildString(lookup(t.symbols, '\\' + name) ?? name, 'normal', a11yStrings)
      } else {
        buildA11yStrings(tree.body, a11yStrings, atomType)
      }
      break
    }

    case 'array': {
      buildArray(tree, a11yStrings, atomType, arrayKind(tree)!)
      break
    }

    case 'raw': {
      throw new Error('KaTeX-a11y: raw not implemented yet')
    }

    case 'size': {
      // Although there are nodes of type "size" in the parse tree, they have
      // no semantic meaning and should be ignored.
      break
    }

    case 'url': {
      throw new Error('KaTeX-a11y: url not implemented yet')
    }

    case 'tag': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      a11yStrings.push(tagLabel(tree.tag, atomType))
      break
    }

    case 'verb': {
      a11yStrings.push(`${t.words.start} ${t.words.verbatim}`)
      a11yStrings.push(tree.body)
      a11yStrings.push(`${t.words.end} ${t.words.verbatim}`)
      break
    }

    case 'environment': {
      throw new Error('KaTeX-a11y: environment not implemented yet')
    }

    case 'horizBrace': {
      startEnd(
        a11yStrings,
        lookup(t.symbols, tree.label) ?? tree.label.slice(1),
        tree.base,
        atomType
      )
      break
    }

    case 'infix': {
      // All infix nodes are replace with other nodes.
      break
    }

    case 'includegraphics': {
      tree.alt && a11yStrings.push(tree.alt)
      break
    }

    case 'font': {
      const set = tree.font === 'mathbb' && lookup(t.sets, raw(tree.body))
      // \mathrm{mod} (used by \pmod) or units like \mathrm{kg} are one word
      const word =
        tree.font === 'mathrm' &&
        tree.body.type === 'ordgroup' &&
        plainText(tree.body.body)
      // \mathbf{v} is "bold v", only for a single token
      const style = lookup(t.fonts, tree.font)
      const short = style && simple(tree.body, atomType)
      if (set) {
        a11yStrings.push(set)
      } else if (word && /^(?:[A-Z][a-z]?){2,}$/.test(word)) {
        // \ce{CuSO4} is \mathrm{CuSO}_4, read the elements one by one
        a11yStrings.push(...word.match(/[A-Z][a-z]?/g)!)
      } else if (word && word.length > 1) {
        buildString(lookup(t.symbols, '\\' + word) ?? word, 'normal', a11yStrings)
      } else if (short) {
        a11yStrings.push(`${style} ${short.join(' ')}`)
      } else {
        buildA11yStrings(tree.body, a11yStrings, atomType)
      }
      break
    }

    case 'href': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'cr': {
      // a line break \\ outside of an environment
      a11yStrings.push(PAUSE)
      break
    }

    case 'underline': {
      startEnd(a11yStrings, t.words.underline, tree.body, atomType)
      break
    }

    case 'xArrow': {
      // reaction arrows and \xrightarrow{f} are relations, "A, Pfeil, B"
      a11yStrings.push(PAUSE)
      buildString(tree.label, 'normal', a11yStrings)
      decorate(a11yStrings, tree.body, t.words.onTop, atomType)
      decorate(a11yStrings, tree.below, t.words.underneath, atomType)
      a11yStrings.push(PAUSE)
      break
    }

    case 'cdlabel': {
      throw new Error('KaTeX-a11y: cdlabel not implemented yet')
    }

    case 'cdlabelparent': {
      throw new Error('KaTeX-a11y: cdlabelparent not implemented yet')
    }

    case 'mclass': {
      // \neq and \ne are macros so we let "htmlmathml" render the mathmal
      // side of things and extract the text from that.
      const atomType = tree.mclass.slice(1)
      // $FlowFixMe: drop the leading "m" from the values in mclass
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    case 'mathchoice': {
      // TODO: track which style we're using, e.g. display, text, etc.
      // default to text style if even that may not be the correct style
      buildA11yStrings(tree.text, a11yStrings, atomType)
      break
    }

    case 'htmlmathml': {
      buildA11yStrings(tree.mathml, a11yStrings, atomType)
      break
    }

    case 'middle': {
      buildString(tree.delim, atomType, a11yStrings)
      break
    }

    case 'internal': {
      // internal nodes are never included in the parse tree
      break
    }

    case 'html': {
      buildA11yStrings(tree.body, a11yStrings, atomType)
      break
    }

    default:
      tree.type.empty
      throw new Error('KaTeX a11y un-recognized type: ' + tree.type)
  }
}

const buildA11yStrings = (
  tree: AnyParseNode | AnyParseNode[],
  a11yStrings: NestedArray<string> = [],
  atomType: Atom | 'normal'
) => {
  if (tree instanceof Array) {
    // |x| is written without \left and \right, an even number of bars are
    // read as pairs, a single one as in \{x | x > 0\} stays a bar
    const isBar = (node: AnyParseNode) =>
      node.type === 'textord' && (node.text === '|' || node.text === '\\vert')
    const bars = tree.filter(isBar).length
    let open = true
    for (let i = 0; i < tree.length; i++) {
      const next: any = tree[i + 1]
      const call = functionCall(tree, i)
      const units = readUnits(tree, i, a11yStrings)
      if (units !== undefined) {
        i = units
      } else if (bars > 1 && bars % 2 === 0 && isBar(tree[i])) {
        buildString('|', open ? 'open' : 'close', a11yStrings)
        open = !open
      } else if (bars === 1 && isBar(tree[i])) {
        // \{x | x > 0\}, "x, senkrechter Strich, x größer 0"
        a11yStrings.push(PAUSE)
        buildA11yStrings(tree[i], a11yStrings, atomType)
        a11yStrings.push(PAUSE)
      } else if (isDecimalComma(tree, i)) {
        buildString(DECIMAL, 'normal', a11yStrings)
        // the negative space of 3,\!14
        tree[i + 1]?.type === 'kern' && i++
      } else if (call) {
        // f(x) is "f von x", f(x + 1) is "f von Klammer auf x plus 1 Klammer zu",
        // \sin(3,14) has only one argument
        const unary = UNARY.test(functionName(tree[i])?.name ?? '')
        const group: any = tree[i + 1]
        const args: any[] =
          group.type === 'leftright' ? group.body : tree.slice(i + 2, call)
        const short = args.every(
          (n) => isTerm(n) || (n.type === 'atom' && n.family === 'punct')
        )
        buildA11yStrings(tree[i], a11yStrings, atomType)
        a11yStrings.push(t.words.functionOf)
        buildRegion(a11yStrings, (regionStrings) => {
          short || buildString('(', 'open', regionStrings)
          // as a list, so that f(g(x)) is found, a comma of \sin becomes {,}
          buildA11yStrings(
            unary
              ? args.map((n) =>
                  raw(n) === ',' ? { type: 'ordgroup', body: [n] } : n
                )
              : args,
            regionStrings,
            atomType
          )
          short || buildString(')', 'close', regionStrings)
        })
        i = call
      } else if (
        raw(tree[i]) === '\\nabla' &&
        next?.type === 'atom' &&
        /^\\(cdot|times)$/.test(next.text)
      ) {
        // divergence and curl, "Nabla Punkt E" and "Nabla Kreuz B"
        buildA11yStrings(tree[i], a11yStrings, atomType)
        a11yStrings.push(next.text === '\\cdot' ? t.words.dot : t.words.cross)
        i++
      } else {
        buildA11yStrings(tree[i], a11yStrings, atomType)
      }
    }
  } else {
    handleObject(tree, a11yStrings, atomType)
  }

  return a11yStrings
}

const flatten = function (array: any[]): any[] {
  let result: any[] = []

  array.forEach(function (item) {
    if (item instanceof Array) {
      result = result.concat(flatten(item))
    } else {
      result.push(item)
    }
  })

  return result
}

// "12.345\u000267" is ["12345", "67"], a single "1.000" stays decimal
const parseNumber = (number: string): string[] => {
  const n = number.replace(/[.\u0002]+$/, '') // "x = 3." ends a sentence
  if (
    /^\d{1,3}(\.\d{3})+(\u0002\d+)?$/.test(n) &&
    (/\..*\./.test(n) || n.includes(DECIMAL))
  ) {
    return n.replace(/\./g, '').split(DECIMAL)
  }
  return n.split(/[.\u0002]/)
}

// "12345,67" in German, long numbers are not rounded
const formatNumber = (number: string) => {
  const [integer, ...rest] = parseNumber(number)
  return rest.length
    ? integer + decimalMark() + rest.join(` ${t.symbols['.']} `)
    : integer
}

const numberValue = (number: string) => {
  const [integer, fraction] = parseNumber(number)
  return Number(fraction ? `${integer}.${fraction}` : integer)
}

/**
 * @param lang - a language tag like "de" or "de-DE", unknown languages are
 *   read in English
 */
const renderA11yString = function (
  text: string,
  settings?: SettingsOptions,
  lang: string = 'en'
): string {
  const dict = LANGUAGES[lang.slice(0, 2).toLowerCase()]
  t = dict ?? en
  locale = dict ? lang : 'en'
  scriptDepth = 0
  const tree = katex.__parse(text, settings)
  functionLetters = new Set()
  collectFunctions(tree)
  const a11yStrings = buildA11yStrings(tree, [], 'normal')
  return flatten(a11yStrings)
    .map((s) => (NUMBER.test(s) ? formatNumber(s) : s))
    .join(' ')
    .split(PAUSE)
    .map((s) => s.trim())
    .filter(Boolean)
    .join(', ')
}

export default renderA11yString
