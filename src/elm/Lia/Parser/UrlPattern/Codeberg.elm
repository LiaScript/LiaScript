module Lia.Parser.UrlPattern.Codeberg exposing (by, pattern)

{-| Codeberg files are loaded via the API of `codeberg.org`.
-}

import Lia.Parser.UrlPattern.Generic exposing (root)


{-| The API URL, `w` is the path after `codeberg.org/`.
-}
by : String -> String -> String
by _ w =
    case String.split "/" w of
        "api" :: "v1" :: "repos" :: params ->
            "https://codeberg.org/api/v1/repos/" ++ String.join "/" params

        user :: repository :: access :: "branch" :: branch :: filePath ->
            if access == "raw" || access == "src" then
                "https://codeberg.org/api/v1/repos/"
                    ++ String.join "/" [ user, repository, "raw", String.join "/" filePath ]
                    ++ "?ref="
                    ++ branch

            else
                "https://codeberg.org/" ++ w

        _ ->
            "https://codeberg.org/" ++ w


{-| Matches Codeberg URLs.
-}
pattern : String
pattern =
    root "codeberg\\.org/(.*)"
