module Lia.Markdown.Inline.Json.Decode exposing (decode)

import Json.Decode as JD
import Lia.Markdown.Effect.Types exposing (Effect)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..))


decode : JD.Decoder Inlines
decode =
    JD.list decInline


decInline : JD.Decoder Inline
decInline =
    [ strReader "Chars" Chars
    , strReader "FootnoteMark" FootnoteMark
    , strReader "Symbol" Symbol
    , strReader "Verbatim" Verbatim
    , inlReader "Bold" Bold
    , inlReader "Italic" Italic
    , inlReader "Strike" Strike
    , inlReader "Superscript" Superscript
    , inlReader "Underline" Underline
    , JD.field "Ref" toReference |> JD.map Ref
    , JD.field "Container" (JD.lazy (\_ -> decode)) |> JD.map Container
    , JD.field "IHTML" (JD.lazy (\_ -> HTML.decode decInline)) |> JD.map IHTML
    , JD.map Script (JD.field "Script" JD.int)
    , effect |> JD.map EInline
    ]
        |> JD.oneOf
        |> JD.andThen toAnnotation


effect : JD.Decoder (Effect Inline)
effect =
    JD.map6 Effect
        (JD.field "EInline" (JD.lazy (\_ -> decode)))
        (JD.field "playback" JD.bool)
        (JD.field "begin" JD.int)
        (JD.field "end" (JD.maybe JD.int))
        (JD.field "voice" JD.string)
        (JD.field "id" JD.int)


strReader :
    String
    -> (String -> Parameters -> Inline)
    -> JD.Decoder (Parameters -> Inline)
strReader key type_ =
    JD.field key JD.string |> JD.map type_


inlReader :
    String
    -> (Inline -> Parameters -> Inline)
    -> JD.Decoder (Parameters -> Inline)
inlReader key type_ =
    JD.field key (JD.lazy (\_ -> decInline)) |> JD.map type_


toAnnotation : (Parameters -> Inline) -> JD.Decoder Inline
toAnnotation fn =
    [ JD.list
        (JD.list JD.string
            |> JD.andThen
                (\p ->
                    case p of
                        [ key, value ] ->
                            JD.succeed ( key, value )

                        _ ->
                            JD.fail "not correct parameter list"
                )
        )
        |> JD.field "a"
    , JD.succeed []
    ]
        |> JD.oneOf
        |> JD.map fn


toRef :
    (Inlines -> String -> Maybe Inlines -> Reference)
    -> String
    -> JD.Decoder Reference
toRef fn3 class =
    JD.map3 fn3
        (JD.field class (JD.lazy (\_ -> decode)))
        (JD.field "url" JD.string)
        toTitle


toTitle : JD.Decoder (Maybe Inlines)
toTitle =
    JD.field "title" (JD.lazy (\_ -> JD.maybe decode))


toMultimedia :
    (Inlines -> ( Bool, String ) -> Maybe Inlines -> value)
    -> String
    -> JD.Decoder value
toMultimedia fn3 class =
    JD.map3 fn3
        (JD.field class (JD.lazy (\_ -> decode)))
        (JD.map2 Tuple.pair
            (JD.field "stream" JD.bool)
            (JD.field "url" JD.string)
        )
        toTitle


toReference : JD.Decoder Reference
toReference =
    [ toRef Link "Link"
    , toRef Mail "Mail"
    , toRef Image "Image"
    , toRef Embed "Embed"
    , toMultimedia Audio "Audio"
    , toMultimedia Movie "Movie"
    ]
        |> JD.oneOf
