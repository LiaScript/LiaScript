module Lia.Markdown.Inline.Stringify exposing
    ( stringify
    , stringify_
    )

import Array
import Lia.Markdown.Effect.Script.Types exposing (Scripts, text)
import Lia.Markdown.Effect.Types as Effect
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))


stringify : Inlines -> String
stringify =
    stringify_ Array.empty Nothing


stringify_ : Scripts a -> Maybe Int -> Inlines -> String
stringify_ effects id =
    List.map (inline2string effects id)
        >> String.concat


inline2string : Scripts a -> Maybe Int -> Inline -> String
inline2string effects id inline =
    case inline of
        Chars str _ ->
            str

        Bold x _ ->
            inline2string effects id x

        Italic x _ ->
            inline2string effects id x

        Strike x _ ->
            inline2string effects id x

        Underline x _ ->
            inline2string effects id x

        Superscript x _ ->
            inline2string effects id x

        Verbatim str _ ->
            str

        Formula _ str _ ->
            str

        Ref ref _ ->
            ref2string effects id ref

        IHTML (HTML.Node _ _ x) _ ->
            stringify_ effects id x

        Container x _ ->
            stringify_ effects id x

        EInline e _ ->
            if Effect.isIn id e then
                stringify_ effects id e.content

            else
                ""

        Script i _ ->
            effects
                |> Array.get i
                |> Maybe.andThen .result
                |> Maybe.andThen text
                |> Maybe.withDefault ""

        _ ->
            ""


ref2string : Scripts a -> Maybe Int -> Reference -> String
ref2string effects id ref =
    case ref of
        Movie alt _ _ ->
            stringify_ effects id alt

        Image alt _ _ ->
            stringify_ effects id alt

        Audio alt _ _ ->
            stringify_ effects id alt

        Link alt _ _ ->
            stringify_ effects id alt

        Mail alt _ _ ->
            stringify_ effects id alt

        Embed alt _ _ ->
            stringify_ effects id alt

        Preview_Lia _ ->
            "preview-lia"

        Preview_Link _ ->
            "preview-link"

        QR_Link _ _ ->
            "qr-code"
