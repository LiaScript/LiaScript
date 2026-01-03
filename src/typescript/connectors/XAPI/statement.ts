/**
 * Utilities for generating xAPI statements
 */

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
  registration?: string
) {
  return addRegistration(
    {
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
          name: { 'en-US': slideName || `Slide ${slideId}` },
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
    },
    registration
  )
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
        name: {
          'en-US':
            quizType !== 'unknown'
              ? `Slide ${slideId} - ${quizType} ${quizId}`
              : `Slide ${slideId} - Quiz ${quizId}`,
        },
        description: {
          'en-US':
            quizType !== 'unknown' ? `${quizType} Question` : 'Quiz Question',
        },
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
  return addRegistration(
    {
      actor,
      verb: {
        id: 'http://adlnet.gov/expapi/verbs/completed',
        display: { 'en-US': 'completed' },
      },
      object: createCourseActivity(courseId, courseTitle),
      result: {
        success,
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
    },
    registration
  )
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
  return addRegistration(
    {
      actor,
      verb: {
        id: 'http://adlnet.gov/expapi/verbs/progressed',
        display: { 'en-US': 'progressed' },
      },
      object: createCourseActivity(courseId, courseTitle),
      result: {
        completion: progress >= 1.0,
        score: {
          scaled: progress, // 0.0 to 1.0
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
    },
    registration
  )
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
