module Port.Share exposing (share)

import Json.Encode as JE
import Port.Event exposing (Event)


share : String -> String -> String -> Event
share title text url =
    [ ( "title", JE.string title )
    , ( "text", JE.string text )
    , ( "url", JE.string url )
    ]
        |> JE.object
        |> Event "share" -1
