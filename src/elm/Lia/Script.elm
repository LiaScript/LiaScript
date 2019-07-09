module Lia.Script exposing
    ( Model
    , Msg
    , add_imports
    , get_title
    , init_presentation
    , init_script
    , init_slides
    , init_textbook
    , load_first_slide
    , load_slide
    , pages
    , parse_section
    , plain_mode
    , slide_mode
    , subscriptions
    , switch_mode
    , update
    , view
    )

import Array
import Html exposing (Html)
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition, add_macros)
import Lia.Event.Base exposing (Event)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Model exposing (load_src)
import Lia.Parser.Parser as Parser
import Lia.Settings.Model exposing (Mode(..))
import Lia.Types exposing (Sections, init_section)
import Lia.Update exposing (Msg(..))
import Lia.View
import Translations


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Update.Msg


pages : Model -> Int
pages =
    .sections >> Array.length


load_slide : Int -> Model -> ( Model, Cmd Msg, Int )
load_slide idx =
    Lia.Update.update (Load idx)


load_first_slide : Model -> ( Model, Cmd Msg, Int )
load_first_slide model =
    load_slide
        (if model.section_active > pages model then
            0

         else
            model.section_active
        )
        { model
            | search_index =
                model.sections
                    |> Array.map (.title >> stringify >> String.trim)
                    |> Array.toList
                    |> List.indexedMap generateIndex
                    |> searchIndex
            , to_do =
                ([ get_title model.sections
                 , model.readme
                 , model.definition.version
                    |> String.split "."
                    |> List.head
                    |> Maybe.withDefault "0"
                    |> String.toInt
                    |> Maybe.withDefault 0
                    |> String.fromInt
                 , model.definition.onload
                 , model.definition.author
                 , model.definition.comment
                 , model.definition.logo
                 ]
                    |> JE.list JE.string
                    |> Event "init" model.section_active
                )
                    :: model.to_do
        }


add_imports : Model -> String -> Model
add_imports model course_url =
    case Parser.parse_defintion model.url course_url of
        Ok ( definition, _ ) ->
            add_todos definition model

        Err _ ->
            model


add_todos : Definition -> Model -> Model
add_todos definition model =
    let
        ( res, events ) =
            load_src model.resource definition.resources
    in
    { model
        | definition = add_macros model.definition definition
        , resource = res
        , to_do =
            events
                |> List.reverse
                |> List.append model.to_do
    }


generateIndex : Int -> String -> ( String, String )
generateIndex id title =
    ( title
        |> String.toLower
        |> String.replace " " "-"
        |> (++) "#"
    , "#" ++ String.fromInt (id + 1)
    )


init_script : Model -> String -> ( Model, Maybe ( String, Int ), List String )
init_script model script =
    case Parser.parse_defintion model.origin script of
        Ok ( definition, ( code, line ) ) ->
            ( { model
                | definition = { definition | resources = [], imports = [], attributes = [] }
                , translation = Translations.getLnFromCode definition.language
              }
                |> add_todos definition
            , Just ( code, line )
            , definition.imports
            )

        Err msg ->
            ( { model | error = Just msg }, Nothing, [] )


parse_section : Model -> ( String, Int ) -> ( Model, Maybe ( String, Int ) )
parse_section model ( code, line ) =
    case Parser.parse_titles line model.definition code of
        Ok ( sec, rest ) ->
            ( { model
                | sections =
                    Array.push
                        (init_section (pages model) sec)
                        model.sections
              }
            , if rest |> Tuple.first |> String.isEmpty then
                Nothing

              else
                Just rest
            )

        Err msg ->
            ( { model | error = Just msg }, Nothing )


get_title : Sections -> String
get_title sections =
    sections
        |> Array.get 0
        |> Maybe.map .title
        |> Maybe.map stringify
        |> Maybe.withDefault "Lia"
        |> String.trim
        |> (++) "Lia: "


filterIndex : String -> ( String, String ) -> Bool
filterIndex str ( key, _ ) =
    str == key


searchIndex : List ( String, String ) -> String -> String
searchIndex index str =
    let
        fn =
            str
                |> String.toLower
                |> filterIndex
    in
    case index |> List.filter fn |> List.head of
        Just ( _, val ) ->
            val

        Nothing ->
            str


init_textbook : String -> String -> String -> Maybe Int -> Model
init_textbook url readme origin slide_number =
    Lia.Model.init Textbook url readme origin slide_number


init_slides : String -> String -> String -> Maybe Int -> Model
init_slides url readme origin slide_number =
    Lia.Model.init Slides url readme origin slide_number


init_presentation : String -> String -> String -> Maybe Int -> Model
init_presentation url readme origin slide_number =
    Lia.Model.init Presentation url readme origin slide_number


view : Model -> Html Msg
view model =
    Lia.View.view model


subscriptions : Model -> Sub Msg
subscriptions model =
    Lia.Update.subscriptions model


update : Msg -> Model -> ( Model, Cmd Msg, Int )
update =
    Lia.Update.update


switch_mode : Mode -> Model -> Model
switch_mode mode model =
    let
        settings =
            model.settings
    in
    { model | settings = { settings | mode = mode } }


plain_mode : Model -> Model
plain_mode =
    switch_mode Textbook


slide_mode : Model -> Model
slide_mode =
    switch_mode Slides
