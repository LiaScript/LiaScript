module Lia.Utils exposing (toEscapeString, toJSstring)

{-
   string_replace : ( String, String ) -> String -> String
   string_replace ( search, replace ) string =
       string
           |> String.split search
           |> String.join replace
-}


toJSstring : String -> String
toJSstring =
    String.split "\\" >> String.join "\\\\"


toEscapeString : String -> String
toEscapeString str =
    str
        |> String.replace "\"" "\\\""
        |> String.replace "'" "\\'"
        |> String.replace "\n" "\\n"
