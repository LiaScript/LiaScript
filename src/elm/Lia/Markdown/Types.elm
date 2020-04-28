module Lia.Markdown.Types exposing (Markdown(..), MarkdownS)

import Lia.Markdown.Chart.Types exposing (Chart)
import Lia.Markdown.Code.Types exposing (Code)
import Lia.Markdown.Effect.Types exposing (Effect)
import Lia.Markdown.HTML.Types exposing (Node)
import Lia.Markdown.Inline.Types exposing (Annotation, Inlines)
import Lia.Markdown.Quiz.Types exposing (Quiz)
import Lia.Markdown.Survey.Types exposing (Survey)
import Lia.Markdown.Table.Types exposing (Table)


type Markdown
    = HLine Annotation
    | Quote Annotation MarkdownS
    | Paragraph Annotation Inlines
    | BulletList Annotation (List MarkdownS)
    | OrderedList Annotation (List ( String, MarkdownS ))
    | Table Annotation Table
    | Quiz Annotation Quiz (Maybe ( MarkdownS, Int ))
    | Effect Annotation (Effect Markdown)
    | Comment ( Int, Int )
    | Survey Annotation Survey
    | Chart Annotation Chart
    | Code Annotation Code
    | ASCII Annotation String
    | HTML Annotation (Node Markdown)


type alias MarkdownS =
    List Markdown
