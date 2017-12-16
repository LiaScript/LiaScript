module Lia exposing (..)

--import Lia.Helper exposing (get_slide)

import Array
import Debug
import Html exposing (Html)
import Json.Encode as JE
import Lia.Effect.Model as Effect
import Lia.Index.Model as Index
import Lia.Model
import Lia.Parser
import Lia.Preprocessor
import Lia.Quiz.Model as Quiz
import Lia.Survey.Model as Survey
import Lia.Types exposing (Section, Sections)
import Lia.Update
import Lia.View
import Regex


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Update.Msg


type alias Mode =
    Lia.Types.Mode


set_script : Model -> String -> Model
set_script model script =
    case Lia.Parser.parse_defintion script of
        Ok ( code, definition ) ->
            case Lia.Parser.parse_titles code of
                Ok title_sections ->
                    { model
                        | definition = definition
                        , sections =
                            title_sections
                                |> List.map init_section
                                |> Array.fromList
                    }
                        |> Lia.Update.generate

                Err msg ->
                    { model | error = Just msg }

        Err msg ->
            { model | error = Just msg }


init_section : ( Int, String, String ) -> Section
init_section ( tags, title, code ) =
    { code = code
    , title = title
    , indentation = tags
    , body = []
    , error = Nothing
    , effects = 0
    , speach = []
    , code_vector = Array.empty
    , effect_model = Effect.init
    }


init_textbook : Maybe String -> Model
init_textbook uid =
    Lia.Model.init Lia.Types.Textbook uid


init_slides : Maybe String -> Model
init_slides uid =
    Lia.Model.init Lia.Types.Slides uid


init_presentation : Maybe String -> Model
init_presentation uid =
    Lia.Model.init Lia.Types.Presentation uid


parse : String -> Model -> Model
parse script model =
    model



-- case Lia.Parser.run script of
--     Ok ( slides, code_vector, quiz_vector, survey_vector, narrator, scripts ) ->
--         let
--             x =
--                 scripts
--                     |> List.reverse
--                     |> List.map load_js
--         in
--         { model
--             | slides = slides
--             , error = ""
--             , quiz_model =
--                 if Array.isEmpty model.quiz_model then
--                     quiz_vector
--                 else
--                     model.quiz_model
--             , index_model = Index.init slides
--             , effect_model =
--                 Effect.init narrator <|
--                     case get_slide model.current_slide slides of
--                         Just slide ->
--                             Just slide
--
--                         _ ->
--                             List.head slides
--             , code_model = code_vector
--             , survey_model =
--                 if Array.isEmpty model.survey_model then
--                     survey_vector
--                 else
--                     model.survey_model
--             , narrator =
--                 if narrator == "" then
--                     "US English Male"
--                 else
--                     narrator
--             , script = script
--         }
--
--     Err msg ->
--         { model | error = msg, script = script }


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
    model



-- case what of
--     "quiz" ->
--         case Quiz.json2model json of
--             Ok quiz_model ->
--                 { model | quiz_model = quiz_model }
--
--             _ ->
--                 model
--
--     "survey" ->
--         case Survey.json2model json of
--             Ok survey_model ->
--                 { model | survey_model = survey_model }
--
--             _ ->
--                 model
--
--     _ ->
--         model
