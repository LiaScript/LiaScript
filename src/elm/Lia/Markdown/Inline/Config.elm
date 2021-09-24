module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    , setViewer
    )

import Dict exposing (Dict)
import Html exposing (Html)
import Lia.Markdown.Effect.Script.Types exposing (Msg, Scripts)
import Lia.Section exposing (SubSection)
import Lia.Settings.Types exposing (Mode(..))
import Translations exposing (Lang)


type alias Config sub =
    { view : Maybe (Int -> SubSection -> List (Html (Msg sub)))
    , slide : Int
    , visible : Maybe Int
    , speaking : Maybe Int
    , lang : Lang
    , theme : Maybe String
    , media : Dict String ( Int, Int )
    , oEmbed : Maybe { maxwidth : Int, maxheight : Int, scale : Float, thumbnail : Bool }
    , scripts : Scripts SubSection
    , translations : Maybe ( String, String )
    }


init :
    Int
    -> Mode
    -> Int
    -> Maybe Int
    -> Scripts SubSection
    -> Lang
    -> Maybe String
    -> Maybe ( String, String )
    -> Dict String ( Int, Int )
    -> Config sub
init slide mode visible speaking effects theme lang translations media =
    Config
        Nothing
        slide
        (if mode == Textbook then
            Nothing

         else
            Just visible
        )
        speaking
        theme
        lang
        media
        Nothing
        effects
        translations


setViewer : (Int -> SubSection -> List (Html (Msg sub))) -> Config sub -> Config sub
setViewer fn config =
    { config | view = Just fn }
