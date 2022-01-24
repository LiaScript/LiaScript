module Lia.Markdown.Config exposing
    ( Config
    , init
    , setSubViewer
    )

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


init : Lang -> ( String, String ) -> Settings -> Screen -> Section -> Int -> Dict String ( Int, Int ) -> Config sub
init lang translations settings screen section id media =
    let
        config =
            inline lang translations settings section.effect_model id media
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


inline : Lang -> ( String, String ) -> Settings -> Effect.Model SubSection -> Int -> Dict String ( Int, Int ) -> Inline.Config sub
inline lang translations settings effect id media =
    Inline.init
        { mode = settings.mode
        , visible = Just effect.visible
        , slide = id
        , speaking = effect.speaking
        , lang = lang
        , theme = Just settings.editor
        , light = settings.light
        , tooltips = settings.tooltips
        , media = media
        , scripts = effect.javascript
        , translations = Just translations
        }


setSubViewer : (Int -> SubSection -> List (Html (Script.Msg Msg))) -> Config Msg -> Config Msg
setSubViewer function config =
    { config
        | view =
            viewer (Inline.setViewer function config.main)
                >> List.map (Html.map Script)
    }
