module Lia.Types exposing (Design, Mode(..), Section, Sections)

import Array exposing (Array)
import Lia.Code.Types as Code
import Lia.Effect.Model as Effect
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Types exposing (Markdown)
import Lia.Quiz.Types as Quiz
import Lia.Survey.Types as Survey


type Mode
    = Presentation
    | Slides
    | Textbook
    | PresentationWithSubtitles


type alias Design =
    { theme : String
    , light : String
    }


type alias Section =
    { code : String
    , title : Inlines
    , visited : Bool
    , indentation : Int
    , body : List Markdown
    , error : Maybe String
    , effects : Int
    , speach : List String
    , code_vector : Code.Vector
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , effect_model : Effect.Model
    }


type alias Sections =
    Array Section
