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
import Lia.Types exposing (Slide)
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
    let
        ( code, definition ) =
            Lia.Parser.parse_defintion script
    in
    { model
        | definition = definition
        , slides =
            code
                |> Regex.split Regex.All (Regex.regex "\\n#")
                |> List.map init_slide
                |> Array.fromList
    }


init_slide : String -> Slide
init_slide code =
    let
        slide =
            { code = code
            , title = ""
            , indentation = -1
            , body = []
            , error = Nothing
            , effects = -1
            , speach = []
            }
    in
    case Lia.Parser.parse_title code of
        Ok ( ident, title, body ) ->
            { slide
                | code = body
                , title = title
                , indentation = ident
            }

        Err msg ->
            { slide | error = Just msg }


init_plain : Maybe String -> Model
init_plain uid =
    Lia.Model.init Lia.Types.Textbook uid


init_slides : Maybe String -> Model
init_slides uid =
    Lia.Model.init Lia.Types.Slides uid


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
