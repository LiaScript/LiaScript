module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    )

import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang)


type alias Config =
    { slide : Int
    , visible : Maybe Int
    , speaking : Maybe Int
    , lang : Lang
    , effects : Scripts
    }


init :
    Int
    -> Mode
    -> Int
    -> Maybe Int
    -> Scripts
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
