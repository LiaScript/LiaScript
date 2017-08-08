module Lia exposing (..)

--import Html.Attributes as Attr
--import Html.Events exposing (onClick, onInput)
--import Json.Encode
--import Lia.Model exposing (Block(..), Inline(..), Reference(..), Slide)

import Html exposing (Html)
import Lia.Model
import Lia.Parser
import Lia.Type exposing (Mode(..), Slide)
import Lia.Update
import Lia.View


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Type.Msg


init : Mode -> String -> Model
init mode script =
    parse <| Lia.Model.Model script "" [] 0 mode


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


update : Msg -> Model -> ( Model, Cmd msg )
update =
    Lia.Update.update
