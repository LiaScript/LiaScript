module Index.Model exposing
    ( Action(..)
    , Course
    , Modal(..)
    , Model
    , Release
    , cardID
    , init
    , reset_modal
    , urlInputID
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
    , masonry = Masonry.empty
    }


reset_modal : Model -> Model
reset_modal model =
    { model | modal = Nothing, error = Nothing }


type Action
    = Popup_Delete
    | Popup_Reset


type alias Course =
    { id : String
    , versions : Dict String Release
    , active : Maybe String
    , last_visit : String
    , popup : Maybe Action
    }


type alias Release =
    { title : Inlines
    , definition : Definition
    }


{-| Id of the card of a course, it gets the focus when the card before it got
deleted.
-}
cardID : String -> String
cardID =
    (++) "lia-card-"


{-| Id of the input for a course url, it gets the focus when the last card got
deleted.
-}
urlInputID : String
urlInputID =
    "lia-course-url"
