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
  private location: number | null

  /** Passing threshold in [0,1] */
  private scaled_passing_score: number | null

  /** Inited flag + timing */
  private inited: boolean = false
  private startMs: number = 0
  private commitTimer: number | null = null

  /** Small write buffer for frequent SetValue calls */
  private pending: Array<[CMIElement, string]> = []
  private flushTimer: number | null = null

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
      this.writeBuffered('cmi.suspend_data', JSON.stringify(data))
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

  private flushPendingNow() {
    if (!this.scorm || !this.active) return
    if (this.pending.length === 0) return

    for (const [u, d] of this.pending) {
      if (this.scorm.SetValue(u, d) === 'false') {
        const e = this.scorm.GetLastError()
        WARN(
          'SetValue error',
          u,
          d,
          e,
          this.scorm.GetErrorString(e),
          this.scorm.GetDiagnostic(e)
        )
      }
    }
    this.pending = []
    this.commit()
  }

  private writeBuffered(uri: CMIElement, data: string) {
    if (!this.scorm || !this.active) return
    this.pending.push([uri, data])
    if (this.flushTimer) return

    this.flushTimer = window.setTimeout(() => {
      this.flushTimer = null
      this.flushPendingNow()
    }, 300)
  }

  /** Direct SetValue + immediate commit (critical updates) */
  private write(uri: CMIElement, data: string): void {
    if (!this.scorm || !this.active) return

    LOG('write: ', uri, data)

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

    this.commit()
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

    // ensure pending writes are flushed
    this.flushPendingNow()

    // set session time
    const dur = this.isoDuration(Date.now() - this.startMs)
    this.scorm.SetValue('cmi.session_time', dur)

    // bookmark or close attempt
    this.scorm.SetValue('cmi.exit', suspend ? 'suspend' : '')

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
        this.storeHelper(record)
        this.score()
        break
      case 'survey':
      case 'task':
        this.storeHelper(record)
        break
    }
  }

  storeHelper(record: Base.Record) {
    for (let i = 0; i < this.db[record.table][record.id].length; i++) {
      if (Utils.neq(record.data[i], this.db[record.table][record.id][i])) {
        this.updateInteraction(
          this.id[record.table][record.id][i],
          record.data[i]
        )
        // mirror in memory
        this.db[record.table][record.id][i] = record.data[i]
        // mark quiz results if available
        if (record.table === 'quiz') {
          this.updateQuiz(this.id[record.table][record.id][i], record.data[i])
        }
      }
    }
  }

  /**
   * Compute score/progress for UI *always*; write to LMS only when active.
   */
  score(): void {
    let total = 0
    let solved = 0
    let finished = 0
    let count = 0

    for (let i = 0; i < this.db.quiz.length; i++) {
      for (let j = 0; j < this.db.quiz[i].length; j++) {
        count = this.db.quiz[i][j].score
        total += count
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

    const score = total === 0 ? 0 : solved / total
    const progress = total === 0 ? 0 : (solved + finished) / total

    // Always update UI-visible score
    ;(window as any)['SCORE'] = score
    LOG('SCORE updated =>', score, 'progress =>', progress)

    // If not active (preview or no-credit), stop here.
    if (!this.scorm || !this.active) return

    // LMS writes
    this.write('cmi.score.min', '0')
    this.write('cmi.score.max', JSON.stringify(total))
    this.write('cmi.score.scaled', JSON.stringify(score))
    this.write('cmi.score.raw', JSON.stringify(solved))
    this.write('cmi.progress_measure', JSON.stringify(progress))

    if (this.scaled_passing_score != null) {
      if (score >= this.scaled_passing_score) {
        this.write('cmi.success_status', 'passed')
        this.write('cmi.completion_status', 'completed')
      } else if (finished + solved === total && total > 0) {
        this.write('cmi.success_status', 'failed')
        this.write('cmi.completion_status', 'completed')
      } else {
        this.write('cmi.success_status', 'unknown')
        this.write('cmi.completion_status', 'incomplete')
      }
    } else {
      // No mastery available → success unknown; completion from progress
      this.write('cmi.success_status', 'unknown')
      if (finished + solved === total && total > 0) {
        this.write('cmi.completion_status', 'completed')
      } else {
        this.write('cmi.completion_status', 'incomplete')
      }
    }
  }

  slide(id: number) {
    this.location = id
    this.writeBuffered('cmi.location', JSON.stringify(id))
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
    this.writeBuffered(
      ('cmi.interactions.' + id + '.learner_response') as CMIElement,
      Utils.encodeJSON(state)
    )
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
  console.log('SCORM2004: ', ...args)
}

function WARN(...args: any[]) {
  console.log('SCORM2004: ', ...args)
}

export { Connector }
