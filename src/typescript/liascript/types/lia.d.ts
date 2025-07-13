export as namespace Lia

interface Window {
  LIA: {
    settings: Settings
  }
}

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
  dir: 'ltr' | 'rtl'
  tooltips: boolean
  preferBrowserTTS: boolean
  hideVideoComments: boolean
  audio: {
    rate: number
    pitch: number
  }
}

export enum Mode {
  Slides = 'Slides',
  Presentation = 'Presentation',
  Textbook = 'Textbook',
}

type Lang =
  | 'ar'
  | 'bg'
  | 'de'
  | 'en'
  | 'es'
  | 'fa'
  | 'fr'
  | 'hy'
  | 'it'
  | 'ko'
  | 'nl'
  | 'ru'
  | 'tw'
  | 'ua'
  | 'zh'
