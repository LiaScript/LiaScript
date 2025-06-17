module Lia.Parser.UrlPattern.GitHub exposing (..)

import Lia.Parser.UrlPattern.Generic as Generic


by : String -> String -> String
by _ w =
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


pattern : String
pattern =
    Generic.root "github\\.com/(.*)"
