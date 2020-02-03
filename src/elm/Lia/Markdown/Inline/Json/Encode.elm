module Lia.Markdown.Inline.Json.Encode exposing (encode)

import Json.Encode as JE
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines, Reference(..))


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

            EInline i j list a ->
                [ ( "EInline", encode list )
                , ( "i", JE.int i )
                , ( "j", JE.int j )
                , ( "a", encAnnotation a )
                ]

            Container list a ->
                [ ( "Container", encode list )
                , ( "a", encAnnotation a )
                ]

            HTML str ->
                [ ( "HTML", JE.string "" )
                , ( "a", encAnnotation Nothing )
                ]

            _ ->
                []


encReference : Reference -> JE.Value
encReference ref =
    case ref of
        Link list url title ->
            encRef "Link" list url title

        Mail list url title ->
            encRef "Mail" list url title

        Image list url title ->
            encRef "Image" list url title

        Audio list url title ->
            encMultimedia "Audio" list url title

        Movie list url title ->
            encMultimedia "Movie" list url title


encRef : String -> Inlines -> String -> String -> JE.Value
encRef class list url title =
    JE.object
        [ ( class, encode list )
        , ( "url", JE.string url )
        , ( "title", JE.string title )
        ]


encMultimedia : String -> Inlines -> ( Bool, String ) -> String -> JE.Value
encMultimedia class list ( stream, url ) title =
    JE.object
        [ ( class, encode list )
        , ( "stream", JE.bool stream )
        , ( "url", JE.string url )
        , ( "title", JE.string title )
        ]


encAnnotation : Annotation -> JE.Value
encAnnotation annotation =
    case annotation of
        Just a ->
            JE.dict identity JE.string a

        Nothing ->
            JE.null
