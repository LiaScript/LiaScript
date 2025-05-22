module Lia.Parser.PatReplace exposing
    ( link
    , replace
    , repo
    , root
    )

import Base64
import Const
import Regex
import Url exposing (percentEncode)


replace : List { pattern : String, by : String -> String -> String } -> String -> ( Bool, String )
replace patterns url =
    case patterns of
        [] ->
            ( False, url )

        t :: ts ->
            case check t.pattern url of
                Just str ->
                    ( True, t.by url str )

                _ ->
                    replace ts url


link : String -> String
link =
    replace
        [ { by =
                \_ w ->
                    "https://raw.githubusercontent.com/"
                        ++ (case w |> String.split "/" of
                                -- [user, repo]
                                [ _, _ ] ->
                                    w ++ "/master/README.md"

                                -- user :: repo :: "tree" :: path ..
                                _ :: _ :: "tree" :: _ ->
                                    String.replace "/tree/" "/" w ++ "/README.md"

                                _ :: _ :: "raw" :: "refs" :: "heads" :: _ ->
                                    String.replace "/raw/refs/heads" "/refs/heads" w

                                _ ->
                                    String.replace "/blob/" "/" w
                           )
          , pattern = root "github\\.com/(.*)"
          }
        , { by = \_ w -> "https://dl.dropbox.com/" ++ w
          , pattern = root "dropbox\\.com/(.*)"
          }
        , { by = \_ w -> createOneDriveLink ("https://onedrive.live.com/" ++ w)
          , pattern = root "onedrive\\.live\\.com/(.*)"
          }
        , { by =
                \_ w ->
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
          , pattern = root "codeberg\\.org/(.*)"
          }
        , { by =
                \_ w ->
                    case w |> String.split "/" of
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

                        _ ->
                            "https://gitlab.com/" ++ w
          , pattern = root "gitlab\\.com/(.*)"
          }

        -- Generic GitLab
        , { by =
                \_ w ->
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
          , pattern = "gitlab://(.*)"
          }
        ]
        >> Tuple.second


{-| **private:** creates a OneDrive link from a given URL

this is based on the following script:

<https://github.com/felixrieseberg/onedrive-link/blob/main/bin/onedrive-link>

-}
createOneDriveLink : String -> String
createOneDriveLink url =
    let
        -- Step 1: Convert to base64
        base64 =
            Base64.encode url

        -- Step 2: Replace '/' with '_' and '+' with '-'
        modifiedBase64 =
            base64
                |> String.replace "/" "_"
                |> String.replace "+" "-"

        -- Step 3: Remove trailing '=' character if present
        finalBase64 =
            if String.endsWith "=" modifiedBase64 then
                String.dropRight 1 modifiedBase64

            else
                modifiedBase64
    in
    "https://api.onedrive.com/v1.0/shares/u!" ++ finalBase64 ++ "/root/content"


{-| **private:** translates the `Const.urlProxy` string into a regular
expression.
-}
urlProxy : String
urlProxy =
    Const.urlProxy
        |> String.replace "." "\\."
        |> String.replace "?" "\\?"


{-| This is the inverse function to link and tries to determine the URL of the
main repository.

    repo "https://raw.githubusercontent.com/LiaScript/LiaScript/development/README.md"
        == "https://github.com/LiaScript/LiaScript/tree/development"

Gitlab and some other resources cannot be downloaded directly, therefor the proxy
URL is automatically added by the system, which is ignored.

    repo "Const.proxyURL"+"https://gitlab.com/OvGU-ESS/eLab_v2/lia_script/-/raw/master/README.md"
    = "https://gitlab.com/OvGU-ESS/eLab_v2/lia_script/-/blob/master/README.md"

Works also fro dropbox...

-}
repo : String -> Maybe String
repo =
    replace
        [ { by =
                \_ w ->
                    "https://github.com/"
                        ++ (case w |> String.split "/" of
                                user :: repository :: "blob" :: hash :: _ ->
                                    user ++ "/" ++ repository ++ "/tree/" ++ hash

                                user :: repository :: "refs" :: "heads" :: branch :: _ ->
                                    user ++ "/" ++ repository ++ "/tree/" ++ branch

                                -- user :: repo :: branch :: path ..
                                user :: repository :: branch :: _ ->
                                    user ++ "/" ++ repository ++ "/tree/" ++ branch

                                _ ->
                                    w
                           )
          , pattern = root "raw.githubusercontent\\.com/(.*)"
          }
        , { by = \_ w -> "https://gitlab.com/" ++ String.replace "-/raw/" "-/tree/" w
          , pattern = root (urlProxy ++ "https://gitlab\\.com/(.*)")
          }

        -- Pattern:
        --
        -- USER.gitlab.io/PROJECT/folder/.../file -> gitlab.com/USER/PROJECT
        , { by =
                \_ w ->
                    case w |> String.split "/" |> List.map (String.split ".") of
                        [ user, "gitlab", "io" ] :: [ project ] :: _ ->
                            "https://gitlab.com/" ++ user ++ "/" ++ project

                        _ ->
                            "https://" ++ w
          , pattern = root "(.*\\.gitlab\\.io/.*)"
          }
        , { by = \_ w -> "https://dropbox.com/s/" ++ w
          , pattern = root "dl\\.dropbox\\.com/s/(.*)"
          }
        ]
        >> (\( found, string ) ->
                if found then
                    Just <| String.replace Const.urlProxy "" string

                else
                    Nothing
           )


regex : String -> Regex.Regex
regex =
    Regex.fromString >> Maybe.withDefault Regex.never


check : String -> String -> Maybe String
check pattern url =
    case
        url
            |> Regex.findAtMost 1 (regex pattern)
            |> List.head
    of
        Just match ->
            match.submatches
                |> List.head
                |> Maybe.withDefault Nothing

        _ ->
            Nothing


root : String -> String
root =
    (++) "(?:http(?:s)?://)?(?:www\\.)?"
