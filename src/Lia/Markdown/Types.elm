module Lia.Markdown.Types exposing (Markdown(..))

import Lia.Chart.Types exposing (Chart)
import Lia.Code.Types exposing (Code)
import Lia.Helper exposing (ID)
import Lia.Inline.Types exposing (..)
import Lia.Quiz.Types exposing (Quiz)
import Lia.Survey.Types exposing (Survey)


type Markdown
    = HLine
    | Quote (List Markdown)
    | Paragraph Inlines
    | BulletList (List (List Markdown))
    | OrderedList (List (List Markdown))
    | Table MultInlines (List String) (List MultInlines)
    | Quiz Quiz (Maybe ( List Markdown, Int ))
    | Effect ID (Maybe String) String (List Markdown)
    | Comment ID Inlines
    | Survey Survey
    | Chart Chart
    | Code Code



--  | AnnotatedMarkdown Markdown Parameters
