module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    )

import Dict exposing (Dict)
import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang)


type alias Config =
    { slide : Int

    --, mode : Mode
    , visible : Maybe Int
    , speaking : Maybe Int
    , lang : Lang
    , effects : Dict Int (Result String String)
    }


init : Int -> Mode -> Int -> Maybe Int -> Dict Int (Result String String) -> Lang -> Config
init slide mode visible speaking effects lang =
    Config
        slide
        --mode
        (if mode == Textbook then
            Nothing

         else
            Just visible
        )
        speaking
        lang
        effects
