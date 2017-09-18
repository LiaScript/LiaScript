module Lia exposing (..)

import Array
import Html exposing (Html)
import Json.Encode as JE
import Lia.Code.Model as Code
import Lia.Effect.Model as Effect
import Lia.Index.Model as Index
import Lia.Model
import Lia.Parser
import Lia.Quiz.Model as Quiz
import Lia.Survey.Model as Survey
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
    parse <|
        { script = ""
        , error = ""
        , mode = mode
        , slides = []
        , current_slide = 0
        , show_contents = True
        , quiz_model = Array.empty
        , code_model = Array.empty
        , survey_model = Array.empty
        , index_model = Index.init []
        , effect_model = Effect.init "US English Male" Nothing
        , narator = "US English Male"
        }


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
        Ok ( slides, codes, quiz_vector, survey_vector, narator ) ->
            { model
                | slides = slides
                , error = ""
                , quiz_model =
                    if model.quiz_model == Array.empty then
                        quiz_vector
                    else
                        model.quiz_model
                , index_model = Index.init slides
                , effect_model = Effect.init narator <| List.head slides
                , code_model = Code.init codes
                , survey_model =
                    if model.survey_model == Array.empty then
                        survey_vector
                    else
                        model.survey_model
                , narator =
                    if narator == "" then
                        "US English Male"
                    else
                        narator
            }

        Err msg ->
            { model | error = msg }


view : Model -> Html Msg
view model =
    Lia.View.view model


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ( String, JE.Value ) )
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


restore : Model -> ( String, JE.Value ) -> Model
restore model ( what, json ) =
    case what of
        "quiz" ->
            case Quiz.json2model json of
                Ok quiz_model ->
                    { model | quiz_model = quiz_model }

                _ ->
                    model

        "survey" ->
            case Survey.json2model json of
                Ok survey_model ->
                    { model | survey_model = survey_model }

                _ ->
                    model

        _ ->
            model
