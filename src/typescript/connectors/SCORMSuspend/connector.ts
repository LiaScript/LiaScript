/**
 * The suspend connectors: LiaScript's database calls go to the engine, which
 * keeps all state in `cmi.suspend_data` and reports to the LMS. The course's
 * initial state and meta data come from `config.js` (`window.config_`).
 */

import * as Base from '../Base/index'
import { Settings } from '../Base/settings'

import * as Adapter from './adapter'
import { Engine, type Clock } from './engine'
import type { LiaMeta } from './meta'
import { profile } from './profile'
import type { Version } from './report'

const clock: Clock = {
  now: () => Date.now(),
  date: () => new Date(),
  later: (fn, ms) => {
    const id = window.setTimeout(fn, ms)
    return () => window.clearTimeout(id)
  },
}

export class SuspendConnector extends Base.Connector {
  private engine: Engine
  private location: number | null

  constructor(version: Version) {
    super()

    const warn = (...args: any[]) => console.warn(`SCORM ${version} (suspend):`, ...args)
    const config = (window as any).config_ || {}
    const meta: LiaMeta | null = config.meta?.version === 1 ? config.meta : null
    const mastery = (window as any).MASTERY_SCORE

    this.engine = new Engine(
      Adapter.connect(version, warn),
      {
        profile: profile(version),
        defaults: { quiz: config.quiz || [], survey: config.survey || [], task: config.task || [] },
        meta,
        forceActive: !!(window as any).ACTIVE,
        mastery: typeof mastery === 'number' ? mastery : null,
        slides: meta?.slides.length,
        warn,
      },
      clock
    )

    this.engine.start()
    this.location = this.engine.location()
    ;(window as any).SCORE = this.engine.score()

    window.addEventListener('pagehide', () => this.engine.finish())
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'hidden') this.engine.hide()
    })
  }

  initSettings(data: Lia.Settings | null, _local = false) {
    return Settings.init(data, false, this.setSettings)
  }

  setSettings = (data: Lia.Settings) => {
    this.engine.setSettings(data)
  }

  getSettings() {
    const stored = this.engine.settings()
    const json: Lia.Settings = stored ? ({ ...stored, fromStorage: true } as any) : Settings.data

    if (window.innerWidth <= 768) {
      json.table_of_contents = false
    }
    return json
  }

  open(_uidDB: string, _versionDB: number, _slide: number) {
    const location = this.location
    if (location !== null && location > 0) {
      setTimeout(() => (window as any).LIA.goto(location), 500)
    }
  }

  load(record: Base.Record) {
    return this.engine.load(record.table, record.id)
  }

  loadAll(table: string) {
    return this.engine.loadAll(table)
  }

  store(record: Base.Record) {
    this.engine.store(record.table, record.id, record.data)
    ;(window as any).SCORE = this.engine.score()
  }

  update(record: Base.Record, mapping: (project: any) => any) {
    this.engine.update(record.table, record.id, mapping)
  }

  slide(id: number) {
    this.engine.slide(id)
  }
}
