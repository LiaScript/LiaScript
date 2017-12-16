module Lia.Types exposing (Design, Mode(..), Section, Sections)

import Array exposing (Array)
import Lia.Chart.Types exposing (Chart)
import Lia.Code.Types exposing (Code, CodeVector)
import Lia.Effect.Model as Effect
import Lia.Inline.Types exposing (..)
import Lia.Markdown.Types exposing (Markdown)
import Lia.Quiz.Types exposing (Quiz)
import Lia.Survey.Types exposing (Survey)


type Mode
    = Presentation
    | Slides
    | Textbook


type alias Design =
    { theme : String
    , light : String
    }


type alias Section =
    { code : String
    , title : String
    , indentation : Int
    , body : List Markdown
    , error : Maybe String
    , effects : Int
    , speach : List String
    , code_vector : CodeVector
    , effect_model : Effect.Model
    }


type alias Sections =
    Array Section
