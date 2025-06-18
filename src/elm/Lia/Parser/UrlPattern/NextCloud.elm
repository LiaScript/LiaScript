module Lia.Parser.UrlPattern.NextCloud exposing (..)


byGeneric : String -> String -> String
byGeneric _ w =
    let
        baseUrl =
            case String.split "?" w of
                base :: _ ->
                    base

                [] ->
                    w
    in
    if String.endsWith "/download" baseUrl then
        "https://" ++ baseUrl

    else
        "https://" ++ baseUrl ++ "/download"


patternGeneric : String
patternGeneric =
    "nextcloud://(.*)"
