module Lia.Parser.UrlPattern.NextCloud exposing (byGeneric, patternGeneric)

{-| Shared NextCloud files (`nextcloud://host/s/...`) are downloaded by
appending `/download`.
-}

import Lia.Parser.UrlPattern.Generic exposing (withoutQuery)


{-| The download URL, `w` is the URL without `nextcloud://`.
-}
byGeneric : String -> String -> String
byGeneric _ w =
    let
        baseUrl =
            withoutQuery w
    in
    if String.endsWith "/download" baseUrl then
        "https://" ++ baseUrl

    else
        "https://" ++ baseUrl ++ "/download"


{-| Matches `nextcloud://` URLs.
-}
patternGeneric : String
patternGeneric =
    "nextcloud://(.*)"
