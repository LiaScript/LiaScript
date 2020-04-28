module Lia.Markdown.Inline.Stringify exposing
    ( stringify
    , stringify_
    )

import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))


stringify : Inlines -> String
stringify =
    stringify_ -1


stringify_ : Int -> Inlines -> String
stringify_ effect_id =
    List.map (inline2string effect_id)
        >> String.concat


inline2string : Int -> Inline -> String
inline2string effect_id inline =
    case inline of
        Chars str _ ->
            str

        Bold x _ ->
            inline2string effect_id x

        Italic x _ ->
            inline2string effect_id x

        Strike x _ ->
            inline2string effect_id x

        Underline x _ ->
            inline2string effect_id x

        Superscript x _ ->
            inline2string effect_id x

        Verbatim str _ ->
            str

        Formula _ str _ ->
            str

        Ref ref _ ->
            ref2string ref

        EInline e _ ->
            if effect_id == -1 then
                stringify_ effect_id e.content

            else if (e.begin <= effect_id) && (e.end > effect_id) then
                stringify_ effect_id e.content

            else
                ""

        _ ->
            ""


ref2string : Reference -> String
ref2string ref =
    case ref of
        Movie alt _ _ ->
            stringify alt

        Image alt _ _ ->
            stringify alt

        Audio alt _ _ ->
            stringify alt

        Link alt _ _ ->
            stringify alt

        Mail alt _ _ ->
            stringify alt

        Embed alt _ _ ->
            stringify alt
