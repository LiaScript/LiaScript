/**
 * Finds the LMS's SCORM API and wraps it as the engine's `LMS`. No alert(),
 * no exceptions: without an API the connector simply stores nothing.
 */

import type { LMS } from './engine'
import type { Version } from './report'

const NAME: Record<Version, string> = { '1.2': 'API', '2004': 'API_1484_11' }

function read(win: Window, name: string): any {
  try {
    return (win as any)?.[name] ?? null
  } catch (e) {
    // a parent on another origin
    return null
  }
}

function parentOf(win: Window): Window | null {
  try {
    return win.parent && win.parent !== win ? win.parent : null
  } catch (e) {
    return null
  }
}

/** the standard search: up the frames, then up the opener's frames */
export function find(version: Version, win: Window = window): any {
  const name = NAME[version]

  const search = (start: Window | null) => {
    let current = start
    for (let tries = 0; current && tries < 10; tries++) {
      const api = read(current, name)
      if (api) return api
      current = parentOf(current)
    }
    return null
  }

  let api = search(win)
  if (!api) {
    try {
      if (win.opener) api = search(win.opener) || search(parentOf(win.opener) || null)
    } catch (e) {}
  }
  if (!api) {
    try {
      // a window opened from a frame of the LMS
      if (win.top?.opener) api = search(win.top.opener)
    } catch (e) {}
  }
  return api
}

const yes = (value: any) => value === true || String(value) === 'true'

/** Initializes the API and wraps it, or returns null. */
export function connect(version: Version, warn: (...args: any[]) => void, win: Window = window): LMS | null {
  const api = find(version, win)
  if (!api) {
    warn(`no SCORM ${version} API found, nothing will be stored`)
    return null
  }

  const v12 = version === '1.2'
  const call = (name12: string, name2004: string, ...args: any[]) => {
    try {
      return api[v12 ? name12 : name2004](...args)
    } catch (e: any) {
      warn(`${v12 ? name12 : name2004} failed:`, e?.message)
      return ''
    }
  }

  const lastError = () => String(call('LMSGetLastError', 'GetLastError') ?? '')

  const error = () => {
    const code = lastError()
    return `${code} ${call('LMSGetErrorString', 'GetErrorString', code) || ''} ${call('LMSGetDiagnostic', 'GetDiagnostic', code) || ''}`.trim()
  }

  if (!yes(call('LMSInitialize', 'Initialize', ''))) {
    // 101 (1.2) / 103 (2004): already initialized, e.g. after a reload
    const code = lastError()
    if (code !== (v12 ? '101' : '103')) {
      warn('Initialize failed:', error())
      return null
    }
  }

  return {
    get: (element) => {
      const value = call('LMSGetValue', 'GetValue', element)
      return value == null ? '' : String(value)
    },
    set: (element, value) => yes(call('LMSSetValue', 'SetValue', element, value)),
    error,
    commit: () => yes(call('LMSCommit', 'Commit', '')),
    finish: () => yes(call('LMSFinish', 'Terminate', '')),
  }
}
