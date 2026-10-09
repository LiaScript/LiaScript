module Lia.Definition.Json.Decode exposing (decode)

{-| Decoder for definitions stored by `Lia.Definition.Json.Encode`.
-}

import Dict
import I18n.Quotation exposing (quotation)
import Json.Decode as JD
import Lia.Definition.Types exposing (Definition, Resource(..))
import Lia.Markdown.Inline.Json.Decode as Inline


{-| Decode the definitions, `appendix` is not stored and has to be passed
(with leading `?`). Imports, section values and settings are not stored.
-}
decode : String -> JD.Decoder Definition
decode appendix =
    JD.succeed Definition
        |> field "author" JD.string
        |> field "date" JD.string
        |> field "email" JD.string
        |> field "language" JD.string
        |> field "language" (JD.map quotation JD.string)
        |> field "logo" JD.string
        |> field "narrator" JD.string
        |> field "version" JD.string
        |> field "comment" Inline.decode
        |> field "resources" (JD.list resource)
        |> field "base" JD.string
        |> with appendix
        |> field "translation" (JD.dict JD.string)
        |> with_ (JD.field "formulas" (JD.dict JD.string) |> JD.maybe |> JD.map (Maybe.withDefault Dict.empty))
        |> field "macro" (JD.dict JD.string)
        |> with []
        |> field "attributes" (JD.list Inline.decode)
        |> with -1
        |> with -1
        |> field "onload" JD.string
        |> with Nothing
        |> with Nothing


{-| Decode the next record field from a JSON field.
-}
field : String -> JD.Decoder a -> JD.Decoder (a -> value) -> JD.Decoder value
field key dec =
    with_ (JD.field key dec)


{-| Decode the next record field with a decoder.
-}
with_ : JD.Decoder a -> JD.Decoder (a -> value) -> JD.Decoder value
with_ =
    JD.map2 (|>)


{-| Set the next record field to a fixed value.
-}
with : a -> JD.Decoder (a -> value) -> JD.Decoder value
with =
    JD.succeed >> with_


{-| `{"Link": url}`, `{"Script": url}` or `{"Module": url}`
-}
resource : JD.Decoder Resource
resource =
    JD.oneOf
        [ JD.field "Link" JD.string |> JD.map Link
        , JD.field "Script" JD.string |> JD.map Script
        , JD.field "Module" JD.string |> JD.map Module
        ]
