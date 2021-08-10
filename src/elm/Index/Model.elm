module Index.Model exposing
    ( Course
    , Model
    , Release
    , init
    , loaded
    , loadedBoard
    , loadedList
    )

import Dict exposing (Dict)
import Index.View.Board as Board exposing (Board)
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)


type alias Model =
    { input : String
    , courses : List Course
    , initialized : State
    , boardConfig : Maybe JE.Value
    , board : Board Course
    }


type alias State =
    { board : Bool
    , list : Bool
    }


init : Model
init =
    Board.init "Default"
        |> Model "" [] (State False False) Nothing


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


loadedBoard : Model -> Model
loadedBoard model =
    let
        state =
            model.initialized
    in
    { model | initialized = { state | board = True } }


loadedList : Model -> Model
loadedList model =
    let
        state =
            model.initialized
    in
    { model | initialized = { state | list = True } }


loaded : Model -> Bool
loaded { initialized } =
    initialized.board && initialized.list
