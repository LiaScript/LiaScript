module Lia.Markdown.Config exposing
    ( Config
    , init
    , setSubViewer
    )

import Html exposing (Html)
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Inline.Config as Inline
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (Section, SubSection(..))
import Lia.Settings.Model exposing (Mode(..))
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


init : Mode -> Section -> Int -> String -> Lang -> Bool -> Screen -> Config sub
init mode section id ace_theme lang light screen =
    let
        config =
            inline mode section id ace_theme lang
    in
    Config
        mode
        (viewer config >> List.map (Html.map Script))
        section
        ace_theme
        light
        screen
        config


inline : Mode -> Section -> Int -> String -> Lang -> Inline.Config sub
inline mode section id ace_theme lang =
    Inline.init id
        mode
        section.effect_model.visible
        section.effect_model.speaking
        section.effect_model.javascript
        lang
        (Just ace_theme)


setSubViewer : (Int -> SubSection -> List (Html (Script.Msg Msg))) -> Config Msg -> Config Msg
setSubViewer function config =
    { config
        | view =
            viewer (Inline.setViewer function config.main)
                >> List.map (Html.map Script)
    }
