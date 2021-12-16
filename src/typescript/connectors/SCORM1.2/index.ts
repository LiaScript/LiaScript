import Lia from '../../liascript/types/lia.d'
import Port from '../../liascript/types/ports'
import { SCORM } from './scorm'

import { Connector as Base } from '../Base/index'

const scorm = require('simplify-scorm/src/scormAPI')

scorm.scormAPIFunc()

class Connector extends Base {
  private scorm?: SCORM
  private active: boolean

  private quiz?: boolean[][]
  private survey?: boolean[][]

  constructor() {
    super()

    this.active = false

    if (window.top && window.top.API) {
      this.scorm = window.top.API

      if (!this.scorm) return

      console.log('LMSInitialize', this.scorm.LMSInitialize(''))

      // store state information only in normal mode
      let mode = this.scorm.LMSGetValue('cmi.core.lesson_mode')
      this.active = mode === 'normal'

      this.scorm.LMSCommit()

      this.restore()
    }
  }

  restore() {
    this.quiz = window.config_.quiz.map((e) => e.map((_) => null))
    this.survey = window.config_.survey.map((e) => e.map((_) => null))

    let count = this.countObjectives()

    // search all objectives for the given topics and sections
    for (let i = 0; i < count; i++) {
      let item = this.getObjective(i)
      if (!!item) {
        if (item.type === 'survey') {
          this.survey[item.sec][item.i] = true
        } else if (item.type === 'quiz') {
          if (item.data.solved === 1) {
            this.quiz[item.sec][item.i] = true
          } else if (item.data.solved === -1) {
            this.quiz[item.sec][item.i] = false
          }
        }
      }
    }

    this.score()
  }

  score() {
    if (!this.scorm) return

    let total =
      this.quiz.reduce((a, b) => a + b.length, 0) +
      this.survey.reduce((a, b) => a + b.length, 0)

    let solved =
      this.quiz
        .map((e) => e.filter((f) => f === true))
        .reduce((a, b) => a + b.length, 0) +
      this.survey
        .map((e) => e.filter((f) => f === true))
        .reduce((a, b) => a + b.length, 0)

    let finished =
      this.quiz
        .map((e) => e.filter((f) => f != null))
        .reduce((a, b) => a + b.length, 0) +
      this.survey
        .map((e) => e.filter((f) => f != null))
        .reduce((a, b) => a + b.length, 0)

    let score = solved === 0 ? 0 : (solved * 100) / total

    this.scorm.LMSSetValue('cmi.core.score.raw', score.toString())

    let masteryScore = JSON.parse(
      this.scorm.LMSGetValue('cmi.student_data.mastery_score')
    )

    if (score >= masteryScore && score < 100) {
      this.scorm.LMSSetValue('cmi.core.lesson_status', 'passed')
    } else if (score >= 100) {
      this.scorm.LMSSetValue('cmi.core.lesson_status', 'completed')
    } else if (finished === solved) {
      this.scorm.LMSSetValue('cmi.core.lesson_status', 'failed')
    }

    this.scorm.LMSCommit()
  }

  slide(id: number) {
    if (!this.scorm) return

    let location = this.scorm.LMSGetValue('cmi.core.lesson_location')

    try {
      let loc = JSON.parse(location)

      if (loc.slide && loc.visited) {
        loc.slide = id
        loc.visited[id] = true

        this.scorm.LMSSetValue('cmi.core.lesson_location', JSON.stringify(loc))

        this.scorm.LMSCommit()
      }
    } catch (e) {
      console.warn('slide:', e)
    }
  }

  open(uidDB: string, versionDB: number, slide: number, data: any) {
    if (!this.scorm) return

    let location = null

    try {
      location = JSON.parse(this.scorm.LMSGetValue('cmi.core.lesson_location'))
      this.send({
        route: [['goto', location.slide]],
        message: null,
      })
    } catch (e) {
      location = {
        slide: slide,
        visited: Array(data.sections.length).fill(false),
      }

      location.visited[slide] = true

      this.scorm.LMSSetValue(
        'cmi.core.lesson_location',
        JSON.stringify(location)
      )

      this.scorm.LMSCommit()
    }
  }

  countObjectives(): number {
    let count = -1
    if (this.scorm) {
      try {
        count = parseInt(this.scorm.LMSGetValue('cmi.objectives._count'))
      } catch (e) {
        console.warn('Could not get objectives count')
        count = -1
      }
    }

    return count
  }

  countInteractions(): number {
    let count = -1

    if (this.scorm) {
      try {
        count = parseInt(this.scorm.LMSGetValue('cmi.interactions._count'))
      } catch (e) {
        console.warn('Could not get objectives count')
        count = -1
      }
    }

    return count
  }

  // generates a unique id to be used in interactions and objectives
  label(obj: { type: string; sec: number; i: number; data: string }) {
    return [obj.type, obj.sec + 1, obj.i].join('/')
  }

  getObjective(id: number):
    | undefined
    | {
        type: string
        sec: number
        i: number
        data: any
      } {
    if (!this.scorm) return

    let val = null

    try {
      val = this.scorm.LMSGetValue('cmi.objectives.' + id + '.id')

      let [type, sec, i, ...blob] = val.split('/')

      let data = JSON.parse(decodeURI(blob.join('/')))

      if (type === 'survey') {
        data = {
          submitted: true,
          state: data,
        }
      }

      return {
        type: type,
        sec: parseInt(sec) - 1,
        i: parseInt(i),
        data: data,
      }
    } catch (e) {
      console.warn('could not getObjective', val, id, e)
    }
  }

  setObjective(
    id: number,
    obj: { type: string; sec: number; i: number; data: any }
  ) {
    if (!this.scorm) return

    let blob = this.label(obj)

    if (obj.type === 'survey') {
      // use only the state info to be stored in objectives.id
      blob = blob + '/' + encodeURI(JSON.stringify(obj.data.state))
    } else if (obj.type === 'quiz') {
      blob = blob + '/' + encodeURI(JSON.stringify(obj.data))
    }

    console.log(
      'setObjective',
      this.scorm.LMSSetValue('cmi.objectives.' + id + '.id', blob)
    )
    this.scorm.LMSCommit()

    switch (obj.type) {
      case 'quiz':
        if (obj.data.solved === 1) {
          this.quiz[obj.sec][obj.i] = true
        } else if (obj.data.solved === -1) {
          this.quiz[obj.sec][obj.i] = false
        }
        break
      case 'survey':
        this.survey[obj.sec][obj.i] = true
    }
    this.score()
  }

  logInteraction(obj: { type: string; sec: number; i: number; data: any }) {
    if (!this.scorm) return

    let id = this.countInteractions()

    let label = this.label(obj)

    this.scorm.LMSSetValue('cmi.interactions.' + id + '.id', label)

    switch (obj.type) {
      case 'code': {
        this.scorm.LMSSetValue(
          'cmi.interactions.' + id + '.student_response',
          JSON.stringify(obj.data).slice(0, 254)
        )
        break
      }
      case 'quiz': {
        this.scorm.LMSSetValue(
          'cmi.interactions.' + id + '.result',
          obj.data.solved === 0
            ? 'neutral'
            : obj.data.solved === 1
            ? 'correct'
            : 'wrong'
        )

        this.scorm.LMSSetValue(
          'cmi.interactions.' + id + '.student_response',
          JSON.stringify(obj.data).slice(0, 254)
        )
        break
      }
      case 'survey': {
        // this.scorm.LMSSetValue("cmi.interactions."+ id +".type", "fill-in")
        this.scorm.LMSSetValue('cmi.interactions.' + id + '.result', 'neutral')
        this.scorm.LMSSetValue(
          'cmi.interactions.' + id + '.student_response',
          JSON.stringify(obj.data.state).slice(0, 254)
        )
        break
      }
    }

    this.scorm.LMSSetValue(
      'cmi.interactions.' + id + '.time',
      new Date().toISOString().split('T')[1].split('.')[0] // only hh:mm:ss are allowed in this version of scorm
    )

    this.scorm.LMSCommit()
  }

  store(event: Lia.Event) {
    if (!this.scorm || !this.active) return

    if (event.route[0][0] === 'code') {
      for (let i = 0; i < event.message.length; i++) {
        this.logInteraction({
          type: event.route[0][0],
          sec: event.route[0][1],
          i: i,
          data: event.message[i],
        })
      }

      return
    }

    let items = []
    let count = this.countObjectives()

    // search all objectives for the given topics and sections
    for (let i = 0; i < count; i++) {
      let item = this.getObjective(i)
      if (!!item) {
        if (item.sec === event.route[0][1] && item.type === event.route[0][0]) {
          // store only the position to be overwritten
          items.push(i)
        }
      }
    }

    let obj = {
      type: event.route[0][0],
      sec: event.route[0][1],
      i: 0,
      data: null,
    }

    for (let i = 0; i < event.message.length; i++) {
      obj.i = i
      obj.data = event.message[i]

      // insert as new or overwrite existing ones
      this.setObjective(
        items.length === 0 ? this.countObjectives() : items[i],
        obj
      )
      this.logInteraction(obj)
    }

    this.score()
  }

  load(event: Lia.Event) {
    if (!this.scorm) return

    if (event.route[0][0] === 'code') {
      this.send({
        route: [event.route[0], ['restore', -1]],
        message: null,
      })
      return
    }

    let items = []
    let count = this.countObjectives()

    // search all objectives for the given topics and sections
    for (let i = 0; i < count; i++) {
      let item = this.getObjective(i)
      if (!!item) {
        if (item.sec === event.route[0][1] && item.type === event.route[0][0]) {
          items.push(item)
        }
      }
    }

    if (items.length !== 0) {
      this.send({
        route: [event.route[0], ['restore', -1]],
        message: items.sort((a, b) => a.i - b.i).map((e) => e.data),
      })
    }
  }
}

export { Connector }
