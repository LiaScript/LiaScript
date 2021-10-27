module Port.Event exposing
    ( Event
    , decode
    , encode
    , init
    , initWithId
    , store
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Chart.Types exposing (Point)


type alias Event =
    { route : List Point
    , message : JE.Value
    }


type Point
    = Point String (Maybe Int)


init : String -> JE.Value -> Event
init topic =
    Event [ Point topic Nothing ]


initWithId : String -> Int -> JE.Value -> Event
initWithId topic id =
    Event [ Point topic (Just id) ]


encode : Event -> JE.Value
encode { route, message } =
    JE.object
        [ ( "route", JE.list encPoint route )
        , ( "message", message )
        ]


encPoint : Point -> JE.Value
encPoint (Point topic id) =
    JE.object
        [ ( "topic", JE.string topic )
        , ( "id"
          , id
                |> Maybe.map JE.int
                |> Maybe.withDefault JE.null
          )
        ]


decPoint : JD.Decoder Point
decPoint =
    JD.map2 Point
        (JD.field "topic" JD.string)
        (JD.field "id" (JD.maybe JD.int))


decode : JD.Value -> Result JD.Error Event
decode =
    JD.decodeValue
        (JD.map2 Event
            (JD.field "route" (JD.list decPoint))
            (JD.field "message" JD.value)
        )


store : JE.Value -> Event
store =
    init "store"
