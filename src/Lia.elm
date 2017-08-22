module Lia exposing (..)

import Array
import Html exposing (Html)
import Lia.Effect.Model as Effect
import Lia.Index.Model as Index
import Lia.Model
import Lia.Parser
import Lia.Quiz.Model as Quiz
import Lia.Types
import Lia.Update
import Lia.View


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Update.Msg


type alias Mode =
    Lia.Types.Mode


init : Mode -> String -> Model
init mode script =
    parse <| Lia.Model.Model script "" [] Array.empty 0 mode (Effect.Model 0 0) True (Index.Model "" [] Nothing)


set_script : Model -> String -> Model
set_script model script =
    { model | script = script }


init_plain : String -> Model
init_plain =
    init Lia.Types.Plain


init_slides : String -> Model
init_slides =
    init Lia.Types.Slides


parse : Model -> Model
parse model =
    case Lia.Parser.run model.script of
        Ok slides ->
            { model
                | slides = slides
                , error = ""
                , quiz = Quiz.init slides
                , index = Index.init slides
            }

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
    switch_mode Lia.Types.Plain


slide_mode : Model -> Model
slide_mode =
    switch_mode Lia.Types.Slides
