/**
 * The lifecycle of the suspend connectors, without DOM or LMS discovery, so it
 * can run against a fake LMS in tests. connector.ts wires it to LiaScript and
 * the browser.
 *
 * - The whole learner state lives in `cmi.suspend_data` (codec.ts).
 * - Status, score and location use the fields SCORM defines for them.
 * - Every quiz, survey, task list and code project is reported as one
 *   interaction (report.ts), written only when it changed.
 * - In no-credit or browse mode the state and position are still saved, but
 *   nothing is reported. Review mode saves nothing.
 * - Nothing throws: a value the LMS refuses is logged, retried in a simpler
 *   form once, and the field is left alone for the rest of the session.
 */

import * as Codec from './codec'
import * as Report from './report'
import * as State from './state'
import type { LiaMeta } from './meta'
import type { Profile } from './profile'

export interface LMS {
  get(element: string): string
  /** false if the LMS refused the value */
  set(element: string, value: string): boolean
  /** a description of the last error */
  error(): string
  commit(): boolean
  finish(): boolean
}

export interface Clock {
  now(): number
  date(): Date
  /** runs fn after ms, returns a function that cancels it */
  later(fn: () => void, ms: number): () => void
}

export interface Options {
  profile: Profile
  defaults: Codec.Defaults
  meta?: LiaMeta | null
  /** `window.ACTIVE`: report even without credit */
  forceActive?: boolean
  /** `window.MASTERY_SCORE` in [0, 1], used if the LMS passes none */
  mastery?: number | null
  /** number of slides, to complete a course without quizzes or surveys */
  slides?: number
  warn?: (...args: any[]) => void
}

export const TIMING = {
  /** commit after a burst of writes */
  commit: 750,
  /** save state after this long without changes … */
  quiet: 1000,
  /** … but at the latest after this long */
  latest: 5000,
}

/** 1.2 has one status for both; a learner never moves down this list */
const RANK: Record<string, number> = {
  '': 0,
  'not attempted': 0,
  unknown: 0,
  browsed: 0,
  incomplete: 1,
  failed: 2,
  completed: 3,
  passed: 4,
}

type Table = Report.Table

interface Slot {
  item: Report.Item
  n: number
}

const key = (table: Table, slide: number, index: number) => `${table}:${slide}:${index}`
const clone = <T>(value: T): T => (value === undefined ? value : JSON.parse(JSON.stringify(value)))
const round = (value: number, digits = 4) => Math.round(value * 10 ** digits) / 10 ** digits

/** only printable ASCII, for an LMS that refused the full text */
const ascii = (text: string) =>
  Report.transliterate(text)
    .replace(/[^\x20-\x7e]/g, '?')
    .slice(0, 250)

export class Engine {
  private lms: LMS | null
  private options: Options
  private clock: Clock
  private profile: Profile
  private warn: (...args: any[]) => void

  /** the LMS stores state and position (not in review mode) */
  private writable = false
  /** the LMS gets status, score and interactions (credit or forced) */
  private tracking = false
  /** suspend_data of a newer format: keep it untouched */
  private readOnly = false
  private finished = false

  private snapshot: Codec.Snapshot
  /** code projects as Elm knows them, changed or not */
  private projects: (any[] | null)[] = []
  /** the files of each project as the course defines them, if seen */
  private original: (any[] | null)[] = []

  private slots = new Map<string, Slot>()
  private dirty = new Set<string>()
  private lastValues: Record<string, string> = {}
  private disabled = new Set<string>()

  private mastery: number | null = null
  private status = ''
  private success = ''
  private total = 0
  private current = 0
  private enteredAt = 0
  private startedAt = 0
  private limit = 0
  private warned = new Set<string>()

  private cancelCommit: (() => void) | null = null
  private cancelQuiet: (() => void) | null = null
  private cancelLatest: (() => void) | null = null

  constructor(lms: LMS | null, options: Options, clock: Clock) {
    this.lms = lms
    this.options = options
    this.clock = clock
    this.profile = options.profile
    this.warn = options.warn || ((...args) => console.warn('SCORM suspend:', ...args))
    this.snapshot = Codec.emptySnapshot(options.defaults)

    for (const slide of options.defaults.quiz) {
      for (const quiz of slide || []) this.total += quiz?.score ?? 1
    }
  }

  // --- start ----------------------------------------------------------------

  /** Reads what the LMS has stored; call once after Initialize. */
  start() {
    this.startedAt = this.enteredAt = this.clock.now()
    if (!this.lms) return

    const cmi = this.profile.cmi
    const mode = this.read(cmi.mode) || 'normal'
    const credit = this.read(cmi.credit) || 'credit'

    this.writable = mode !== 'review'
    this.tracking = this.writable && (!!this.options.forceActive || (mode === 'normal' && credit === 'credit'))

    if (!this.tracking) {
      this.warn(`mode "${mode}", credit "${credit}": the state is saved, results are not reported`)
    }

    this.restore(this.read(cmi.suspend))

    if (this.tracking) {
      this.layout()
      this.initStatus()
    }
  }

  private restore(text: string) {
    const unpacked = Codec.unpack(text)

    switch (unpacked.kind) {
      case 'ok': {
        const { snapshot, skipped } = Codec.decodePayload(unpacked.payload, this.options.defaults)
        if (skipped.length) this.warn('the course changed, not restored:', skipped.join(', '))
        this.snapshot = snapshot
        this.projects = snapshot.code.slice()
        break
      }
      case 'legacy':
        // written by the classic connector: only the settings are usable
        this.snapshot.settings = unpacked.settings
        break
      case 'future':
        this.warn('suspend_data was written by a newer version, it is not changed in this session')
        this.readOnly = true
        break
      case 'corrupt':
        this.warn('suspend_data is unreadable, starting fresh:', unpacked.reason)
        break
    }
  }

  /** Allocates one interaction per item, in course order, and writes id and type. */
  private layout() {
    const items = Report.catalogue(this.options.defaults, this.options.meta)
    const hash = Report.catalogueHash(items)
    const count = parseInt(this.read(this.profile.cmi.count) || '0', 10) || 0

    let base = count
    let from = 0
    const index = this.snapshot.index

    if (index && index.hash === hash && index.base <= count) {
      base = index.base
      from = Math.max(0, count - base)
    } else if (index && index.hash !== hash) {
      this.warn('the course changed, its interactions start anew at', count)
    }

    items.forEach((item, k) => {
      this.slots.set(key(item.table, item.slide, item.index), { item, n: base + k })
      if (k >= from) this.header(item, base + k)
    })

    if (!index || index.hash !== hash || index.base !== base) {
      this.snapshot.index = { hash, base }
      this.saveSoon()
    }

    // restored answers whose interactions are new (the course changed, or
    // the LMS lost them) are reported again
    items.slice(from).forEach((item) => {
      const initial = this.initialOf(item)
      const state = this.stateOf(item)
      if (state != null && JSON.stringify(state) !== JSON.stringify(initial)) {
        this.dirty.add(key(item.table, item.slide, item.index))
      }
    })
  }

  private initialOf(item: Report.Item) {
    if (item.table === 'code') return null
    return this.options.defaults[item.table][item.slide]?.[item.index]
  }

  private header(item: Report.Item, n: number) {
    const prefix = `cmi.interactions.${n}.`
    this.field(prefix + 'id', item.id)
    this.field(prefix + 'type', Report.typeOf(item, this.initialOf(item), this.profile.version))
  }

  private initStatus() {
    const cmi = this.profile.cmi

    // 0 means "everyone passes" (the exporter's default): then completion
    // alone counts, rather than passing learners who did nothing yet
    const lms = parseFloat(this.read(cmi.mastery)) / this.profile.masteryScale
    const fallback = this.options.mastery
    this.mastery =
      Number.isFinite(lms) && lms > 0 ? lms : typeof fallback === 'number' && fallback > 0 ? fallback : null

    this.status = this.read(cmi.completion)
    if (cmi.success) this.success = this.read(cmi.success)

    if ((RANK[this.status] ?? 0) === 0) {
      this.status = 'incomplete'
      this.write(cmi.completion, 'incomplete')
    }

    if (this.profile.version === '1.2') {
      this.write(cmi.scoreMin, '0')
      this.write(cmi.scoreMax, '100')
    } else if (this.total > 0) {
      this.write(cmi.scoreMin, '0')
      this.write(cmi.scoreMax, String(round(this.total)))
    }

    this.evaluate()
  }

  // --- LiaScript ------------------------------------------------------------

  settings(): Record<string, any> | null {
    return this.snapshot.settings
  }

  setSettings(data: Record<string, any>) {
    this.snapshot.settings = clone(data)
    this.saveSoon()
  }

  /** the slide to return to */
  location(): number | null {
    if (!this.lms) return null
    const value = parseInt(this.read(this.profile.cmi.location), 10)
    return Number.isFinite(value) && value >= 0 ? value : null
  }

  load(table: string, slide: number): any {
    switch (table) {
      case 'quiz':
      case 'survey':
      case 'task':
        return this.snapshot[table][slide]
      case 'code':
        // null lets LiaScript store its initial projects
        return (this.projects[slide] = this.snapshot.code[slide] ?? this.projects[slide] ?? null)
    }
    return undefined
  }

  loadAll(table: string): { id: number; data: any }[] {
    switch (table) {
      case 'quiz':
      case 'survey':
      case 'task':
        return this.snapshot[table].map((data, id) => ({ id, data }))
    }
    return []
  }

  store(table: string, slide: number, data: any) {
    if (this.finished) return

    switch (table) {
      case 'quiz':
      case 'survey':
      case 'task': {
        const list = State.changes(table, this.snapshot[table][slide], data)
        if (!list.length) return

        this.snapshot[table][slide] = clone(data)
        list.forEach((change) => this.dirty.add(key(table, slide, change.index)))

        if (table !== 'task') this.evaluate()

        if (list.some((change) => change.urgent)) this.flush()
        else this.saveSoon()
        break
      }

      case 'code':
        // LiaScript stores the initial projects of a slide: nothing changed yet
        this.projects[slide] = clone(data)
        this.original[slide] = (data || []).map((project: any) => clone(project?.file))
        break
    }
  }

  /** LiaScript's changes to code projects: runs, version switches, views */
  update(table: string, slide: number, mapping: (projects: any) => any) {
    if (this.finished || table !== 'code') return

    const projects = this.projects[slide]
    if (!projects) return

    try {
      this.projects[slide] = mapping(clone(projects))
    } catch (e: any) {
      this.warn('code update failed:', e?.message)
      return
    }

    this.snapshot.code[slide] = this.projects[slide]

    // report the projects whose files differ from the course's
    const original = this.original[slide]
    this.projects[slide]!.forEach((project, i) => {
      if (!original || JSON.stringify(project?.file) !== JSON.stringify(original[i])) {
        this.dirty.add(key('code', slide, i))
      }
    })
    this.saveSoon()
  }

  slide(n: number) {
    if (this.finished) return

    this.current = n
    this.enteredAt = this.clock.now()

    if (this.writable && !this.readOnly) {
      this.write(this.profile.cmi.location, String(n))
      this.commitSoon()
    }

    if (n > this.snapshot.visited) {
      this.snapshot.visited = n
      // a course without quizzes or surveys completes with its last slide
      if (this.tracking) this.evaluate()
      this.saveSoon()
    }
  }

  /** the scaled score, for `window.SCORE` */
  score(): number {
    return this.total > 0 ? this.points().solved / this.total : 0
  }

  /** the page is hidden: it may never come back */
  hide() {
    this.flush()
  }

  /** the page is closed: save everything and end the session, once */
  finish() {
    if (this.finished || !this.lms) return
    this.flush()
    this.finished = true

    const cmi = this.profile.cmi
    if (this.writable) {
      this.write(cmi.sessionTime, this.profile.timespan(this.clock.now() - this.startedAt))
      this.write(cmi.exit, 'suspend')
    }

    this.cancelCommit?.()
    this.cancelCommit = null
    this.lms.commit()

    if (!this.lms.finish()) this.warn('finish failed:', this.lms.error())
  }

  // --- status ---------------------------------------------------------------

  private points() {
    let solved = 0
    let finished = 0
    this.snapshot.quiz.forEach((slide, s) =>
      (slide || []).forEach((quiz, i) => {
        const weight = this.options.defaults.quiz[s]?.[i]?.score ?? 1
        if (quiz?.solved === 1) solved += weight
        if (quiz?.solved === 1 || quiz?.solved === -1) finished += weight
      })
    )

    let surveys = 0
    let submitted = 0
    this.snapshot.survey.forEach((slide) =>
      (slide || []).forEach((survey) => {
        surveys++
        if (survey?.submitted) submitted++
      })
    )

    return { solved, finished, surveys, submitted }
  }

  /** writes status, score and progress from the current state */
  private evaluate() {
    if (!this.tracking || this.finished) return

    const { solved, finished, surveys, submitted } = this.points()
    const cmi = this.profile.cmi
    const total = this.total
    const scaled = total > 0 ? solved / total : 0
    const surveysDone = submitted === surveys

    let done: boolean
    if (total === 0 && surveys === 0) {
      done = this.options.slides ? this.snapshot.visited >= this.options.slides - 1 : true
    } else {
      done = finished >= total && surveysDone
    }

    const passed = this.mastery !== null && total > 0 && scaled >= this.mastery && surveysDone

    if (this.profile.version === '1.2') {
      if (this.mastery !== null && total > 0) {
        // In 1.2 passed, failed and completed end the attempt: afterwards an
        // LMS like Moodle only reopens it for review. And with a mastery
        // score, Moodle turns any reported score into passed or failed when
        // the learner leaves. So score and result are reported once
        // everything is done, the attempt stays open until then.
        if (done) {
          this.write(cmi.scoreRaw, String(round(scaled * 100, 2)))
          this.upgrade(cmi.completion, passed ? 'passed' : 'failed')
        }
        return
      }

      if (total > 0) this.write(cmi.scoreRaw, String(round(scaled * 100, 2)))
      this.upgrade(cmi.completion, done ? 'completed' : 'incomplete')
      return
    }

    if (total > 0) {
      this.write(cmi.scoreRaw, String(round(solved)))
      this.write(cmi.scoreScaled!, String(round(scaled)))
    }

    const parts = total + surveys
    const progress = parts > 0 ? (finished + submitted) / parts : done ? 1 : 0
    this.write(cmi.progress!, String(round(Math.min(1, progress))))

    if (done && this.status !== 'completed') {
      this.status = 'completed'
      this.write(cmi.completion, 'completed')
    }

    if (this.mastery !== null && total > 0) {
      const success = passed ? 'passed' : done ? 'failed' : ''
      if (success && this.success !== 'passed' && success !== this.success) {
        this.success = success
        this.write(cmi.success!, success)
      }
    }
  }

  /** 1.2: only ever move a status up */
  private upgrade(element: string, status: string) {
    if ((RANK[status] ?? 0) > (RANK[this.status] ?? 0)) {
      this.status = status
      this.write(element, status)
    }
  }

  // --- interactions ---------------------------------------------------------

  private stateOf(item: Report.Item) {
    if (item.table === 'code') return this.snapshot.code[item.slide]?.[item.index]
    return this.snapshot[item.table][item.slide]?.[item.index]
  }

  private reportItem(slot: Slot) {
    const { item, n } = slot
    const report = Report.report(item, this.stateOf(item), this.profile.version)
    if (!report) return

    const prefix = `cmi.interactions.${n}.`
    const now = this.clock.date()

    this.header(item, n)
    if (report.description !== undefined) this.field(prefix + 'description', report.description)
    if (report.weighting !== undefined) this.field(prefix + 'weighting', report.weighting)
    if (report.pattern !== undefined) this.field(prefix + 'correct_responses.0.pattern', report.pattern)
    if (report.response !== undefined) this.field(prefix + this.profile.cmi.response, report.response)
    if (report.result !== undefined) this.field(prefix + 'result', report.result)

    this.field(prefix + this.profile.cmi.time, this.profile.timestamp(now))
    if (item.slide === this.current) {
      this.field(prefix + 'latency', this.profile.timespan(this.clock.now() - this.enteredAt))
    }
  }

  /**
   * Writes one interaction field. If the LMS refuses it, a text is tried once
   * more as plain ASCII; after that the field is not written again.
   */
  private field(element: string, value: string) {
    const name = element.replace(/^cmi\.interactions\.\d+\./, '').replace(/\.\d+\./g, '.n.')
    if (this.disabled.has(name)) return
    if (this.write(element, value, false)) return

    const simple = ascii(value)
    if (simple !== value && simple !== '' && this.write(element, simple, false)) return

    this.disabled.add(name)
    this.warn(`the LMS refused ${element} = ${JSON.stringify(value)} (${this.lms?.error()}), not writing ${name} again`)
  }

  // --- saving ---------------------------------------------------------------

  private saveSoon() {
    if (!this.writable || this.finished) return

    this.cancelQuiet?.()
    this.cancelQuiet = this.clock.later(() => this.flush(), TIMING.quiet)

    if (!this.cancelLatest) {
      this.cancelLatest = this.clock.later(() => this.flush(), TIMING.latest)
    }
  }

  /** reports what changed, saves the state and commits, now */
  flush() {
    if (!this.lms || this.finished) return

    this.cancelQuiet?.()
    this.cancelLatest?.()
    this.cancelQuiet = this.cancelLatest = null

    if (this.tracking) {
      for (const k of this.dirty) {
        const slot = this.slots.get(k)
        if (slot) this.reportItem(slot)
      }
    }
    this.dirty.clear()

    this.save()

    this.cancelCommit?.()
    this.cancelCommit = null
    if (!this.lms.commit()) this.warn('commit failed:', this.lms.error())
  }

  private save() {
    if (!this.writable || this.readOnly) return

    const limits = this.profile.suspendLimits
    while (this.limit < limits.length) {
      const { text, dropped } = Codec.fit(this.snapshot, this.options.defaults, limits[this.limit])

      const message = dropped.join(', ')
      if (dropped.length && !this.warned.has(message)) {
        this.warned.add(message)
        this.warn(`suspend_data is limited to ${limits[this.limit]} characters, not saved:`, message)
      }

      if (this.write(this.profile.cmi.suspend, text, false)) return

      this.warn(`the LMS refused ${text.length} characters of suspend_data:`, this.lms?.error())
      this.limit++
    }
  }

  // --- LMS access -------------------------------------------------------------

  private read(element: string): string {
    try {
      const value = this.lms?.get(element)
      return typeof value === 'string' ? value : value == null ? '' : String(value)
    } catch (e: any) {
      this.warn('reading', element, 'failed:', e?.message)
      return ''
    }
  }

  /** SetValue, unless the value is already there; true if stored */
  private write(element: string, value: string, warn = true): boolean {
    if (!this.lms) return false
    if (this.lastValues[element] === value) return true

    let ok = false
    try {
      ok = this.lms.set(element, value)
    } catch (e: any) {
      if (warn) this.warn('writing', element, 'failed:', e?.message)
      return false
    }

    if (ok) {
      this.lastValues[element] = value
      this.commitSoon()
    } else if (warn) {
      this.warn(`the LMS refused ${element} = ${JSON.stringify(value).slice(0, 200)}:`, this.lms.error())
    }
    return ok
  }

  private commitSoon() {
    if (this.cancelCommit || this.finished) return
    this.cancelCommit = this.clock.later(() => {
      this.cancelCommit = null
      if (this.lms && !this.finished && !this.lms.commit()) this.warn('commit failed:', this.lms.error())
    }, TIMING.commit)
  }
}
