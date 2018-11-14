module Lia exposing
    ( Mode
    , Model
    , Msg
    , get_title
    , init_presentation
    , init_slides
    , init_textbook
    , load_slide
    , plain_mode
    , set_script
    , slide_mode
    , subscriptions
    , switch_mode
    , update
    , view
    )

--import Lia.Preprocessor exposing (sections)

import Array
import Html exposing (Html)
import Json.Encode as JE
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Model exposing (json2settings, load_src, settings2model)
import Lia.Parser
import Lia.Types exposing (Section, Sections, init_section)
import Lia.Update exposing (Msg(..), maybe_event)
import Lia.Utils exposing (toUnixNewline)
import Lia.View
import Translations


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Update.Msg


type alias Mode =
    Lia.Types.Mode


load_slide : Model -> Int -> ( Model, Cmd Msg )
load_slide model idx =
    Lia.Update.update (Load idx False) model


set_script : Model -> String -> Model
set_script model script =
    case script |> toUnixNewline |> Lia.Parser.parse_defintion model.url of
        Ok ( code, definition ) ->
            case Lia.Parser.parse_titles definition code of
                Ok title_sections ->
                    let
                        ( _, link_logs ) =
                            load_src "link" [] definition.links

                        ( javascript, js_logs ) =
                            load_src "script" [] definition.scripts

                        sections =
                            title_sections
                                |> List.map init_section
                                |> Array.fromList

                        section_active =
                            if Array.length sections > model.section_active then
                                model.section_active

                            else
                                0
                    in
                    { model
                        | definition = { definition | scripts = [] }
                        , sections = sections
                        , section_active = section_active
                        , javascript = javascript
                        , translation = Translations.getLnFromCode definition.language
                        , to_do =
                            js_logs
                                |> List.append link_logs
                                |> (::) ( "init", section_active, JE.list [ JE.string <| get_title sections, JE.string model.readme ] )
                                |> List.reverse
                    }

                Err msg ->
                    { model | error = Just msg }

        Err msg ->
            { model | error = Just msg }


get_title : Sections -> String
get_title sections =
    sections
        |> Array.get 0
        |> Maybe.map .title
        |> Maybe.map stringify
        |> Maybe.withDefault "Lia Script"
        |> String.trim
        |> (++) "Lia: "


init_textbook : String -> String -> String -> Model
init_textbook url readme origin =
    Lia.Model.init Lia.Types.Textbook url readme origin Nothing


init_slides : String -> String -> String -> Maybe Int -> Model
init_slides url readme origin slide_number =
    Lia.Model.init Lia.Types.Slides url readme origin slide_number


init_presentation : String -> String -> String -> Maybe Int -> Model
init_presentation url readme origin slide_number =
    Lia.Model.init Lia.Types.Presentation url readme origin slide_number


view : Model -> Html Msg
view model =
    Lia.View.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Lia.Update.subscriptions model


update : Msg -> Model -> ( Model, Cmd Msg )
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
