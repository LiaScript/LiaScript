module Const exposing
    ( align
    , globalBreakpoints
    , icon
    , urlLiascript
    , urlLiascriptCourse
    , urlProxy
    )


icon : String
icon =
    "icon.ico"


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
