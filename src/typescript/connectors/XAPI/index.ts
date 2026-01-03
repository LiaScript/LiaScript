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
    this.courseId = config.courseId || window.location.href
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
        // Convert array of arrays to Record<slideId, Record<quizIndex, state>> structure
        quizConfig.forEach((slideQuizzes: any[], slideId: number) => {
          if (slideQuizzes?.length > 0) {
            this.quizStates[slideId] = {}
            slideQuizzes.forEach((quiz, i) => {
              this.quizStates[slideId][i] = quiz
            })
          }
        })

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
      // Keep track of latest statement per quiz (by timestamp)
      const latestQuizStatements: Record<string, any> = {}

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

        // Collect quiz answers (answered verb) - will process latest only
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
            const key = `${slideId}-${quizIndex}`
            const timestamp = new Date(stmt.timestamp).getTime()

            // Keep only the most recent statement for each quiz
            if (
              !latestQuizStatements[key] ||
              new Date(latestQuizStatements[key].timestamp).getTime() <
                timestamp
            ) {
              latestQuizStatements[key] = stmt
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

      // Now process the latest quiz statements only
      for (const key in latestQuizStatements) {
        const stmt = latestQuizStatements[key]
        const slideId =
          stmt.object.definition?.extensions?.[
            'http://liascript.github.io/extensions/slideId'
          ]
        const quizIndex =
          stmt.object.definition?.extensions?.[
            'http://liascript.github.io/extensions/quizIndex'
          ]

        // Ensure quiz state structure exists for this slide
        if (!this.quizStates[slideId]) {
          this.quizStates[slideId] = {}
        }

        // Reconstruct quiz state from statement
        const result = stmt.result || {}
        const extensions = result.extensions || {}

        const trial =
          extensions['http://liascript.github.io/extensions/trial'] || 0

        // Determine solved status:
        // solved: 1 = correctly solved (got the right answer)
        // solved: -1 = resolved (clicked resolve button to show solution)
        // solved: 0 = still trying (has attempts but not resolved)
        let solved = 0
        if (result.success === true) {
          solved = 1 // Successfully answered correctly
        } else if (result.success === false) {
          // Check if resolved (completion=true) vs still trying
          if (result.completion === true) {
            solved = -1 // Resolved (showed solution)
          } else {
            solved = 0 // Still trying (failed attempts)
          }
        }

        const quizState: any = {
          solved,
          state:
            extensions['http://liascript.github.io/extensions/state'] || [],
          trial,
          hint: extensions['http://liascript.github.io/extensions/hint'] || 0,
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
    if (this.totalSlides === 0) return false

    const slideProgress = this.visitedSlides.size / this.totalSlides
    const slideComplete = slideProgress >= this.progressThreshold

    // If no quizzes, just check slides
    if (this.maxScore === 0) return slideComplete

    // With quizzes, check both slides and all quizzes answered
    const quizComplete = Object.values(this.quizStates).every((slideQuizzes) =>
      Object.values(slideQuizzes).every((quiz) => quiz.solved !== undefined)
    )
    return slideComplete && quizComplete
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

    // Get total slide count from LiaScript course structure
    const windowAny = window as any
    if (windowAny.LIA?.course?.slides) {
      this.totalSlides = windowAny.LIA.course.slides.length
      if (this.debug) {
        console.log('Total slides in course:', this.totalSlides)
      }
    }

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

    if (table === 'quiz' && this.quizStates[id]) {
      // Convert object to array format expected by LiaScript
      const quizArray: any[] = []
      for (const quizIndex in this.quizStates[id]) {
        quizArray[parseInt(quizIndex)] = this.quizStates[id][quizIndex]
      }

      if (this.debug) {
        console.log(`Load quiz[${id}]:`, quizArray.length, 'items')
      }
      return quizArray
    }

    return undefined
  }

  /**
   * Store data (quiz, survey, task)
   * @param record Record to store
   */
  store(record: Base.Record) {
    if (!this.active || !this.lrs || record.table !== 'quiz' || !record.data)
      return

    this.lastActivityTime = Date.now()
    const { id, data } = record

    if (!this.quizStates[id]) {
      this.quizStates[id] = {}
    }

    // Process each quiz on the slide
    data.forEach((quiz: any, i: number) => {
      if (!quiz) return

      this.quizStates[id][i] = quiz

      // Update scores
      if (quiz.score !== undefined) {
        if (quiz.solved === 1) this.totalScore += quiz.score
        this.maxScore += quiz.score
      }

      // Extract quiz type from state object
      const quizType =
        quiz.state && typeof quiz.state === 'object'
          ? Object.keys(quiz.state)[0] || 'unknown'
          : 'unknown'

      // Send answered statement
      const statement = Statement.generateAnsweredStatement(
        this.actor,
        this.courseId,
        this.courseTitle,
        id,
        i,
        quizType,
        quiz.input || quiz.answer || '',
        quiz.solved === 1,
        quiz.solved === 1 ? quiz.score || 1 : 0,
        quiz.score || 1,
        quiz,
        this.registration
      )

      this.lrs
        .sendStatement(statement)
        .then(() => {
          if (this.debug) console.log(`Sent answer: slide ${id}, quiz ${i}`)
          this.sendCompletionIfNeeded()
        })
        .catch((err) =>
          console.error('Failed to send answered statement:', err)
        )
    })
  }

  /**
   * Update data
   * @param record Record to update
   * @param fn Update function
   */
  update(record: Base.Record, fn: (a: any) => any) {
    super.update(record, fn)
    this.store(record)
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
