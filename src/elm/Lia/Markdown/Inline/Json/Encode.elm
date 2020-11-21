module Lia.Markdown.Inline.Json.Encode exposing (encode)

import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters)
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
                , ( "a", encAnnotation a )
                ]

            Symbol str a ->
                [ ( "Symbol", JE.string str )
                , ( "a", encAnnotation a )
                ]

            Bold x a ->
                [ ( "Bold", encInline x )
                , ( "a", encAnnotation a )
                ]

            Italic x a ->
                [ ( "Italic", encInline x )
                , ( "a", encAnnotation a )
                ]

            Strike x a ->
                [ ( "Strike", encInline x )
                , ( "a", encAnnotation a )
                ]

            Underline x a ->
                [ ( "Underline", encInline x )
                , ( "a", encAnnotation a )
                ]

            Superscript x a ->
                [ ( "Superscript", encInline x )
                , ( "a", encAnnotation a )
                ]

            Verbatim str a ->
                [ ( "Verbatim", JE.string str )
                , ( "a", encAnnotation a )
                ]

            Formula head body a ->
                [ ( "Formula", JE.string head )
                , ( "body", JE.string body )
                , ( "a", encAnnotation a )
                ]

            Ref ref a ->
                [ ( "Ref", encReference ref )
                , ( "a", encAnnotation a )
                ]

            FootnoteMark str a ->
                [ ( "FootnoteMark", JE.string str )
                , ( "a", encAnnotation a )
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
                , ( "a", encAnnotation a )
                ]

            Container list a ->
                [ ( "Container", encode list )
                , ( "a", encAnnotation a )
                ]

            IHTML node a ->
                [ ( "IHTML"
                  , HTML.encode encInline node
                  )
                , ( "a", encAnnotation a )
                ]

            Script id a ->
                [ ( "Script"
                  , JE.int id
                  )
                , ( "a", encAnnotation a )
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


encAnnotation : Parameters -> JE.Value
encAnnotation annotation =
    case annotation of
        [] ->
            JE.null

        _ ->
            annotation
                |> List.map (\( key, value ) -> JE.list JE.string [ key, value ])
                |> JE.list identity
