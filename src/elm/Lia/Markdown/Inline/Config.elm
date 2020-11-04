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
    , theme : Maybe String
    , scripts : Scripts
    }


init :
    Int
    -> Mode
    -> Int
    -> Maybe Int
    -> Scripts
    -> Lang
    -> Maybe String
    -> Config
init slide mode visible speaking effects theme lang =
    Config
        slide
        (if mode == Textbook then
            Nothing

         else
            Just visible
        )
        speaking
        theme
        lang
        effects
