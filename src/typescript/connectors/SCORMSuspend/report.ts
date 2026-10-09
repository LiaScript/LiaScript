/**
 * What teachers see: every quiz, survey, task list and code project becomes
 * one `cmi.interactions.n` entry.
 *
 * SCORM 1.2 reports readable text (type `fill-in`): Moodle's interactions
 * report shows 1.2 responses as they are, and the 1.2 `choice` format allows
 * single characters only. SCORM 2004 reports semantic types (`choice`,
 * `matching`, `fill-in`, …) whose option ids (`o1`, `r2`, …) are explained by a
 * legend in `description`.
 *
 * Every value is made to pass the strictest validation found in Moodle and
 * ILIAS: no line breaks, no leading `{`, no `"`, within the length limits.
 * Everything here is pure.
 */

import type { CodeMeta, LiaMeta, QuizMeta, SurveyMeta, TaskMeta } from './meta'
import { QUIZ_STATE_KEY } from './meta'
import type { Defaults } from './codec'

export type Version = '1.2' | '2004'

export type Table = 'quiz' | 'survey' | 'task' | 'code'

export interface Item {
  table: Table
  slide: number
  index: number
  /** `cmi.interactions.n.id` */
  id: string
  /** title of the slide, the question of an element without one */
  title: string
  /** description of the element, if the exporter provided one */
  meta?: QuizMeta | SurveyMeta | TaskMeta | CodeMeta
  /** weight of a quiz, from the course */
  weight: number
}

/** The values of one interaction, as they are written. */
export interface Report {
  type: string
  response?: string
  pattern?: string
  result?: string
  description?: string
  weighting?: string
}

/** At most this many interactions: the SCORM 2004 smallest permitted maximum. */
export const MAX_ITEMS = 250

const LIMIT = {
  '1.2': { response: 255, pattern: 255 },
  '2004': { response: 4000, pattern: 4000, part: 250, description: 250, code: 3990 },
}

// --- text ---------------------------------------------------------------------

/**
 * Makes text safe for any LMS: line breaks become ⏎ (Moodle rejects them in
 * SCORM 2004), quotes become ＂ (ILIAS strips them, OPAL fails on them), a
 * leading `{` is moved off the start (it would read as a `{lang=…}` tag), and
 * text over `limit` is cut with a `…[+N]` marker, N counting the characters
 * left out. Like the LMS checks, the limit counts UTF-16 units (an emoji is
 * two); the cut never splits a character.
 */
export function sanitize(text: string, limit: number): string {
  let clean = String(text)
    .replace(/\r\n|\r|\n|\u2028|\u2029/g, '⏎')
    .replace(/\t/g, '  ')
    .replace(/[\u0000-\u001f\u007f]/g, '')
    .replace(/"/g, '＂')

  if (clean.startsWith('{')) clean = ' ' + clean
  if (clean.length <= limit) return clean

  const chars = Array.from(clean)
  let kept = ''
  for (let keep = 0; keep < chars.length; keep++) {
    const next = kept + chars[keep]
    // the marker counts towards the limit
    if (next.length + `…[+${chars.length - keep - 1}]`.length > limit) {
      return kept + `…[+${chars.length - keep}]`
    }
    kept = next
  }
  return kept
}

/** A 2004 delimited list must not contain its own delimiters. */
const part = (text: string, limit: number) =>
  sanitize(String(text).replace(/\[,\]/g, '[ ,]').replace(/\[\.\]/g, '[ .]'), limit)

/** Latin letters without their accents: `Grüße` → `Grusse` */
export const transliterate = (text: string) =>
  text
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/\u00df/g, 'ss')
    .replace(/\u00e6/g, 'ae')
    .replace(/\u00c6/g, 'AE')
    .replace(/\u00f8/g, 'o')
    .replace(/\u00d8/g, 'O')

/** ASCII words for an identifier: `Grüße, Welt!` → `Grusse_Welt` */
export function slug(text: string, max = 60): string {
  return transliterate(text)
    .replace(/[^A-Za-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '')
    .slice(0, max)
    .replace(/_+$/, '')
}

/** FNV-1a, 32 bit, as 8 hex digits. */
export function hash(text: string): string {
  let h = 0x811c9dc5
  for (let i = 0; i < text.length; i++) {
    h ^= text.charCodeAt(i)
    h = Math.imul(h, 0x01000193) >>> 0
  }
  return h.toString(16).padStart(8, '0')
}

// --- catalogue ----------------------------------------------------------------

const PREFIX: Record<Table, string> = { quiz: 'Q', survey: 'S', task: 'T', code: 'C' }

/** A meta entry only counts if it describes the same kind of element. */
function quizMeta(meta: QuizMeta | undefined, initial: any): QuizMeta | undefined {
  if (!meta || meta.unknown) return undefined
  const key = initial?.state && Object.keys(initial.state)[0]
  return QUIZ_STATE_KEY[meta.type] === key ? meta : undefined
}

/**
 * Every reportable element, in course order: per slide its quizzes, surveys,
 * task lists and code projects. Code projects are only known from the meta.
 * Beyond MAX_ITEMS, quizzes are kept first, then surveys, code and tasks.
 */
export function catalogue(defaults: Defaults, meta?: LiaMeta | null): Item[] {
  const slides = Math.max(
    defaults.quiz.length,
    defaults.survey.length,
    defaults.task.length,
    meta?.slides.length || 0
  )

  const items: Item[] = []

  for (let s = 0; s < slides; s++) {
    const slideMeta = meta?.slides[s]
    const title = slideMeta?.title || ''

    const add = (table: Table, i: number, meta: any, weight = 1) => {
      const described = meta?.unknown ? undefined : meta
      const text = described?.question || title
      const name = slug(text)
      items.push({
        table,
        slide: s,
        index: i,
        id: `${PREFIX[table]}${s + 1}.${i + 1}` + (name ? '_' + name : ''),
        title,
        meta: described,
        weight,
      })
    }

    ;(defaults.quiz[s] || []).forEach((initial, i) =>
      add('quiz', i, quizMeta(slideMeta?.quiz[i], initial), initial?.score ?? 1)
    )
    ;(defaults.survey[s] || []).forEach((_, i) => add('survey', i, slideMeta?.survey[i]))
    ;(defaults.task[s] || []).forEach((_, i) => add('task', i, slideMeta?.task[i]))
    ;(slideMeta?.code || []).forEach((code, i) => add('code', i, code))
  }

  if (items.length <= MAX_ITEMS) return items

  const priority: Table[] = ['quiz', 'survey', 'code', 'task']
  const kept = new Set(
    priority
      .flatMap((table) => items.filter((item) => item.table === table))
      .slice(0, MAX_ITEMS)
  )
  return items.filter((item) => kept.has(item))
}

/** Identifies a catalogue, to notice when a course update changed it. */
export const catalogueHash = (items: Item[]) =>
  hash(items.map((item) => item.id).join('|'))

// --- values -------------------------------------------------------------------

const label = (labels: string[] | undefined, i: number) =>
  labels?.[i] !== undefined && labels[i] !== '' ? labels[i] : `#${i + 1}`

const selected = (bools: boolean[]) =>
  bools.flatMap((bit, i) => (bit ? [i] : []))

const SHORT_ID = /^[\w.]{1,250}$/

/** a survey's keys in the order of the course, not of its state object */
function ordered(keys: string[], options: { key: string }[] | undefined): string[] {
  const known = (options || []).map((o) => o.key).filter((key) => keys.includes(key))
  return [...known, ...keys.filter((key) => !known.includes(key))]
}

/** Readable answer of one value, for SCORM 1.2 and fill-in parts. */
function readable(state: any, meta: any): string | undefined {
  const kind = state && Object.keys(state)[0]
  const value = state?.[kind]

  switch (kind) {
    case 'Text':
      return value
    case 'Select':
    case 'Drop':
      return value < 0 ? undefined : label(meta?.options, value)
    case 'SingleChoice':
    case 'MultipleChoice': {
      if (Array.isArray(value)) {
        const picked = selected(value).map((i) => label(meta?.options, i))
        return picked.length ? picked.join('; ') : '–'
      }
      // survey: {key: bool}
      const options: { key: string; label: string }[] = meta?.options || []
      const picked = ordered(Object.keys(value), options)
        .filter((key) => value[key])
        .map((key) => options.find((o) => o.key === key)?.label || key)
      return picked.length ? picked.join('; ') : '–'
    }
    case 'Matrix':
      return value
        .map((row: any, r: number) => {
          const cells = row[Object.keys(row)[0]] as boolean[]
          const picked = selected(cells).map((c) => label(meta?.columns, c))
          return `${label(meta?.rows, r)}: ${picked.length ? picked.join(', ') : '–'}`
        })
        .join('; ')
    case 'SingleChoiceMatrix':
    case 'MultipleChoiceMatrix':
      return value
        .map((row: any, r: number) => {
          const options: { key: string; label: string }[] = meta?.options || []
          const picked = ordered(Object.keys(row), options)
            .filter((key) => row[key])
            .map((key) => options.find((o) => o.key === key)?.label || key)
          return `${label(meta?.rows, r)}: ${picked.length ? picked.join(', ') : '–'}`
        })
        .join('; ')
    case 'Multi':
      return value
        .map((gap: any, g: number) => readable(gap, meta?.gaps?.[g]) ?? '–')
        .join(' | ')
  }
  return undefined
}

/** Readable solution of a quiz, from its meta. */
function readableSolution(meta: QuizMeta): string | undefined {
  switch (meta.type) {
    case 'text':
      return meta.solution ?? undefined
    case 'single':
    case 'multiple':
      return meta.solution ? selected(meta.solution).map((i) => label(meta.options, i)).join('; ') : undefined
    case 'select':
    case 'drop':
      return meta.solution ? meta.solution.map((i) => label(meta.options, i)).join(' / ') : undefined
    case 'matrix':
      return meta.solution
        ? meta.solution
            .map((row, r) => `${label(meta.rows, r)}: ${selected(row).map((c) => label(meta.columns, c)).join(', ')}`)
            .join('; ')
        : undefined
    case 'gap':
      return meta.gaps
        .map((gap) =>
          gap.type === 'text'
            ? gap.solution ?? '?'
            : gap.solution
              ? gap.solution.map((i) => label(gap.options, i)).join(' / ')
              : '?'
        )
        .join(' | ')
  }
  return undefined
}

function quizResult(state: any, version: Version): string | undefined {
  if (state.solved === 1) return 'correct'
  // a revealed solution counts as not solved by the learner
  if (state.solved === -1 || state.trial > 0) return version === '1.2' ? 'wrong' : 'incorrect'
  return undefined
}

const weighting = (weight: number, version: Version) =>
  version === '1.2'
    ? String(Math.max(-100, Math.min(100, Math.round(weight * 100) / 100)))
    : String(Math.round(weight * 10000) / 10000)

function codeText(projects: any, onlyVisible: boolean): string {
  const files: any[] = projects?.file || []
  return files
    .filter((file) => !onlyVisible || file.visible)
    .map((file) => (files.length > 1 ? `${file.name}:\n${file.code}` : file.code))
    .join('\n\n')
}

/**
 * The interaction values of an item for its current state, or null while
 * there is nothing to report (a quiz never checked, a survey not submitted).
 */
export function report(item: Item, state: any, version: Version): Report | null {
  if (state === undefined || state === null) return null

  const out = version === '1.2' ? report12(item, state) : report2004(item, state)

  // a revealed solution fills the quiz with that solution: the learner's
  // last checked answer, already reported, is the one to keep
  if (out && item.table === 'quiz' && state.solved === -1) delete out.response

  return out
}

function report12(item: Item, state: any): Report | null {
  const limit = LIMIT['1.2']
  const meta: any = item.meta

  switch (item.table) {
    case 'quiz': {
      const result = quizResult(state, '1.2')
      if (!result) return null
      const answer = readable(state.state, meta)
      const solution = meta && readableSolution(meta)
      return {
        type: 'fill-in',
        response: answer === undefined ? undefined : sanitize(answer, limit.response),
        pattern: solution === undefined ? undefined : sanitize(solution, limit.pattern),
        result,
        weighting: weighting(item.weight, '1.2'),
      }
    }
    case 'survey': {
      if (!state.submitted) return null
      const answer = readable(state.state, meta)
      return {
        type: 'fill-in',
        response: answer === undefined ? undefined : sanitize(answer, limit.response),
        result: 'neutral',
      }
    }
    case 'task': {
      const items: string[] = meta?.items || []
      return {
        type: 'fill-in',
        response: sanitize(
          (state as boolean[]).map((done, i) => `[${done ? 'x' : ' '}] ${label(items, i)}`).join('; '),
          limit.response
        ),
        result: 'neutral',
      }
    }
    case 'code': {
      const text = codeText(state, true) || codeText(state, false)
      return { type: 'fill-in', response: sanitize(text, limit.response), result: 'neutral' }
    }
  }
}

/** `o1`, `o2`, … for option i; a survey keeps its own key where it is valid. */
const optionId = (i: number) => `o${i + 1}`
const surveyId = (key: string, i: number) => (SHORT_ID.test(key) ? key : optionId(i))

/** "question [o1=3, o2=4]" within 250 characters, the legend kept if possible. */
function describe(question: string, legend: string[]): string {
  const limit = LIMIT['2004'].description
  if (!legend.length) return sanitize(question, limit)

  const tail = sanitize(` [${legend.join(', ')}]`, limit)
  const room = limit - Array.from(tail).length
  const head = room > 20 ? sanitize(question, room) : ''
  return sanitize(head + tail, limit)
}

function report2004(item: Item, state: any): Report | null {
  const limit = LIMIT['2004']
  const meta: any = item.meta
  const question = meta?.question || item.title || `${item.table} ${item.slide + 1}.${item.index + 1}`

  switch (item.table) {
    case 'quiz': {
      const result = quizResult(state, '2004')
      if (!result) return null
      const value = state.state
      const kind = Object.keys(value)[0]
      const out: Report = { type: 'other', result, weighting: weighting(item.weight, '2004') }

      switch (kind) {
        case 'Text':
          out.type = 'fill-in'
          out.response = part(value.Text, limit.part)
          if (meta?.solution != null) out.pattern = part(meta.solution, limit.part)
          out.description = describe(question, [])
          break

        case 'SingleChoice':
        case 'MultipleChoice': {
          out.type = 'choice'
          const picked = selected(value[kind]).slice(0, 36)
          if (picked.length) out.response = picked.map(optionId).join('[,]')
          if (meta?.solution) out.pattern = selected(meta.solution).map(optionId).join('[,]')
          out.description = describe(
            question,
            (value[kind] as boolean[]).map((_, i) => `${optionId(i)}=${label(meta?.options, i)}`)
          )
          break
        }

        case 'Select':
        case 'Drop': {
          out.type = 'choice'
          if (value[kind] >= 0) out.response = optionId(value[kind])
          if (meta?.solution?.length) out.pattern = optionId(meta.solution[0])
          out.description = describe(
            question,
            (meta?.options || []).map((o: string, i: number) => `${optionId(i)}=${o}`)
          )
          break
        }

        case 'Matrix': {
          out.type = 'matching'
          const rows: any[] = value.Matrix
          const pairs = rows
            .flatMap((row, r) => selected(row[Object.keys(row)[0]]).map((c) => `r${r + 1}[.]c${c + 1}`))
            .slice(0, 36)
          if (pairs.length) out.response = pairs.join('[,]')
          if (meta?.solution) {
            out.pattern = (meta.solution as boolean[][])
              .flatMap((row, r) => selected(row).map((c) => `r${r + 1}[.]c${c + 1}`))
              .slice(0, 36)
              .join('[,]')
          }
          out.description = describe(question, [
            ...rows.map((_, r) => `r${r + 1}=${label(meta?.rows, r)}`),
            ...(meta?.columns || []).map((c: string, i: number) => `c${i + 1}=${c}`),
          ])
          break
        }

        case 'Multi': {
          const gaps: any[] = value.Multi
          const answers = gaps.map((gap, g) => readable(gap, meta?.gaps?.[g]) ?? '')
          const solutions: string[] | undefined = meta?.gaps?.map((gap: any) =>
            gap.type === 'text'
              ? gap.solution ?? ''
              : gap.solution?.length
                ? label(gap.options, gap.solution[0])
                : ''
          )
          if (answers.length <= 10) {
            out.type = 'fill-in'
            out.response = answers.map((a) => part(a, limit.part)).join('[,]')
            if (solutions) out.pattern = solutions.map((s) => part(s, limit.part)).join('[,]')
          } else {
            out.type = 'long-fill-in'
            out.response = sanitize(answers.join(' | '), limit.response)
            if (solutions) out.pattern = sanitize(solutions.join(' | '), limit.pattern)
          }
          out.description = describe(question, [])
          break
        }

        default:
          // script-checked (`Generic`): the result is all there is
          out.description = describe(question, [])
      }
      return out
    }

    case 'survey': {
      if (!state.submitted) return null
      const value = state.state
      const kind = Object.keys(value)[0]
      const out: Report = { type: 'other', result: 'neutral' }
      const options: { key: string; label: string }[] = meta?.options || []

      switch (kind) {
        case 'Text':
          out.type = meta?.type === 'textarea' ? 'long-fill-in' : 'fill-in'
          out.response = out.type === 'fill-in' ? part(value.Text, limit.part) : sanitize(value.Text, limit.response)
          out.description = describe(question, [])
          break

        case 'SingleChoice':
        case 'MultipleChoice': {
          out.type = 'choice'
          const keys = ordered(Object.keys(value[kind]), options)
          const picked = keys.filter((key) => value[kind][key])
          if (picked.length) out.response = picked.map((key) => surveyId(key, keys.indexOf(key))).join('[,]')
          out.description = describe(
            question,
            keys.map((key, i) => `${surveyId(key, i)}=${options.find((o) => o.key === key)?.label || key}`)
          )
          break
        }

        case 'Select':
        case 'Drop': {
          out.type = 'choice'
          if (value[kind] >= 0) out.response = optionId(value[kind])
          out.description = describe(question, options.map((o, i) => `${optionId(i)}=${o.label}`))
          break
        }

        case 'SingleChoiceMatrix':
        case 'MultipleChoiceMatrix': {
          out.type = 'matching'
          const rows: any[] = value[kind]
          const keys = rows.length ? ordered(Object.keys(rows[0]), options) : []
          const pairs = rows
            .flatMap((row, r) => keys.filter((key) => row[key]).map((key) => `r${r + 1}[.]${surveyId(key, keys.indexOf(key))}`))
            .slice(0, 36)
          if (pairs.length) out.response = pairs.join('[,]')
          out.description = describe(question, [
            ...rows.map((_, r) => `r${r + 1}=${label(meta?.rows, r)}`),
            ...keys.map((key, i) => `${surveyId(key, i)}=${options.find((o) => o.key === key)?.label || key}`),
          ])
          break
        }

        default:
          out.response = sanitize(JSON.stringify(value), limit.response)
          out.description = describe(question, [])
      }
      return out
    }

    case 'task': {
      const items: string[] = meta?.items || []
      const done = selected(state as boolean[]).slice(0, 36)
      const out: Report = {
        type: 'choice',
        result: 'neutral',
        description: describe(
          question,
          (state as boolean[]).map((_, i) => `i${i + 1}=${label(items, i)}`)
        ),
      }
      if (done.length) out.response = done.map((i) => `i${i + 1}`).join('[,]')
      return out
    }

    case 'code': {
      const files = (meta as CodeMeta | undefined)?.files?.map((f) => f.name).join(', ')
      return {
        type: 'long-fill-in',
        response: sanitize(codeText(state, false), limit.code),
        result: 'neutral',
        description: describe(`Code: ${question}${files ? ` (${files})` : ''}`, []),
      }
    }
  }
}

/**
 * The interaction type of an item, from its initial state: the same type
 * `report` uses, known before the learner answered anything.
 */
export function typeOf(item: Item, initial: any, version: Version): string {
  if (version === '1.2') return 'fill-in'

  switch (item.table) {
    case 'quiz':
      return report(item, { ...initial, solved: 1 }, version)?.type || 'other'
    case 'survey':
      return report(item, { ...initial, submitted: true }, version)?.type || 'other'
    case 'task':
      return 'choice'
    case 'code':
      return 'long-fill-in'
  }
}
