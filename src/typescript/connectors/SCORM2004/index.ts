import { Connector as Base, Record } from '../Base/index'
import { CMIElement, SCORM } from './scorm.d'
import log from '../../liascript/log'
/**
 * This implementation of a SCORM 2004 connector for LiaScript is mainly based
 * on the definitions at:
 *
 * <https://scorm.com/scorm-explained/technical-scorm/run-time/run-time-reference/#section-4>
 */
class Connector extends Base {
  private scorm?: SCORM

  /**
   * A course can be opened in different cmi.modes:
   *
   * - browse
   * - normal
   * - review
   *
   * Only in normal mode the states will be stored actively within the backend.
   */
  private active: boolean

  /**
   * Stored currently active slide number
   */
  private location: number | null

  /**
   * This score is a value between 0 and 1. It indicated is the course shall be
   * rated or not. Every value larger than 0 will result in an rated course.
   */
  private scaled_passing_score: number | null

  /**
   * To simplify the handling of state data, these are preserved and loaded by
   * this db, which is also replicated as a scorm interaction. The state is
   * stored as the associated learner_response (type "long-fill-in")
   */
  private db: {
    quiz: any[][]
    survey: any[][]
    task: any[][]
  }

  /**
   * Data is stored linearly within the backend and requires a unique ID per
   * element. This object is used to provide a simple lookup handler to get
   * from a 2d position to a 1d Id ;-)
   */
  private id: {
    quiz: number[][]
    survey: number[][]
    task: number[][]
  }

  constructor() {
    super()

    // by default no data will be stored
    this.active = false

    // and the course will not be rated
    this.scaled_passing_score = null

    this.db = { quiz: [], survey: [], task: [] }
    this.id = { quiz: [], survey: [], task: [] }

    // try if there is an SCORM 2004 api accessible
    if (window.API_1484_11 || window.top.API_1484_11) {
      LOG('successfully opened API')
      this.scorm = window.API_1484_11 || window.top.API_1484_11

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
    }
  }

  init() {
    if (!this.scorm) return

    LOG('Initialize ', this.scorm.Initialize(''))

    // store state information only in normal mode
    let mode = this.scorm.GetValue('cmi.mode')
    this.active = mode === 'normal'

    this.active = true

    this.scaled_passing_score = JSON.parse(
      this.scorm.GetValue('cmi.scaled_passing_score')
    )

    LOG('open location ...')
    this.location = jsonParse(this.scorm.GetValue('cmi.location'))
    LOG('... ', this.location)

    // if no location has been stored so far, this is the first visit
    if (this.location === null) {
      this.slide(0)

      // store all data as interactions with an sequential id
      let id = 0
      id = this.initFirst('quiz', id)
      id = this.initFirst('survey', id)
      id = this.initFirst('task', id)
    } else {
      // restore the current state from the interactions
      let id = 0
      id = this.initSecond('quiz', id)
      id = this.initSecond('survey', id)
      id = this.initSecond('task', id)
    }
  }

  /**
   * This is helper that populates any kind of states with sequential ids as
   * interactions within the backend.
   * @param key
   * @param id
   * @returns the last sequence id
   */
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

  /**
   * If the data has already been stored it is loaded with this method and the
   * sequential ids are restored to the `this.id` look-up table.
   * @param key
   * @param id
   * @returns the last sequence id
   */
  initSecond(key: 'quiz' | 'survey' | 'task', id: number) {
    for (let slide = 0; slide < this.db[key].length; slide++) {
      this.id[key].push([])

      for (let i = 0; i < this.db[key][slide].length; i++) {
        let data = this.getInteraction(id)
        if (data) {
          this.db[key][slide][i] = data[2]
        }
        this.id[key][slide].push(id)

        id++
      }
    }

    return id
  }

  /**
   * This module does nothing at the moment, it is only used to indicate that
   * the course is now ready. If so, we will open the last visited slide.
   */
  open(_uri: string, _version: number, _slide: number) {
    if (this.location !== null) window.LIA.goto(this.location)
  }

  /**
   * Since the date is stored in local memory, it is okay, if it is read from
   * the memory directly. Changes are only feed back wile storing.
   *
   * @param record
   * @returns the loaded dataset or nothing (for code)
   */
  load(record: Record) {
    if (!this.active) return

    switch (record.table) {
      case 'quiz':
      case 'survey':
      case 'task':
        LOG('loading ', record.table, record.id, this.db.task[record.id])
        return this.db[record.table][record.id]
    }
  }

  /**
   * Store the data, send from LiaScript to the Backend.
   * @param record
   */
  store(record: Record) {
    if (!this.active) return

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

  /**
   * This helper checks if there has been a change in the new version and if
   * so, this will be stored within the backend
   * @param record
   */
  storeHelper(record: Record) {
    for (let i = 0; i < this.db[record.table][record.id].length; i++) {
      if (neq(record.data[i], this.db[record.table][record.id][i])) {
        this.updateInteraction(
          this.id[record.table][record.id][i],
          record.data[i]
        )

        // mark quizzes if possible
        if (record.table == 'quiz') {
          this.updateQuiz(this.id[record.table][record.id][i], record.data[i])
        }
      }
    }
  }

  /**
   * This method currently only scores quizzes if a score was defined by the
   * creator.
   */
  score(): void {
    if (!this.active || !this.scaled_passing_score) return

    let total = this.db.quiz.reduce((a, b) => a + b.length, 0)

    let solved = this.db.quiz
      .map((e) => e.filter((f) => f === true))
      .reduce((a, b) => a + b.length, 0)

    // since a user can try out quizzes as much often as he or she wants, only
    // solved or resolved quizzes are taken into account
    let finished = this.db.quiz
      .map((e) => e.filter((f) => f != null))
      .reduce((a, b) => a + b.length, 0)

    let score = solved === 0 ? 0 : solved / total

    this.write('cmi.score.min', '0')
    this.write('cmi.score.max', JSON.stringify(total))
    this.write('cmi.score.raw', JSON.stringify(solved))

    if (score >= this.scaled_passing_score) {
      this.write('cmi.success_status', 'passed')
    } else if (finished === solved) {
      this.write('cmi.success_status', 'failed')
    }
  }

  /**
   * Helper function to debug when writing values to the backend. If writing
   * fails, it will spit out as much information/warnings as possible.
   * @param uri
   * @param data
   */
  write(uri: CMIElement, data: string): void {
    if (!this.scorm) return

    LOG('write: ', uri, data)

    if (this.scorm.SetValue(uri, data) === 'false') {
      console.warn('error occurred for ', uri, data)

      let error = this.scorm.GetLastError()
      console.warn('GetLastError:', error)
      if (error) {
        console.warn('GetErrorString:', this.scorm.GetErrorString(error))
        console.warn('GetDiagnostic:', this.scorm.GetDiagnostic(error))
      } else {
        console.warn('GetDiagnostic:', this.scorm.GetDiagnostic(''))
      }
    }

    this.scorm.Commit('')
  }

  /**
   * store the last visited slide permanently.
   * @param id
   */
  slide(id: number) {
    this.location = id
    this.write('cmi.location', JSON.stringify(id))
  }

  /** Interactions are used to store quizzes, this, way, the objectives
   * can be used to to store the different states.
   *
   * @param id
   * @param content
   * @returns
   */
  setInteraction(id: number, content: string) {
    this.write(`cmi.interactions.${id}.id`, content)
    this.write(`cmi.interactions.${id}.type`, 'long-fill-in')
  }

  /**
   * Quizzes might be marked for some reason with additional labels.
   * @param id - sequential interaction id
   * @param state - of the quit
   * @returns
   */
  updateQuiz(id: number, state: any): void {
    if (!this.active) return

    switch (state.solved) {
      case 0: {
        if (state.trial > 0)
          this.write(`cmi.interactions.${id}.result`, 'incorrect')
        break
      }
      case 1: {
        this.write(`cmi.interactions.${id}.result`, 'correct')
        break
      }
      case -1: {
        this.write(`cmi.interactions.${id}.result`, 'neutral')
        break
      }
    }
  }

  /**
   * Store the current user state as a stringified json.
   * @param id
   * @param state
   */
  updateInteraction(id: number, state: any): void {
    this.write(`cmi.interactions.${id}.learner_response`, JSON.stringify(state))
  }

  /**
   * Read out the state from the backend
   * @param id
   * @returns
   */
  getInteraction(id: number): any | null {
    if (!this.active) return null

    try {
      return JSON.parse(
        this.scorm.GetValue(`cmi.interactions.${id}.learner_response`)
      )
    } catch (e) {
      console.warn('SCORM: getInteraction => ', e)
    }

    return null
  }
}

/**
 * A simple json-parser that does not trow an error, but returns null if it fails
 * @param string - a valid JSON representation
 */
function jsonParse(json: string) {
  try {
    return JSON.parse(json)
  } catch (e) {}
  return null
}

/**
 * Compare Object state information for quizzes, surveys, and tasks
 * @param a
 * @param b
 * @returns true if not equal otherwise false
 */
function neq(a: any, b: any) {
  return JSON.stringify(a) != JSON.stringify(b)
}

/**
 * Only for debugging purposes. Needs :
 *
 * `window.LIA.debug = true`
 *
 * @param args
 */
function LOG(...args) {
  log.info('SCORM2004: ' + args)
}

/**
 * Only for debugging purposes. Needs :
 *
 * `window.LIA.debug = true`
 *
 * @param args
 */
function WARN(...args) {
  log.warn('SCORM2004: ' + args)
}

export { Connector }
