module Lia.Markdown.Types exposing (Markdown(..), MarkdownS)

import Lia.Markdown.Chart.Types exposing (Chart)
import Lia.Markdown.Code.Types exposing (Code)
import Lia.Markdown.Inline.Types exposing (..)
import Lia.Markdown.Quiz.Types exposing (Quiz)
import Lia.Markdown.Survey.Types exposing (Survey)
import SvgBob


type Markdown
    = HLine Annotation
    | Quote Annotation MarkdownS
    | Paragraph Annotation Inlines
    | BulletList Annotation (List MarkdownS)
    | OrderedList Annotation (List MarkdownS)
    | Table Annotation MultInlines (List String) (List MultInlines)
    | Quiz Annotation Quiz (Maybe ( MarkdownS, Int ))
    | Effect Annotation ( Int, Int, MarkdownS )
    | Comment ( Int, Int )
    | Survey Annotation Survey
    | Chart Annotation Chart
    | Code Annotation Code
    | ASCII Annotation SvgBob.Model


type alias MarkdownS =
    List Markdown
