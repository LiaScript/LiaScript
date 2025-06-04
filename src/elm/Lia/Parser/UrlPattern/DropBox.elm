module Lia.Parser.UrlPattern.DropBox exposing (..)

import Lia.Parser.UrlPattern.Generic exposing (root)


by : String -> String -> String
by _ w =
    "https://dl.dropbox.com/" ++ w


pattern : String
pattern =
    root "dropbox\\.com/(.*)"
