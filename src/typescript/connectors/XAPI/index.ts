import Lia from '../../liascript/types/lia.d'

import * as Base from '../Base/index'
import { Settings } from '../Base/settings'
import * as Utils from '../utils'
import * as Statement from './statement'
import * as LRS from './lrs'

/**
 * xAPI Connector for LiaScript
 *
 * This connector implements the Experience API (xAPI) standard for tracking
 * learning experiences in LiaScript courses.
 */
export class Connector extends Base.Connector {
  private lrs: LRS.LRSConnection | null
  private actor: any
  private courseId: string
  private courseTitle: string
  private active: boolean
  private debug: boolean
  private totalScore: number
  private maxScore: number
  private visitedSlides: Set<number>
  private totalSlides: number
  private quizStates: Record<number, Record<number, any>>
  private startTime: number
  private lastActivityTime: number
  private completionSent: boolean
  private progressThreshold: number

  /**
   * Create a new xAPI connector
   * @param config Configuration options for the connector
   */
  constructor(
    config: {
      endpoint?: string
      auth?: string
      actor?: any
      courseId?: string
      courseTitle?: string
      debug?: boolean
    } = {}
  ) {
    super()

    this.active = false
    this.debug = config.debug || false
    this.totalScore = 0
    this.maxScore = 0
    this.visitedSlides = new Set()
    this.totalSlides = 0
    this.quizStates = {}
    this.startTime = Date.now()
    this.lastActivityTime = this.startTime
    this.completionSent = false
    this.progressThreshold = 0.9 // 90% of slides visited is considered complete

    // Default actor if none provided
    this.actor = config.actor || {
      objectType: 'Agent',
      name: 'Anonymous',
      mbox: 'mailto:anonymous@example.com',
    }

    // Set course ID and title
    this.courseId = config.courseId || window.location.href
    this.courseTitle =
      config.courseTitle || document.title || 'LiaScript Course'

    // Initialize LRS connection if endpoint is provided
    if (config.endpoint) {
      try {
        this.lrs = new LRS.LRSConnection(
          config.endpoint,
          config.auth || '',
          '1.0.3',
          this.debug
        )
        this.active = true

        if (this.debug) {
          console.log(
            'xAPI connector initialized with LRS endpoint:',
            config.endpoint
          )
        }

        // Set up window unload event to send terminated statement
        window.addEventListener('beforeunload', this.handleUnload.bind(this))
      } catch (e) {
        console.error('Failed to initialize LRS connection:', e)
        this.lrs = null
      }
    } else {
      console.warn('No LRS endpoint provided, xAPI tracking will be disabled')
      this.lrs = null
    }
  }

  /**
   * Handle window unload event to send terminated statement
   */
  private handleUnload() {
    if (!this.active || !this.lrs) return

    const duration = Statement.formatDuration(Date.now() - this.startTime)

    // Send terminated statement
    const statement = Statement.generateTerminatedStatement(
      this.actor,
      this.courseId,
      this.courseTitle,
      duration
    )

    // Use sendBeacon for more reliable delivery during page unload
    if (navigator.sendBeacon && this.lrs.endpoint) {
      const headers = {
        'Content-Type': 'application/json',
        'X-Experience-API-Version': '1.0.3',
      }

      if (this.lrs.auth) {
        headers['Authorization'] = this.lrs.auth
      }

      navigator.sendBeacon(this.lrs.endpoint, JSON.stringify([statement]))
    } else {
      // Fallback to synchronous XHR
      this.lrs.sendStatement(statement)
    }
  }

  /**
   * Check if course is complete based on progress
   * @returns True if course is complete
   */
  private checkCompletion(): boolean {
    // Course is complete if:
    // 1. We have visited enough slides (based on threshold)
    // 2. All quizzes have been answered (if there are any)

    let slideProgress = 0
    if (this.totalSlides > 0) {
      slideProgress = this.visitedSlides.size / this.totalSlides
    }

    let quizComplete = true
    if (this.maxScore > 0) {
      quizComplete = Object.values(this.quizStates).every((slideQuizzes) =>
        Object.values(slideQuizzes).every((quiz) => quiz.solved !== undefined)
      )
    }

    // If we have quizzes, both conditions must be met
    // If no quizzes, just check slide progress
    if (this.maxScore > 0) {
      return slideProgress >= this.progressThreshold && quizComplete
    } else {
      return slideProgress >= this.progressThreshold
    }
  }

  /**
   * Send completion statement if course is complete
   */
  private sendCompletionIfNeeded() {
    if (this.completionSent || !this.active || !this.lrs) return

    if (this.checkCompletion()) {
      const success =
        this.maxScore > 0 ? this.totalScore / this.maxScore >= 0.7 : true
      const duration = Statement.formatDuration(Date.now() - this.startTime)

      const statement = Statement.generateCompletedStatement(
        this.actor,
        this.courseId,
        this.courseTitle,
        success,
        this.totalScore,
        this.maxScore,
        duration
      )

      this.lrs
        .sendStatement(statement)
        .then((id) => {
          if (this.debug) {
            console.log('Sent completed statement, ID:', id)
          }
          this.completionSent = true
        })
        .catch((err) => {
          console.error('Failed to send completed statement:', err)
        })
    }
  }

  /**
   * Open a course and initialize tracking
   * @param uidDB Course ID
   * @param versionDB Course version
   * @param slide Initial slide number
   */
  open(uidDB: string, versionDB: number, slide: number) {
    if (!this.active || !this.lrs) return

    // Reset tracking state
    this.startTime = Date.now()
    this.lastActivityTime = this.startTime
    this.completionSent = false

    // Update course ID and title if available
    if (uidDB) {
      this.courseId = String(uidDB)
    }

    if (window.LIA && window.LIA.course) {
      this.courseTitle = window.LIA.course.title || this.courseTitle
      this.totalSlides = window.LIA.course.slides.length || 0
    }

    // Send initialized statement
    const statement = Statement.generateInitializedStatement(
      this.actor,
      this.courseId,
      this.courseTitle
    )

    this.lrs
      .sendStatement(statement)
      .then((id) => {
        if (this.debug) {
          console.log('Sent initialized statement, ID:', id)
        }
      })
      .catch((err) => {
        console.error('Failed to send initialized statement:', err)
      })

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
    if (!this.active || !this.lrs) return

    // Update activity time
    this.lastActivityTime = Date.now()

    // Add to visited slides
    this.visitedSlides.add(id)

    // Get slide title if available
    let slideTitle = `Slide ${id}`
    if (window.LIA && window.LIA.course && window.LIA.course.slides[id]) {
      slideTitle = window.LIA.course.slides[id].title || slideTitle
    }

    // Send experienced statement
    const statement = Statement.generateExperiencedStatement(
      this.actor,
      this.courseId,
      this.courseTitle,
      id,
      slideTitle
    )

    this.lrs
      .sendStatement(statement)
      .then((responseId) => {
        if (this.debug) {
          console.log('Sent experienced statement, ID:', responseId)
        }
      })
      .catch((err) => {
        console.error('Failed to send experienced statement:', err)
      })

    // Send progress statement if we know the total slides
    if (this.totalSlides > 0) {
      const progress = this.visitedSlides.size / this.totalSlides

      const progressStatement = Statement.generateProgressedStatement(
        this.actor,
        this.courseId,
        this.courseTitle,
        progress
      )

      this.lrs
        .sendStatement(progressStatement)
        .then(() => {
          // Check if course is complete after updating progress
          this.sendCompletionIfNeeded()
        })
        .catch((err) => {
          console.error('Failed to send progress statement:', err)
        })
    }
  }

  /**
   * Store data (quiz, survey, task)
   * @param record Record to store
   */
  store(record: Base.Record) {
    if (!this.active || !this.lrs) return

    // Update activity time
    this.lastActivityTime = Date.now()

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

        // Handle quiz score
        if (quiz.score !== undefined) {
          // Update total score
          if (quiz.solved === 1) {
            // Correct answer
            this.totalScore += quiz.score
          }
          this.maxScore += quiz.score
        }

        // Send answered statement
        const statement = Statement.generateAnsweredStatement(
          this.actor,
          this.courseId,
          this.courseTitle,
          id,
          i,
          quiz.type || 'unknown',
          quiz.input || quiz.answer || '',
          quiz.solved === 1, // success
          quiz.solved === 1 ? quiz.score || 1 : 0, // score
          quiz.score || 1 // maxScore
        )

        this.lrs
          .sendStatement(statement)
          .then((responseId) => {
            if (this.debug) {
              console.log('Sent answered statement, ID:', responseId)
            }

            // Check if course is complete after answering quiz
            this.sendCompletionIfNeeded()
          })
          .catch((err) => {
            console.error('Failed to send answered statement:', err)
          })
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
    this.totalScore = 0
    this.maxScore = 0
    this.visitedSlides.clear()
    this.quizStates = {}
    this.startTime = Date.now()
    this.lastActivityTime = this.startTime
    this.completionSent = false

    // Call base implementation
    super.reset(uidDB, versionDB)
  }
}
