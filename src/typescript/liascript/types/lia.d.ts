export as namespace Lia

export type Send = (_: Event) => void

export type Event = {
  reply: boolean
  track: TRACK
  service: string
  message: {
    cmd: string
    param: any
  }
}

export type TRACK = POI[]

type POI = [string, number]

export type Settings = {
  table_of_contents: Boolean
  mode: Mode
  theme: string
  light: boolean
  editor: string
  font_size: number
  sound: boolean
  lang: Lang
  tooltips: boolean
  preferBrowserTTS: boolean
}

type Mode = 'Slides' | 'Presentation' | 'Textbook'

type Lang =
  | 'ar'
  | 'bg'
  | 'de'
  | 'en'
  | 'es'
  | 'fa'
  | 'hy'
  | 'ko'
  | 'nl'
  | 'ru'
  | 'tw'
  | 'ua'
  | 'zh'
