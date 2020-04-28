module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    )

import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang)


type alias Config =
    { slide : Int

    --, mode : Mode
    , visible : Maybe Int
    , speaking : Maybe Int
    , lang : Lang
    }


init : Int -> Mode -> Int -> Maybe Int -> Lang -> Config
init slide mode visible speaking lang =
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
