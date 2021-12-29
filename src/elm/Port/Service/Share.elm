module Port.Service.Share exposing (share)

import Json.Encode as JE
import Port.Event as Event exposing (Event)


share : { title : String, text : String, url : String } -> Event
share { title, text, url } =
    { cmd = "share"
    , param =
        JE.object
            [ ( "title", JE.string title )
            , ( "text", JE.string text )
            , ( "url", JE.string url )
            ]
    }
        |> Event.initX "share"
        |> Event.withNoReply
