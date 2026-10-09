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

const same = (a: any, b: any) => JSON.stringify(a) === JSON.stringify(b)

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
