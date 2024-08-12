module Lia.Settings.Types exposing
    ( Action(..)
    , Audio(..)
    , Mode(..)
    , Settings
    , TTS
    , fromGroup
    , init
    , toGroup
    )

import Translations exposing (Lang(..))


type alias Settings =
    { table_of_contents : Bool
    , support_menu : Bool
    , mode : Mode
    , theme : String
    , light : Bool
    , editor : String
    , font_size : Int
    , sound : Bool
    , lang : String
    , action : Maybe Action
    , speaking : Bool
    , initialized : Bool
    , hasShareApi : Maybe Bool
    , translateWithGoogle : Maybe Bool
    , customTheme : Maybe String
    , tooltips : Bool
    , hideVideoComments : Bool
    , sync : Maybe Bool
    , showQRCode : Bool
    , tts : TTS
    , chat : { show : Bool, updates : Bool }
    , audio : { pitch : String, rate : String }
    }


type alias TTS =
    { preferBrowser : Bool
    , isBrowserSupported : Bool
    , isResponsiveVoiceSupported : Bool
    }


type Action
    = ShowInformation
    | ShowTranslations
    | ShowSettings
    | ShowModes
    | ShowShare
    | Close


type Mode
    = Slides -- Underline Comments and Effects
    | Presentation -- Only effects
    | Textbook -- Render Comments and Effects at ones


type Audio
    = Pitch String
    | Rate String


init : Bool -> Mode -> Settings
init hasShareApi mode =
    { table_of_contents = True
    , support_menu = False
    , mode = mode
    , theme = "default"
    , light = True
    , editor = "dreamweaver"
    , font_size = 100
    , sound = True
    , lang = "default"
    , action = Nothing
    , speaking = False
    , initialized = False
    , hasShareApi = Just hasShareApi
    , translateWithGoogle = Just False
    , customTheme = Nothing
    , tooltips = False
    , hideVideoComments = False
    , sync = Just False
    , showQRCode = False
    , tts =
        { preferBrowser = False
        , isBrowserSupported = False
        , isResponsiveVoiceSupported = False
        }
    , chat =
        { show = False
        , updates = False
        }
    , audio = { pitch = "1", rate = "1" }
    }


toGroup : String -> Maybe Action
toGroup str =
    case str of
        "information" ->
            Just ShowInformation

        "mode" ->
            Just ShowModes

        "setting" ->
            Just ShowSettings

        "translation" ->
            Just ShowTranslations

        "share" ->
            Just ShowShare

        _ ->
            Nothing


fromGroup : Action -> String
fromGroup grp =
    case grp of
        ShowSettings ->
            "setting"

        ShowTranslations ->
            "translation"

        ShowInformation ->
            "information"

        ShowModes ->
            "mode"

        ShowShare ->
            "share"

        Close ->
            "close"
