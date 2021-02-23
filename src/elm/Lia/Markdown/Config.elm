module Lia.Markdown.Config exposing
    ( Config
    , init
    , setSubViewer
    )

import Html exposing (Html)
import Lia.Markdown.Effect.Model as Effect
import Lia.Markdown.Effect.Script.Update as Script
import Lia.Markdown.Inline.Config as Inline
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (Section, SubSection(..))
import Lia.Settings.Types exposing (Mode(..), Settings)
import Session exposing (Screen)
import Translations exposing (Lang)


type alias Config sub =
    { mode : Mode
    , view : Inlines -> List (Html Msg)
    , section : Section
    , ace_theme : String
    , light : Bool
    , screen : Screen
    , translations : ( String, String )
    , main : Inline.Config sub
    }


init : Lang -> ( String, String ) -> Settings -> Screen -> Section -> Int -> Config sub
init lang translations settings screen section id =
    let
        config =
            inline lang settings section.effect_model id
    in
    Config
        settings.mode
        (viewer config >> List.map (Html.map Script))
        section
        settings.theme
        settings.light
        (if settings.table_of_contents then
            { screen | width = screen.width - 260 }

         else
            screen
        )
        translations
        config


inline : Lang -> Settings -> Effect.Model SubSection -> Int -> Inline.Config sub
inline lang settings effect id =
    Inline.init id
        settings.mode
        effect.visible
        effect.speaking
        effect.javascript
        lang
        (Just settings.theme)


setSubViewer : (Int -> SubSection -> List (Html (Script.Msg Msg))) -> Config Msg -> Config Msg
setSubViewer function config =
    { config
        | view =
            viewer (Inline.setViewer function config.main)
                >> List.map (Html.map Script)
    }
