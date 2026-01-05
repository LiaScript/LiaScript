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
  private lastVisitedSlide: number
  private totalSlides: number
  private quizStates: Record<number, Record<number, any>>
  private surveyStates: Record<number, Record<number, any>>
  private taskStates: Record<number, Record<number, any>>
  private startTime: number
  private lastActivityTime: number
  private completionSent: boolean
  private progressThreshold: number
  private stateRestored: Promise<void>

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
    this.lastVisitedSlide = 0
    this.totalSlides = 0
    this.quizStates = {}
    this.surveyStates = {}
    this.taskStates = {}
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

    // Initialize quiz, survey, and task structures from course configuration (like SCORM does)
    // This loads the initial state objects directly
    try {
      const windowAny = window as any
      if (windowAny.config_) {
        if (this.debug) {
          console.log(
            'Initializing structures from config...',
            JSON.stringify(windowAny.config_)
          )
        }

        // Initialize quizzes
        const quizConfig = windowAny.config_.quiz || [[]]
        quizConfig.forEach((slideQuizzes: any[], slideId: number) => {
          if (slideQuizzes?.length > 0) {
            this.quizStates[slideId] = {}
            slideQuizzes.forEach((quiz, i) => {
              this.quizStates[slideId][i] = quiz
            })
          }
        })

        // Initialize surveys
        const surveyConfig = windowAny.config_.survey || [[]]
        surveyConfig.forEach((slideSurveys: any[], slideId: number) => {
          if (slideSurveys?.length > 0) {
            this.surveyStates[slideId] = {}
            slideSurveys.forEach((survey, i) => {
              this.surveyStates[slideId][i] = survey
            })
          }
        })

        // Initialize tasks
        const taskConfig = windowAny.config_.task || [[]]
        taskConfig.forEach((slideTasks: any[], slideId: number) => {
          if (slideTasks?.length > 0) {
            this.taskStates[slideId] = {}
            slideTasks.forEach((task, i) => {
              this.taskStates[slideId][i] = task
            })
          }
        })

        if (this.debug) {
          console.log('Initialized structures from config:', {
            quizzes: Object.keys(this.quizStates).length,
            surveys: Object.keys(this.surveyStates).length,
            tasks: Object.keys(this.taskStates).length,
          })
        }
      }
    } catch (e) {
      if (this.debug) {
        console.warn('Could not load config:', e)
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

        // Restore state from LRS immediately (async)
        // Store the promise so load() can wait for restoration to complete
        this.stateRestored = this.restoreState().catch((err) => {
          if (this.debug) {
            console.warn('Could not restore state from LRS:', err)
          }
          // Even on error, resolve the promise so load() doesn't block forever
          return Promise.resolve()
        })
      } catch (e) {
        console.error('Failed to initialize LRS connection:', e)
        this.lrs = null
      }
    } else {
      console.warn('No LRS endpoint provided, xAPI tracking will be disabled')
      this.lrs = null
      // No state to restore, resolve immediately
      this.stateRestored = Promise.resolve()
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
      // Keep track of latest statement per quiz/survey/task (by timestamp)
      const latestQuizStatements: Record<string, any> = {}
      const latestSurveyStatements: Record<string, any> = {}
      const latestTaskStatements: Record<string, any> = {}
      let latestSlideStatement: any = null

      for (const stmt of response.statements) {
        // Restore slide visits (experienced verb) - track the most recent one
        if (stmt.verb.id === 'http://adlnet.gov/expapi/verbs/experienced') {
          const slideId =
            stmt.object.definition?.extensions?.[
              'http://liascript.github.io/extensions/slideId'
            ]
          if (slideId !== undefined) {
            this.visitedSlides.add(slideId)

            // Track the most recent slide visit by timestamp
            const timestamp = new Date(stmt.timestamp).getTime()
            if (
              !latestSlideStatement ||
              new Date(latestSlideStatement.timestamp).getTime() < timestamp
            ) {
              latestSlideStatement = stmt
            }

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
          const surveyIndex =
            stmt.object.definition?.extensions?.[
              'http://liascript.github.io/extensions/surveyIndex'
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
          } else if (slideId !== undefined && surveyIndex !== undefined) {
            const key = `${slideId}-${surveyIndex}`
            const timestamp = new Date(stmt.timestamp).getTime()

            // Keep only the most recent statement for each survey
            if (
              !latestSurveyStatements[key] ||
              new Date(latestSurveyStatements[key].timestamp).getTime() <
                timestamp
            ) {
              latestSurveyStatements[key] = stmt
            }
          }
        }

        // Collect task interactions (interacted verb) - will process latest only
        if (stmt.verb.id === 'http://adlnet.gov/expapi/verbs/interacted') {
          const slideId =
            stmt.object.definition?.extensions?.[
              'http://liascript.github.io/extensions/slideId'
            ]
          const taskIndex =
            stmt.object.definition?.extensions?.[
              'http://liascript.github.io/extensions/taskIndex'
            ]

          if (slideId !== undefined && taskIndex !== undefined) {
            const key = `${slideId}-${taskIndex}`
            const timestamp = new Date(stmt.timestamp).getTime()

            // Keep only the most recent statement for each task
            if (
              !latestTaskStatements[key] ||
              new Date(latestTaskStatements[key].timestamp).getTime() <
                timestamp
            ) {
              latestTaskStatements[key] = stmt
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

      // Set the last visited slide from the most recent experienced statement
      if (latestSlideStatement) {
        this.lastVisitedSlide =
          latestSlideStatement.object.definition?.extensions?.[
            'http://liascript.github.io/extensions/slideId'
          ] || 0
        if (this.debug) {
          console.log('Last visited slide:', this.lastVisitedSlide)
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

      // Now process the latest survey statements
      for (const key in latestSurveyStatements) {
        const stmt = latestSurveyStatements[key]
        const slideId =
          stmt.object.definition?.extensions?.[
            'http://liascript.github.io/extensions/slideId'
          ]
        const surveyIndex =
          stmt.object.definition?.extensions?.[
            'http://liascript.github.io/extensions/surveyIndex'
          ]

        if (!this.surveyStates[slideId]) {
          this.surveyStates[slideId] = {}
        }

        const result = stmt.result || {}
        const extensions = result.extensions || {}

        const surveyState: any = {
          submitted: result.completion || false,
          state:
            extensions['http://liascript.github.io/extensions/state'] || {},
        }

        this.surveyStates[slideId][surveyIndex] = surveyState

        if (this.debug) {
          console.log(
            `Restored survey state: slide ${slideId}, survey ${surveyIndex}`,
            surveyState
          )
        }
      }

      // Now process the latest task statements
      for (const key in latestTaskStatements) {
        const stmt = latestTaskStatements[key]
        const slideId =
          stmt.object.definition?.extensions?.[
            'http://liascript.github.io/extensions/slideId'
          ]
        const taskIndex =
          stmt.object.definition?.extensions?.[
            'http://liascript.github.io/extensions/taskIndex'
          ]

        if (!this.taskStates[slideId]) {
          this.taskStates[slideId] = {}
        }

        const result = stmt.result || {}
        const extensions = result.extensions || {}

        // Tasks are simple boolean arrays
        const taskState =
          extensions['http://liascript.github.io/extensions/state'] || []

        this.taskStates[slideId][taskIndex] = taskState

        if (this.debug) {
          console.log(
            `Restored task state: slide ${slideId}, task ${taskIndex}`,
            taskState
          )
        }
      }

      if (this.debug) {
        console.log('State restoration complete:', {
          visitedSlides: this.visitedSlides.size,
          lastVisitedSlide: this.lastVisitedSlide,
          quizStates: Object.keys(this.quizStates).length,
          surveyStates: Object.keys(this.surveyStates).length,
          taskStates: Object.keys(this.taskStates).length,
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

    // Add to visited slides and track as last visited
    this.visitedSlides.add(id)
    this.lastVisitedSlide = id

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
   * Blocks until state restoration from LRS is complete
   * @param record Record to load
   * @returns Stored data for the record
   */
  async load(record: Base.Record) {
    // Wait for state restoration to complete before returning data
    await this.stateRestored

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

    if (table === 'survey' && this.surveyStates[id]) {
      // Convert object to array format expected by LiaScript
      const surveyArray: any[] = []
      for (const surveyIndex in this.surveyStates[id]) {
        surveyArray[parseInt(surveyIndex)] = this.surveyStates[id][surveyIndex]
      }

      if (this.debug) {
        console.log(`Load survey[${id}]:`, surveyArray.length, 'items')
      }
      return surveyArray
    }

    if (table === 'task' && this.taskStates[id]) {
      // Convert object to array format expected by LiaScript
      const taskArray: any[] = []
      for (const taskIndex in this.taskStates[id]) {
        taskArray[parseInt(taskIndex)] = this.taskStates[id][taskIndex]
      }

      if (this.debug) {
        console.log(`Load task[${id}]:`, taskArray.length, 'items')
      }
      return taskArray
    }

    return undefined
  }

  /**
   * Store data (quiz, survey, task)
   * @param record Record to store
   */
  store(record: Base.Record) {
    if (!this.active || !this.lrs || !record.data) return

    this.lastActivityTime = Date.now()
    const { table, id, data } = record

    // Handle quizzes
    if (table === 'quiz') {
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
      return
    }

    // Handle surveys
    if (table === 'survey') {
      if (!this.surveyStates[id]) {
        this.surveyStates[id] = {}
      }

      // Process each survey on the slide
      data.forEach((survey: any, i: number) => {
        if (!survey) return

        this.surveyStates[id][i] = survey

        // Send answered statement for survey
        const statement = Statement.generateAnsweredStatement(
          this.actor,
          this.courseId,
          this.courseTitle,
          id,
          i,
          'Survey',
          JSON.stringify(survey.state),
          survey.submitted,
          0, // Surveys don't have scores
          0,
          survey,
          this.registration,
          i, // Use surveyIndex instead of quizIndex
          true // isSurvey flag
        )

        this.lrs
          .sendStatement(statement)
          .then(() => {
            if (this.debug)
              console.log(`Sent survey answer: slide ${id}, survey ${i}`)
          })
          .catch((err) =>
            console.error('Failed to send survey statement:', err)
          )
      })
      return
    }

    // Handle tasks
    if (table === 'task') {
      if (!this.taskStates[id]) {
        this.taskStates[id] = {}
      }

      // Process each task on the slide
      data.forEach((task: any, i: number) => {
        if (!task) return

        this.taskStates[id][i] = task

        // Send interacted statement for task
        const statement = Statement.generateTaskStatement(
          this.actor,
          this.courseId,
          this.courseTitle,
          id,
          i,
          task,
          this.registration
        )

        this.lrs
          .sendStatement(statement)
          .then(() => {
            if (this.debug)
              console.log(`Sent task interaction: slide ${id}, task ${i}`)
          })
          .catch((err) => console.error('Failed to send task statement:', err))
      })
      return
    }
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
    this.lastVisitedSlide = 0
    this.quizStates = {}
    this.surveyStates = {}
    this.taskStates = {}
    this.startTime = Date.now()
    this.lastActivityTime = this.startTime
    this.completionSent = false

    // Call base implementation
    super.reset(uidDB, versionDB)
  }
}
