/**
 * Learner state ⇄ the text kept in `cmi.suspend_data`.
 *
 * suspend_data holds 4096 characters in SCORM 1.2 and 64000 in SCORM 2004, and
 * has to carry the settings, every quiz, survey, task and code project. The
 * state is therefore stored positionally and only where it differs from the
 * course's initial state (`window.config_`): the kind of every element is known
 * from that initial state, so no type tags are stored. The result is deflated
 * and written as base64url behind a short header:
 *
 *     "LS1Z" + base64url(deflateRaw(JSON(payload)))
 *
 * Everything here is pure, so it can be tested without a browser.
 */

/// <reference path="./pako.d.ts" />
import { deflateRaw, inflateRaw } from 'pako'
import * as Base64 from './base64url'
import { md5 } from './md5'

export const FORMAT_VERSION = 1
export const HEADER = 'LS' + FORMAT_VERSION + 'Z'

/** The course's initial state vectors, as the exporter writes them. */
export interface Defaults {
  quiz: any[][]
  survey: any[][]
  task: any[][]
}

/** Which interaction index each report item got; see report.ts. */
export interface InteractionIndex {
  /** identifies the item catalogue the indices were allocated for */
  hash: string
  /** index of the first item */
  base: number
}

/** The learner's state, in the shapes LiaScript sends to a connector. */
export interface Snapshot {
  settings: Record<string, any> | null
  quiz: any[][]
  survey: any[][]
  task: any[][]
  /** per slide: the code projects, or null while the learner changed none */
  code: (any[] | null)[]
  index: InteractionIndex | null
  /** highest slide the learner opened */
  visited: number
}

export type Unpacked =
  | { kind: 'empty' }
  | { kind: 'ok'; payload: any[] }
  /** written by the classic SCORM connectors: settings JSON only */
  | { kind: 'legacy'; settings: Record<string, any> }
  /** a newer format: keep it, do not overwrite it */
  | { kind: 'future' }
  | { kind: 'corrupt'; reason: string }

class Mismatch extends Error {}

const clone = <T>(value: T): T => JSON.parse(JSON.stringify(value))

// --- state values -------------------------------------------------------------

const isPlainObject = (value: any) =>
  value !== null && typeof value === 'object' && !Array.isArray(value)

const isBoolDict = (value: any) =>
  isPlainObject(value) &&
  Object.keys(value).length > 0 &&
  Object.values(value).every((v) => typeof v === 'boolean')

/**
 * Bools as a '0101' string. Unlike a bit mask it keeps the length, so an
 * answer to a quiz that has since gained or lost an option is recognized as
 * no longer fitting. Deflate makes up for the extra characters.
 */
function encodeBools(bools: boolean[]): string {
  return bools.map((bit) => (bit ? '1' : '0')).join('')
}

function decodeBools(n: number, code: any): boolean[] {
  if (typeof code === 'string' && code.length === n && /^[01]*$/.test(code)) {
    return Array.from(code, (bit) => bit === '1')
  }
  throw new Mismatch('bools')
}

function expectArray(value: any, length: number) {
  if (!Array.isArray(value) || value.length !== length) {
    throw new Mismatch('length')
  }
}

/**
 * Encodes `value` relative to `initial`, which gives its kind: `{"Text":…}`,
 * `{"SingleChoice":[…]}`, a survey's `{key: bool}`, a task's `[bool]`, …
 */
export function encodeValue(initial: any, value: any): any {
  if (Array.isArray(initial) && initial.every((v) => typeof v === 'boolean')) {
    expectArray(value, initial.length)
    return encodeBools(value)
  }

  if (isBoolDict(initial)) {
    const keys = Object.keys(initial)
    if (!isPlainObject(value) || Object.keys(value).length !== keys.length) {
      throw new Mismatch('keys')
    }
    return encodeBools(keys.map((key) => value[key] === true))
  }

  if (isPlainObject(initial) && Object.keys(initial).length === 1) {
    const kind = Object.keys(initial)[0]
    if (!isPlainObject(value) || !(kind in value)) throw new Mismatch(kind)

    const inner = initial[kind]
    const given = value[kind]

    switch (kind) {
      case 'Text':
        if (typeof given !== 'string') throw new Mismatch(kind)
        return given
      case 'Select':
      case 'Drop':
        if (!Number.isInteger(given)) throw new Mismatch(kind)
        return given
      case 'Generic':
        return 0
      case 'SingleChoice':
      case 'MultipleChoice':
        return encodeValue(inner, given)
      case 'Matrix':
      case 'Multi':
      case 'SingleChoiceMatrix':
      case 'MultipleChoiceMatrix':
        expectArray(given, inner.length)
        return inner.map((part: any, i: number) => encodeValue(part, given[i]))
    }
  }

  // unknown shapes are kept as they are
  return value
}

export function decodeValue(initial: any, code: any): any {
  if (Array.isArray(initial) && initial.every((v) => typeof v === 'boolean')) {
    return decodeBools(initial.length, code)
  }

  if (isBoolDict(initial)) {
    const keys = Object.keys(initial)
    const bools = decodeBools(keys.length, code)
    return Object.fromEntries(keys.map((key, i) => [key, bools[i]]))
  }

  if (isPlainObject(initial) && Object.keys(initial).length === 1) {
    const kind = Object.keys(initial)[0]
    const inner = initial[kind]

    switch (kind) {
      case 'Text':
        if (typeof code !== 'string') throw new Mismatch(kind)
        return { Text: code }
      case 'Select':
      case 'Drop':
        if (!Number.isInteger(code)) throw new Mismatch(kind)
        return { [kind]: code }
      case 'Generic':
        return { Generic: null }
      case 'SingleChoice':
      case 'MultipleChoice':
        return { [kind]: decodeValue(inner, code) }
      case 'Matrix':
      case 'Multi':
      case 'SingleChoiceMatrix':
      case 'MultipleChoiceMatrix':
        expectArray(code, inner.length)
        return {
          [kind]: inner.map((part: any, i: number) => decodeValue(part, code[i])),
        }
    }
  }

  return code
}

// --- elements -----------------------------------------------------------------

const same = (a: any, b: any) => JSON.stringify(a) === JSON.stringify(b)

/** [slide, i, solved, trial, hint, state, error?] */
function encodeQuiz(slide: number, i: number, initial: any, quiz: any) {
  const changed =
    quiz.solved !== initial.solved ||
    quiz.trial !== initial.trial ||
    quiz.hint !== initial.hint ||
    (quiz.error_msg || '') !== (initial.error_msg || '') ||
    !same(quiz.state, initial.state)

  if (!changed) return null

  const entry: any[] = [
    slide,
    i,
    quiz.solved,
    quiz.trial,
    quiz.hint,
    same(quiz.state, initial.state) ? null : encodeValue(initial.state, quiz.state),
  ]
  if (quiz.error_msg) entry.push(quiz.error_msg)
  return entry
}

function decodeQuiz(initial: any, entry: any[]) {
  const [, , solved, trial, hint, state, error] = entry

  if (![0, 1, -1].includes(solved) || !Number.isInteger(trial) || !Number.isInteger(hint)) {
    throw new Mismatch('quiz')
  }

  return {
    ...clone(initial),
    solved,
    trial,
    hint,
    error_msg: typeof error === 'string' ? error : '',
    state: state === null ? clone(initial.state) : decodeValue(initial.state, state),
  }
}

/** [slide, i, submitted, state, error?] */
function encodeSurvey(slide: number, i: number, initial: any, survey: any) {
  if (same(survey, initial)) return null

  const entry: any[] = [
    slide,
    i,
    survey.submitted ? 1 : 0,
    same(survey.state, initial.state) ? null : encodeValue(initial.state, survey.state),
  ]
  if (survey.errorMessage) entry.push(survey.errorMessage)
  return entry
}

function decodeSurvey(initial: any, entry: any[]) {
  const [, , submitted, state, error] = entry
  const survey: any = {
    ...clone(initial),
    submitted: submitted === 1,
    state: state === null ? clone(initial.state) : decodeValue(initial.state, state),
  }
  if (typeof error === 'string') survey.errorMessage = error
  return survey
}

/** [slide, i, mask] */
function encodeTask(slide: number, i: number, initial: any, task: any) {
  return same(task, initial) ? null : [slide, i, encodeValue(initial, task)]
}

// --- code ---------------------------------------------------------------------

const EMPTY_LOG = { ok: true, level: -1, messages: [], details: [] }

/**
 * A project keeps only its current files, [lang, name, code, flags]: no
 * version history, no logs. `file` is what the editor shows, which Elm also
 * sets when the learner switches to another version.
 */
export function encodeProject(project: any): any[] {
  return project.file.map((file: any) => [
    file.lang,
    file.name,
    file.code,
    (file.visible ? 1 : 0) | (file.fullscreen ? 2 : 0),
  ])
}

/** Rebuilds the full project Elm expects, with one version for the files. */
export function decodeProject(files: any[]): any {
  if (!Array.isArray(files) || files.length === 0) throw new Mismatch('code')

  const repository: Record<string, string> = {}
  const hashes: string[] = []
  const file = files.map((entry) => {
    const [lang, name, code, flags] = entry
    if (typeof code !== 'string' || typeof name !== 'string' || typeof lang !== 'string') {
      throw new Mismatch('code')
    }
    const hash = md5(code)
    repository[hash] = code
    hashes.push(hash)
    return { lang, name, code, visible: (flags & 1) === 1, fullscreen: (flags & 2) === 2 }
  })

  return {
    file,
    version: [{ hashes, log: clone(EMPTY_LOG) }],
    version_active: 0,
    log: clone(EMPTY_LOG),
    repository,
  }
}

// --- snapshot ⇄ payload -------------------------------------------------------

/**
 * [settings, quiz, survey, task, code, index, visited]; `0` for an absent
 * settings object or index keeps the array short.
 */
export function encodeSnapshot(snapshot: Snapshot, defaults: Defaults): any[] {
  const quiz: any[] = []
  const survey: any[] = []
  const task: any[] = []
  const code: any[] = []

  const each = (
    table: any[][],
    initial: any[][],
    encode: (s: number, i: number, init: any, value: any) => any[] | null,
    into: any[]
  ) => {
    table.forEach((slide, s) =>
      (slide || []).forEach((value, i) => {
        const init = initial[s]?.[i]
        if (init === undefined || value == null) return
        const entry = encode(s, i, init, value)
        if (entry) into.push(entry)
      })
    )
  }

  each(snapshot.quiz, defaults.quiz, encodeQuiz, quiz)
  each(snapshot.survey, defaults.survey, encodeSurvey, survey)
  each(snapshot.task, defaults.task, encodeTask, task)

  snapshot.code.forEach((projects, s) => {
    if (projects) code.push([s, projects.map(encodeProject)])
  })

  return [
    snapshot.settings || 0,
    quiz,
    survey,
    task,
    code,
    snapshot.index ? [snapshot.index.hash, snapshot.index.base] : 0,
    snapshot.visited,
  ]
}

export function emptySnapshot(defaults: Defaults): Snapshot {
  return {
    settings: null,
    quiz: clone(defaults.quiz),
    survey: clone(defaults.survey),
    task: clone(defaults.task),
    code: [],
    index: null,
    visited: 0,
  }
}

/**
 * Applies a payload to the course's initial state. An entry that no longer
 * fits the course (it was updated since) is dropped alone and listed in
 * `skipped`; everything else is restored.
 */
export function decodePayload(
  payload: any[],
  defaults: Defaults
): { snapshot: Snapshot; skipped: string[] } {
  const snapshot = emptySnapshot(defaults)
  const skipped: string[] = []

  if (!Array.isArray(payload)) {
    return { snapshot, skipped: ['payload'] }
  }

  const [settings, quiz, survey, task, code, index, visited] = payload

  if (isPlainObject(settings)) snapshot.settings = settings

  const apply = (
    entries: any,
    table: 'quiz' | 'survey' | 'task',
    decode: (initial: any, entry: any[]) => any
  ) => {
    if (!Array.isArray(entries)) return
    for (const entry of entries) {
      const [s, i] = Array.isArray(entry) ? entry : []
      const initial = defaults[table][s]?.[i]
      try {
        if (initial === undefined) throw new Mismatch('position')
        snapshot[table][s][i] = decode(initial, entry)
      } catch (e) {
        skipped.push(`${table} ${s}.${i}`)
      }
    }
  }

  apply(quiz, 'quiz', decodeQuiz)
  apply(survey, 'survey', decodeSurvey)
  apply(task, 'task', (initial, entry) => decodeValue(initial, entry[2]))

  if (Array.isArray(code)) {
    for (const entry of code) {
      try {
        const [s, projects] = entry
        if (!Number.isInteger(s) || !Array.isArray(projects)) throw new Mismatch('code')
        snapshot.code[s] = projects.map(decodeProject)
      } catch (e) {
        skipped.push(`code ${Array.isArray(entry) ? entry[0] : '?'}`)
      }
    }
  }

  if (Array.isArray(index) && typeof index[0] === 'string' && Number.isInteger(index[1])) {
    snapshot.index = { hash: index[0], base: index[1] }
  }

  if (Number.isInteger(visited) && visited >= 0) snapshot.visited = visited

  return { snapshot, skipped }
}

// --- text ---------------------------------------------------------------------

export function pack(payload: any[]): string {
  const json = new TextEncoder().encode(JSON.stringify(payload))
  return HEADER + Base64.encode(deflateRaw(json, { level: 9 }))
}

export function unpack(text: string | null | undefined): Unpacked {
  if (!text) return { kind: 'empty' }

  if (text.startsWith('{')) {
    try {
      const settings = JSON.parse(text)
      return isPlainObject(settings)
        ? { kind: 'legacy', settings }
        : { kind: 'corrupt', reason: 'legacy settings are not an object' }
    } catch (e) {
      return { kind: 'corrupt', reason: 'legacy settings are not JSON' }
    }
  }

  const header = text.match(/^LS(\d+)([A-Z])/)
  if (!header) return { kind: 'corrupt', reason: 'unknown header' }
  if (parseInt(header[1], 10) > FORMAT_VERSION) return { kind: 'future' }
  if (header[0] !== HEADER) return { kind: 'corrupt', reason: 'unknown codec ' + header[0] }

  try {
    const bytes = inflateRaw(Base64.decode(text.slice(HEADER.length)))
    const payload = JSON.parse(new TextDecoder().decode(bytes))
    return Array.isArray(payload)
      ? { kind: 'ok', payload }
      : { kind: 'corrupt', reason: 'payload is not an array' }
  } catch (e: any) {
    return { kind: 'corrupt', reason: String(e?.message || e) }
  }
}

// --- budget -------------------------------------------------------------------

/**
 * Packs the snapshot into at most `limit` characters.
 *
 * If it does not fit, state is left out in this order, packing again after
 * each step: code projects (largest slide first), tasks, surveys (largest
 * first), the hint/error fields of quizzes, then quizzes from the last one.
 * Settings, the interaction index and navigation are always kept. `dropped`
 * names what was left out, so the caller can warn once.
 */
export function fit(
  snapshot: Snapshot,
  defaults: Defaults,
  limit: number
): { text: string; dropped: string[] } {
  const payload = encodeSnapshot(snapshot, defaults)
  const dropped: string[] = []
  let text = pack(payload)

  const size = (value: any) => JSON.stringify(value).length
  const retry = () => (text = pack(payload)).length <= limit

  if (text.length <= limit) return { text, dropped }

  // 1. code, largest slide first
  const code: any[] = payload[4]
  code.sort((a, b) => size(b) - size(a))
  while (code.length) {
    dropped.push(`code of slide ${code.shift()[0] + 1}`)
    if (retry()) return { text, dropped }
  }

  // 2. tasks
  if (payload[3].length) {
    payload[3] = []
    dropped.push('tasks')
    if (retry()) return { text, dropped }
  }

  // 3. surveys, largest first
  const survey: any[] = payload[2]
  survey.sort((a, b) => size(b) - size(a))
  while (survey.length) {
    const [s, i] = survey.shift()
    dropped.push(`survey ${s + 1}.${i + 1}`)
    if (retry()) return { text, dropped }
  }

  // 4. hint counters and error messages of quizzes
  const quiz: any[] = payload[1]
  if (quiz.some((entry) => entry[4] || entry.length > 6)) {
    for (const entry of quiz) {
      entry[4] = 0
      entry.length = 6
    }
    dropped.push('quiz hints and messages')
    if (retry()) return { text, dropped }
  }

  // 5. quizzes, from the end of the course
  while (quiz.length) {
    const [s, i] = quiz.pop()
    dropped.push(`quiz ${s + 1}.${i + 1}`)
    if (retry()) return { text, dropped }
  }

  return { text, dropped }
}
