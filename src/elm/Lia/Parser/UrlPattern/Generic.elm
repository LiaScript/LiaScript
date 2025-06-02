module Lia.Parser.UrlPattern.Generic exposing (..)


root : String -> String
root =
    (++) "(?:http(?:s)?://)?(?:www\\.)?"
