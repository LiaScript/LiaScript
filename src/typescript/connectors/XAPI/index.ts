import Lia from '../../liascript/types/lia.d'

import * as Base from '../Base/index'
import { Settings } from '../Base/settings'
import * as Utils from '../utils'
import * as Statement from './statement'
import * as LRS from './lrs'
import * as Code from './code'
import * as Restore from './restore'
import * as Report from '../SCORMSuspend/report'
import * as State from '../SCORMSuspend/state'
import type { LiaMeta } from '../SCORMSuspend/meta'

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
  private visitedSlides: Set<number>
  private lastVisitedSlide: number
  private totalSlides: number
  private quizStates: Record<number, Record<number, any>>
  private surveyStates: Record<number, Record<number, any>>
  private taskStates: Record<number, Record<number, any>>
  /** code projects per slide: restored from the LRS … */
  private codeStates: Record<number, any[]>
  /** … and as Elm knows them, changed or not */
  private codeProjects: Record<number, any[] | null>
  /** the course description the exporter wrote (`config_.meta`), if any */
  private meta: LiaMeta | null = null
  /** key of language maps */
  private lang = 'en-US'
  /** every quiz, survey, task and code project the meta describes */
  private items = new Map<string, Report.Item>()
  private startTime: number
  private lastActivityTime: number
  private accumulatedTime: number // Time from previous sessions in milliseconds
  private completionSent: boolean
  private progressThreshold: number = 0
  private masteryScore: number = 0
  private stateRestored: Promise<void>
  /** the terminated or suspended statement of this page was sent */
  private unloadSent = false

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
      masteryThreshold?: number
      progressThreshold?: number
    } = {}
  ) {
    super()

    window['SCORE'] = 0

    this.active = false
    this.debug = config.debug || false
    this.visitedSlides = new Set()
    this.lastVisitedSlide = 0
    this.totalSlides = 0
    this.quizStates = {}
    this.surveyStates = {}
    this.taskStates = {}
    this.codeStates = {}
    this.codeProjects = {}
    this.startTime = Date.now()
    this.lastActivityTime = this.startTime
    this.accumulatedTime = 0 // No previous session time yet
    this.completionSent = false
    this.registration =
      config.registration || this.storedRegistration(config.courseId, config.actor)

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

        // Load thresholds from window.config_ (set by config.js in xAPI export)
        // Falls back to constructor config, then to defaults
        this.progressThreshold =
          windowAny.config_.progressThreshold ?? config.progressThreshold ?? 0.9
        this.masteryScore =
          windowAny.config_.masteryThreshold ?? config.masteryThreshold ?? 0.8

        if (this.debug) {
          console.log('Loaded thresholds:', {
            progressThreshold: this.progressThreshold,
            masteryScore: this.masteryScore,
          })
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

        // Readable statements need the course description; without it (an
        // older package) they stay generic
        if (windowAny.config_.meta?.version === 1) {
          this.meta = windowAny.config_.meta
          this.lang = Report.language(this.meta)
          Report.catalogue(
            {
              quiz: windowAny.config_.quiz || [],
              survey: windowAny.config_.survey || [],
              task: windowAny.config_.task || [],
            },
            this.meta,
            Infinity
          ).forEach((item) =>
            this.items.set(`${item.table}:${item.slide}:${item.index}`, item)
          )
        }

        if (this.debug) {
          console.log('Initialized structures from config:', {
            quizzes: Object.keys(this.quizStates).length,
            surveys: Object.keys(this.surveyStates).length,
            tasks: Object.keys(this.taskStates).length,
          })
        }
      } else {
        // No window.config_ available, use defaults from constructor parameter
        this.progressThreshold = config.progressThreshold ?? 0.9
        this.masteryScore = config.masteryThreshold ?? 0.8
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

        // Send a terminated or suspended statement when the page is left;
        // pagehide also fires where beforeunload does not (mobile, bfcache)
        window.addEventListener('beforeunload', this.handleUnload.bind(this))
        window.addEventListener('pagehide', this.handleUnload.bind(this))

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
   * The registration of a launch that did not get one from the LMS.
   *
   * State is restored from the statements of the current registration, so a
   * fresh one per page load would never find the learner's earlier answers.
   * It is kept per course and learner in localStorage instead.
   */
  private storedRegistration(courseId?: string, actor?: any): string {
    const who = actor?.mbox || actor?.account?.name || actor?.name || 'anonymous'
    const key = `lia-xapi-registration:${courseId || location.pathname}:${who}`

    try {
      const known = localStorage.getItem(key)
      if (known) return known

      const fresh = this.generateUUID()
      localStorage.setItem(key, fresh)
      return fresh
    } catch (e) {
      return this.generateUUID()
    }
  }

  /**
   * The readable description of an element and its state, if the course
   * description knows the element
   */
  private describe(
    table: Report.Table,
    slide: number,
    index: number,
    state: any
  ): Report.Interaction | undefined {
    const item = this.items.get(`${table}:${slide}:${index}`)
    return item ? Report.interaction(item, state, this.lang) : undefined
  }

  /** The states of a slide as an array, as LiaScript uses them */
  private list(states: Record<number, Record<number, any>>, id: number) {
    const array: any[] = []
    for (const index in states[id] || {}) {
      array[parseInt(index)] = states[id][index]
    }
    return array
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
   * Handle window unload event to send terminated or suspended statement
   */
  private handleUnload() {
    if (!this.active || !this.lrs || this.unloadSent) return

    const duration = Statement.formatDuration(this.getTotalDuration())

    // Determine which statement to send based on completion status
    let statement: any

    if (this.completionSent) {
      // Course is complete - send terminated statement
      statement = Statement.generateTerminatedStatement(
        this.actor,
        this.courseId,
        this.courseTitle,
        duration,
        this.registration
      )
    } else {
      // Course is incomplete - send suspended statement with progress
      const progress =
        this.totalSlides > 0 ? this.visitedSlides.size / this.totalSlides : 0

      statement = Statement.generateSuspendedStatement(
        this.actor,
        this.courseId,
        this.courseTitle,
        duration,
        this.lastVisitedSlide,
        progress,
        this.registration
      )
    }

    // a keepalive request outlives the page and, unlike sendBeacon, carries
    // the credentials
    this.unloadSent = true
    this.lrs.sendOnUnload(statement)
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
      let latestProgressStatement: any = null // Track most recent progressed/suspended/completed for time

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

        // Track the latest statement with duration for time accumulation
        if (
          stmt.verb.id === 'http://adlnet.gov/expapi/verbs/progressed' ||
          stmt.verb.id === 'http://adlnet.gov/expapi/verbs/suspended' ||
          stmt.verb.id === 'http://adlnet.gov/expapi/verbs/completed'
        ) {
          const timestamp = new Date(stmt.timestamp).getTime()
          if (
            !latestProgressStatement ||
            new Date(latestProgressStatement.timestamp).getTime() < timestamp
          ) {
            latestProgressStatement = stmt
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

      // Code: every slide from its newest code statement
      this.codeStates = Code.restore(response.statements, this.meta?.slides)

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

        // Reconstruct quiz state from statement, in the shape of the course's
        const quizState = Restore.quizState(
          stmt,
          this.quizStates[slideId][quizIndex]
        )

        // Update the quiz state (replacing null or existing state)
        this.quizStates[slideId][quizIndex] = quizState

        if (this.debug) {
          console.log(
            `Restored quiz state: slide ${slideId}, quiz ${quizIndex}`,
            quizState
          )
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

      // Restore accumulated time from the latest statement with duration
      if (latestProgressStatement?.result?.duration) {
        this.accumulatedTime = this.parseDuration(
          latestProgressStatement.result.duration
        )
        if (this.debug) {
          console.log(
            'Restored accumulated time:',
            this.accumulatedTime,
            'ms (',
            Math.round(this.accumulatedTime / 1000),
            'seconds)'
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
          codeStates: Object.keys(this.codeStates).length,
          completionSent: this.completionSent,
          accumulatedTime: this.accumulatedTime,
        })
      }
    } catch (err) {
      console.error('Error restoring state from LRS:', err)
      throw err
    }
  }

  /**
   * Parse ISO8601 duration string to milliseconds
   * @param duration ISO8601 duration string (e.g., "PT1H30M15S")
   * @returns Duration in milliseconds
   */
  private parseDuration(duration: string): number {
    // Format: PT[hours]H[minutes]M[seconds]S
    const regex = /PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?/
    const matches = duration.match(regex)

    if (!matches) return 0

    const hours = parseInt(matches[1] || '0', 10)
    const minutes = parseInt(matches[2] || '0', 10)
    const seconds = parseFloat(matches[3] || '0')

    return (hours * 3600 + minutes * 60 + seconds) * 1000
  }

  /**
   * Get total duration including previous sessions
   * @returns Total duration in milliseconds
   */
  private getTotalDuration(): number {
    return this.accumulatedTime + (Date.now() - this.startTime)
  }

  /**
   * Check if course is complete based on progress
   * Calculates combined completion ratio across slides, quizzes, and surveys
   * @returns True if course is complete
   */
  private checkCompletion(): boolean {
    if (this.totalSlides === 0) return false

    // Count completed quizzes
    let completedQuizzes = 0
    let totalQuizzes = 0
    for (const slideId in this.quizStates) {
      for (const quizIndex in this.quizStates[slideId]) {
        totalQuizzes++
        const quiz = this.quizStates[slideId][quizIndex]
        if (quiz.solved !== 0) {
          completedQuizzes++
        }
      }
    }

    // Count completed surveys
    let completedSurveys = 0
    let totalSurveys = 0
    for (const slideId in this.surveyStates) {
      for (const surveyIndex in this.surveyStates[slideId]) {
        totalSurveys++
        const survey = this.surveyStates[slideId][surveyIndex]
        if (survey.submitted === true) {
          completedSurveys++
        }
      }
    }

    // Calculate combined completion ratio
    const totalItems = this.totalSlides + totalQuizzes + totalSurveys
    const completedItems =
      this.visitedSlides.size + completedQuizzes + completedSurveys

    if (this.debug) {
      console.log('Completion check:', {
        visitedSlides: this.visitedSlides.size,
        totalSlides: this.totalSlides,
        completedQuizzes,
        totalQuizzes,
        completedSurveys,
        totalSurveys,
        completedItems,
        totalItems,
        progressThreshold: this.progressThreshold,
      })
    }

    if (totalItems === 0) return false

    const completionRatio = completedItems / totalItems

    return completionRatio >= this.progressThreshold
  }

  /**
   * Send progress/completion statement to track current state
   * Like SCORM, this sends updates continuously, not just at the end
   */
  private sendCompletionIfNeeded() {
    if (!this.active || !this.lrs) return

    let total = 0
    let solved = 0
    let finished = 0
    let count = 0

    for (const slideId in this.quizStates) {
      for (const quizIndex in this.quizStates[slideId]) {
        const quiz = this.quizStates[slideId][quizIndex]
        count = quiz.score || 0

        total += count

        switch (quiz.solved) {
          case 1: {
            solved += count
            break
          }
          case -1: {
            finished += count
            break
          }
        }
      }
    }

    const score = solved === 0 ? 0 : solved / total

    window['SCORE'] = score

    if (this.debug) {
      console.log('Checking completion...', {
        totalSlides: this.totalSlides,
        visitedSlides: this.visitedSlides.size,
        maxScore: total,
        totalScore: solved,
        quizStates: Object.keys(this.quizStates).length,
        completionSent: this.completionSent,
      })
    }

    const duration = Statement.formatDuration(this.getTotalDuration())
    const progress =
      this.totalSlides > 0 ? this.visitedSlides.size / this.totalSlides : 0

    // COMPLETION: Use checkCompletion() to determine if course is complete
    // This checks slides visited, all quizzes answered, and all surveys submitted
    const completionStatus = this.checkCompletion()

    // SUCCESS: Based on quiz/survey performance (assessment mastery)
    let success: boolean | undefined = undefined

    if (this.masteryScore == null) {
      // No mastery score defined - success is not applicable
      success = undefined
    } else {
      // Check if all quizzes have been completed (either solved or failed)
      const allQuizzesCompleted = finished + solved === total && total > 0

      if (score >= this.masteryScore || total === 0) {
        // Passed: achieved mastery score and completed all surveys
        success = true
      } else if (allQuizzesCompleted) {
        // All quizzes and surveys are done - determine pass/fail
        if (score >= this.masteryScore) {
          success = true
        } else {
          success = false
        }
      } else {
        // Still in progress: not all assessments completed yet
        success = undefined
      }
    }

    if (this.debug) {
      console.log('Success calculation:', {
        masteryScore: this.masteryScore,
        score,
        solved,
        finished,
        total,
        allQuizzesCompleted: finished + solved === total,

        success,
      })
    }

    const progressStatement = Statement.generateProgressedStatement(
      this.actor,
      this.courseId,
      this.courseTitle,
      progress,
      this.registration,
      duration,
      solved,
      total,
      completionStatus,
      success
    )

    this.lrs
      .sendStatement(progressStatement)
      .then(() => {
        if (this.debug) {
          console.log(
            `Sent progressed statement: ${
              progress * 100
            }% complete, score: ${solved}/${total}, completion: ${completionStatus}, success: ${success}`
          )
        }
      })
      .catch((err) => {
        console.error('Failed to send progressed statement:', err)
      })

    if (completionStatus && !this.completionSent) {
      // Send completed statement only once when course completion criteria met

      const statement = Statement.generateCompletedStatement(
        this.actor,
        this.courseId,
        this.courseTitle,
        success,
        solved,
        total,
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

    // Where the learner left off, read before this visit's first slide
    // replaces it
    await this.stateRestored
    const resumeAt = this.lastVisitedSlide

    // Reset tracking state
    this.startTime = Date.now()
    this.lastActivityTime = this.startTime
    this.completionSent = false

    // Get total slide count from LiaScript course structure
    const windowAny = window as any
    if (windowAny.config_?.totalSlides) {
      this.totalSlides = windowAny.config_.totalSlides
      if (this.debug) {
        console.log('Total slides in course:', this.totalSlides)
      }
    } else {
      if (this.debug) {
        console.warn(
          'Could not get total slides - config_.totalSlides not available'
        )
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

    // Return to the last visited slide, as the SCORM connectors do
    if (resumeAt && resumeAt !== slide) {
      setTimeout(() => (window as any)['LIA'].goto(resumeAt), 500)
    }

    // Check if course was already completed (from restored state)
    // This handles the case where user returns to an already-finished course
    if (!this.completionSent) {
      this.sendCompletionIfNeeded()
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

    // Get slide title if available: `3. Lists and Tasks`
    let slideTitle = `Slide ${id}`
    const windowAny = window as any
    if (this.meta?.slides[id]?.title) {
      slideTitle = `${id + 1}. ${this.meta.slides[id].title}`
    } else if (
      windowAny.LIA &&
      windowAny.LIA.course &&
      windowAny.LIA.course.slides[id]
    ) {
      slideTitle = windowAny.LIA.course.slides[id].title || slideTitle
    }

    // Calculate total duration including previous sessions
    const duration = Statement.formatDuration(this.getTotalDuration())

    // Send experienced statement
    const statement = Statement.generateExperiencedStatement(
      this.actor,
      this.courseId,
      this.courseTitle,
      id,
      slideTitle,
      this.registration,
      duration,
      this.lang
    )

    this.lrs
      .sendStatement(statement)
      .then((responseId) => {
        if (this.debug) {
          console.log('Sent experienced statement, ID:', responseId)
        }
        // Send progress/completion update after slide experience
        // This provides continuous tracking like SCORM does
        this.sendCompletionIfNeeded()
      })
      .catch((err) => {
        console.error('Failed to send experienced statement:', err)
      })
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

    if (table === 'code') {
      // null lets LiaScript store its initial projects
      this.codeProjects[id] =
        this.codeStates[id] ?? this.codeProjects[id] ?? null
      return this.codeProjects[id]
    }

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
   * Load every id of a table (quiz, survey, task) from memory in one call,
   * instead of one `load` per slide. Used to preload all persisted
   * quiz/survey answers when joining a classroom.
   * @param table Table to load
   * @returns the stored data per id, only for ids that have an entry
   */
  async loadAll(table: string) {
    await this.stateRestored

    const states: Record<number, Record<number, any>> | undefined =
      table === 'quiz'
        ? this.quizStates
        : table === 'survey'
        ? this.surveyStates
        : table === 'task'
        ? this.taskStates
        : undefined

    if (!states) return []

    return Object.entries(states).map(([id, entries]) => {
      const data: any[] = []
      for (const index in entries) {
        data[parseInt(index)] = entries[index]
      }
      return { id: parseInt(id), data }
    })
  }

  /**
   * Store data (quiz, survey, task)
   * @param record Record to store
   */
  store(record: Base.Record) {
    if (!this.active || !this.lrs || !record.data) return

    this.lastActivityTime = Date.now()
    const { table, id, data } = record

    // LiaScript stores the initial projects of a slide: nothing changed yet
    if (table === 'code') {
      this.codeProjects[id] = JSON.parse(JSON.stringify(data))
      return
    }

    // Handle quizzes
    if (table === 'quiz') {
      if (!this.quizStates[id]) {
        this.quizStates[id] = {}
      }

      // Process each quiz on the slide
      data.forEach((quiz: any, i: number) => {
        if (!quiz) return

        const previous = this.quizStates[id][i]
        this.quizStates[id][i] = quiz

        // Every change on a slide stores all of its quizzes; only one the
        // learner has worked on, and only when it changed, is an answer
        const attempted = quiz.trial > 0 || quiz.solved !== 0
        if (!attempted || State.same(previous, quiz)) {
          return
        }

        if (this.debug) console.log('Storing quiz:', id, i, quiz)

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
          // the learner's input, as LiaScript keeps it
          quiz.state ?? '',
          quiz.solved === 1 ? true : quiz.solved === -1 ? false : null,
          quiz.solved === 1 ? quiz.score || 1 : 0,
          quiz.score || 1,
          quiz,
          this.registration,
          undefined,
          false,
          this.describe('quiz', id, i, quiz)
        )

        this.lrs
          .sendStatement(statement)
          .then(() => {
            if (this.debug) console.log(`Sent answer: slide ${id}, quiz ${i}`)
            // Send progress update after quiz answer (like SCORM continuous updates)
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

      // Every change on a slide stores all of its surveys; only one that
      // changed and is submitted is an answer
      const submitted = State.changes(
        'survey',
        this.list(this.surveyStates, id),
        data
      ).filter((change) => change.urgent)

      data.forEach((survey: any, i: number) => {
        if (survey) this.surveyStates[id][i] = survey
      })

      submitted.forEach(({ index: i }) => {
        const survey = data[i]

        // Send answered statement for survey
        const statement = Statement.generateAnsweredStatement(
          this.actor,
          this.courseId,
          this.courseTitle,
          id,
          i,
          'Survey',
          survey.state,
          survey.submitted,
          0, // Surveys don't have scores
          0,
          survey,
          this.registration,
          i, // Use surveyIndex instead of quizIndex
          true, // isSurvey flag
          this.describe('survey', id, i, survey)
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

      // Only the task lists that changed
      const changed = State.changes(
        'task',
        this.list(this.taskStates, id),
        data
      )

      data.forEach((task: any, i: number) => {
        if (task) this.taskStates[id][i] = task
      })

      changed.forEach(({ index: i }) => {
        const task = data[i]
        if (!task) return

        // Send interacted statement for task
        const statement = Statement.generateTaskStatement(
          this.actor,
          this.courseId,
          this.courseTitle,
          id,
          i,
          task,
          this.registration,
          this.describe('task', id, i, task)
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
   * LiaScript's changes to code projects: runs, version switches, views.
   * A project whose code changed is sent with the code of the whole slide.
   * @param record Record to update
   * @param fn Update function
   */
  update(record: Base.Record, fn: (a: any) => any) {
    const { table, id } = record
    if (table !== 'code' || !this.active || !this.lrs) return

    const before = this.codeProjects[id]
    if (!before) return

    let after: any[]
    try {
      after = fn(JSON.parse(JSON.stringify(before)))
    } catch (e) {
      console.warn('xAPI: code update failed', e)
      return
    }

    this.lastActivityTime = Date.now()
    this.codeProjects[id] = after
    this.codeStates[id] = after

    for (const i of Code.changed(before, after)) {
      const statement = Statement.generateCodeStatement(
        this.actor,
        this.courseId,
        this.courseTitle,
        id,
        i,
        after,
        this.registration,
        this.describe('code', id, i, after[i])
      )

      this.lrs
        .sendStatement(statement)
        .then(() => {
          if (this.debug) console.log(`Sent code: slide ${id}, project ${i}`)
        })
        .catch((err) => console.error('Failed to send code statement:', err))
    }
  }

  /**
   * Reset the connector
   * @param uidDB Course ID
   * @param versionDB Course version
   */
  reset(uidDB?: string, versionDB?: number) {
    // Reset state
    this.visitedSlides.clear()
    this.lastVisitedSlide = 0
    this.quizStates = {}
    this.surveyStates = {}
    this.taskStates = {}
    this.codeStates = {}
    this.codeProjects = {}
    this.startTime = Date.now()
    this.lastActivityTime = this.startTime
    this.accumulatedTime = 0
    this.completionSent = false

    // Call base implementation
    super.reset(uidDB, versionDB)
  }
}
