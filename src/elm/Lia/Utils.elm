module Lia.Utils exposing (toJSstring)

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
