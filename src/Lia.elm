module Lia exposing (..)

--import Html.Attributes as Attr
--import Html.Events exposing (onClick, onInput)
--import Json.Encode
--import Lia.Model exposing (Block(..), Inline(..), Reference(..), Slide)

import Html exposing (Html)
import Lia.Model exposing (Slide)
import Lia.Msg exposing (..)
import Lia.Parser
import Lia.View exposing (Mode(..))


type alias Model =
    { script : String
    , error : String
    , lia : List Slide
    , slide : Int
    , mode : Mode
    }


init : Mode -> String -> Model
init mode script =
    parse <| Model script "" [] 0 mode


init_plain : String -> Model
init_plain =
    init Plain


init_slides : String -> Model
init_slides =
    init Slides


parse : Model -> Model
parse model =
    case Lia.Parser.run model.script of
        Ok lia ->
            { model | lia = lia, error = "" }

        Err msg ->
            { model | error = msg }


view : Model -> Html Msg
view model =
    Lia.View.view model.mode model.lia model.slide
