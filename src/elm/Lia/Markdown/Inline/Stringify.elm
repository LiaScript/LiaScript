module Lia.Markdown.Inline.Stringify exposing
    ( stringify
    , stringify_
    )

import Array exposing (Array)
import Lia.Markdown.Effect.Script.Types exposing (Scripts, text)
import Lia.Markdown.Effect.Types as Effect
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Multi.Types as Input
import Lia.Utils as Utils


stringify : Inlines -> String
stringify =
    stringify_
        { scripts = Array.empty
        , visible = Nothing
        , input = { state = Array.empty, options = Array.empty }
        }


stringify_ :
    { config
        | scripts : Scripts a
        , visible : Maybe Int
        , input :
            { x
                | state : Input.State
                , options : Array (List Inlines)
            }
    }
    -> Inlines
    -> String
stringify_ config =
    List.map (inline2string config)
        >> String.concat


inline2string :
    { config
        | scripts : Scripts a
        , visible : Maybe Int
        , input :
            { x
                | state : Input.State
                , options : Array (List Inlines)
            }
    }
    -> Inline
    -> String
inline2string config inline =
    case inline of
        Chars str _ ->
            str

        Bold x _ ->
            inline2string config x

        Italic x _ ->
            inline2string config x

        Strike x _ ->
            inline2string config x

        Underline x _ ->
            inline2string config x

        Superscript x _ ->
            inline2string config x

        Verbatim str _ ->
            str

        Formula _ str _ ->
            str

        Ref ref _ ->
            ref2string config ref

        IHTML (HTML.Node _ _ x) _ ->
            stringify_ config x

        Container x _ ->
            stringify_ config x

        EInline e _ ->
            if Effect.isIn config.visible e then
                stringify_ config e.content

            else
                ""

        Script i _ ->
            config.scripts
                |> Array.get i
                |> Maybe.andThen .result
                |> Maybe.andThen text
                |> Maybe.withDefault ""

        Quiz ( _, id ) _ ->
            case Array.get id config.input.state of
                Just (Block.Text str) ->
                    str

                Just (Block.Select _ [ id2 ]) ->
                    if id2 == -1 then
                        ""

                    else
                        config.input.options
                            |> Array.get id
                            |> Maybe.andThen (Utils.get id2)
                            |> Maybe.map (stringify_ config)
                            |> Maybe.withDefault ""

                _ ->
                    ""

        _ ->
            ""


ref2string :
    { config
        | scripts : Scripts a
        , visible : Maybe Int
        , input :
            { x
                | state : Input.State
                , options : Array (List Inlines)
            }
    }
    -> Reference
    -> String
ref2string config ref =
    case ref of
        Movie alt _ _ ->
            stringify_ config alt

        Image alt _ _ ->
            stringify_ config alt

        Audio alt _ _ ->
            stringify_ config alt

        Link alt _ _ ->
            stringify_ config alt

        Mail alt _ _ ->
            stringify_ config alt

        Embed alt _ _ ->
            stringify_ config alt

        Preview_Lia _ ->
            "preview-lia"

        Preview_Link _ ->
            "preview-link"

        QR_Link _ _ ->
            "qr-code"
