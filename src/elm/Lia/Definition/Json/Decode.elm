module Lia.Definition.Json.Decode exposing (decode)

import Json.Decode as JD
import Lia.Definition.Types exposing (Definition, Resource(..))
import Lia.Markdown.Inline.Json.Decode as Inline


decode : JD.Decoder Definition
decode =
    JD.succeed Definition
        |> andMap "author" JD.string
        |> andMap "date" JD.string
        |> andMap "email" JD.string
        |> andMap "language" JD.string
        |> andMap "logo" JD.string
        |> andMap "narrator" JD.string
        |> andMap "version" JD.string
        |> andMap "comment" Inline.decode
        |> andMap "resources" (JD.list decResource)
        |> andMap "base" JD.string
        |> andMap "translation" (JD.dict JD.string)
        |> andMap "macro" (JD.dict JD.string)
        |> JD.map2 (|>) (JD.succeed [])
        |> andMap "attributes" (JD.list Inline.decode)
        |> JD.map2 (|>) (JD.succeed -1)
        |> JD.map2 (|>) (JD.succeed -1)
        |> JD.map2 (|>) (JD.succeed False)
        |> andMap "onload" JD.string
        |> JD.map2 (|>) (JD.succeed Nothing)
        |> JD.map2 (|>) (JD.succeed Nothing)


andMap : String -> JD.Decoder a -> JD.Decoder (a -> value) -> JD.Decoder value
andMap key dec =
    JD.map2 (|>) (JD.field key dec)


decResource : JD.Decoder Resource
decResource =
    JD.oneOf
        [ JD.field "Link" JD.string |> JD.map Link
        , JD.field "Script" JD.string |> JD.map Script
        ]
