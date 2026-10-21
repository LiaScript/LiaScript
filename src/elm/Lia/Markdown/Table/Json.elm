module Lia.Markdown.Table.Json exposing (encode)

import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Table.Types exposing (Table, className)


encode : Table -> JE.Value
encode table =
    JE.object
        [ ( "class", JE.string (className table.class) )
        , ( "head", JE.list cell table.head )
        , ( "format", JE.list JE.string table.format )
        , ( "body", JE.list (JE.list cell) table.body )
        , ( "id", JE.int table.id )
        ]


cell : ( Parameters, Inlines ) -> JE.Value
cell ( _, inlines ) =
    JE.object
        [ ( "cell", Inline.encode inlines )
        , ( "a", JE.null )
        ]
