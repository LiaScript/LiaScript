module Lia.Parser.UrlPattern.GitLab exposing (..)

import I18n.Translations exposing (Lang(..))
import Lia.Parser.UrlPattern.Generic as Generic
import Url exposing (percentEncode)


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
        "api" :: "v4" :: "projects" :: params ->
            "https://gitlab.com/api/v4/projects/"
                ++ String.join "/" params

        user :: repository :: "-" :: "raw" :: branch :: filePath ->
            "https://gitlab.com/api/v4/projects/"
                ++ String.join
                    "/"
                    [ percentEncode (user ++ "/" ++ repository), "repository/files", String.join "/" filePath, "raw" ]
                ++ "?ref="
                ++ branch

        user :: repository :: "-" :: "blob" :: branch :: filePath ->
            "https://gitlab.com/api/v4/projects/"
                ++ String.join
                    "/"
                    [ percentEncode (user ++ "/" ++ repository), "repository/files", String.join "/" filePath, "raw" ]
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
