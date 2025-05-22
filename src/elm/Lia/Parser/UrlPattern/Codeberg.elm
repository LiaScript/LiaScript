module Lia.Parser.UrlPattern.Codeberg exposing (..)

import Lia.Parser.UrlPattern.Generic exposing (root)


by : String -> String -> String
by _ w =
    case w |> String.split "/" of
        "api" :: "v1" :: "repos" :: params ->
            "https://codeberg.org/api/v1/repos/"
                ++ String.join "/" params

        user :: repository :: "raw" :: "branch" :: branch :: filePath ->
            "https://codeberg.org/api/v1/repos/"
                ++ String.join "/"
                    [ user, repository, "raw", String.join "/" filePath ]
                ++ "?ref="
                ++ branch

        user :: repository :: "src" :: "branch" :: branch :: filePath ->
            "https://codeberg.org/api/v1/repos/"
                ++ String.join "/"
                    [ user, repository, "raw", String.join "/" filePath ]
                ++ "?ref="
                ++ branch

        _ ->
            "https://codeberg.org/" ++ w


pattern : String
pattern =
    root "codeberg\\.org/(.*)"
