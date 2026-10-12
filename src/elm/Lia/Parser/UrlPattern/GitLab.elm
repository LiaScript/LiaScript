module Lia.Parser.UrlPattern.GitLab exposing
    ( by
    , byGeneric
    , pattern
    , patternGeneric
    , toDirectory
    )

{-| GitLab files are loaded via the "get raw file" API, for gitlab.com and for
self-hosted instances (`gitlab://host/...`, see `PatReplace.link`).
-}

import Lia.Parser.UrlPattern.Generic as Generic exposing (withoutQuery)
import List.Extra as List
import Regex
import Url exposing (percentDecode, percentEncode)


{-| The API URL for gitlab.com, `w` is the path after `gitlab.com/`.
-}
by : String -> String -> String
by _ w =
    case String.split "/" (withoutQuery w) of
        -- already a resolved API URL - pass it through unchanged (with its
        -- query intact) instead of rebuilding it from the query-stripped
        -- parts, which used to silently drop `?ref=...`
        "api" :: "v4" :: "projects" :: _ ->
            "https://gitlab.com/" ++ w

        user :: repository :: "-" :: access :: branch :: filePath ->
            if access == "raw" || access == "blob" then
                "https://gitlab.com/api/v4/projects/"
                    ++ String.join "/"
                        [ percentEncode (user ++ "/" ++ repository)
                        , "repository/files"
                        , percentEncode (String.join "/" filePath)
                        , "raw"
                        ]
                    ++ "?ref="
                    ++ branch

            else
                "https://gitlab.com/" ++ w

        _ ->
            "https://gitlab.com/" ++ w


{-| Matches gitlab.com URLs.
-}
pattern : String
pattern =
    Generic.root "gitlab\\.com/(.*)"


{-| The API URL for a self-hosted GitLab, `w` is
`domain/group/.../repo/-/raw/branch/path` without `gitlab://`. A missing
branch is `main`, a missing path `README.md`.
-}
byGeneric : String -> String -> String
byGeneric _ w =
    let
        parts =
            String.split "/" (withoutQuery w)

        at i =
            parts |> List.drop i |> List.head

        dash =
            parts
                |> List.elemIndex "-"
                |> Maybe.withDefault -1

        -- all parts between the domain and the dash
        repository =
            if dash > 1 then
                parts
                    |> List.drop 1
                    |> List.take (dash - 1)
                    |> String.join "/"

            else
                ""

        -- raw or blob
        accessType =
            if dash >= 0 then
                at (dash + 1) |> Maybe.withDefault ""

            else
                ""

        branch =
            if accessType /= "" then
                at (dash + 2) |> Maybe.withDefault "main"

            else
                "main"

        filePath =
            if branch /= "" && List.length parts > dash + 3 then
                parts
                    |> List.drop (dash + 3)
                    |> String.join "/"

            else
                "README.md"
    in
    "https://"
        ++ Maybe.withDefault "" (at 0)
        ++ "/api/v4/projects/"
        ++ percentEncode repository
        ++ "/repository/files/"
        ++ percentEncode filePath
        ++ "/raw?ref="
        ++ branch


{-| Matches `gitlab://` URLs.
-}
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


{-| Matches the API URL of a file: domain, repository, path and branch.
-}
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
    case path |> String.split "/" |> List.init of
        Just ((_ :: _) as dirs) ->
            String.join "/" dirs ++ "/"

        _ ->
            ""
