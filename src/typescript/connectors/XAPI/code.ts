/**
 * Code projects in xAPI statements.
 *
 * Every statement about a code project carries the files of all projects of
 * its slide (`…/extensions/code`), each as [lang, name, code, flags] like the
 * suspend connectors store them: Elm drops projects when it loads fewer than
 * a slide has, so a slide is always restored as a whole, from its newest
 * statement. Everything here is pure.
 */

import { decodeProject, encodeProject } from '../SCORMSuspend/codec'

export const EXTENSION = 'http://liascript.github.io/extensions/code'

const SLIDE = 'http://liascript.github.io/extensions/slideId'
const INDEX = 'http://liascript.github.io/extensions/codeIndex'

/** the files of every project of a slide */
export function encodeSlide(projects: any[]): any[] {
  return projects.map(encodeProject)
}

/** what makes up a project's code: its file names and contents */
const sources = (project: any) =>
  JSON.stringify((project?.file || []).map((file: any) => [file.name, file.code]))

/**
 * The projects whose code differs from before. Showing or hiding a file,
 * fullscreen and a run without edits change no code.
 */
export function changed(before: any[] | null | undefined, after: any[]): number[] {
  return after.flatMap((project, i) => (sources(before?.[i]) === sources(project) ? [] : [i]))
}

/**
 * The projects per slide, from the newest code statement of each slide.
 * A statement whose code cannot be read is skipped.
 */
export function restore(statements: any[]): Record<number, any[]> {
  const newest: Record<number, any> = {}

  for (const statement of statements) {
    const extensions = statement?.object?.definition?.extensions || {}
    const slide = extensions[SLIDE]
    if (!Number.isInteger(slide) || extensions[INDEX] === undefined) continue
    if (!Array.isArray(statement.result?.extensions?.[EXTENSION])) continue

    const time = new Date(statement.timestamp).getTime()
    if (!newest[slide] || new Date(newest[slide].timestamp).getTime() < time) {
      newest[slide] = statement
    }
  }

  const projects: Record<number, any[]> = {}
  for (const [slide, statement] of Object.entries(newest) as [any, any][]) {
    try {
      projects[slide] = statement.result.extensions[EXTENSION].map(decodeProject)
    } catch (e) {
      // written by something else, or damaged: the course's code stays
    }
  }
  return projects
}
