module Service.Share exposing (link)

import Json.Encode as JE
import Service.Event as Event exposing (Event)


{-| Create a share event that allows to send the resource `url` with a `title`
and `text` that will be send via the `Navigator.share()` API.

<https://developer.mozilla.org/en-US/docs/Web/API/Navigator/share#shareable_file_types>

-}
link : { title : String, text : String, url : String, image : Maybe String } -> Event
link { title, text, url, image } =
    { cmd = "link"
    , param =
        JE.object
            [ ( "title", JE.string title )
            , ( "text", JE.string text )
            , ( "url", JE.string url )
            , ( "files"
              , image
                    |> Maybe.map (JE.string >> List.singleton)
                    |> Maybe.withDefault []
                    |> JE.list identity
              )
            ]
    }
        |> Event.init "share"
        |> Event.withNoReply
