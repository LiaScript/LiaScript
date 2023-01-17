module Lia.Markdown.Inline.Json.Encode exposing (encode)

import Html.Attributes exposing (name)
import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.HTML.Json exposing (encParameters)
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))


encode : Inlines -> JE.Value
encode list =
    JE.list encInline list


encInline : Inline -> JE.Value
encInline element =
    JE.object <|
        case element of
            Chars str a ->
                [ ( "Chars", JE.string str )
                , encParameters a
                ]

            Symbol str a ->
                [ ( "Symbol", JE.string str )
                , encParameters a
                ]

            Bold x a ->
                baseEncoder "Bold" x a

            Italic x a ->
                baseEncoder "Italic" x a

            Strike x a ->
                baseEncoder "Strike" x a

            Underline x a ->
                baseEncoder "Underline" x a

            Superscript x a ->
                baseEncoder "Superscript" x a

            Verbatim str a ->
                [ ( "Verbatim", JE.string str )
                , encParameters a
                ]

            Formula head body a ->
                [ ( "Formula", JE.string head )
                , ( "body", JE.string body )
                , encParameters a
                ]

            Ref ref a ->
                [ ( "Ref", encReference ref )
                , encParameters a
                ]

            FootnoteMark str a ->
                [ ( "FootnoteMark", JE.string str )
                , encParameters a
                ]

            EInline e a ->
                [ ( "EInline", encode e.content )
                , ( "begin", JE.int e.begin )
                , ( "end"
                  , e.end
                        |> Maybe.map JE.int
                        |> Maybe.withDefault JE.null
                  )
                , ( "playback", JE.bool e.playback )
                , ( "voice", JE.string e.voice )
                , ( "id", JE.int e.id )
                , encParameters a
                ]

            Container list a ->
                [ ( "Container", encode list )
                , encParameters a
                ]

            IHTML node a ->
                htmlEncoder node a

            Script id a ->
                [ ( "Script", JE.int id )
                , encParameters a
                ]


baseEncoder : String -> Inline -> Parameters -> List ( String, JE.Value )
baseEncoder name content attr =
    [ ( name, encInline content )
    , encParameters attr
    ]


htmlEncoder : HTML.Node Inline -> Parameters -> List ( String, JE.Value )
htmlEncoder node attr =
    [ ( "IHTML", HTML.encode encInline node )
    , encParameters attr
    ]


encReference : Reference -> JE.Value
encReference ref =
    case ref of
        Link list url title ->
            encRef "Link" list url title

        Mail list url title ->
            encRef "Mail" list url title

        Embed list url title ->
            encRef "Embed" list url title

        Image list url title ->
            encRef "Image" list url title

        Audio list url title ->
            encMultimedia "Audio" list url title

        Movie list url title ->
            encMultimedia "Movie" list url title

        Preview_Lia url ->
            encRef "Preview_Lia" [] url Nothing

        Preview_Link url ->
            encRef "Preview_Link" [] url Nothing

        QR_Link url title ->
            encRef "QR_Link" [] url title


encRef : String -> Inlines -> String -> Maybe Inlines -> JE.Value
encRef class list url title =
    JE.object
        [ ( class, encode list )
        , ( "url", JE.string url )
        , encTitle title
        ]


encMultimedia : String -> Inlines -> ( Bool, String ) -> Maybe Inlines -> JE.Value
encMultimedia class list ( stream, url ) title =
    JE.object
        [ ( class, encode list )
        , ( "stream", JE.bool stream )
        , ( "url", JE.string url )
        , encTitle title
        ]


encTitle : Maybe Inlines -> ( String, JE.Value )
encTitle title =
    ( "title"
    , title
        |> Maybe.map encode
        |> Maybe.withDefault JE.null
    )
