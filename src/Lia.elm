module Lia exposing (..)

import Array
import Html exposing (Html)
import Json.Encode as JE
import Lia.Effect.Model as Effect
import Lia.Helper exposing (get_slide)
import Lia.Index.Model as Index
import Lia.Model
import Lia.Parser
import Lia.Quiz.Model as Quiz
import Lia.Survey.Model as Survey
import Lia.Types
import Lia.Update
import Lia.Utils exposing (get_local, load_js, set_local)
import Lia.View


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Update.Msg


type alias Mode =
    Lia.Types.Mode


init : Mode -> Maybe String -> Model
init mode uid =
    let
        local_theme =
            "theme"
                |> get_local
                |> Maybe.withDefault "default"

        local_light =
            case get_local "theme_light" of
                Just "off" ->
                    False

                _ ->
                    True

        local_silent =
            case get_local "silent" of
                Just "false" ->
                    False

                _ ->
                    True

        local_mode =
            case get_local "mode" of
                Just "Slides" ->
                    Lia.Types.Slides

                Just "Slides_only" ->
                    Lia.Types.Slides_only

                _ ->
                    mode

        local_slide =
            uid
                |> Maybe.andThen get_local
                |> Maybe.andThen
                    (\slide ->
                        case String.toInt slide of
                            Ok i ->
                                Just i

                            Err _ ->
                                Just 0
                    )
                |> Maybe.withDefault 0
    in
    { uid = uid
    , script = ""
    , error = ""
    , mode = local_mode
    , slides = []
    , current_slide = local_slide
    , show_contents = True
    , quiz_model = Array.empty
    , code_model = Array.empty
    , survey_model = Array.empty
    , index_model = Index.init []
    , effect_model = Effect.init "US English Male" Nothing
    , narrator = "US English Male"
    , silent = local_silent
    , theme = local_theme
    , theme_light = local_light
    }


set_script : Model -> String -> Model
set_script model script =
    { model | script = script }


init_plain : Maybe String -> Model
init_plain uid =
    init Lia.Types.Textbook uid


init_slides : Maybe String -> Model
init_slides uid =
    init Lia.Types.Slides uid


parse : String -> Model -> Model
parse script model =
    case Lia.Parser.run script of
        Ok ( slides, code_vector, quiz_vector, survey_vector, narrator, scripts ) ->
            let
                x =
                    scripts
                        |> List.reverse
                        |> List.map load_js
            in
            { model
                | slides = slides
                , error = ""
                , quiz_model =
                    if Array.isEmpty model.quiz_model then
                        quiz_vector
                    else
                        model.quiz_model
                , index_model = Index.init slides
                , effect_model =
                    Effect.init narrator <|
                        case get_slide model.current_slide slides of
                            Just slide ->
                                Just slide

                            _ ->
                                List.head slides
                , code_model = code_vector
                , survey_model =
                    if Array.isEmpty model.survey_model then
                        survey_vector
                    else
                        model.survey_model
                , narrator =
                    if narrator == "" then
                        "US English Male"
                    else
                        narrator
                , script = script
            }

        Err msg ->
            { model | error = msg, script = script }


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
    switch_mode Lia.Types.Textbook


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
