module Lia.Parser.UrlPattern.GitHub exposing (by, pattern)

{-| GitHub repositories and files are loaded from `raw.githubusercontent.com`.
-}

import Lia.Parser.UrlPattern.Generic as Generic


{-| The raw URL, `w` is the path after `github.com/`. A repository or folder
links to its `README.md`.
-}
by : String -> String -> String
by _ w =
    "https://raw.githubusercontent.com/"
        ++ (case String.split "/" w of
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


{-| Matches GitHub URLs.
-}
pattern : String
pattern =
    Generic.root "github\\.com/(.*)"
