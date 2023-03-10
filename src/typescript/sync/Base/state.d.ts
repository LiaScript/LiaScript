export type Data = Record<string, any>

export type Section = {
  q: Data[]
  s: Data[]
  c: Data[]
}

export type Vector = Section[]

export type Cursor = {
  id: string
  section: number
  project: number
  file: number
  position: {
    row: number
    column: number
  }
  color: string
}
