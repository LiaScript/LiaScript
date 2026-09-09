module Lia.Parser.UrlPattern.GitLab exposing (..)

import I18n.Translations exposing (Lang(..))
import Lia.Parser.UrlPattern.Generic as Generic
import List.Extra
import Regex
import Url exposing (percentDecode, percentEncode)


by : String -> String -> String
by _ w =
    -- First handle any query parameters by removing them
    let
        baseUrl =
            w
                |> String.split "?"
                |> List.head
                |> Maybe.withDefault w

        parts =
            baseUrl |> String.split "/"
    in
    case parts of
        -- already a resolved API URL - pass it through unchanged (with its
        -- query intact) instead of rebuilding it from the query-stripped
        -- `parts`, which used to silently drop `?ref=...`
        "api" :: "v4" :: "projects" :: _ ->
            "https://gitlab.com/" ++ w

        user :: repository :: "-" :: "raw" :: branch :: filePath ->
            "https://gitlab.com/api/v4/projects/"
                ++ String.join
                    "/"
                    [ percentEncode (user ++ "/" ++ repository), "repository/files", percentEncode (String.join "/" filePath), "raw" ]
                ++ "?ref="
                ++ branch

        user :: repository :: "-" :: "blob" :: branch :: filePath ->
            "https://gitlab.com/api/v4/projects/"
                ++ String.join
                    "/"
                    [ percentEncode (user ++ "/" ++ repository), "repository/files", percentEncode (String.join "/" filePath), "raw" ]
                ++ "?ref="
                ++ branch

        _ ->
            "https://gitlab.com/" ++ w


pattern : String
pattern =
    Generic.root "gitlab\\.com/(.*)"


byGeneric : String -> String -> String
byGeneric _ w =
    -- Split URL into major parts we need
    let
        -- Remove potential query string
        baseUrl =
            w
                |> String.split "?"
                |> List.head
                |> Maybe.withDefault w

        -- Extract parts: domain/user/repo/-/raw/branch/path
        urlParts =
            String.split "/" baseUrl

        domain =
            urlParts
                |> List.head
                |> Maybe.withDefault ""

        -- Find the index of the -/raw/ or -/blob/ part
        dashIndex =
            urlParts
                |> List.indexedMap Tuple.pair
                |> List.filter (\( _, part ) -> part == "-")
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.withDefault -1

        -- Extract repository part (all parts between domain and dash)
        repository =
            if dashIndex > 1 then
                urlParts
                    |> List.drop 1
                    |> List.take (dashIndex - 1)
                    |> String.join "/"

            else
                ""

        -- Extract access type (raw or blob)
        accessType =
            if dashIndex >= 0 && List.length urlParts > dashIndex + 1 then
                urlParts |> List.drop (dashIndex + 1) |> List.head |> Maybe.withDefault ""

            else
                ""

        -- Extract branch
        branch =
            if accessType /= "" && List.length urlParts > dashIndex + 2 then
                urlParts |> List.drop (dashIndex + 2) |> List.head |> Maybe.withDefault "main"

            else
                "main"

        -- Extract file path
        filePath =
            if branch /= "" && List.length urlParts > dashIndex + 3 then
                urlParts
                    |> List.drop (dashIndex + 3)
                    |> String.join "/"

            else
                "README.md"
    in
    "https://"
        ++ domain
        ++ "/api/v4/projects/"
        ++ percentEncode repository
        ++ "/repository/files/"
        ++ percentEncode filePath
        ++ "/raw?ref="
        ++ branch


patternGeneric : String
patternGeneric =
    "gitlab://(.*)"


{-| Inverse of `by`/`byGeneric`: given an already-resolved "get raw file" API
URL - `.../api/v4/projects/OWNER%2FREPO/repository/files/PATH/raw?ref=BRANCH`
- reconstruct the human-readable `-/raw/branch/dir/` directory URL it lives
in, so that a relative sibling resource can be resolved from it again via
`link`.

This exists because the API URL isn't a real directory hierarchy - the
browser's address bar ends up holding this resolved form after every course
load (LiaScript canonicalizes it there), so `origin` can't rely on the URL
still being in its original, hierarchical `-/blob/`/`-/raw/` shape.

    toDirectory "https://gitlab.com/api/v4/projects/owner%2Frepo/repository/files/dir%2Ffile.md/raw?ref=main"
        == Just "https://gitlab.com/owner/repo/-/raw/main/dir/"

-}
toDirectory : String -> Maybe String
toDirectory url =
    case
        url
            |> Regex.findAtMost 1 apiFileUrl
            |> List.head
            |> Maybe.map .submatches
    of
        Just [ Just domain, Just encodedRepository, Just encodedFilePath, Just branch ] ->
            Maybe.map2
                (\repository filePath ->
                    domain ++ "/" ++ repository ++ "/-/raw/" ++ branch ++ "/" ++ directoryOf filePath
                )
                (percentDecode encodedRepository)
                (percentDecode encodedFilePath)

        _ ->
            Nothing


apiFileUrl : Regex.Regex
apiFileUrl =
    "^(.*)/api/v4/projects/([^/]+)/repository/files/(.*)/raw\\?ref=(.*)$"
        |> Regex.fromString
        |> Maybe.withDefault Regex.never


{-| The directory containing `path` (its last `/`-segment dropped), or "" if
`path` has none.
-}
directoryOf : String -> String
directoryOf path =
    case path |> String.split "/" |> List.Extra.init of
        Just (_ :: _ as dirs) ->
            String.join "/" dirs ++ "/"

        _ ->
            ""
