import { CMIElement, SCORM } from './scorm'

import * as Base from '../Base/index'
import { Settings } from '../Base/settings'
import * as Utils from '../utils'

/**
 * This is a very simplistic Connector, that does only store the current slide
 * position and restore it, if necessary. SCORM 1.2 is in many ways simply to
 * restrictive.
 *
 * @see <https://scorm.com/scorm-explained/technical-scorm/run-time/run-time-reference/#section-2>
 */
class Connector extends Base.Connector {
  private scorm?: SCORM
  private location: number | null
  private active: boolean

  /**
   * To simplify the handling of state data, these are preserved and loaded by
   * this db, which is also replicated as a scorm objective. The state is
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

    this.db = { quiz: [], survey: [], task: [] }
    this.id = { quiz: [], survey: [], task: [] }

    console.warn(
      `Hello, this is LiaScript from within a SCORM 1.2 package. You should definitely try out the SCORM 2004 exporter, since this one cannot be used to store states or any kind of progress. The only thing that is stores, is currently the user location...

IF YOU ARE AN ELABORATE AND EXPERIENCED SCORM DEVELOPER?
========================================================

And you want to help us, to extend this service, please contact us via LiaScript@web.de

Have fun ;-)`
    )

    if (window.top && window.top.API) {
      LOG('successfully opened API')
      this.scorm = window.top.API

      LOG('LMSInitialize', this.scorm.LMSInitialize(''))

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
    if (this.scorm) {
      // store state information only in normal mode
      let mode = this.scorm.LMSGetValue('cmi.core.lesson_mode') || 'unknown'
      this.active = mode === 'normal' || mode === 'unknown'

      WARN(
        'Running in "' +
          mode +
          '" mode, results will ' +
          (this.active ? '' : 'NOT') +
          ' be stored!'
      )

      LOG('open location ...')
      this.location = Utils.jsonParse(
        this.scorm.LMSGetValue('cmi.core.lesson_location')
      )
      LOG('... ', this.location || 0)

      // if no location has been stored so far, this is the first visit
      if (this.location === null) {
        this.slide(0)
      }

      let id = 0
      if (this.countObjectives() === 0 && this.active) {
        // store all data as objectives with an sequential id
        LOG('seeding values ...')
        id = this.initFirst('quiz', id)
        id = this.initFirst('survey', id)
        id = this.initFirst('task', id)
        LOG('... done')
      } else {
        // restore the current state from the objective
        LOG('restoring values ...')
        id = this.initSecond('quiz', id)
        id = this.initSecond('survey', id)
        id = this.initSecond('task', id)
        LOG('... done')
      }

      // calculate the new/old scoring value
      window['SCORE'] = 0
      this.score()
    }
  }

  /**
   * This is helper that populates any kind of states with sequential ids as
   * objectives within the backend.
   * @param key
   * @param id
   * @returns the last sequence id
   */
  initFirst(key: 'quiz' | 'survey' | 'task', id: number) {
    for (let slide = 0; slide < this.db[key].length; slide++) {
      this.id[key].push([])
      for (let i = 0; i < this.db[key][slide].length; i++) {
        this.setObjective(id, this.db[key][slide][i])
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
        let data = this.getObjective(id)

        if (data) {
          this.db[key][slide][i] = data
        }

        this.id[key][slide].push(id)

        id++
      }
    }

    return id
  }

  /**
   * This method currently only scores quizzes if a score was defined by the
   * creator.
   */
  score(): void {
    if (!this.active || !this.score) return

    let total = 0
    let solved = 0
    let finished = 0
    let count = 0

    for (let i = 0; i < this.db.quiz.length; i++) {
      for (let j = 0; j < this.db.quiz[i].length; j++) {
        count = this.db.quiz[i][j].score

        total += count

        switch (this.db.quiz[i][j].solved) {
          case 1: {
            solved += count
          }
          case -1: {
            finished += count
          }
        }
      }
    }

    const score = solved === 0 ? 0 : solved / total

    this.write('cmi.core.score.min', '0')
    this.write('cmi.core.score.max', '100')
    this.write('cmi.core.score.raw', formatCMIDecimal(score * 100))

    let masteryScore = Utils.jsonParse(
      this.scorm?.LMSGetValue('cmi.student_data.mastery_score') || 'null'
    )

    if (masteryScore == null) {
      this.write('cmi.core.lesson_status', 'not attempted')
    } else {
      if (score >= masteryScore / 100) {
        this.write('cmi.core.lesson_status', 'passed')
      } else if (finished + solved === total) {
        this.write('cmi.core.lesson_status', 'failed')
      } else {
        this.write('cmi.core.lesson_status', 'incomplete')
      }
    }

    window['SCORE'] = score
  }

  /**
   * This module does nothing at the moment, it is only used to indicate that
   * the course is now ready. If so, we will open the last visited slide.
   */
  open(_uri: string, _version: number, _slide: number) {
    if (this.location !== null) {
      const location = this.location
      setTimeout(function () {
        window['LIA'].goto(location)
      }, 500)
    }
  }

  slide(id: number): void {
    this.location = id

    if (this.scorm && this.active) {
      this.scorm.LMSSetValue('cmi.core.lesson_location', JSON.stringify(id))
      this.scorm.LMSCommit('')
    }
  }

  countObjectives(): number | null {
    if (!this.scorm) return null

    let value = parseInt(this.scorm.LMSGetValue('cmi.objectives._count'))

    return value || 0
  }

  initSettings(data: Lia.Settings | null, local = false) {
    return Settings.init(data, false, this.setSettings)
  }

  setSettings(data: Lia.Settings) {
    this.write(`cmi.suspend_data`, JSON.stringify(data))
  }

  getSettings() {
    let data: string | null = ''

    try {
      data = this.scorm?.LMSGetValue('cmi.suspend_data') || null
    } catch (e) {
      WARN('cannot read settings from cmi.suspend_data')
    }

    let json: Lia.Settings | null = null

    if (typeof data === 'string') {
      try {
        json = JSON.parse(data)
      } catch (e) {
        WARN('getSettings =>', e)
      }

      if (!json) {
        json = Settings.data
      }

      if (window.innerWidth <= 768) {
        json.table_of_contents = false
      }
    }

    return json
  }

  write(uri: CMIElement, data: string) {
    if (this.scorm) {
      this.scorm.LMSSetValue(uri, data)
      this.scorm.LMSCommit('')
    } else {
      WARN('could not write', uri, data)
    }
  }

  /**
   * Read out the state from the backend
   * @param id
   * @returns
   */
  getObjective(id: number): any | null {
    if (!this.active) return null

    let data: undefined | string

    try {
      if (this.scorm) {
        data = this.scorm.LMSGetValue(`cmi.objectives.${id}.id`)

        if (data) return Utils.decodeJSON(data)
      }
    } catch (e) {
      WARN('getObjective =>', e, `cmi.objectives.${id}.id`, data)
    }

    return null
  }

  /**
   * Store the current user state as a stringified json.
   * @param id
   * @param state
   */
  setObjective(id: number, state: any): void {
    const data = Utils.encodeJSON(state)

    if (data.length > 255) {
      WARN(`cmi.objectives.${id}.id`, 'Content exceeds 256Bytes!')
    }

    this.write(`cmi.objectives.${id}.id`, data)
  }

  /**
   * Since the date is stored in local memory, it is okay, if it is read from
   * the memory directly. Changes are only feed back wile storing.
   *
   * @param record
   * @returns the loaded dataset or nothing (for code)
   */
  load(record: Base.Record) {
    if (!this.active) return

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

  /**
   * Store the data, send from LiaScript to the Backend.
   * @param record
   */
  store(record: Base.Record) {
    if (!this.active) return

    WARN('store', record)

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
  storeHelper(record: Base.Record) {
    for (let i = 0; i < this.db[record.table][record.id].length; i++) {
      if (Utils.neq(record.data[i], this.db[record.table][record.id][i])) {
        this.setObjective(this.id[record.table][record.id][i], record.data[i])

        // store the changed data in memory
        this.db[record.table][record.id][i] = record.data[i]

        // mark quizzes if possible
        if (record.table == 'quiz') {
          this.updateQuiz(this.id[record.table][record.id][i], record.data[i])
        }
      }
    }
  }

  /**
   * Quizzes might be marked for some reason with additional labels.
   * @param id - sequential objective id
   * @param state - of the quit
   * @returns
   */
  updateQuiz(id: number, state: any): void {
    if (!this.active) return

    switch (state.solved) {
      case 0: {
        if (state.trial > 0) this.write(`cmi.objectives.${id}.status`, 'failed')
        break
      }
      case 1: {
        this.write(`cmi.objectives.${id}.status`, 'completed')
        break
      }
      case -1: {
        this.write(`cmi.objectives.${id}.status`, 'incomplete')
        break
      }
    }
  }
}

/**
 * Only for debugging purposes. Needs :
 *
 * `window.LIA.debug = true`
 *
 * @param args
 */
function LOG(...args) {
  console.log('SCORM1.2: ', ...args)
}

/**
 * Only for debugging purposes. Needs :
 *
 * `window.LIA.debug = true`
 *
 * @param args
 */
function WARN(...args) {
  console.log('SCORM1.2: ', ...args)
}

function formatCMIDecimal(floatValue: number) {
  // Round the float value to 4 decimal places
  const roundedValue = floatValue.toFixed(4)

  // Split the integer and fractional parts
  const [integerPart, fractionalPart] = roundedValue.toString().split('.')

  // Construct the CMIDecimal string with up to 10 digits to the left of the decimal point and 10 digits to the right of the decimal point
  const formattedValue = `${integerPart}.${fractionalPart.padEnd(10, '0')}`

  // Return the formatted value
  return formattedValue
}

export { Connector }
