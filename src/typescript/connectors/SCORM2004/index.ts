import { Connector as Base, Record } from '../Base/index'
import { CMIElement, SCORM } from './scorm.d'
import log from '../../liascript/log'

function jsonParse(string: string) {
  try {
    return JSON.parse(string)
  } catch (e) {}
  return null
}

function neq(a: any, b: any) {
  return JSON.stringify(a) != JSON.stringify(b)
}

function LOG(...args) {
  log.info('SCORM2004: ' + args)
}

function WARN(...args) {
  log.warn('SCORM2004: ' + args)
}

class Connector extends Base {
  private scorm?: SCORM
  private active: boolean

  private quiz: any[][]
  private survey: any[][]
  private task: any[][]

  private quiz_ids: number[][]
  private survey_ids: number[][]
  private task_ids: number[][]

  constructor() {
    super()

    this.active = true

    window.LIA.debug = true

    if (window.API_1484_11 || window.top.API_1484_11) {
      LOG('successfully opened API')
      this.scorm = window.API_1484_11 || window.top.API_1484_11

      LOG('loading quizzes ...')
      try {
        // @ts-ignore
        this.quiz = window.config_.quiz || [[]]
        LOG(' ... done')
      } catch (e) {
        WARN('... failed', e)
        this.quiz = [[]]
      }
      this.quiz_ids = []

      LOG('loading surveys ...')
      try {
        // @ts-ignore
        this.survey = window.config_.survey || [[]]
        LOG(' ... done')
      } catch (e) {
        WARN('... failed', e)
        this.survey = [[]]
      }
      this.survey_ids = []

      LOG('loading tasks ...')
      try {
        // @ts-ignore
        this.task = window.config_.task || [[]]
        LOG(' ... done')
      } catch (e) {
        WARN('... failed', e)
        this.task = [[]]
      }
      this.task_ids = []

      this.init()
    }
  }

  load(record: Record) {
    if (!this.active) return

    switch (record.table) {
      case 'quiz':
        LOG('loading ', record.table, record.id, this.quiz[record.id])
        return this.quiz[record.id]
      case 'survey':
        LOG('loading ', record.table, record.id, this.quiz[record.id])
        return this.survey[record.id]
    }
  }

  store(record: Record) {
    if (!this.active) return

    switch (record.table) {
      case 'quiz': {
        for (let i = 0; i < this.quiz[record.id].length; i++) {
          if (neq(record.data[i], this.quiz[record.id][i])) {
            return this.updateInteraction(
              this.quiz_ids[record.id][i],
              record.data[i]
            )
          }
        }
        break
      }
      case 'survey': {
        for (let i = 0; i < this.survey[record.id].length; i++) {
          if (neq(record.data[i], this.survey[record.id][i])) {
            return this.updateInteraction(
              this.survey_ids[record.id][i],
              record.data[i]
            )
          }
        }
        break
      }
    }
  }

  init() {
    if (!this.scorm) return

    LOG('Initialize ', this.scorm.Initialize(''))

    // store state information only in normal mode
    //let mode = this.scorm.GetValue('cmi.mode')
    //this.active = mode === 'normal'
    this.scorm.Commit('')

    LOG('open location ...')
    let location = jsonParse(this.scorm.GetValue('cmi.location'))
    LOG('... ', location)

    // if no location has been stored so far, this is the first visit
    if (location === null) {
      this.slide(0)

      // The quizzes are stored as interactions. And the associated state
      // as objectives attached to this
      let id = 0
      for (let slideNumber = 0; slideNumber < this.quiz.length; slideNumber++) {
        this.quiz_ids.push([])
        for (let i = 0; i < this.quiz[slideNumber].length; i++) {
          this.setInteraction(id, `Quiz:${slideNumber}-${i}`)
          this.quiz_ids[slideNumber].push(id)
          id++
        }
      }

      for (
        let slideNumber = 0;
        slideNumber < this.survey.length;
        slideNumber++
      ) {
        this.survey_ids.push([])
        for (let i = 0; i < this.survey[slideNumber].length; i++) {
          this.setInteraction(id, `Survey:${slideNumber}-${i}`)
          this.survey_ids[slideNumber].push(id)
          id++
        }
      }

      for (let slideNumber = 0; slideNumber < this.task.length; slideNumber++) {
        this.task_ids.push([])
        for (let i = 0; i < this.task[slideNumber].length; i++) {
          this.setInteraction(id, `Task:${slideNumber}-${i}`)
          this.task_ids[slideNumber].push(id)
          id++
        }
      }

      this.scorm.Commit('')
    }
    // restore the current state from the interactions
    else {
      let id = 0
      for (let slideNumber = 0; slideNumber < this.quiz.length; slideNumber++) {
        this.quiz_ids.push([])
        for (let i = 0; i < this.quiz[slideNumber].length; i++) {
          let data = this.getInteraction(id)
          if (data) {
            this.quiz[slideNumber][i] = data
          }
          this.quiz_ids[slideNumber].push(id)

          id++
        }
      }

      for (
        let slideNumber = 0;
        slideNumber < this.survey.length;
        slideNumber++
      ) {
        this.survey_ids.push([])

        for (let i = 0; i < this.survey[slideNumber].length; i++) {
          let data = this.getInteraction(id)
          if (data) {
            this.survey[slideNumber][i] = data[2]
          }
          this.survey_ids[slideNumber].push(id)

          id++
        }
      }

      for (let slideNumber = 0; slideNumber < this.task.length; slideNumber++) {
        this.task_ids.push([])

        for (let i = 0; i < this.task[slideNumber].length; i++) {
          let data = this.getInteraction(id)
          if (data) {
            this.task[slideNumber][i] = data[2]
          }
          this.task_ids[slideNumber].push(id)

          id++
        }
      }
    }
  }

  slide(id: number) {
    if (!this.scorm) return

    LOG('slide: ', id, this.scorm.SetValue('cmi.location', JSON.stringify(id)))

    this.scorm.Commit('')
  }

  /** Interactions are used to store quizzes, this, way, the objectives
   * can be used to to store the different states
   *
   * @param id
   * @param content
   * @returns
   */
  setInteraction(id: number, content: string) {
    if (!this.active) return

    this.scorm.SetValue(`cmi.interactions.${id}.id`, content)
    this.scorm.SetValue(`cmi.interactions.${id}.type`, 'long-fill-in')
  }

  updateQuiz(id: number, state: any): void {
    if (!this.active) return

    this.updateInteraction(id, state)

    switch (state.solved) {
      case 0: {
        if (state.trial > 0)
          this.scorm.SetValue(`cmi.interactions.${id}.result`, 'incorrect')
        break
      }
      case 1: {
        this.scorm.SetValue(`cmi.interactions.${id}.result`, 'correct')
        break
      }
      case -1: {
        this.scorm.SetValue(`cmi.interactions.${id}.result`, 'neutral')
        break
      }
    }

    this.scorm.Commit('')
  }

  updateInteraction(id: number, state: any): void {
    if (!this.active) return

    LOG(
      'update interaction',
      this.scorm.SetValue(
        `cmi.interactions.${id}.learner_response`,
        JSON.stringify(state)
      )
    )

    this.scorm.Commit('')
  }

  getInteraction(id: number): any | null {
    if (!this.active) return null

    try {
      return JSON.parse(
        this.scorm.GetValue(`cmi.interactions.${id}.learner_response`)
      )
    } catch (e) {}

    return null
  }

  countInteractions() {
    return this.count('cmi.interactions._count')
  }

  count(string: CMIElement): number | null {
    if (!this.active) null

    let value = parseInt(this.scorm.GetValue(string))

    return value ? value : null
  }
}

export { Connector }
