module Lia.Markdown.Inline.Stringify exposing (stringify)

import Lia.Markdown.Inline.Types exposing (..)


stringify : Inlines -> String
stringify inlines =
    inlines
        |> List.map inline2string
        |> String.concat


inline2string : Inline -> String
inline2string inline =
    case inline of
        Chars str _ ->
            str

        Symbol str _ ->
            str

        Bold x _ ->
            inline2string x

        Italic x _ ->
            inline2string x

        Strike x _ ->
            inline2string x

        Underline x _ ->
            inline2string x

        Superscript x _ ->
            inline2string x

        Verbatim str _ ->
            str

        Formula _ str _ ->
            str

        Ref ref _ ->
            ref2string ref

        HTML str _ ->
            ""

        JavaScirpt _ _ ->
            ""

        EInline _ _ inlines _ ->
            stringify inlines

        Container inlines _ ->
            stringify inlines


ref2string : Reference -> String
ref2string ref =
    case ref of
        Movie alt _ ->
            alt

        Image alt _ ->
            alt

        Link alt _ ->
            alt
