module Lia.Markdown.Inline.Config exposing
    ( Config
    , init
    , setViewer
    )

import Array exposing (Array)
import Dict exposing (Dict)
import Html exposing (Html)
import I18n.Translations exposing (Lang)
import Lia.Markdown.Effect.Script.Types exposing (Msg, Scripts)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Quiz.Multi.Types as Input
import Lia.Section exposing (SubSection)
import Lia.Settings.Types exposing (Mode(..))
import Lia.Sync.Types as Sync


type alias Config sub =
    { view : Maybe (Int -> Int -> SubSection -> List (Html (Msg sub)))
    , oEmbed : Maybe { maxwidth : Int, maxheight : Int, scale : Float, thumbnail : Bool }
    , visible : Maybe Int
    , slide : Int
    , speaking : Maybe Int
    , lang : Lang
    , theme : Maybe String
    , light : Bool
    , tooltips : Bool
    , hideVideoComments : Bool
    , media : Dict String ( Int, Int )
    , scripts : Scripts SubSection
    , input :
        { state : Input.State
        , options : Array (List Inlines)
        , on : String -> Int -> String -> String
        , path : List ( String, Int )
        , active : Bool
        , partiallyCorrect : Array Bool
        }
    , translations : Maybe ( String, String )
    , formulas : Dict String String
    , sync : Maybe Sync.Settings
    }


init :
    { mode : Mode
    , visible : Maybe Int
    , slide : Int
    , speaking : Maybe Int
    , lang : Lang
    , theme : Maybe String
    , light : Bool
    , tooltips : Bool
    , hideVideoComments : Bool
    , media : Dict String ( Int, Int )
    , scripts : Scripts SubSection
    , translations : Maybe ( String, String )
    , formulas : Maybe (Dict String String)
    , sync : Maybe Sync.Settings
    }
    -> Config sub
init config =
    { view = Nothing
    , oEmbed = Nothing
    , visible =
        if config.mode == Textbook then
            Nothing

        else
            config.visible
    , slide = config.slide
    , speaking = config.speaking
    , lang = config.lang
    , theme = config.theme
    , light = config.light
    , tooltips = config.tooltips
    , hideVideoComments = config.hideVideoComments
    , media = config.media
    , scripts = config.scripts
    , input =
        { state = Array.empty
        , options = Array.empty
        , on = \_ _ _ -> ""
        , path = []
        , active = False
        , partiallyCorrect = Array.empty
        }
    , translations = config.translations
    , sync = config.sync
    , formulas =
        config.formulas
            |> Maybe.withDefault Dict.empty
    }


setViewer : (Int -> Int -> SubSection -> List (Html (Msg sub))) -> Config sub -> Config sub
setViewer fn config =
    { config | view = Just fn }
