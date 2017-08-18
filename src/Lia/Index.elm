module Lia.Index exposing (create, scan)

import Lia.Type exposing (Block(..), Inline(..), Quiz(..), Reference(..), Slide)
import String


create : List Slide -> List String
create slides =
    List.map extract_string slides


scan : List String -> String -> List Int
scan index pattern =
    index
        |> List.indexedMap (,)
        |> List.filter (\( _, str ) -> String.contains (String.toLower pattern) str)
        |> List.map (\( i, _ ) -> i)


extract_string : Slide -> String
extract_string slide =
    slide.title
        ++ (slide.body
                |> List.map parse_block
                |> String.concat
           )
        |> String.toLower


parse_block : Block -> String
parse_block element =
    let
        scan e =
            List.map parse_inline e
                |> String.concat
    in
    case element of
        Paragraph e ->
            scan e

        Quote e ->
            scan e

        CodeBlock language code ->
            code

        Quiz quiz _ _ ->
            case quiz of
                TextInput _ ->
                    ""

                SingleChoice _ e ->
                    List.map scan e
                        |> String.concat

                MultipleChoice e ->
                    List.map (\( _, ee ) -> scan ee) e
                        |> String.concat

        EBlock _ sub_blocks ->
            List.map (\sub -> parse_block sub) sub_blocks
                |> String.concat

        _ ->
            ""


parse_inline : Inline -> String
parse_inline element =
    case element of
        Chars str ->
            str

        Code str ->
            str

        Bold e ->
            parse_inline e

        Italic e ->
            parse_inline e

        Underline e ->
            parse_inline e

        Superscript e ->
            parse_inline e

        Ref e ->
            case e of
                Link alt_ url_ ->
                    alt_ ++ "" ++ url_

                Image alt_ url_ ->
                    alt_ ++ "" ++ url_

                Movie alt_ url_ ->
                    alt_ ++ "" ++ url_

        Formula _ str ->
            str

        HTML str ->
            str

        EInline _ e ->
            List.map parse_inline e
                |> String.concat

        _ ->
            ""
