module Lia.Parser.UrlPattern.Generic exposing (root, withoutQuery)

{-| Helpers for the URL patterns.
-}


{-| Prefix a pattern with an optional `http(s)://` and `www.`.
-}
root : String -> String
root =
    (++) "(?:http(?:s)?://)?(?:www\\.)?"


{-| Cut off the `?query` of an URL.
-}
withoutQuery : String -> String
withoutQuery url =
    url
        |> String.split "?"
        |> List.head
        |> Maybe.withDefault url
