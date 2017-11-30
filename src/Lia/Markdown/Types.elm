module Lia.Markdown.Types exposing (Markdown(..), MultiLine)

import Lia.Chart.Types exposing (Chart)
import Lia.Code.Types exposing (Code)
import Lia.Inline.Types exposing (..)
import Lia.Quiz.Types exposing (Quiz)
import Lia.Survey.Types exposing (Survey)


type alias MultiLine =
    List Line


type Markdown
    = HLine
    | Quote Line
    | Paragraph Line
    | BulletList (List (List Markdown))
    | OrderedList (List (List Markdown))
    | Table MultiLine (List String) (List MultiLine)
    | Quiz Quiz (Maybe ( List Markdown, Int ))
    | EBlock Int (Maybe String) (List Markdown)
    | EComment Int Line
    | Survey Survey
    | Chart Chart
    | Code Code
