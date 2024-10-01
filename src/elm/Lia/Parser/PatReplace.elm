module Lia.Parser.PatReplace exposing
    ( link
    , replace
    , repo
    , root
    )

import Const
import Regex


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
        , { by = \_ w -> "https://dl.dropbox.com/s/" ++ w
          , pattern = root "dropbox\\.com/s/(.*)"
          }
        ]
        >> Tuple.second


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
