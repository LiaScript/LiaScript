module Lia.Parser.Helper exposing
    ( c_frame
    , debug
    , inlineCode
    , newline
    , newlines
    , newlines1
    , spaces
    , spaces1
    , string1Till
    , stringTill
    )

import Combine
    exposing
        ( Parser
        , ignore
        , keep
        , many1Till
        , manyTill
        , map
        , modifyInput
        , modifyState
        , regex
        , string
        , withColumn
        , withLine
        , withSourceLine
        , withState
        )
import Combine.Char exposing (anyChar)
import Lia.Parser.Context exposing (Context)


debug : String -> Parser Context a -> Parser Context a
debug log p =
    withLine
        (\y ->
            withColumn
                (\x ->
                    withSourceLine
                        (\s ->
                            withState
                                (\ss ->
                                    let
                                        output =
                                            --  Debug.log log
                                            ( y
                                            , x
                                            , String.slice 0 x s
                                                ++ "["
                                                ++ String.slice x (x + 1) s
                                                ++ "]"
                                                ++ String.slice (x + 1) -1 s
                                                ++ " -- ["
                                                ++ (ss.indentation |> String.join ",")
                                                ++ "]/"
                                                ++ (if ss.indentation_skip then
                                                        "True"

                                                    else
                                                        "False"
                                                   )
                                            )
                                    in
                                    p
                                )
                        )
                )
        )


c_frame : Parser s Int
c_frame =
    regex "(`){3,}" |> map String.length


newline : Parser s String
newline =
    string "\n"


newlines : Parser s String
newlines =
    regex "\n*"


newlines1 : Parser s String
newlines1 =
    regex "\n+"


spaces : Parser s String
spaces =
    regex "[\t ]*"


spaces1 : Parser s String
spaces1 =
    regex "[\t ]+"


stringTill : Parser s p -> Parser s String
stringTill p =
    manyTill anyChar p |> map String.fromList


string1Till : Parser s p -> Parser s String
string1Till p =
    many1Till anyChar p |> map String.fromList


{-| inline code parser for elements surrounded by backticks
-}
inlineCode : Parser s String
inlineCode =
    string "`"
        |> keep (regex "([^`\n\\\\]*|\\\\`|\\\\)+")
        |> ignore (string "`")
        |> map (String.replace "\\`" "`")


logger identifier =
    modifyState
        (\input ->
            let
                _ =
                    Debug.log identifier input.abort
            in
            input
        )
        |> ignore
            (modifyInput
                (\input ->
                    let
                        _ =
                            Debug.log identifier input
                    in
                    input
                )
            )
