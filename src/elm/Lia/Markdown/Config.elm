module Lia.Markdown.Config exposing (Config, init)

import Html exposing (Html)
import Lia.Markdown.Inline.Config as Inline
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (Section)
import Lia.Settings.Model exposing (Mode(..))
import Session exposing (Screen)
import Translations exposing (Lang)


type alias Config =
    { view : Inlines -> List (Html Msg)
    , section : Section
    , ace_theme : String
    , light : Bool
    , screen : Screen
    , main : Inline.Config
    }


init : Mode -> Section -> Int -> String -> Lang -> Bool -> Screen -> Config
init mode section id ace_theme lang light screen =
    let
        config =
            Inline.init id
                mode
                section.effect_model.visible
                section.effect_model.speaking
                section.effect_model.javascript
                lang
    in
    Config
        (viewer config >> List.map (Html.map Script))
        section
        ace_theme
        light
        screen
        config
