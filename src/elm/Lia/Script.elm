module Lia.Script exposing
    ( Model
    , Msg
    , add_imports
    , add_todos
    , applyDefinitionSettings
    , backup
    , getSectionNumberFrom
    , handle
    , init
    , init_script
    , load_first_slide
    , load_slide
    , pages
    , parse_section
    , skip_to_main_content
    , subscriptions
    , update
    , view
    )

{-| This module defines the basic interface to LiaScript. In order to implement
parsing and interpreting LiaScript courses, this module contains all messages,
the Model, update and view functions.
-}

--import Lia.Section as Section exposing (Sections)
--import Lia.Settings.Types exposing (Settings)

import Array
import Dict
import Html exposing (Html)
import I18n.Translations as Translations
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition, add_macros)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Update as Markdown
import Lia.Model exposing (getTitle, loadResource)
import Lia.Parser.Parser as Parser
import Lia.Parser.PatReplace exposing (resourceOrigin)
import Lia.Section as Section exposing (Section, Sections)
import Lia.Settings.Types exposing (Mode(..), Settings)
import Lia.Settings.Update as Settings
import Lia.Update exposing (Msg(..))
import Lia.Utils exposing (checkFalse, checkPersistency, urlQuery)
import Lia.View
import Return exposing (Return)
import Service.Database
import Service.Event as Event exposing (Event)
import Service.Resource
import Service.Sync
import Session exposing (Screen, Session)
import Url


{-| Alias for the model defined by `Lia.Model.Model`
-}
type alias Model =
    Lia.Model.Model


{-| Alias for the messages defined in `Lia.Update.Msg`
-}
type alias Msg =
    Lia.Update.Msg


backup : Model -> Model
backup model =
    { model
        | backup =
            model.sections
                |> Array.map entry
                >> Array.toList
                >> Dict.fromList
        , sections = Array.empty
    }


entry : Section -> ( String, String )
entry sec =
    ( stringify sec.title, sec.code )


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


{-| Used by the "skip navigation" link: close the table of contents on small
screens and move the focus to the current slide.
-}
skip_to_main_content : Session -> Model -> Return Model Msg Markdown.Msg
skip_to_main_content session =
    Lia.Update.update session Focus


{-| To be called if the course is has been downloaded and preprocessed, and should
now be displayed for the first time. It determines the active section, creates
a `search_index` for local referenced links, and creates connector event, that
passes a preprocessed version of the course, to the cache used by the backend.
-}
load_first_slide : Session -> Model -> Return Model Msg Markdown.Msg
load_first_slide session model =
    let
        search_index =
            searchIndex model.sections
    in
    load_slide
        session
        False
        (model.anchor
            |> Maybe.andThen (getSectionNumberFrom search_index)
            |> Maybe.withDefault model.section_active
            |> min (pages model - 1)
        )
        { model
            | title = getTitle model.sections
            , search_index = search_index
            , to_do =
                Service.Database.index_store model
                    :: Settings.customizeEvent model.settings
                    :: (if model.sync.fromUrl && not (String.isEmpty model.readme) then
                            -- the saved classrooms are otherwise only listed
                            -- when the dialog gets opened by hand, but a room
                            -- from the URL needs them to find its local cache,
                            -- see `Lia.Sync.Types.restoreSaved`
                            Service.Sync.listClassrooms model.readme
                                |> Event.push "sync"
                                |> (\event -> event :: model.to_do)

                        else
                            model.to_do
                       )
            , persistent =
                checkPersistency model.definition.macro
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
    (case String.toInt fragment of
        Just number ->
            Just number

        Nothing ->
            ("#" ++ fragment)
                |> index
                |> String.dropLeft 1
                |> String.toInt
    )
        |> Maybe.map (\number -> number - 1)
        |> Maybe.andThen
            (\slide ->
                if slide < 0 then
                    Nothing

                else
                    Just slide
            )


{-| Parse the main definitions of Markdown document and add it to todos...
This is only used to add imports, which might require to load additional
resources and to add additional macros.
-}
add_imports : { model : Model, base : String } -> String -> Model
add_imports { model, base } code =
    case Parser.parse_definition (resourceOrigin base) (base |> urlQuery |> Maybe.withDefault "") code of
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
init_script :
    Model
    -> String
    ->
        { model : Model
        , code : Maybe ( String, Int )
        , templates : List String
        , event : Maybe Event
        }
init_script model script =
    case
        Parser.parse_definition model.origin
            (model.readme
                |> urlQuery
                |> Maybe.withDefault ""
            )
            script
    of
        Ok ( definition, ( code, line ) ) ->
            { model =
                { model
                    | definition = { definition | attributes = [] }
                    , translation =
                        definition.language
                            |> Translations.getLnFromCode
                            |> Maybe.withDefault Translations.En
                    , langCode = definition.language
                    , langCodeOriginal = definition.language
                    , persistent = checkPersistency definition.macro
                    , settings = applyDefinitionSettings model.readme definition model.settings
                }
                    |> add_todos definition
            , code = Just ( code, line )
            , templates = definition.imports
            , event =
                definition.macro
                    |> Dict.get "style"
                    |> Maybe.map Service.Resource.style
            }

        Err msg ->
            { model = { model | error = Just msg }
            , code = Nothing
            , templates = []
            , event = Nothing
            }


{-| Derive all settings that are controlled by the course header/macros (e.g.
`edit`, `translateWithGoogle`, `sharing`, `classroom`, `custom`, light/dark
mode) from a parsed `Definition`. This has to be re-applied any time a
`Definition` is (re-)established for a course, whether via a fresh parse
(`init_script`) or via restoring a previously cached course from the
database (`index_restore`), since these settings are never themselves
persisted/cached.
-}
applyDefinitionSettings : String -> Definition -> Settings -> Settings
applyDefinitionSettings readme definition settings =
    let
        -- a feature can only be switched off by the macro `key: false`
        unlessDisabled key value =
            if Maybe.map checkFalse (Dict.get key definition.macro) == Just False then
                Nothing

            else
                value
    in
    { settings
        | light = Maybe.withDefault settings.light definition.lightMode
        , mode = Maybe.withDefault settings.mode definition.mode
        , customTheme = Dict.get "custom" definition.macro
        , translateWithGoogle = unlessDisabled "translateWithGoogle" settings.translateWithGoogle
        , hasShareApi = unlessDisabled "sharing" settings.hasShareApi
        , sync = unlessDisabled "classroom" settings.sync
        , edit =
            case Dict.get "edit" definition.macro of
                Just "true" ->
                    Just ("https://liascript.github.io/LiveEditor/?/show/file/" ++ readme)

                Just "on" ->
                    Just ("https://liascript.github.io/LiveEditor/?/show/file/" ++ readme)

                Just "false" ->
                    Nothing

                Just "off" ->
                    Nothing

                url ->
                    url
    }


{-| Successively parse section after section. Every time this function is
called a new section is added to the section array in the model and the
remainder of the code gets returned. If there is no more code to parse,
`Nothing` gets returned.

This successive pre-parsing is intended to minimize blocking time, since parsing
very large documents might take some time. Parsing this it is possible to
present some progress to the user as well as do other stuff in the background.

-}
parse_section : Model -> ( String, Int ) -> ( Model, Maybe ( String, Int ) )
parse_section model ( code, line ) =
    case Parser.parse_titles line model.backup model.definition code of
        Ok ( sec, rest ) ->
            ( { model | sections = Array.push (Section.init model.seed (pages model) sec) model.sections }
            , if rest |> Tuple.first |> String.isEmpty then
                Nothing

              else
                Just rest
            )

        Err msg ->
            ( { model | error = Just msg }, Nothing )


{-| **@private:** Map relative links to section titles `#the-main-title` onto
section numbers `#2`, other strings are returned unchanged. Links are percent
decoded and compared in lowercase, titles become lowercase slugs, where spaces
and hyphens are merged into one hyphen. If titles are equal, the first section
wins.

    searchIndex sections "#The-Main%20%20Title" == "#2"

-}
searchIndex : Sections -> String -> String
searchIndex sections =
    let
        index =
            sections
                |> Array.toIndexedList
                |> List.foldr
                    (\( id, sec ) ->
                        Dict.insert
                            (sec.title
                                |> stringify
                                |> String.trim
                                |> String.toLower
                                |> String.replace "-" " "
                                |> String.split " "
                                |> List.filter (String.isEmpty >> not)
                                |> String.join "-"
                                |> (++) "#"
                            )
                            ("#" ++ String.fromInt (id + 1))
                    )
                    Dict.empty
    in
    \str ->
        index
            |> Dict.get
                (str
                    |> Url.percentDecode
                    |> Maybe.withDefault str
                    |> String.toLower
                )
            |> Maybe.withDefault str


{-| Alias for model initialization defined by `Lia.Model.init`
-}
init :
    { seed : Int
    , hasShareApi : Maybe Bool
    , openTOC : Bool
    , isFullscreen : Bool
    , settings : JE.Value
    , backends : { support : List String, enabled : Bool }
    , url : String
    , readme : String
    , origin : String
    , anchor : Maybe String
    }
    -> Model
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
