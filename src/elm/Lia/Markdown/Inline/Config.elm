module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    , setViewer
    )

import Html exposing (Html)
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.Effect.Script.Update exposing (Msg)
import Lia.Section exposing (SubSection)
import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang)


type alias Config sub =
    { view : Maybe (Int -> SubSection -> List (Html (Msg sub)))
    , slide : Int
    , visible : Maybe Int
    , speaking : Maybe Int
    , lang : Lang
    , theme : Maybe String
    , scripts : Scripts SubSection
    }


init :
    Int
    -> Mode
    -> Int
    -> Maybe Int
    -> Scripts SubSection
    -> Lang
    -> Maybe String
    -> Config sub
init slide mode visible speaking effects theme lang =
    Config
        Nothing
        slide
        (if mode == Textbook || mode == Newspaper then
            Nothing

         else
            Just visible
        )
        speaking
        theme
        lang
        effects


setViewer : (Int -> SubSection -> List (Html (Msg sub))) -> Config sub -> Config sub
setViewer fn config =
    { config | view = Just fn }
