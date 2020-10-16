module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    )

import Array exposing (Array)
import Lia.Markdown.Effect.JavaScript exposing (JavaScript)
import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang)


type alias Config =
    { slide : Int
    , visible : Maybe Int
    , speaking : Maybe Int
    , lang : Lang
    , effects : Array JavaScript
    }


init :
    Int
    -> Mode
    -> Int
    -> Maybe Int
    -> Array JavaScript
    -> Lang
    -> Config
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
