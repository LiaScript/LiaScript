/** Serialize an async job behind many triggers: while one run is in
 * flight, further calls only mark it dirty and exactly one more run follows.
 * Runs never overlap - so two snapshots computed by the job can't land out of
 * order - and a burst of N triggers costs two runs, not N.
 *
 * The job has to handle its own errors; a rejection is treated like a
 * completed run.
 */
export function coalesce(job: () => Promise<unknown>): () => void {
  let running = false
  let dirty = false

  const run = () => {
    if (running) {
      dirty = true
      return
    }
    running = true

    const done = () => {
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
