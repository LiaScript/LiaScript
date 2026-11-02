/**
 * Learner state rebuilt from xAPI statements. A rebuilt state has the shape
 * LiaScript stores, so that the next store on its slide is not taken for a
 * change and sent again. Everything here is pure.
 */

const EXT = 'http://liascript.github.io/extensions/'

/**
 * A quiz state from its newest answered statement, on top of the course's
 * initial state, which gives the fields and the weight (`score`).
 *
 * solved: 1 = correctly solved, -1 = resolved (the solution was shown),
 * 0 = still trying.
 */
export function quizState(statement: any, initial: any) {
  const result = statement?.result || {}
  const extensions = result.extensions || {}

  let solved = 0
  if (result.success === true) solved = 1
  else if (result.success === false && result.completion === true) solved = -1

  return {
    ...(initial || { error_msg: '', score: result.score?.max ?? 1 }),
    solved,
    state: extensions[EXT + 'state'] ?? initial?.state ?? [],
    trial: extensions[EXT + 'trial'] || 0,
    hint: extensions[EXT + 'hint'] || 0,
    error_msg: '',
  }
}
