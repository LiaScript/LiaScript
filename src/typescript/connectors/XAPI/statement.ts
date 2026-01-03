/**
 * Utilities for generating xAPI statements
 */

/**
 * Generate an initialized statement for course start
 */
export function generateInitializedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  registration?: string
) {
  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/initialized',
      display: { 'en-US': 'initialized' },
    },
    object: {
      id: courseId,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/course',
        name: { 'en-US': courseTitle },
      },
    },
    timestamp: new Date().toISOString(),
  }

  if (registration) {
    statement.context = { registration }
  }

  return statement
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
  registration?: string
) {
  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/experienced',
      display: { 'en-US': 'experienced' },
    },
    object: {
      id: `${courseId}/slides/${slideId}`,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/module',
        name: { 'en-US': slideName || `Slide ${slideId}` },
        extensions: {
          'http://liascript.github.io/extensions/slideId': slideId,
        },
      },
    },
    context: {
      contextActivities: {
        parent: [
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
    },
    timestamp: new Date().toISOString(),
  }

  if (registration) {
    statement.context.registration = registration
  }

  return statement
}

/**
 * Generate an answered statement for quiz responses
 */
export function generateAnsweredStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  slideId: number,
  quizId: number,
  quizType: string,
  response: any,
  success: boolean,
  score: number,
  maxScore: number,
  quizState?: any,
  registration?: string
) {
  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/answered',
      display: { 'en-US': 'answered' },
    },
    object: {
      id: `${courseId}/slides/${slideId}/quiz/${quizId}`,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/question',
        name: { 'en-US': `${quizType} Question ${quizId}` },
        extensions: {
          'http://liascript.github.io/extensions/slideId': slideId,
          'http://liascript.github.io/extensions/quizIndex': quizId,
        },
      },
    },
    result: {
      success: success,
      completion: true,
      response: JSON.stringify(response),
      score: {
        scaled: maxScore > 0 ? score / maxScore : 0,
        raw: score,
        min: 0,
        max: maxScore,
      },
    },
    context: {
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
    },
    timestamp: new Date().toISOString(),
  }

  // Add registration if provided
  if (registration) {
    statement.context.registration = registration
  }

  // Add quiz state extensions if provided
  if (quizState) {
    statement.result.extensions = {
      'http://liascript.github.io/extensions/state': quizState.state || [],
      'http://liascript.github.io/extensions/trial': quizState.trial || 0,
      'http://liascript.github.io/extensions/hint': quizState.hint || 0,
    }
  }

  return statement
}

/**
 * Generate a completed statement for course completion
 */
export function generateCompletedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  success: boolean,
  score: number,
  maxScore: number,
  duration: string,
  registration?: string
) {
  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/completed',
      display: { 'en-US': 'completed' },
    },
    object: {
      id: courseId,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/course',
        name: { 'en-US': courseTitle },
      },
    },
    result: {
      success: success,
      completion: true,
      score: {
        scaled: maxScore > 0 ? score / maxScore : 0,
        raw: score,
        min: 0,
        max: maxScore,
      },
      duration: duration,
    },
    timestamp: new Date().toISOString(),
  }

  if (registration) {
    statement.context = { registration }
  }

  return statement
}

/**
 * Generate a progressed statement for tracking progress
 */
export function generateProgressedStatement(
  actor: any,
  courseId: string,
  courseTitle: string,
  progress: number,
  registration?: string
) {
  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/progressed',
      display: { 'en-US': 'progressed' },
    },
    object: {
      id: courseId,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/course',
        name: { 'en-US': courseTitle },
      },
    },
    result: {
      completion: progress >= 1.0,
      progress: progress,
    },
    timestamp: new Date().toISOString(),
  }

  if (registration) {
    statement.context = { registration }
  }

  return statement
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
  const statement: any = {
    actor: actor,
    verb: {
      id: 'http://adlnet.gov/expapi/verbs/terminated',
      display: { 'en-US': 'terminated' },
    },
    object: {
      id: courseId,
      objectType: 'Activity',
      definition: {
        type: 'http://adlnet.gov/expapi/activities/course',
        name: { 'en-US': courseTitle },
      },
    },
    result: {
      duration: duration,
    },
    timestamp: new Date().toISOString(),
  }

  if (registration) {
    statement.context = { registration }
  }

  return statement
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
