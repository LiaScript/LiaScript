module Lia.Script exposing
    ( Model
    , Msg
    , add_imports
    , add_todos
    , getSectionNumberFrom
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

{-| This module defines the basic interface to LiaScript. In order to implement
parsing and interpreting LiaScript courses, this module contains all messages,
the Model, update and view functions.
-}

import Array
import Dict
import Html exposing (Html)
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition, add_macros)
import Lia.Json.Encode as Json
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (loadResource)
import Lia.Parser.Parser as Parser
import Lia.Section as Section exposing (Sections)
import Lia.Settings.Update as Settings
import Lia.Update exposing (Msg(..))
import Lia.View
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Session exposing (Screen, Session)
import Translations


{-| Alias for the model defined by `Lia.Model.Model`
-}
type alias Model =
    Lia.Model.Model


{-| Alias for the messages defined in `Lia.Update.Msg`
-}
type alias Msg =
    Lia.Update.Msg


{-| Return the number of sections
-}
pages : Model -> Int
pages =
    .sections >> Array.length


{-| Release a section load. To be used if the course has been already loaded. If
this is the first load, then some more initialization has to be done, so use
`load_first_slide` in this case.
-}
load_slide : Session -> Bool -> Int -> Model -> Return Model Msg Markdown.Msg
load_slide session force =
    Load force >> Lia.Update.update session


{-| To be called if the course is has been downloaded and preprocessed, and should
now be displayed for the first time. It determines the active section, creates
a `search_index` for local referenced links, and creates connector event, that
passes a preprocessed version of the course, to the cache used by the backend.
-}
load_first_slide : Session -> Model -> Return Model Msg Markdown.Msg
load_first_slide session model =
    let
        search_index =
            model.sections
                |> Array.map (.title >> stringify >> String.trim)
                |> Array.toList
                |> List.indexedMap generateIndex
                |> searchIndex

        slide =
            model.anchor
                |> Maybe.andThen (getSectionNumberFrom search_index)
                |> Maybe.withDefault model.section_active
    in
    load_slide
        session
        False
        (if slide >= pages model then
            pages model - 1

         else
            slide
        )
        { model
            | title = get_title model.sections
            , search_index = search_index
            , to_do =
                Service.Database.index_store model
                    :: Settings.customizeEvent model.settings
                    :: model.to_do
        }


{-| This function is used to analyse URL fragments based on a given
index-function. It the given String can be parsed as a number, this value is
returned (minus one), since url fragments start with 1. Otherwise, the section
number is determined by the order of the document (matching the section title):

    getSectionNumberFrom index "12" == Just 11

    getSectionNumberFrom index "0" == Nothing

    getSectionNumberFrom index "some-title" == Just 14

-}
getSectionNumberFrom : (String -> String) -> String -> Maybe Int
getSectionNumberFrom index fragment =
    let
        slide =
            case fragment |> String.toInt of
                Just number ->
                    number - 1

                Nothing ->
                    "#"
                        ++ fragment
                        |> index
                        |> String.dropLeft 1
                        |> String.toInt
                        |> Maybe.map ((+) -1)
                        |> Maybe.withDefault -1
    in
    if slide < 0 then
        Nothing

    else
        Just slide


{-| Parse the main definitions of Markdown document and add it to todos...
This is only used to add imports, which might require to load additional
resources and to add additional macros.
-}
add_imports : Model -> String -> Model
add_imports model code =
    case Parser.parse_definition model.url code of
        Ok ( definition, _ ) ->
            add_todos definition model

        Err _ ->
            model


{-| Convenience function for basic event routing. All events in all modules are
handled by a `Handle` message and this is simply a translation:

    handle
      { topic: "..."
      , section: 1
      , message: ...
      } -> Handle {topic: ...

-}
handle : Event -> Msg
handle =
    Handle


{-| Add parsed definitions from the main header of imports. This adds additional
resources to be loaded and merges the defined macros with those that are already
accessible.
-}
add_todos : Definition -> Model -> Model
add_todos definition model =
    let
        ( res, events ) =
            loadResource model.resource definition.resources
    in
    { model
        | definition = add_macros model.definition definition
        , resource = res
        , to_do =
            events
                |> List.reverse
                |> List.append model.to_do
    }


{-| **@private**: Process a title-string, so that it can be easily compared with
relative links. Incorporates string lowercase, replacement of " " by "-", etc.

    generateIndex 1 "The Main  Title" == ( "#the-main-title", "#2" )

-}
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


checkFalse : String -> Bool
checkFalse string =
    case string |> String.trim |> String.toLower |> String.toList of
        [ '0' ] ->
            False

        'f' :: 'a' :: 'l' :: 's' :: 'e' :: _ ->
            False

        'o' :: 'f' :: 'f' :: _ ->
            False

        'd' :: 'i' :: 's' :: 'a' :: 'b' :: 'l' :: 'e' :: _ ->
            False

        _ ->
            True


{-| Initialize a LiaScript Model with the code of a course. The header of this
course is parsed as a definition, that contains `@authors`, `@import`, etc. The
result is a:

1.  `Model` that is pre-configured
2.  `String` that only contains the document code without header definitions
3.  `List String` of templates that have to be downloaded and parsed

**Note:** This function is intended to be used to initialize sequential parsing,
thus one section at a time. After the model has been initialized the function
`parse_section` should be called.

-}
init_script : Model -> String -> ( Model, Maybe String, List String )
init_script model script =
    case Parser.parse_definition model.origin script of
        Ok ( definition, code ) ->
            let
                settings =
                    model.settings
            in
            ( { model
                | definition = { definition | attributes = [] }
                , translation =
                    definition.language
                        |> Translations.getLnFromCode
                        |> Maybe.withDefault Translations.En
                , langCode = definition.language
                , langCodeOriginal = definition.language
                , settings =
                    { settings
                        | light =
                            definition.lightMode
                                |> Maybe.withDefault settings.light
                        , mode =
                            definition.mode
                                |> Maybe.withDefault settings.mode
                        , customTheme = Dict.get "custom" definition.macro
                        , translateWithGoogle =
                            case
                                definition.macro
                                    |> Dict.get "translateWithGoogle"
                                    |> Maybe.map checkFalse
                            of
                                Just False ->
                                    Nothing

                                _ ->
                                    settings.translateWithGoogle
                        , hasShareApi =
                            case
                                definition.macro
                                    |> Dict.get "sharing"
                                    |> Maybe.map checkFalse
                            of
                                Just False ->
                                    Nothing

                                _ ->
                                    settings.hasShareApi
                    }
              }
                |> add_todos definition
            , Just code
            , definition.imports
            )

        Err msg ->
            ( { model | error = Just msg }, Nothing, [] )


{-| Successively parse section after section. Every time this function is
called a new section is added to the section array in the model and the
remainder of the code gets returned. If there is no more code to parse,
`Nothing` gets returned.

This successive pre-parsing is intended to minimize blocking time, since parsing
very large documents might take some time. Parsing this it is possible to
present some progress to the user as well as do other stuff in the background.

-}
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


{-| Get a stringified version of the first title:

    `# **Main Title**` -> "Main Title"

-}
get_title : Sections -> String
get_title =
    Array.get 0
        >> Maybe.map (.title >> stringify >> String.trim)
        >> Maybe.withDefault "Lia"


{-| **@private:** Used by the index-title search to identify the section number
that matches the relative Markdown link.
-}
filterIndex : String -> ( String, String ) -> Bool
filterIndex str ( idx, _ ) =
    str == idx


{-| **@private:** Search the index on titles for matching relative links.
-}
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


{-| Alias for model initialization defined by `Lia.Model.int`
-}
init : Bool -> Bool -> JE.Value -> List String -> String -> String -> String -> Maybe String -> Model
init =
    Lia.Model.init


{-| Alias for global LiaScript view defined in `Lia.View.view`
-}
view : Screen -> Bool -> Model -> Html Msg
view =
    Lia.View.view


{-| Alias LiaScript subscriptions defined by `Lia.Update.subscriptions`
-}
subscriptions : Model -> Sub Msg
subscriptions =
    Lia.Update.subscriptions


{-| Alias for LiaScript update `Lia.Update.update`
-}
update : Session -> Msg -> Model -> Return Model Msg Markdown.Msg
update =
    Lia.Update.update
