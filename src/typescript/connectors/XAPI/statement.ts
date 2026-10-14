/**
 * Utilities for generating xAPI statements
 */

import type { Interaction } from '../SCORMSuspend/report'
import { codeText } from '../SCORMSuspend/report'
import * as Code from './code'

const ANSWER = 'http://liascript.github.io/extensions/answer'

/**
 * Describes the object as the interaction, keeping the extensions restoring
 * relies on, and reports the response in its format and as plain text.
 */
function describeAs(statement: any, interaction?: Interaction) {
  if (!interaction) return statement

  statement.object.definition = {
    ...interaction.definition,
    extensions: statement.object.definition.extensions,
  }

  delete statement.result.response
  if (interaction.response !== undefined) {
    statement.result.response = interaction.response
  }
  if (interaction.answer !== undefined) {
    statement.result.extensions = {
      ...statement.result.extensions,
      [ANSWER]: interaction.answer,
    }
  }
  return statement
}

/** The slide and the course, as context of an element on that slide */
function slideContext(courseId: string, courseTitle: string, slideId: number) {
  return {
    contextActivities: {
      parent: [
        {
          id: `${courseId}/slides/${slideId}`,
          objectType: 'Activity',
          definition: {
            type: 'http://adlnet.gov/expapi/activities/module',
          },
        },
      ],
      grouping: [
        {
          id: courseId,
          objectType: 'Activity',
          definition: {
            type: 'http://adlnet.gov/expapi/activities/course',
            name: { 'en-US': courseTitle },
          },
        },
      ],
    },
  }
}

/**
 * Helper: Create course activity object
 */
function createCourseActivity(courseId: string, courseTitle: string) {
  return {
    id: courseId,
    objectType: 'Activity' as const,
    definition: {
      type: 'http://adlnet.gov/expapi/activities/course',
      name: { 'en-US': courseTitle },
    },
  }
}

/**
 * Helper: Add registration to context
 */
function addRegistration(statement: any, registration?: string) {
  if (registration) {
    statement.context = statement.context || {}
    statement.context.registration = registration
  }
  return statement
}

/**
 * Generate an initialized statement for course start
 */
export function generateInitializedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  registration?: string
) {
  return addRegistration(
    {
      actor,
      verb: {
        id: 'http://adlnet.gov/expapi/verbs/initialized',
        display: { 'en-US': 'initialized' },
      },
      object: createCourseActivity(courseId, courseTitle),
      result: {
        completion: false,
      },
      timestamp: new Date().toISOString(),
    },
    registration
  )
}

/**
 * Generate an experienced statement for viewing a slide
 */
export function generateExperiencedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  slideId: number,
  slideName: string,
  registration?: string,
  duration?: string,
  lang = 'en-US'
) {
  const statement: any = {
    actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/experienced',
      display: { 'en-US': 'experienced' },
    },
    object: {
      id: `${courseId}/slides/${slideId}`,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/module',
        name: { [lang]: slideName || `Slide ${slideId}` },
        extensions: {
          'http://liascript.github.io/extensions/slideId': slideId,
        },
      },
    },
    context: {
      contextActivities: {
        parent: [createCourseActivity(courseId, courseTitle)],
      },
    },
    timestamp: new Date().toISOString(),
  }

  // Add duration if provided
  if (duration) {
    statement.result = { duration }
  }

  return addRegistration(statement, registration)
}

/**
 * Generate an answered statement for quiz responses and surveys. With an
 * interaction (from the course's meta data) the question is described
 * readably; otherwise the response is the learner's state as JSON.
 */
export function generateAnsweredStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  slideId: number,
  quizId: number,
  quizType: string,
  response: any,
  success: boolean | null,
  score: number,
  maxScore: number,
  quizState?: any,
  registration?: string,
  surveyIndex?: number,
  isSurvey = false,
  interaction?: Interaction
) {
  const itemType = isSurvey ? 'survey' : 'quiz'
  const itemIndex = isSurvey ? surveyIndex : quizId

  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/answered',
      display: { 'en-US': 'answered' },
    },
    object: {
      id: `${courseId}/slides/${slideId}/${itemType}/${itemIndex}`,
      objectType: 'Activity',
      definition: {
        type: isSurvey
          ? 'http://adlnet.gov/expapi/activities/survey'
          : 'http://adlnet.gov/expapi/activities/question',
        name: {
          'en-US': isSurvey
            ? `Slide ${slideId} - Survey ${itemIndex}`
            : quizType !== 'unknown'
            ? `Slide ${slideId} - ${quizType} ${quizId}`
            : `Slide ${slideId} - Quiz ${quizId}`,
        },
        description: {
          'en-US': isSurvey
            ? 'Survey Question'
            : quizType !== 'unknown'
            ? `${quizType} Question`
            : 'Quiz Question',
        },
        extensions: {
          'http://liascript.github.io/extensions/slideId': slideId,
          ...(isSurvey
            ? { 'http://liascript.github.io/extensions/surveyIndex': itemIndex }
            : { 'http://liascript.github.io/extensions/quizIndex': quizId }),
        },
      },
    },
    result: {
      // xAPI allows a boolean or nothing; null makes the LRS reject the
      // statement. For quizzes, null means "attempted, not yet decided".
      ...(typeof success === 'boolean' ? { success } : {}),
      // For surveys, completion indicates submitted; a quiz is complete once
      // solved or resolved
      completion: isSurvey ? success === true : success !== null,
      response: JSON.stringify(response),
      score: {
        scaled: maxScore > 0 ? score / maxScore : 0,
        raw: score,
        min: 0,
        max: maxScore,
      },
    },
    context: slideContext(courseId, courseTitle, slideId),
    timestamp: new Date().toISOString(),
  }

  // Add registration if provided
  if (registration) {
    statement.context.registration = registration
  }

  // Add state extensions
  if (quizState || isSurvey) {
    statement.result.extensions = {
      'http://liascript.github.io/extensions/state': isSurvey
        ? quizState.state || {}
        : quizState?.state || [],
    }

    // Add quiz-specific extensions
    if (!isSurvey && quizState) {
      statement.result.extensions[
        'http://liascript.github.io/extensions/trial'
      ] = quizState.trial || 0
      statement.result.extensions[
        'http://liascript.github.io/extensions/hint'
      ] = quizState.hint || 0
    }
  }

  return describeAs(statement, interaction)
}

/**
 * Generate an interacted statement for task checkbox interactions
 */
export function generateTaskStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  slideId: number,
  taskId: number,
  taskState: boolean[],
  registration?: string,
  interaction?: Interaction
) {
  const completedCount = taskState.filter((checked) => checked).length
  const totalCount = taskState.length
  const progress = totalCount > 0 ? completedCount / totalCount : 0

  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/interacted',
      display: { 'en-US': 'interacted' },
    },
    object: {
      id: `${courseId}/slides/${slideId}/task/${taskId}`,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/task',
        name: {
          'en-US': `Slide ${slideId} - Task ${taskId}`,
        },
        description: {
          'en-US': 'Task List',
        },
        extensions: {
          'http://liascript.github.io/extensions/slideId': slideId,
          'http://liascript.github.io/extensions/taskIndex': taskId,
        },
      },
    },
    result: {
      completion: progress === 1,
      score: {
        scaled: progress,
        raw: completedCount,
        min: 0,
        max: totalCount,
      },
      extensions: {
        'http://liascript.github.io/extensions/state': taskState,
      },
    },
    context: slideContext(courseId, courseTitle, slideId),
    timestamp: new Date().toISOString(),
  }

  // Add registration if provided
  if (registration) {
    statement.context.registration = registration
  }

  return describeAs(statement, interaction)
}

/**
 * Generate an interacted statement for the code of a project the learner
 * changed. It carries the files of every project of the slide, to restore
 * the slide from it (see code.ts).
 */
export function generateCodeStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  slideId: number,
  codeIndex: number,
  projects: any[],
  registration?: string,
  interaction?: Interaction
) {
  const project = projects[codeIndex]
  const files = (project?.file || []).map((file: any) => file.name).join(', ')
  const code = codeText(project, true) || codeText(project, false)

  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/interacted',
      display: { 'en-US': 'interacted' },
    },
    object: {
      id: `${courseId}/slides/${slideId}/code/${codeIndex}`,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/cmi.interaction',
        name: { 'en-US': `Slide ${slideId} - Code ${codeIndex}` },
        description: { 'en-US': files ? `Code (${files})` : 'Code' },
        interactionType: 'long-fill-in',
        extensions: {
          'http://liascript.github.io/extensions/slideId': slideId,
          'http://liascript.github.io/extensions/codeIndex': codeIndex,
        },
      },
    },
    result: {
      ...(code ? { response: code } : {}),
      extensions: {
        [Code.EXTENSION]: Code.encodeSlide(projects),
      },
    },
    context: slideContext(courseId, courseTitle, slideId),
    timestamp: new Date().toISOString(),
  }

  if (registration) {
    statement.context.registration = registration
  }

  return describeAs(statement, interaction)
}

/**
 * Generate a completed statement for course completion
 */
export function generateCompletedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  success: boolean | undefined,
  score: number,
  maxScore: number,
  duration: string,
  registration?: string
) {
  const statement: any = {
    actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/completed',
      display: { 'en-US': 'completed' },
    },
    object: createCourseActivity(courseId, courseTitle),
    result: {
      completion: true,
      score: {
        scaled: maxScore > 0 ? score / maxScore : 0,
        raw: score,
        min: 0,
        max: maxScore,
      },
      duration,
    },
    timestamp: new Date().toISOString(),
  }

  if (success !== undefined) {
    statement.result.success = success
  }

  return addRegistration(statement, registration)
}

/**
 * Generate a progressed statement for tracking progress
 */
export function generateProgressedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  progress: number,
  registration?: string,
  duration?: string,
  totalScore?: number,
  maxScore?: number,
  completion?: boolean,
  success?: boolean
) {
  const statement: any = {
    actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/progressed',
      display: { 'en-US': 'progressed' },
    },
    object: createCourseActivity(courseId, courseTitle),
    result: {
      // Use provided completion status if available, otherwise default to progress >= 1.0
      completion: completion !== undefined ? completion : progress >= 1.0,
      score: {
        scaled: progress, // 0.0 to 1.0 for slide progress
        raw: Math.round(progress * 100),
        min: 0,
        max: 100,
      },
      extensions: {
        'http://liascript.github.io/extensions/progress': progress,
        'http://liascript.github.io/extensions/progressPercent': Math.round(
          progress * 100
        ),
      },
    },
    timestamp: new Date().toISOString(),
  }

  // Add success if provided (for pass/fail tracking)
  if (success !== undefined) {
    statement.result.success = success
  }

  // Add duration if provided
  if (duration) {
    statement.result.duration = duration
  }

  // Override score with quiz scores if provided (for course-level tracking)
  if (maxScore !== undefined && maxScore > 0) {
    statement.result.score = {
      scaled: totalScore! / maxScore,
      raw: totalScore!,
      min: 0,
      max: maxScore,
    }
  }

  return addRegistration(statement, registration)
}

/**
 * Generate a terminated statement for course exit
 */
export function generateTerminatedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  duration: string,
  registration?: string
) {
  return addRegistration(
    {
      actor,
      verb: {
        id: 'http://adlnet.gov/expapi/verbs/terminated',
        display: { 'en-US': 'terminated' },
      },
      object: createCourseActivity(courseId, courseTitle),
      result: { duration },
      timestamp: new Date().toISOString(),
    },
    registration
  )
}

/**
 * Generate a suspended statement for incomplete course exit
 */
export function generateSuspendedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  duration: string,
  lastSlide: number,
  progress: number,
  registration?: string
) {
  return addRegistration(
    {
      actor,
      verb: {
        id: 'http://adlnet.gov/expapi/verbs/suspended',
        display: { 'en-US': 'suspended' },
      },
      object: createCourseActivity(courseId, courseTitle),
      result: {
        completion: false,
        duration,
        extensions: {
          'http://liascript.github.io/extensions/lastSlide': lastSlide,
          'http://liascript.github.io/extensions/progress': progress,
          'http://liascript.github.io/extensions/progressPercent': Math.round(
            progress * 100
          ),
        },
      },
      timestamp: new Date().toISOString(),
    },
    registration
  )
}

/**
 * Format duration in ISO8601 format
 * @param milliseconds Duration in milliseconds
 * @returns ISO8601 formatted duration string
 */
export function formatDuration(milliseconds: number): string {
  // Format as PT[hours]H[minutes]M[seconds]S
  const seconds = Math.floor(milliseconds / 1000)
  const hours = Math.floor(seconds / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  const remainingSeconds = seconds % 60

  let duration = 'PT'
  if (hours > 0) {
    duration += `${hours}H`
  }
  if (minutes > 0) {
    duration += `${minutes}M`
  }
  if (remainingSeconds > 0 || (hours === 0 && minutes === 0)) {
    duration += `${remainingSeconds}S`
  }

  return duration
}
