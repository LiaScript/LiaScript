module Lia.Markdown.Config exposing
    ( Config
    , init
    , setID
    , setMain
    , setSubViewer
    )

import Const
import Dict exposing (Dict)
import Html exposing (Html)
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Inline.Config as Inline
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (Section, SubSection(..))
import Lia.Settings.Types exposing (Mode(..), Settings)
import Lia.Sync.Types as Sync
import Session exposing (Screen)
import Translations exposing (Lang)


type alias Config sub =
    { mode : Mode
    , view : Inlines -> List (Html Msg)
    , section : Section
    , ace_theme : String
    , light : Bool
    , screen : Screen
    , main : Inline.Config sub
    }


init :
    Lang
    -> ( String, String )
    -> Settings
    -> Sync.Settings
    -> Screen
    -> Int
    -> Maybe (Dict String String)
    -> Dict String ( Int, Int )
    -> Section
    -> Config sub
init lang translations settings sync screen id formula media section =
    let
        main =
            inline lang
                translations
                settings
                screen
                section.effect_model
                id
                (section.definition
                    |> Maybe.map .formulas
                    |> mergeFormulas formula
                )
                media
                sync
    in
    Config
        settings.mode
        (viewer main >> List.map (Html.map Script))
        section
        settings.editor
        settings.light
        (if settings.table_of_contents then
            { screen | width = screen.width - 260 }

         else
            screen
        )
        main



--setMain : Inline.Config sub -> Config sub -> Config sub


setMain main config =
    { config
        | main = main
        , view = viewer main >> List.map (Html.map Script)
    }


setID : Int -> Config sub -> Config sub
setID id config =
    let
        section =
            config.section

        main =
            config.main
    in
    { config
        | section = { section | id = id }
        , main = { main | slide = id }
        , mode = Textbook
    }


mergeFormulas : Maybe (Dict String String) -> Maybe (Dict String String) -> Maybe (Dict String String)
mergeFormulas main sec =
    case ( main, sec ) of
        ( Just _, Nothing ) ->
            main

        ( Just m, Just s ) ->
            Just <| Dict.union m s

        ( Nothing, Just _ ) ->
            sec

        _ ->
            Nothing


inline :
    Lang
    -> ( String, String )
    -> Settings
    -> Screen
    -> Effect.Model SubSection
    -> Int
    -> Maybe (Dict String String)
    -> Dict String ( Int, Int )
    -> Sync.Settings
    -> Inline.Config sub
inline lang translations settings screen effect id formulas media sync =
    Inline.init
        { mode = settings.mode
        , visible = Just effect.visible
        , slide = id
        , speaking = effect.speaking
        , lang = lang
        , theme = Just settings.editor
        , light = settings.light
        , tooltips = settings.tooltips && (screen.width >= Const.tooltipBreakpoint)
        , media = media
        , scripts = effect.javascript
        , translations = Just translations
        , sync = Just sync
        , formulas = formulas
        }


setSubViewer : (Int -> SubSection -> List (Html (Script.Msg Msg))) -> Config Msg -> Config Msg
setSubViewer function config =
    { config
        | view =
            viewer (Inline.setViewer function config.main)
                >> List.map (Html.map Script)
    }
