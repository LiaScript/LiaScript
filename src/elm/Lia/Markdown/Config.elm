module Lia.Markdown.Config exposing
    ( Config
    , init
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
import Lia.Settings.Types exposing (Mode, Settings)
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
    -> Section
    -> Int
    -> Dict String ( Int, Int )
    -> Config sub
init lang translations settings sync screen section id media =
    let
        config =
            inline lang translations settings screen section.effect_model id media sync
    in
    Config
        settings.mode
        (viewer config >> List.map (Html.map Script))
        section
        settings.editor
        settings.light
        (if settings.table_of_contents then
            { screen | width = screen.width - 260 }

         else
            screen
        )
        config


inline : Lang -> ( String, String ) -> Settings -> Screen -> Effect.Model SubSection -> Int -> Dict String ( Int, Int ) -> Sync.Settings -> Inline.Config sub
inline lang translations settings screen effect id media sync =
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
        }


setSubViewer : (Int -> SubSection -> List (Html (Script.Msg Msg))) -> Config Msg -> Config Msg
setSubViewer function config =
    { config
        | view =
            viewer (Inline.setViewer function config.main)
                >> List.map (Html.map Script)
    }
