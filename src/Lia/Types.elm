module Lia.Types exposing (Design, Mode(..), Section, Sections)

import Array exposing (Array)
import Lia.Code.Types as Code
import Lia.Definition.Types exposing (Definition)
import Lia.Effect.Model as Effect
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Types exposing (Markdown)
import Lia.Quiz.Types as Quiz
import Lia.Survey.Types as Survey


type Mode
    = Slides -- Underline Comments and Effects
    | Presentation -- Only effects
    | Textbook -- Render Comments and Effects at ones


type alias Design =
    { theme : String
    , light : String
    , font_size : Int
    , ace : String
    }


type alias Section =
    { code : String
    , title : Inlines
    , visited : Bool
    , indentation : Int
    , body : List Markdown
    , parsed : Bool
    , error : Maybe String
    , code_vector : Code.Vector
    , quiz_vector : Quiz.Vector
    , survey_vector : Survey.Vector
    , effect_model : Effect.Model
    , definition : Maybe Definition
    }


type alias Sections =
    Array Section
