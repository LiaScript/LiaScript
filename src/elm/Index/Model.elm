module Index.Model exposing (Course, Model, Version, init)

import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias Model =
    { input : String
    , courses : List Course
    , initialized : Bool
    }


init : Model
init =
    Model "" [] False


type alias Course =
    { id : String
    , versions : Dict String Version
    , active : Maybe String
    , last_visit : String
    }


type alias Version =
    { title : Inlines
    , definition : Definition
    }
