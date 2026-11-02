/**
 * What a `store` from LiaScript changed, compared with the mirrored state.
 * Urgent changes (a quiz was checked or resolved, a survey was submitted) are
 * reported and saved at once, everything else after a pause.
 */

export type Table = 'quiz' | 'survey' | 'task'

export interface Change {
  index: number
  urgent: boolean
}

/** JSON with sorted keys: a store may return objects in another key order */
const canonical = (value: any): string =>
  JSON.stringify(value, (_, v) =>
    v && typeof v === 'object' && !Array.isArray(v)
      ? Object.fromEntries(Object.keys(v).sort().map((key) => [key, v[key]]))
      : v
  )

export const same = (a: any, b: any) => canonical(a) === canonical(b)

export function changes(table: Table, before: any[] | undefined, after: any[]): Change[] {
  const list: Change[] = []
  if (!Array.isArray(after)) return list

  after.forEach((value, index) => {
    const old = before?.[index]
    if (same(old, value)) return

    switch (table) {
      case 'quiz':
        list.push({
          index,
          urgent: !old || old.solved !== value?.solved || old.trial !== value?.trial,
        })
        break
      case 'survey':
        list.push({ index, urgent: !!value?.submitted })
        break
      case 'task':
        list.push({ index, urgent: false })
        break
    }
  })

  return list
}
