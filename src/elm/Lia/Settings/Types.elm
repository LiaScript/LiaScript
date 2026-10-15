module Lia.Settings.Types exposing
    ( Action(..)
    , Audio(..)
    , Mode(..)
    , PlaybackState(..)
    , Settings
    , TTS
    , fromGroup
    , init
    , submenuID
    , toGroup
    , toggleID
    )

{-| The user settings of LiaScript and the state of the menus and the TTS
output.
-}


{-| The state of the narrator, the progress is only known for recordings and
browser voices.
-}
type PlaybackState
    = Idle
    | Speaking
    | Paused
    | SpeakingWithProgress { current : Float, total : Float }
    | PausedWithProgress { current : Float, total : Float }
    | SeekingFromPlaying { current : Float, total : Float }
    | SeekingFromPaused { current : Float, total : Float }


{-| -}
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
    , playback : PlaybackState
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
    , fullscreen : Bool
    , edit : Maybe String
    }


{-| -}
type alias TTS =
    { preferBrowser : Bool
    , isBrowserSupported : Bool
    , isResponsiveVoiceSupported : Bool

    -- tag name of a custom element registered by a template, that is shown
    -- as the narrator avatar for comments without a video recording
    , avatar : Maybe String
    }


{-| The menu that is open.
-}
type Action
    = ShowInformation
    | ShowTranslations
    | ShowSettings
    | ShowModes
    | ShowShare
    | Close


{-| The id of the toolbar button, which opens and closes the submenu of an
action.
-}
toggleID : Action -> String
toggleID action =
    case action of
        ShowModes ->
            "lia-mode-menu-button"

        _ ->
            "lia-btn-" ++ actionName action


{-| The id of the submenu of an action, referenced by `aria-controls`.
-}
submenuID : Action -> String
submenuID action =
    "lia-submenu-" ++ actionName action


actionName : Action -> String
actionName action =
    case action of
        ShowInformation ->
            "information"

        ShowTranslations ->
            "translations"

        ShowSettings ->
            "settings"

        ShowModes ->
            "modes"

        ShowShare ->
            "share"

        Close ->
            "close"


{-| -}
type Mode
    = Slides -- Underline Comments and Effects
    | Presentation -- Only effects
    | Textbook -- Render Comments and Effects at ones


{-| -}
type Audio
    = Pitch String
    | Rate String


{-| -}
init : Maybe Bool -> Bool -> Mode -> Settings
init hasShareApi isFullscreen mode =
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
    , playback = Idle
    , hasShareApi = hasShareApi
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
        , avatar = Nothing
        }
    , chat =
        { show = False
        , updates = False
        }
    , audio = { pitch = "1", rate = "1" }
    , fullscreen = isFullscreen
    , edit = Nothing
    }


{-| The menu of a `data-group-id`, see `Library.Group`.
-}
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


{-| The `data-group-id` of a menu.
-}
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
