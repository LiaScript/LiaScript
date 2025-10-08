import * as Base from '../Base/index'
import { CMIElement, SCORM } from './scorm.d'
import log from '../../liascript/log'
import { Settings } from '../Base/settings'

import * as Utils from '../utils'

/**
 * Improved SCORM 2004 connector for LiaScript
 * - Proper Initialize/Commit/Terminate lifecycle
 * - Tracks session time (cmi.session_time) in ISO-8601 duration
 * - Uses cmi.exit = "suspend" on close for bookmarking (and checks cmi.entry)
 * - Respects cmi.mode AND cmi.credit for deciding whether to store
 * - Periodic commits + pagehide/visibilitychange safety
 * - Buffered writes for chatty updates; direct writes for critical status/score
 * - Always updates window.SCORE (even in preview/no-credit)
 */
class Connector extends Base.Connector {
  private scorm?: SCORM

  /** Active = we will store/track. Only when mode=normal AND credit=credit */
  private active: boolean

  /** Stored currently active slide number */
  private location: number | null = null

  /** Passing threshold in [0,1] */
  private scaled_passing_score: number | null

  /** Inited flag + timing */
  private inited: boolean = false
  private startMs: number = 0
  private commitTimer: number | null = null
  private totalScore: number = 0
  private pendingCommit: number | null = null

  /** Cache last written values to avoid redundant LMS traffic */
  private lastValues: Record<string, string> = {}

  /** Throttle per-interaction latency writes */
  private lastLatencyAt: Map<number, number> = new Map()
  private lastWriteAt: Map<string, number> = new Map()

  /** State mirrors */
  private db: { quiz: any[][]; survey: any[][]; task: any[][] }
  private id: { quiz: number[][]; survey: number[][]; task: number[][] }

  constructor() {
    super()

    this.active = false
    this.scaled_passing_score = null

    this.db = { quiz: [], survey: [], task: [] }
    this.id = { quiz: [], survey: [], task: [] }

    const scormAPI = this.getAPI(window)

    if (scormAPI) {
      LOG('successfully opened API')
      this.scorm = scormAPI

      LOG('loading quizzes ...')
      try {
        // @ts-ignore
        this.db.quiz = window.config_.quiz || [[]]
        LOG(' ... done')

        for (let i = 0; i < this.db.quiz.length; i++) {
          for (let j = 0; j < this.db.quiz[i].length; j++) {
            this.totalScore += this.db.quiz[i][j].score
          }
        }
      } catch (e) {
        WARN('... failed', e)
      }

      LOG('loading surveys ...')
      try {
        // @ts-ignore
        this.db.survey = window.config_.survey || [[]]
        LOG(' ... done')
      } catch (e) {
        WARN('... failed', e)
      }

      LOG('loading tasks ...')
      try {
        // @ts-ignore
        this.db.task = window.config_.task || [[]]
        LOG(' ... done')
      } catch (e) {
        WARN('... failed', e)
      }

      this.init()
    } else {
      WARN('Could not find API')
    }
  }

  // ———————————————————————————————————————————
  // API discovery (SCORM standard algorithm)
  // ———————————————————————————————————————————
  scanForAPI(win: any) {
    let nFindAPITries = 0
    const maxTries = 500
    try {
      while (
        win.API_1484_11 == null &&
        win.parent != null &&
        win.parent != win
      ) {
        nFindAPITries++
        if (nFindAPITries > maxTries) {
          return null
        }
        win = win.parent
      }
      return win.API_1484_11
    } catch (e: any) {
      WARN('scanForAPI =>', e?.message)
    }
    return null
  }

  getAPI(win: any) {
    let API = null
    if (win.parent != null && win.parent != win) {
      API = this.scanForAPI(win.parent)
    }
    if (API == null && win.opener != null) {
      API = this.scanForAPI(win.opener)
    }
    return API
  }

  // ———————————————————————————————————————————
  // Settings bridge
  // ———————————————————————————————————————————
  initSettings(data: Lia.Settings | null, local = false) {
    return Settings.init(data, false, this.setSettings)
  }

  setSettings = (data: Lia.Settings) => {
    if (this.active && this.scorm) {
      this.write('cmi.suspend_data', JSON.stringify(data))
    } else {
      WARN('cannot write to "cmi.suspend_data"')
    }
  }

  getSettings() {
    let data: string | null = ''

    try {
      data = this.scorm?.GetValue('cmi.suspend_data') || null
    } catch (e) {
      WARN('cannot read settings from cmi.suspend_data')
    }

    let json: Lia.Settings | null = null

    if (typeof data === 'string' && data !== '') {
      try {
        json = JSON.parse(data)
      } catch (e) {
        WARN('getSettings =>', e)
      }
    }

    if (!json) {
      json = Settings.data
    }

    if (window.innerWidth <= 768) {
      json.table_of_contents = false
    }

    return json
  }

  // ———————————————————————————————————————————
  // Lifecycle
  // ———————————————————————————————————————————
  private isoDuration(ms: number) {
    const s = ms / 1000
    const h = Math.floor(s / 3600)
    const m = Math.floor((s % 3600) / 60)
    const sec = (s % 60).toFixed(2)
    return `PT${h}H${m}M${sec}S`
  }

  private commit() {
    if (!this.scorm || !this.inited) return
    const ok = this.scorm.Commit('')
    if (ok === 'false') {
      const e = this.scorm.GetLastError()
      WARN(
        'Commit error',
        e,
        this.scorm.GetErrorString(e),
        this.scorm.GetDiagnostic(e)
      )
    }
  }

  /**
   * Buffered SetValue. Avoids duplicate writes and batches Commit calls.
   * Use flush=true for critical updates (e.g., finish/exit).
   */
  private write(uri: CMIElement, data: string, flush: boolean = false): void {
    if (!this.scorm || !this.active) return

    LOG('write: ', uri, data)

    // Skip duplicate writes
    if (this.lastValues[uri] === data) {
      if (flush) this.commit()
      return
    }
    this.lastValues[uri] = data

    if (this.scorm.SetValue(uri, data) === 'false') {
      WARN('error occurred for', uri, data)
      const error = this.scorm.GetLastError()
      WARN('GetLastError:', error)
      if (error) {
        WARN('GetErrorString:', this.scorm.GetErrorString(error))
        WARN('GetDiagnostic:', this.scorm.GetDiagnostic(error))
      } else {
        WARN('GetDiagnostic:', this.scorm.GetDiagnostic(''))
      }
    }

    if (flush) {
      this.commit()
    } else {
      // debounce commit burst
      if (this.pendingCommit) {
        clearTimeout(this.pendingCommit)
      }
      this.pendingCommit = window.setTimeout(() => {
        this.pendingCommit = null
        this.commit()
      }, 750)
    }
  }

  /** Throttled write to avoid spamming LMS for fast-changing fields */
  private writeThrottled(
    uri: CMIElement,
    data: string,
    intervalMs: number = 300
  ): void {
    const now = Date.now()
    const last = this.lastWriteAt.get(uri) || 0
    if (now - last >= intervalMs || this.lastValues[uri] !== data) {
      this.lastWriteAt.set(uri, now)
      this.write(uri, data)
    }
  }

  init() {
    if (!this.scorm) return

    const ok = this.scorm.Initialize('')
    this.inited = ok === 'true'
    LOG('Initialize', ok)
    if (!this.inited) {
      WARN('Initialize failed')
      return
    }

    this.startMs = Date.now()

    const mode = this.scorm.GetValue('cmi.mode') || ''
    const credit = this.scorm.GetValue('cmi.credit') || ''
    this.active = mode === 'normal' && credit === 'credit'

    WARN(
      `Running in "${mode}" mode, credit=${credit}. Results will ${
        this.active ? '' : 'NOT '
      }be stored!`
    )

    if (this.active) {
      // passing score
      this.scaled_passing_score = Utils.jsonParse(
        this.scorm.GetValue('cmi.scaled_passing_score')
      )
      if (!this.scaled_passing_score) {
        this.scaled_passing_score = (window as any)['MASTERY_SCORE'] || null
      }

      // ensure baseline completion
      const cs = this.scorm.GetValue('cmi.completion_status')
      if (!cs) {
        this.write('cmi.completion_status', 'incomplete')
      }

      // set static score bounds once
      this.write('cmi.score.min', '0')
      this.write('cmi.score.max', JSON.stringify(this.totalScore))

      // restore location/bookmark
      const entry = this.scorm.GetValue('cmi.entry')
      LOG('cmi.entry =', entry)
      this.location = Utils.jsonParse(this.scorm.GetValue('cmi.location'))
      LOG('open location ...', this.location)
    }

    // first visit? go to slide 0
    if (this.location === null || this.location === undefined) {
      this.slide(0)
    }

    // interactions: create or restore
    const interactionsStored = this.countInteractions()
    if (this.active && interactionsStored === 0) {
      let id = 0
      id = this.initFirst('quiz', id)
      id = this.initFirst('survey', id)
      id = this.initFirst('task', id)
    } else {
      let id = 0
      id = this.initSecond('quiz', id)
      id = this.initSecond('survey', id)
      id = this.initSecond('task', id)
    }

    ;(window as any)['SCORE'] = 0
    this.score()

    // periodic commit
    this.commitTimer = window.setInterval(() => this.commit(), 45000)

    // safe close hooks
    window.addEventListener('pagehide', () => this.finish(true))
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'hidden') this.commit()
    })
  }

  finish(suspend: boolean) {
    if (!this.scorm || !this.inited) return

    // set session time
    const dur = this.isoDuration(Date.now() - this.startMs)
    this.scorm.SetValue('cmi.session_time', dur)

    // bookmark or close attempt
    this.scorm.SetValue('cmi.exit', suspend ? 'suspend' : '')

    // ensure all pending data is flushed now
    if (this.pendingCommit) {
      clearTimeout(this.pendingCommit)
      this.pendingCommit = null
    }
    this.commit()

    const ok = this.scorm.Terminate('')
    this.inited = false

    if (this.commitTimer) {
      clearInterval(this.commitTimer)
      this.commitTimer = null
    }
    WARN('Terminate:', ok)
  }

  // ———————————————————————————————————————————
  // Interactions init/load helpers
  // ———————————————————————————————————————————
  initFirst(key: 'quiz' | 'survey' | 'task', id: number) {
    for (let slide = 0; slide < this.db[key].length; slide++) {
      this.id[key].push([])
      for (let i = 0; i < this.db[key][slide].length; i++) {
        this.setInteraction(id, `${key}:${slide}-${i}`)
        this.id[key][slide].push(id)
        id++
      }
    }
    return id
  }

  countInteractions(): number {
    if (!this.scorm) return 0
    const raw = this.scorm.GetValue('cmi.interactions._count')
    const n = parseInt(raw || '0', 10)
    return Number.isFinite(n) ? n : 0
  }

  initSecond(key: 'quiz' | 'survey' | 'task', id: number) {
    for (let slide = 0; slide < this.db[key].length; slide++) {
      this.id[key].push([])
      for (let i = 0; i < this.db[key][slide].length; i++) {
        const data = this.getInteraction(id)
        if (data) this.db[key][slide][i] = data
        this.id[key][slide].push(id)
        id++
      }
    }
    return id
  }

  // ———————————————————————————————————————————
  // LiaScript hooks
  // ———————————————————————————————————————————
  open(_uri: string, _version: number, _slide: number) {
    if (this.location !== null && this.location !== undefined) {
      const location = this.location
      setTimeout(function () {
        ;(window as any)['LIA'].goto(location)
      }, 500)
    }
  }

  load(record: Base.Record) {
    switch (record.table) {
      case 'quiz':
      case 'survey':
      case 'task':
        LOG(
          'loading ',
          record.table,
          record.id,
          this.db[record.table][record.id]
        )
        return this.db[record.table][record.id]
    }
  }

  store(record: Base.Record) {
    // Always recompute SCORE for UI even in preview/no-credit
    switch (record.table) {
      case 'quiz':
      case 'survey':
        this.storeHelper(record)
        this.score()
        break
      case 'task':
        this.storeHelper(record)
        break
    }
  }

  storeHelper(record: Base.Record) {
    const table = record.table as 'quiz' | 'survey' | 'task'
    for (let i = 0; i < this.db[table][record.id].length; i++) {
      if (Utils.neq(record.data[i], this.db[table][record.id][i])) {
        this.updateInteraction(this.id[table][record.id][i], record.data[i])
        // mirror in memory
        this.db[table][record.id][i] = record.data[i]

        // mark quiz results if available
        if (table === 'quiz') {
          this.updateQuiz(this.id[table][record.id][i], record.data[i])
        }
      }
    }
  }

  /**
   * Compute score/progress for UI *always*; write to LMS only when active.
   */
  score(): void {
    let solved = 0
    let finished = 0
    let count = 0

    for (let i = 0; i < this.db.quiz.length; i++) {
      for (let j = 0; j < this.db.quiz[i].length; j++) {
        count = this.db.quiz[i][j].score

        switch (this.db.quiz[i][j].solved) {
          case 1:
            solved += count
            break
          case -1:
            finished += count
            break
        }
      }
    }

    let surveyCount = 0
    let surveySubmitted = 0
    for (let i = 0; i < this.db.survey.length; i++) {
      for (let j = 0; j < this.db.survey[i].length; j++) {
        surveyCount += 1

        if (this.db.survey[i][j].submitted) {
          surveySubmitted += 1
        }
      }
    }

    const score = this.totalScore === 0 ? 0 : solved / this.totalScore
    const progress =
      this.totalScore === 0 ? 0 : (solved + finished) / this.totalScore

    // Check if all surveys are completed
    const allSurveysCompleted =
      surveyCount === 0 || surveyCount === surveySubmitted

    // Always update UI-visible score
    ;(window as any)['SCORE'] = score
    LOG(
      'SCORE updated =>',
      score,
      'progress =>',
      progress,
      'surveys =>',
      `${surveySubmitted}/${surveyCount}`
    )

    // If not active (preview or no-credit), stop here.
    if (!this.scorm || !this.active) return

    // LMS writes (min/max already set at init)
    const round = (v: number) => Math.round(v * 10000) / 10000
    this.write('cmi.score.scaled', JSON.stringify(round(score)))
    this.write('cmi.score.raw', JSON.stringify(solved))
    this.write('cmi.progress_measure', JSON.stringify(round(progress)))

    if (this.scaled_passing_score != null) {
      if (
        (score >= this.scaled_passing_score || this.totalScore === 0) &&
        allSurveysCompleted
      ) {
        this.write('cmi.success_status', 'passed')
        this.write('cmi.completion_status', 'completed')
      } else if (
        finished + solved === this.totalScore &&
        this.totalScore > 0 &&
        allSurveysCompleted
      ) {
        this.write('cmi.success_status', 'failed')
        this.write('cmi.completion_status', 'completed')
      } else {
        this.write('cmi.success_status', 'unknown')
        this.write('cmi.completion_status', 'incomplete')
      }
    } else {
      // No mastery available → success unknown; completion from progress
      this.write('cmi.success_status', 'unknown')
      if (
        (finished + solved === this.totalScore &&
          this.totalScore > 0 &&
          allSurveysCompleted) ||
        (this.totalScore === 0 && allSurveysCompleted && surveyCount > 0)
      ) {
        this.write('cmi.completion_status', 'completed')
      } else {
        this.write('cmi.completion_status', 'incomplete')
      }
    }
  }

  slide(id: number) {
    this.location = id
    this.write('cmi.location', JSON.stringify(id))
  }

  setInteraction(id: number, content: string) {
    this.write(`cmi.interactions.${id}.id`, content)
    this.write(`cmi.interactions.${id}.type`, 'long-fill-in')
  }

  updateQuiz(id: number, state: any): void {
    if (!this.active) return

    switch (state.solved) {
      case 0:
        if (state.trial > 0)
          this.write(`cmi.interactions.${id}.result`, 'incorrect')
        break
      case 1:
        this.write(`cmi.interactions.${id}.result`, 'correct')
        break
      case -1:
        this.write(`cmi.interactions.${id}.result`, 'neutral')
        break
    }
  }

  updateInteraction(id: number, state: any): void {
    // use buffer: this can be frequent
    this.writeThrottled(
      `cmi.interactions.${id}.learner_response`,
      Utils.encodeJSON(state),
      300
    )

    if (state.score) {
      this.write(
        `cmi.interactions.${id}.weighting`,
        JSON.stringify(state.score)
      )
    }

    // For surveys, track submission status
    if (state.submitted) {
      this.write(`cmi.interactions.${id}.result`, 'neutral')
    }

    // Only write timestamp if it hasn't been set before
    if (!this.scorm?.GetValue(`cmi.interactions.${id}.timestamp`)) {
      var date = new Date()
      var timestamp = new Date(
        date.getTime() - date.getTimezoneOffset() * 60000
      )
        .toISOString()
        .slice(0, -5)

      this.write(`cmi.interactions.${id}.timestamp`, timestamp)
    }

    // set latency (throttled per interaction)
    const now = Date.now()
    const last = this.lastLatencyAt.get(id) || 0
    if (now - last > 5000 || state.solved !== 0 || state.submitted) {
      const dur = this.isoDuration(now - this.startMs)
      this.write(`cmi.interactions.${id}.latency`, dur)
      this.lastLatencyAt.set(id, now)
    }
  }

  getInteraction(id: number): any | null {
    try {
      if (this.scorm) {
        const val = this.scorm.GetValue(
          `cmi.interactions.${id}.learner_response`
        )
        if (val !== '') {
          return Utils.decodeJSON(val)
        }
      }
    } catch (e) {
      WARN('getInteraction => ', e)
    }
    return null
  }
}

function LOG(...args: any[]) {
  if (window.LIA.debug) console.log('SCORM2004: ', ...args)
}

function WARN(...args: any[]) {
  if (window.LIA.debug) console.log('SCORM2004: ', ...args)
}

export { Connector }
