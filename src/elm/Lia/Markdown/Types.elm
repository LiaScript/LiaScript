module Lia.Markdown.Types exposing (Markdown(..), MarkdownS)

import Lia.Chart.Types exposing (Chart)
import Lia.Code.Types exposing (Code)
import Lia.Helper exposing (ID)
import Lia.Markdown.Inline.Types exposing (..)
import Lia.Quiz.Types exposing (Quiz)
import Lia.Survey.Types exposing (Survey)



--import SvgBob


type Markdown
    = HLine Annotation
    | Quote Annotation MarkdownS
    | Paragraph Annotation Inlines
    | BulletList Annotation (List MarkdownS)
    | OrderedList Annotation (List MarkdownS)
    | Table Annotation MultInlines (List String) (List MultInlines)
    | Quiz Annotation Quiz (Maybe ( MarkdownS, Int ))
    | Effect Annotation ( ID, ID, MarkdownS )
    | Comment ( ID, ID )
    | Survey Annotation Survey



--    | Chart Annotation Chart
--    | Code Annotation Code
--    | ASCII Annotation SvgBob.Model


type alias MarkdownS =
    List Markdown
