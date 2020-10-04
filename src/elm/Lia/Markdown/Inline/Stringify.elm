module Lia.Markdown.Inline.Stringify exposing
    ( stringify
    , stringify_
    )

import Lia.Markdown.Effect.Types as Effect
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))


stringify : Inlines -> String
stringify =
    stringify_ Nothing


stringify_ : Maybe Int -> Inlines -> String
stringify_ effect_id =
    List.map (inline2string effect_id)
        >> String.concat


inline2string : Maybe Int -> Inline -> String
inline2string id inline =
    case inline of
        Chars str _ ->
            str

        Bold x _ ->
            inline2string id x

        Italic x _ ->
            inline2string id x

        Strike x _ ->
            inline2string id x

        Underline x _ ->
            inline2string id x

        Superscript x _ ->
            inline2string id x

        Verbatim str _ ->
            str

        Formula _ str _ ->
            str

        Ref ref _ ->
            ref2string id ref

        IHTML (HTML.Node _ _ x) _ ->
            stringify_ id x

        EInline e _ ->
            if Effect.isIn id e then
                stringify_ id e.content

            else
                ""

        Goto inlines _ ->
            inline2string id inlines

        _ ->
            ""


ref2string : Maybe Int -> Reference -> String
ref2string id ref =
    case ref of
        Movie alt _ _ ->
            stringify_ id alt

        Image alt _ _ ->
            stringify_ id alt

        Audio alt _ _ ->
            stringify_ id alt

        Link alt _ _ ->
            stringify_ id alt

        Mail alt _ _ ->
            stringify_ id alt

        Embed alt _ _ ->
            stringify_ id alt

        Preview_Lia _ ->
            "preview-lia"

        Preview_Link _ ->
            "preview-link"
