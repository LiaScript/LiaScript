module Index.Model exposing
    ( Course
    , Modal(..)
    , Model
    , Release
    , init
    , reset_modal
    )

import Dict exposing (Dict)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Library.Masonry as Masonry exposing (Masonry)


type Modal
    = Files
    | Directory


type alias Model =
    { input : String
    , courses : List Course
    , initialized : Bool
    , modal : Maybe Modal
    , error : Maybe String
    , masonry : Masonry Course
    }


init : Model
init =
    { input = ""
    , courses = []
    , initialized = False
    , modal = Nothing
    , error = Nothing
    , masonry = Masonry.empty (Just "example-id")
    }


reset_modal : Model -> Model
reset_modal model =
    { model | modal = Nothing, error = Nothing }


type alias Course =
    { id : String
    , versions : Dict String Release
    , active : Maybe String
    , last_visit : String
    }


type alias Release =
    { title : Inlines
    , definition : Definition
    }
