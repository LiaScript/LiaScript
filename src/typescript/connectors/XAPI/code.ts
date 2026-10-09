/**
 * Code projects in xAPI statements.
 *
 * Every statement about a code project carries the files of all projects of
 * its slide (`…/extensions/code`), each as [lang, name, code, flags] like the
 * suspend connectors store them: Elm drops projects when it loads fewer than
 * a slide has, so a slide is always restored as a whole, from its newest
 * statement. Everything here is pure.
 */

import { decodeProject, encodeProject, fits } from '../SCORMSuspend/codec'
import type { SlideMeta } from '../SCORMSuspend/meta'

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
 * The projects per slide, from the newest code statement of each slide that
 * can be read. With the course description (`slides`), a slide whose code
 * blocks changed since (another number of blocks, other files) starts
 * afresh, see `fits`.
 */
export function restore(
  statements: any[],
  slides?: SlideMeta[] | null
): Record<number, any[]> {
  const candidates: Record<number, any[]> = {}

  for (const statement of statements) {
    const extensions = statement?.object?.definition?.extensions || {}
    const slide = extensions[SLIDE]
    if (!Number.isInteger(slide) || extensions[INDEX] === undefined) continue
    if (!Array.isArray(statement.result?.extensions?.[EXTENSION])) continue
    ;(candidates[slide] = candidates[slide] || []).push(statement)
  }

  const time = (statement: any) => new Date(statement.timestamp).getTime() || 0
  const projects: Record<number, any[]> = {}

  for (const [slide, list] of Object.entries(candidates) as [any, any[]][]) {
    // newest first; an equal time keeps the LRS order (newest first, too)
    list.sort((a, b) => time(b) - time(a))

    for (const statement of list) {
      let restored: any[]
      try {
        restored = statement.result.extensions[EXTENSION].map(decodeProject)
      } catch (e) {
        // written by something else, or damaged: try the one before
        continue
      }

      if (slides && !fits(restored, slides[slide]?.code)) {
        console.warn(`xAPI: the code of slide ${slide} changed, it starts afresh`)
      } else {
        projects[slide] = restored
      }
      break
    }
  }
  return projects
}
