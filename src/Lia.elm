module Lia exposing (..)

import Array
import Html exposing (Html)
import Json.Encode as JE
import Lia.Effect.Model as Effect
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Model
import Lia.Parser
import Lia.Types exposing (Section, Sections)
import Lia.Update exposing (Msg(..))
import Lia.Utils exposing (load_js)
import Lia.View


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
            let
                x =
                    definition
                        |> .scripts
                        |> List.reverse
                        |> List.map load_js
            in
            case Lia.Parser.parse_titles definition code of
                Ok title_sections ->
                    { model
                        | definition = definition
                        , sections =
                            title_sections
                                |> List.map init_section
                                |> Array.fromList
                    }

                Err msg ->
                    { model | error = Just msg }

        Err msg ->
            { model | error = Just msg }


init_section : ( Int, Inlines, String ) -> Section
init_section ( tags, title, code ) =
    { code = code
    , title = title
    , visited = False
    , indentation = tags
    , body = []
    , error = Nothing
    , code_vector = Array.empty
    , quiz_vector = Array.empty
    , survey_vector = Array.empty
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


view : Model -> Html Msg
view model =
    Lia.View.view model


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ( String, JE.Value ) )
update =
    Lia.Update.update


init : Model -> ( Model, Cmd Msg, Maybe ( String, JE.Value ) )
init model =
    Lia.Update.update (Load model.section_active) model


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
