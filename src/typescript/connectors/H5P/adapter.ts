/**
 * A virtual SCORM 2004 LMS for the suspend engine, backed by H5P instead of a
 * SCORM API. H5P keeps one JSON state per learner and content
 * (`getCurrentState` / `previousState`) and grades from xAPI events, so:
 *
 * - suspend data, location and status are kept in memory and handed to the
 *   bridge as that state on every commit;
 * - a result is reported once the course is completed, and again only when
 *   score or success change afterwards. Moodle opens a new attempt for every
 *   result, so a reload or a mere visit must not report again; the last
 *   reported result is part of the state for that reason.
 *
 * No DOM, no H5P: the bridge is all it knows, so it runs in tests.
 */

import type { LMS } from '../SCORMSuspend/engine'

export const STATE_VERSION = 1

/** what H5P stores for a learner */
export interface State {
  v: number
  suspend: string
  location: string
  completion: string
  success: string
  /** the result last reported, see `key` */
  reported: string
}

/** one quiz, survey, task list or code project, as the engine describes it */
export interface Interaction {
  id: string
  type?: string
  description?: string
  weighting?: string
  pattern?: string
  response?: string
  result?: string
}

export interface Result {
  /** points, absent for a course without quizzes */
  raw?: number
  max?: number
  scaled?: number
  /** true: passed, false: failed, null: no mastery score */
  success: boolean | null
  interactions: Interaction[]
}

/** the H5P side, provided by the H5P.LiaScript library */
export interface Bridge {
  /** the state H5P passed in, if any */
  previousState?: unknown
  /** scaled passing score in (0, 1], or none */
  mastery?: number | null
  save(state: State): void
  report(result: Result): void
  /** set by the connector: saves pending changes now, for getCurrentState */
  flush?: () => void
}

const C = {
  mode: 'cmi.mode',
  credit: 'cmi.credit',
  entry: 'cmi.entry',
  location: 'cmi.location',
  suspend: 'cmi.suspend_data',
  completion: 'cmi.completion_status',
  success: 'cmi.success_status',
  raw: 'cmi.score.raw',
  max: 'cmi.score.max',
  scaled: 'cmi.score.scaled',
  mastery: 'cmi.scaled_passing_score',
  count: 'cmi.interactions._count',
}

const INTERACTION = /^cmi\.interactions\.(\d+)\.(.+)$/

/** the fields of an interaction worth reporting, by their SCORM 2004 name */
const FIELDS: Record<string, keyof Interaction> = {
  id: 'id',
  type: 'type',
  description: 'description',
  weighting: 'weighting',
  'correct_responses.0.pattern': 'pattern',
  learner_response: 'response',
  result: 'result',
}

/** A previous state, or null if there is none or it is not ours. */
export function restore(value: unknown): State | null {
  let state: any = value
  if (typeof state === 'string') {
    try {
      state = JSON.parse(state)
    } catch (e) {
      return null
    }
  }
  if (!state || typeof state !== 'object' || state.v !== STATE_VERSION) return null

  const text = (x: unknown) => (typeof x === 'string' ? x : '')
  return {
    v: STATE_VERSION,
    suspend: text(state.suspend),
    location: text(state.location),
    completion: text(state.completion),
    success: text(state.success),
    reported: text(state.reported),
  }
}

const number = (text: string | undefined) => {
  const value = parseFloat(text ?? '')
  return Number.isFinite(value) ? value : undefined
}

export function connect(bridge: Bridge, warn: (...args: any[]) => void): LMS {
  const previous = restore(bridge.previousState)
  if (bridge.previousState != null && !previous) {
    warn('the stored state is not from this version, starting fresh')
  }

  const values: Record<string, string> = {
    [C.mode]: 'normal',
    [C.credit]: 'credit',
    [C.entry]: previous ? 'resume' : 'ab-initio',
    [C.suspend]: previous?.suspend ?? '',
    [C.location]: previous?.location ?? '',
    [C.completion]: previous?.completion || 'not attempted',
    [C.success]: previous?.success || 'unknown',
    [C.count]: '0',
  }
  if (typeof bridge.mastery === 'number' && bridge.mastery > 0 && bridge.mastery <= 1) {
    values[C.mastery] = String(bridge.mastery)
  }

  let reported = previous?.reported ?? ''
  const interactions = new Map<number, Interaction>()
  let failed = ''

  const state = (): State => ({
    v: STATE_VERSION,
    suspend: values[C.suspend],
    location: values[C.location],
    completion: values[C.completion],
    success: values[C.success],
    reported,
  })

  const result = (): Result | null => {
    if (values[C.completion] !== 'completed') return null

    const raw = number(values[C.raw])
    const max = number(values[C.max])
    const success = values[C.success] === 'passed' ? true : values[C.success] === 'failed' ? false : null

    const scored = raw !== undefined && max !== undefined && max > 0
    return {
      raw: scored ? raw : undefined,
      max: scored ? max : undefined,
      scaled: scored ? number(values[C.scaled]) ?? raw! / max! : undefined,
      success,
      interactions: [...interactions.entries()]
        .sort(([a], [b]) => a - b)
        .map(([, item]) => item)
        .filter((item) => item.id && (item.response !== undefined || item.result !== undefined)),
    }
  }

  /** a result is reported only if it differs from the last one */
  const key = (r: Result) => JSON.stringify([r.raw ?? null, r.max ?? null, r.success])

  const call = (name: string, fn: () => void) => {
    try {
      fn()
      return true
    } catch (e: any) {
      failed = `${name}: ${e?.message ?? e}`
      warn(failed)
      return false
    }
  }

  return {
    get(element) {
      return values[element] ?? ''
    },

    set(element, value) {
      const match = element.match(INTERACTION)
      if (match) {
        const field = FIELDS[match[2]]
        if (field) {
          const n = parseInt(match[1], 10)
          const item = interactions.get(n) ?? { id: '' }
          item[field] = value
          interactions.set(n, item)
        }
        return true
      }
      values[element] = value
      return true
    },

    error() {
      return failed
    },

    commit() {
      const r = result()
      if (r && key(r) !== reported) {
        // not marked as reported if it fails, the next commit tries again
        if (!call('report', () => bridge.report(r))) return false
        reported = key(r)
      }
      return call('save', () => bridge.save(state()))
    },

    finish() {
      return true
    },
  }
}
