/** Serialize an async job behind many triggers: while one run is in
 * flight, further calls only mark it dirty and exactly one more run follows.
 * Runs never overlap - so two snapshots computed by the job can't land out of
 * order - and a burst of N triggers costs two runs, not N.
 *
 * The job has to handle its own errors; a rejection is treated like a
 * completed run.
 *
 * A job that never settles (an IndexedDB request or Web Crypto call that
 * hangs) would otherwise block every later trigger forever, silently: the
 * scheduler would stay "running" with nothing ever delivered again. With
 * `stallMs` set, a run exceeding it is reported through `onStall` and no
 * longer counted as running, so the next (or already pending) trigger runs
 * again. If the stalled run settles after all, its late completion starts
 * nothing on its own.
 */
export function coalesce(
  job: () => Promise<unknown>,
  options: { stallMs?: number; onStall?: () => void } = {}
): () => void {
  let running = false
  let dirty = false
  let generation = 0

  const run = () => {
    if (running) {
      dirty = true
      return
    }
    running = true
    const mine = ++generation

    let watchdog: ReturnType<typeof setTimeout> | undefined
    if (options.stallMs) {
      watchdog = setTimeout(() => {
        if (generation !== mine || !running) return
        options.onStall?.()
        done()
      }, options.stallMs)
    }

    const done = () => {
      // a stalled run that settles late must not disturb its successor
      if (generation !== mine) return
      if (watchdog !== undefined) clearTimeout(watchdog)
      running = false
      if (dirty) {
        dirty = false
        run()
      }
    }
    job().then(done, done)
  }

  return run
}
