module Lia.Types exposing (Block(..), Id, Mode(..), Paragraph, Slide)

import Lia.Chart.Types exposing (Chart)
import Lia.Code.Types exposing (Code)
import Lia.Inline.Types exposing (..)
import Lia.Quiz.Types exposing (Quiz)
import Lia.Survey.Types exposing (Survey)


type Mode
    = Slides
    | Slides_only
    | Textbook


type alias Slide =
    { indentation : Int
    , title : String
    , body : List Block
    , effects : Int
    }


type alias Paragraph =
    List Inline


type alias Id =
    Int


type Block
    = HLine
    | CodeBlock Code
    | Quote Paragraph
    | Paragraph Paragraph
    | Table (List Paragraph) (List String) (List (List Paragraph))
    | Quiz Quiz (List Block)
    | EBlock Int (Maybe String) (List Block)
    | EComment Int Paragraph
    | BulletList (List (List Block))
    | OrderedList (List (List Block))
    | SurveyBlock Survey
    | Chart Chart
