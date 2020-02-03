module Lia.Definition.Json.Encode exposing (encode)

import Json.Encode exposing (Value, dict, list, object, string)
import Lia.Definition.Types exposing (Definition, Resource(..))
import Lia.Markdown.Inline.Json.Encode as Inline


encode : Definition -> Value
encode def =
    object
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
        , ( "resources", list encResource def.resources )
        , ( "translation", dict identity string def.translation )
        , ( "macro", dict identity string def.macro )
        ]


encResource : Resource -> Value
encResource r =
    object
        [ case r of
            Link url ->
                ( "Link", string url )

            Script url ->
                ( "Script", string url )
        ]
