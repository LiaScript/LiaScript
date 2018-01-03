module Lia.Markdown.Types exposing (Markdown(..))

import Lia.Chart.Types exposing (Chart)
import Lia.Code.Types exposing (Code)
import Lia.Helper exposing (ID)
import Lia.Markdown.Inline.Types exposing (..)
import Lia.Quiz.Types exposing (Quiz)
import Lia.Survey.Types exposing (Survey)


type Markdown
    = HLine Annotation
    | Quote Annotation (List Markdown)
    | Paragraph Annotation Inlines
    | BulletList Annotation (List (List Markdown))
    | OrderedList Annotation (List (List Markdown))
    | Table Annotation MultInlines (List String) (List MultInlines)
    | Quiz Annotation Quiz (Maybe ( List Markdown, Int ))
    | Effect Annotation ( ID, List Markdown )
    | Comment ID Inlines
    | Survey Annotation Survey
    | Chart Chart
    | Code Annotation Code



--  | AnnotatedMarkdown Markdown Parameters
