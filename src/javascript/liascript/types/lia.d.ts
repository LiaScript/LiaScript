export as namespace Lia;

export type Send = (_: Event) => void

export type ErrType = 'error' | 'warning' | 'info'

export type ErrMessage = {
  row: number,
  column?: number,
  text: string,
  type: ErrType
}

export type Event = {
  topic: string,
  section: number,
  message: Event | any
}

export type Settings = {
  table_of_contents: Boolean,
  mode: Mode,
  theme: string,
  light: boolean,
  editor: string,
  font_size: number,
  sound: boolean,
  lang: Lang
}

type Mode
  = 'Slides'
  | 'Presentation'
  | 'Textbook'

type Lang
  = 'bg'
  | 'de'
  | 'en'
  | 'es'
  | 'fa'
  | 'hy'
  | 'nl'
  | 'ru'
  | 'tw'
  | 'ua'
  | 'zh'
