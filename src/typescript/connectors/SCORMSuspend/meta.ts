/**
 * Course metadata the exporter puts into `window.config_.meta` (version 1).
 *
 * A connector only ever sees learner state, e.g. `{"SingleChoice":[false,true]}`.
 * To report readable answers it needs the question, the option labels and the
 * solution, which exist only when the course is parsed. The exporter's Elm
 * worker (`fulljson-meta`) writes them here, one entry per state element:
 * `slides[s].quiz[i]` describes `config_.quiz[s][i]`, and so on.
 *
 * Every text is plain text, without markup.
 */

export interface LiaMeta {
  version: 1
  /** Language of the exported course; reports describe this translation. */
  lang: string
  slides: SlideMeta[]
}

export interface SlideMeta {
  title: string
  quiz: QuizMeta[]
  survey: SurveyMeta[]
  task: TaskMeta[]
  code: CodeMeta[]
}

interface Described {
  /** The paragraph in front of the element, '' if there is none. */
  question: string
  /** Checked by a script, so there is no static solution. */
  script?: true
  /** The exporter could not describe this element. */
  unknown?: true
}

export type GapMeta =
  | { type: 'text'; solution: string | null }
  | { type: 'select' | 'drop'; options: string[]; solution: number[] | null }

export type QuizMeta = Described &
  (
    | { type: 'text'; solution: string | null }
    | { type: 'single' | 'multiple'; options: string[]; solution: boolean[] | null }
    | { type: 'select' | 'drop'; options: string[]; solution: number[] | null }
    | {
        type: 'matrix'
        rows: string[]
        columns: string[]
        /** per row: several columns may be ticked */
        multiple: boolean[]
        solution: boolean[][] | null
      }
    | { type: 'gap'; gaps: GapMeta[] }
    | { type: 'generic'; solution: null }
  )

export interface SurveyOption {
  /** The key in the survey state, as the author wrote it: `[(good)]` */
  key: string
  label: string
}

export interface SurveyMeta {
  type:
    | 'text'
    | 'textarea'
    | 'single'
    | 'multiple'
    | 'select'
    | 'drop'
    | 'matrix-single'
    | 'matrix-multiple'
  question: string
  options?: SurveyOption[]
  rows?: string[]
  /** not found in the course body */
  unknown?: true
}

export interface TaskMeta {
  question: string
  items: string[]
}

export interface CodeMeta {
  question: string
  files: { name: string; lang: string; hidden?: true }[]
}

/** The state key a quiz meta type belongs to, used to cross-check both. */
export const QUIZ_STATE_KEY: Record<QuizMeta['type'], string> = {
  text: 'Text',
  single: 'SingleChoice',
  multiple: 'MultipleChoice',
  select: 'Select',
  drop: 'Drop',
  matrix: 'Matrix',
  gap: 'Multi',
  generic: 'Generic',
}
