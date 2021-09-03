module Lia.Parser.PatReplace exposing
    ( link
    , replace
    , root
    )

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


regex : String -> Regex.Regex
regex =
    Regex.fromString
        >> Maybe.withDefault Regex.never


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
