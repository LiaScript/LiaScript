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
  private registration: string
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
      registration?: string
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
    this.registration = config.registration || this.generateUUID()

    // Default actor if none provided
    this.actor = config.actor || {
      objectType: 'Agent',
      name: 'Anonymous',
      mbox: 'mailto:anonymous@example.com',
    }

    // Set course ID and title
    const base = window.location.origin
    this.courseId = config.courseId || new URL(window.location.href, base).href

    this.courseTitle =
      config.courseTitle || document.title || 'LiaScript Course'

    // Initialize quiz structure from course configuration (like SCORM does)
    // This loads the initial quiz state objects directly
    try {
      const windowAny = window as any
      if (windowAny.config_) {
        if (this.debug) {
          console.log(
            'Initializing quiz structure from config...',
            JSON.stringify(windowAny.config_)
          )
        }

        const quizConfig = windowAny.config_.quiz || [[]]
        // Convert array of arrays to our Record<slideId, Record<quizIndex, state>> structure
        for (let slideId = 0; slideId < quizConfig.length; slideId++) {
          if (quizConfig[slideId] && quizConfig[slideId].length > 0) {
            this.quizStates[slideId] = {}
            // Store the actual quiz state objects from config
            for (let i = 0; i < quizConfig[slideId].length; i++) {
              this.quizStates[slideId][i] = quizConfig[slideId][i]
            }
          }
        }

        if (this.debug) {
          console.log(
            'Initialized quiz structure from config:',
            Object.keys(this.quizStates)
          )
        }
      }
    } catch (e) {
      if (this.debug) {
        console.warn('Could not load quiz config:', e)
      }
    }

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

        // Restore state from LRS immediately (async, runs in background)
        // This ensures load() calls have the restored state available
        this.restoreState().catch((err) => {
          if (this.debug) {
            console.warn('Could not restore state from LRS:', err)
          }
        })
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
   * Generate a UUID v4
   */
  private generateUUID(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
      /[xy]/g,
      function (c) {
        const r = (Math.random() * 16) | 0
        const v = c === 'x' ? r : (r & 0x3) | 0x8
        return v.toString(16)
      }
    )
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
      duration,
      this.registration
    )

    // Use sendBeacon for more reliable delivery during page unload
    if (navigator.sendBeacon && this.lrs.endpoint) {
      const headers: Record<string, string> = {
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
   * Restore state from LRS statements
   * Queries the LRS for previous statements and reconstructs the course state
   */
  private async restoreState() {
    if (!this.lrs) return

    if (this.debug) {
      console.log('Attempting to restore state from LRS...')
    }

    try {
      // Query for all statements for this actor and activity
      const query: Record<string, any> = {
        agent: JSON.stringify(this.actor),
        activity: this.courseId,
        related_activities: true, // Include child activities (slides, quizzes)
        limit: 1000, // Get up to 1000 statements
      }

      // Include registration if available (important for SCORM Cloud)
      if (this.registration) {
        query.registration = this.registration
      }

      if (this.debug) {
        console.log('LRS query parameters:', query)
      }

      const response = await this.lrs.getStatements(query)

      if (this.debug) {
        console.log('LRS response:', response)
      }

      if (!response || !response.statements) {
        if (this.debug) {
          console.log('No statements found in LRS response')
        }
        return
      }

      if (this.debug) {
        console.log('Processing', response.statements.length, 'statements...')
      }

      // Process statements to restore state
      for (const stmt of response.statements) {
        // Restore slide visits (experienced verb)
        if (stmt.verb.id === 'http://adlnet.gov/expapi/verbs/experienced') {
          const slideId =
            stmt.object.definition?.extensions?.[
              'http://liascript.github.io/extensions/slideId'
            ]
          if (slideId !== undefined) {
            this.visitedSlides.add(slideId)
            if (this.debug) {
              console.log('Restored slide visit:', slideId)
            }
          }
        }

        // Restore quiz answers (answered verb)
        if (stmt.verb.id === 'http://adlnet.gov/expapi/verbs/answered') {
          const slideId =
            stmt.object.definition?.extensions?.[
              'http://liascript.github.io/extensions/slideId'
            ]
          const quizIndex =
            stmt.object.definition?.extensions?.[
              'http://liascript.github.io/extensions/quizIndex'
            ]

          if (slideId !== undefined && quizIndex !== undefined) {
            // Ensure quiz state structure exists for this slide
            if (!this.quizStates[slideId]) {
              this.quizStates[slideId] = {}
            }

            // Reconstruct quiz state from statement
            const result = stmt.result || {}
            const extensions = result.extensions || {}

            const quizState: any = {
              solved: result.success ? 1 : result.success === false ? -1 : 0,
              state:
                extensions['http://liascript.github.io/extensions/state'] || [],
              trial:
                extensions['http://liascript.github.io/extensions/trial'] || 0,
              hint:
                extensions['http://liascript.github.io/extensions/hint'] || 0,
              error_msg: '',
              score: result.score?.raw || 0,
            }

            // Add response/input if available
            if (result.response) {
              quizState.input = result.response
            }

            // Update the quiz state (replacing null or existing state)
            this.quizStates[slideId][quizIndex] = quizState

            if (this.debug) {
              console.log(
                `Restored quiz state: slide ${slideId}, quiz ${quizIndex}`,
                quizState
              )
            }

            // Update scores
            if (result.score?.raw !== undefined) {
              if (result.success) {
                this.totalScore += result.score.raw
              }
              if (result.score.max !== undefined) {
                this.maxScore += result.score.max
              }
            }
          }
        }

        // Check if completion was already sent
        if (stmt.verb.id === 'http://adlnet.gov/expapi/verbs/completed') {
          this.completionSent = true
          if (this.debug) {
            console.log('Found completion statement')
          }
        }
      }

      if (this.debug) {
        console.log('State restoration complete:', {
          visitedSlides: this.visitedSlides.size,
          quizStates: Object.keys(this.quizStates).length,
          totalScore: this.totalScore,
          maxScore: this.maxScore,
          completionSent: this.completionSent,
        })
      }
    } catch (err) {
      console.error('Error restoring state from LRS:', err)
      throw err
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
        duration,
        this.registration
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
  async open(uidDB: string, versionDB: number, slide: number) {
    if (!this.active || !this.lrs) return

    // Reset tracking state
    this.startTime = Date.now()
    this.lastActivityTime = this.startTime
    this.completionSent = false

    // State restoration now happens in constructor
    // This ensures load() has access to restored state

    // Send initialized statement
    const statement = Statement.generateInitializedStatement(
      this.actor,
      this.courseId,
      this.courseTitle,
      this.registration
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
    const windowAny = window as any
    if (
      windowAny.LIA &&
      windowAny.LIA.course &&
      windowAny.LIA.course.slides[id]
    ) {
      slideTitle = windowAny.LIA.course.slides[id].title || slideTitle
    }

    // Send experienced statement
    const statement = Statement.generateExperiencedStatement(
      this.actor,
      this.courseId,
      this.courseTitle,
      id,
      slideTitle,
      this.registration
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
        progress,
        this.registration
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
   * Load data from memory (quiz, survey, task)
   * Returns the cached state that was restored from LRS
   * @param record Record to load
   * @returns Stored data for the record
   */
  load(record: Base.Record) {
    const { table, id } = record

    if (this.debug) {
      console.log(`Load called for table=${table}, id=${id}`)
      console.log('Available quiz states:', Object.keys(this.quizStates))
    }

    // Return quiz state if available (like SCORM does)
    if (table === 'quiz') {
      if (this.quizStates[id]) {
        // Convert object to array format expected by LiaScript
        const quizArray: any[] = []
        for (const quizIndex in this.quizStates[id]) {
          const idx = parseInt(quizIndex)
          quizArray[idx] = this.quizStates[id][idx]
        }

        if (this.debug) {
          console.log(`Returning quiz array for slide ${id}:`, quizArray)
        }

        return quizArray
      } else {
        if (this.debug) {
          console.log(`No quiz state found for slide ${id}`)
        }
      }
    }

    // For survey and task, we would need to add similar logic
    // when we implement support for those types

    return undefined
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

        // Extract quiz type from state object (e.g., "Text", "SingleChoice", "MultipleChoice", etc.)
        let quizType = 'unknown'
        if (quiz.state && typeof quiz.state === 'object') {
          const stateKeys = Object.keys(quiz.state)
          if (stateKeys.length > 0) {
            quizType = stateKeys[0] // The first key is the quiz type
          }
        }

        // Send answered statement with full quiz state
        const statement = Statement.generateAnsweredStatement(
          this.actor,
          this.courseId,
          this.courseTitle,
          id,
          i,
          quizType,
          quiz.input || quiz.answer || '',
          quiz.solved === 1, // success
          quiz.solved === 1 ? quiz.score || 1 : 0, // score
          quiz.score || 1, // maxScore
          quiz, // pass full quiz state for extensions
          this.registration
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
