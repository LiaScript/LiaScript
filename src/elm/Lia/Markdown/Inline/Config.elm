module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    )

import Html exposing (Html)
import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang)


type alias Config =
    { slide : Int
    , mode : Mode
    , visible : Int
    , speaking : Maybe Int
    , lang : Lang
    }


init : Int -> Mode -> Int -> Maybe Int -> Lang -> Config
init slide mode visible speaking lang =
    Config
        slide
        mode
        (if mode == Textbook then
            99999

         else
            visible
        )
        speaking
        lang
