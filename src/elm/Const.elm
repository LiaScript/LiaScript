module Const exposing
    ( align
    , globalBreakpoints
    , gunDB_ServerURL
    , icon
    , nostrRelayURLs
    , tooltipBreakpoint
    , urlLiascript
    , urlLiascriptCourse
    , urlProxy
    )


icon : String
icon =
    "icon.svg"


align :
    { left : String
    , right : String
    , center : String
    , default : String
    }
align =
    { left = "text-left"
    , right = "text-right"
    , center = "text-center"
    , default = "text-left"
    }


{-| Breakpoints as used by the styling

    globalBreakpoints.xs == 480

    globalBreakpoints.sm == 768

    globalBreakpoints.md == 1024

    globalBreakpoints.lg == 1440

    globalBreakpoints.xl == 1680

-}
globalBreakpoints :
    { xs : Int
    , sm : Int
    , md : Int
    , lg : Int
    , xl : Int
    }
globalBreakpoints =
    { xs = 480
    , sm = 768
    , md = 1024
    , lg = 1440
    , xl = 1680
    }


{-| This defines the maximum allowed size on which tooltips can be enabled
-}
tooltipBreakpoint : Int
tooltipBreakpoint =
    globalBreakpoints.sm


{-| If a Markdown-file cannot be downloaded, for some reasons
(presumable due to some [CORS][cors] restrictions), this will be used as an
intermediate proxy. This means, there will be a second trial to download the
file, but not with the URL:

    "https://api.allorigins.win/raw?url=" ++ "https://.../README.md"

[cors]: https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS

-}
urlProxy : String
urlProxy =
    "https://api.allorigins.win/raw?url="


urlLiascript : String
urlLiascript =
    "https://LiaScript.github.io"


urlLiascriptCourse : String
urlLiascriptCourse =
    urlLiascript ++ "/course/?"


{-| This is default server used within the Sync module
-}
gunDB_ServerURL : String
gunDB_ServerURL =
    "https://gun.rig.airfaas.com/gun, https://relay.peer.ooo/gun"


{-| Default public Nostr relays used within the Sync module
-}
nostrRelayURLs : String
nostrRelayURLs =
    "wss://relay.edufeed.org, wss://nos.lol, wss://nostr.mom"
