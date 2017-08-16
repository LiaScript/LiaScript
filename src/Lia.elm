module Lia exposing (..)

import Array
import Html exposing (Html)
import Lia.Helper
import Lia.Model
import Lia.Parser
import Lia.Type
import Lia.Update
import Lia.View


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Type.Msg


type alias Mode =
    Lia.Type.Mode


init : Mode -> String -> Model
init mode script =
    parse <| Lia.Model.Model script "" [] Array.empty 0 mode 0 0 True


set_script : Model -> String -> Model
set_script model script =
    { model | script = script }


init_plain : String -> Model
init_plain =
    init Lia.Type.Plain


init_slides : String -> Model
init_slides =
    init Lia.Type.Slides


parse : Model -> Model
parse model =
    case Lia.Parser.run model.script of
        Ok lia ->
            { model | lia = lia, error = "", quiz = Lia.Helper.quiz_matrix lia }

        Err msg ->
            { model | error = msg }


view : Model -> Html Msg
view model =
    Lia.View.view model


update : Msg -> Model -> ( Model, Cmd Msg )
update =
    Lia.Update.update


switch_mode : Mode -> Model -> Model
switch_mode mode model =
    { model | mode = mode }


plain_mode : Model -> Model
plain_mode =
    switch_mode Lia.Type.Plain


slide_mode : Model -> Model
slide_mode =
    switch_mode Lia.Type.Slides
