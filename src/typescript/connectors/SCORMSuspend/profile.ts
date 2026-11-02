/**
 * The differences between SCORM 1.2 and 2004 that the engine needs: element
 * names, limits and time formats. Everything else is shared.
 */

import type { Version } from './report'

export interface Profile {
  version: Version
  /** largest `cmi.suspend_data` to try first, then the fallbacks */
  suspendLimits: number[]
  cmi: {
    mode: string
    credit: string
    entry: string
    location: string
    suspend: string
    sessionTime: string
    exit: string
    /** 1.2 `lesson_status`, 2004 `completion_status` */
    completion: string
    /** 2004 only */
    success?: string
    scoreRaw: string
    scoreMin: string
    scoreMax: string
    scoreScaled?: string
    progress?: string
    /** where the LMS passes the mastery score */
    mastery: string
    count: string
    response: string
    /** 1.2 `time`, 2004 `timestamp` */
    time: string
  }
  /** how the mastery value of the LMS maps to [0, 1] */
  masteryScale: number
  /** the status values a learner never loses */
  final: string[]
  timespan(ms: number): string
  timestamp(date: Date): string
}

const pad = (n: number, width = 2) => String(Math.floor(n)).padStart(width, '0')

/** local time, `YYYY-MM-DDTHH:MM:SS`: Moodle refuses a `Z` without fractions */
function localDateTime(date: Date) {
  return (
    `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}` +
    `T${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
  )
}

export const SCORM12: Profile = {
  version: '1.2',
  suspendLimits: [4096, 4000, 2000],
  cmi: {
    mode: 'cmi.core.lesson_mode',
    credit: 'cmi.core.credit',
    entry: 'cmi.core.entry',
    location: 'cmi.core.lesson_location',
    suspend: 'cmi.suspend_data',
    sessionTime: 'cmi.core.session_time',
    exit: 'cmi.core.exit',
    completion: 'cmi.core.lesson_status',
    scoreRaw: 'cmi.core.score.raw',
    scoreMin: 'cmi.core.score.min',
    scoreMax: 'cmi.core.score.max',
    mastery: 'cmi.student_data.mastery_score',
    count: 'cmi.interactions._count',
    response: 'student_response',
    time: 'time',
  },
  masteryScale: 100,
  final: ['completed', 'passed'],
  /** `HHHH:MM:SS.SS` */
  timespan(ms: number) {
    const s = Math.max(0, ms) / 1000
    const hours = Math.min(9999, Math.floor(s / 3600))
    return `${pad(hours, 2)}:${pad((s % 3600) / 60)}:${pad(s % 60)}`
  },
  timestamp(date: Date) {
    return `${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}`
  },
}

export const SCORM2004: Profile = {
  version: '2004',
  suspendLimits: [64000, 4000, 2000],
  cmi: {
    mode: 'cmi.mode',
    credit: 'cmi.credit',
    entry: 'cmi.entry',
    location: 'cmi.location',
    suspend: 'cmi.suspend_data',
    sessionTime: 'cmi.session_time',
    exit: 'cmi.exit',
    completion: 'cmi.completion_status',
    success: 'cmi.success_status',
    scoreRaw: 'cmi.score.raw',
    scoreMin: 'cmi.score.min',
    scoreMax: 'cmi.score.max',
    scoreScaled: 'cmi.score.scaled',
    progress: 'cmi.progress_measure',
    mastery: 'cmi.scaled_passing_score',
    count: 'cmi.interactions._count',
    response: 'learner_response',
    time: 'timestamp',
  },
  masteryScale: 1,
  final: ['completed'],
  /** `PT1H2M3.45S` */
  timespan(ms: number) {
    const s = Math.max(0, ms) / 1000
    const seconds = (Math.floor((s % 60) * 100) / 100).toString()
    return `PT${Math.floor(s / 3600)}H${Math.floor((s % 3600) / 60)}M${seconds}S`
  },
  timestamp: localDateTime,
}

export const profile = (version: Version) => (version === '1.2' ? SCORM12 : SCORM2004)
