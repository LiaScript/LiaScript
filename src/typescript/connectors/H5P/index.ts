import Lia from '../../liascript/types/lia.d'

import * as Base from '../Base/index'
import { Settings } from '../Base/settings'
import * as Utils from '../utils'

/**
 * H5P Connector for LiaScript
 *
 * This connector implements the H5P standard for interactive content
 * in LiaScript courses.
 */
export class Connector extends Base.Connector {
  private active: boolean
  private debug: boolean
  private h5pConfig: any
  private courseId: string
  private courseTitle: string
  private visitedSlides: Set<number>
  private totalSlides: number
  private quizStates: Record<number, Record<number, any>>
  private startTime: number

  /**
   * Create a new H5P connector
   * @param config Configuration options for the connector
   */
  constructor(
    config: {
      courseId?: string
      courseTitle?: string
      debug?: boolean
    } = {}
  ) {
    super()

    this.active = true
    this.debug = config.debug || false
    this.visitedSlides = new Set()
    this.totalSlides = 0
    this.quizStates = {}
    this.startTime = Date.now()

    // Set course ID and title
    this.courseId = config.courseId || window.location.href
    this.courseTitle =
      config.courseTitle || document.title || 'LiaScript Course'

    // Initialize H5P configuration
    this.h5pConfig = window['h5pConfig'] || {}

    if (this.debug) {
      console.log('H5P connector initialized with config:', this.h5pConfig)
    }
  }

  /**
   * Open a course and initialize tracking
   * @param uidDB Course ID
   * @param versionDB Course version
   * @param slide Initial slide number
   */
  open(uidDB: string, versionDB: number, slide: number) {
    if (!this.active) return

    // Reset tracking state
    this.startTime = Date.now()

    // Update course ID and title if available
    if (uidDB) {
      this.courseId = String(uidDB)
    }

    if (window.LIA && window.LIA.course) {
      this.courseTitle = window.LIA.course.title || this.courseTitle
      this.totalSlides = window.LIA.course.slides.length || 0
    }

    if (this.debug) {
      console.log(
        'H5P connector opened course:',
        this.courseId,
        'version:',
        versionDB
      )
    }

    // Track initial slide
    if (slide !== undefined) {
      this.slide(slide)
    }
  }

  /**
   * Track slide navigation
   * @param id Slide number
   */
  slide(id: number) {
    if (!this.active) return

    // Add to visited slides
    this.visitedSlides.add(id)

    // Get slide title if available
    let slideTitle = `Slide ${id}`
    if (window.LIA && window.LIA.course && window.LIA.course.slides[id]) {
      slideTitle = window.LIA.course.slides[id].title || slideTitle
    }

    if (this.debug) {
      console.log('H5P connector tracking slide:', id, slideTitle)
    }
  }

  /**
   * Store data (quiz, survey, task)
   * @param record Record to store
   */
  store(record: Base.Record) {
    if (!this.active) return

    const { table, id, data } = record

    // Handle quiz data
    if (table === 'quiz' && data) {
      // Initialize quiz state for this slide if not exists
      if (!this.quizStates[id]) {
        this.quizStates[id] = {}
      }

      // Process each quiz on the slide
      for (let i = 0; i < data.length; i++) {
        const quiz = data[i]

        // Skip if no quiz data
        if (!quiz) continue

        // Track quiz state
        this.quizStates[id][i] = quiz

        if (this.debug) {
          console.log('H5P connector storing quiz data:', id, i, quiz)
        }
      }
    }
  }

  /**
   * Update data
   * @param record Record to update
   * @param fn Update function
   */
  update(record: Base.Record, fn: (a: any) => any) {
    // Call store after update
    super.update(record, fn)
    this.store(record)
  }

  /**
   * Get settings
   * @returns Settings object
   */
  getSettings() {
    // Use base implementation
    return super.getSettings()
  }

  /**
   * Set settings
   * @param data Settings data
   */
  setSettings(data: Lia.Settings) {
    // Use base implementation
    super.setSettings(data)
  }

  /**
   * Reset the connector
   * @param uidDB Course ID
   * @param versionDB Course version
   */
  reset(uidDB?: string, versionDB?: number) {
    // Reset state
    this.visitedSlides.clear()
    this.quizStates = {}
    this.startTime = Date.now()

    // Call base implementation
    super.reset(uidDB, versionDB)
  }
}
