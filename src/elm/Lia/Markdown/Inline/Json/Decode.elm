module Lia.Markdown.Inline.Json.Decode exposing (decode)

import Json.Decode as JD
import Lia.Markdown.Effect.Types exposing (Effect)
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Types exposing (Annotation, Inline(..), Inlines, Reference(..))


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
    -> (String -> Annotation -> Inline)
    -> JD.Decoder (Annotation -> Inline)
strReader key type_ =
    JD.field key JD.string |> JD.map type_


inlReader :
    String
    -> (Inline -> Annotation -> Inline)
    -> JD.Decoder (Annotation -> Inline)
inlReader key type_ =
    JD.field key (JD.lazy (\_ -> decInline)) |> JD.map type_


toAnnotation : (Annotation -> Inline) -> JD.Decoder Inline
toAnnotation fn =
    JD.maybe (JD.field "a" (JD.dict JD.string))
        |> JD.map fn


toRef :
    (Inlines -> String -> String -> Reference)
    -> String
    -> JD.Decoder Reference
toRef fn3 class =
    JD.map3 fn3
        (JD.field class (JD.lazy (\_ -> decode)))
        (JD.field "url" JD.string)
        (JD.field "title" JD.string)


toMultimedia :
    (Inlines -> ( Bool, String ) -> String -> value)
    -> String
    -> JD.Decoder value
toMultimedia fn3 class =
    JD.map3 fn3
        (JD.field class (JD.lazy (\_ -> decode)))
        (JD.map2 Tuple.pair
            (JD.field "stream" JD.bool)
            (JD.field "url" JD.string)
        )
        (JD.field "title" JD.string)


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
