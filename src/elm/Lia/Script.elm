module Lia.Script exposing
    ( Model
    , Msg
    , add_imports
    , add_todos
    , handle
    , init
    , init_script
    , load_first_slide
    , load_slide
    , pages
    , parse_section
    , subscriptions
    , update
    , view
    )

import Array
import Html exposing (Html)
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition, add_macros)
import Lia.Json.Encode as Json
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Model exposing (load_src)
import Lia.Parser.Parser as Parser
import Lia.Section as Section exposing (Sections)
import Lia.Settings.Model exposing (Mode(..))
import Lia.Update exposing (Msg(..))
import Lia.View
import Port.Event exposing (Event)
import Session exposing (Screen, Session)
import Translations


type alias Model =
    Lia.Model.Model


type alias Msg =
    Lia.Update.Msg


pages : Model -> Int
pages =
    .sections >> Array.length


load_slide : Session -> Int -> Model -> ( Model, Cmd Msg, List Event )
load_slide session idx =
    Lia.Update.update session (Load idx)


load_first_slide : Session -> Model -> ( Model, Cmd Msg, List Event )
load_first_slide session model =
    load_slide
        session
        (if model.section_active >= pages model then
            pages model - 1

         else
            model.section_active
        )
        { model
            | title = get_title model.sections
            , search_index =
                model.sections
                    |> Array.map (.title >> stringify >> String.trim)
                    |> Array.toList
                    |> List.indexedMap generateIndex
                    |> searchIndex
            , to_do =
                (Json.encode model
                    |> Event "init" model.section_active
                )
                    :: model.to_do
        }


add_imports : Model -> String -> Model
add_imports model code =
    case Parser.parse_defintion model.url code of
        Ok ( definition, _ ) ->
            add_todos definition model

        Err _ ->
            model


handle : Event -> Msg
handle =
    Handle


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
        |> String.replace "-" " "
        |> String.split " "
        |> List.filter (String.isEmpty >> not)
        |> List.intersperse "-"
        |> String.concat
        |> (++) "#"
    , "#" ++ String.fromInt (id + 1)
    )


init_script : Model -> String -> ( Model, Maybe String, List String )
init_script model script =
    case Parser.parse_defintion model.origin script of
        Ok ( definition, code ) ->
            let
                settings =
                    model.settings
            in
            ( { model
                | definition = { definition | attributes = [] }
                , translation = Translations.getLnFromCode definition.language
                , settings =
                    { settings
                        | light =
                            definition.lightMode
                                |> Maybe.withDefault settings.light
                        , mode =
                            definition.mode
                                |> Maybe.withDefault settings.mode
                    }
              }
                |> add_todos definition
            , Just code
            , definition.imports
            )

        Err msg ->
            ( { model | error = Just msg }, Nothing, [] )


parse_section : Model -> String -> ( Model, Maybe String )
parse_section model code =
    case Parser.parse_titles model.definition code of
        Ok ( sec, rest ) ->
            ( { model
                | sections =
                    Array.push
                        (Section.init (pages model) sec)
                        model.sections
              }
            , if String.isEmpty rest then
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
        |> Maybe.map (stringify >> String.trim)
        |> Maybe.withDefault "Lia"


filterIndex : String -> ( String, String ) -> Bool
filterIndex str ( idx, _ ) =
    str == idx


searchIndex : List ( String, String ) -> String -> String
searchIndex index str =
    let
        fn =
            str
                |> String.toLower
                |> filterIndex
    in
    case index |> List.filter fn |> List.head of
        Just ( _, key ) ->
            key

        Nothing ->
            str


init : Int -> JE.Value -> String -> String -> String -> Maybe Int -> Model
init =
    Lia.Model.init


view : Screen -> Bool -> Bool -> Model -> Html Msg
view =
    Lia.View.view


subscriptions : Model -> Sub Msg
subscriptions =
    Lia.Update.subscriptions


update : Session -> Msg -> Model -> ( Model, Cmd Msg, List Event )
update =
    Lia.Update.update
