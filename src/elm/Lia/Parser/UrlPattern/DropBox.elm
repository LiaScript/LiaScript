module Lia.Parser.UrlPattern.DropBox exposing (by, pattern)

{-| Shared DropBox files are downloaded from `dl.dropbox.com`.
-}

import Lia.Parser.UrlPattern.Generic exposing (root)


{-| The download URL, `w` is the path after `dropbox.com/`.
-}
by : String -> String -> String
by _ w =
    "https://dl.dropbox.com/" ++ w


{-| Matches DropBox URLs.
-}
pattern : String
pattern =
    root "dropbox\\.com/(.*)"
