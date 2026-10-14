module Lia.Definition.Json.Encode exposing (encode)

{-| Encoder for the definitions, used for storing a course and by the
TypeScript side (`onload`, `language`, `macro`, ...).
-}

import Conditional.List as CList
import Dict
import Json.Encode exposing (Value, dict, list, object, string)
import Lia.Definition.Types exposing (Definition, Resource(..))
import Lia.Markdown.Inline.Json.Encode as Inline


{-| Encode all definitions that are needed later on, `formulas` only if there
are some.
-}
encode : Definition -> Value
encode def =
    [ ( "author", string def.author )
    , ( "date", string def.date )
    , ( "email", string def.email )
    , ( "language", string def.language )
    , ( "logo", string def.logo )
    , ( "version", string def.version )
    , ( "base", string def.base )
    , ( "narrator", string def.narrator )
    , ( "onload", string def.onload )
    , ( "comment", Inline.encode def.comment )
    , ( "attributes", list Inline.encode def.attributes )
    , ( "resources", list resource def.resources )
    , ( "translation", dict identity string def.translation )
    , ( "macro", dict identity string def.macro )
    ]
        |> CList.addIf (not <| Dict.isEmpty def.formulas) ( "formulas", dict identity string def.formulas )
        |> object


{-| `{"Link": url}`, `{"Script": url}` or `{"Module": url}`
-}
resource : Resource -> Value
resource r =
    case r of
        Link url ->
            object [ ( "Link", string url ) ]

        Script url ->
            object [ ( "Script", string url ) ]

        Module url ->
            object [ ( "Module", string url ) ]
