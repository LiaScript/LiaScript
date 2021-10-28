module Port.Event exposing
    ( Event
    , decode
    , destructure
    , empty
    , encode
    , id_
    , init
    , initWithId
    , message
    , pop
    , popWithId
    , push
    , pushWithId
    , store
    , topicWithId
    , topic_
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Chart.Types exposing (Point)


type alias Event =
    { route : List Point
    , message : JE.Value
    }


type alias Point =
    { topic : String
    , id : Maybe Int
    }


empty : String -> Event
empty topic =
    init topic JE.null


init : String -> JE.Value -> Event
init topic =
    Event [ Point topic Nothing ]


initWithId : String -> Int -> JE.Value -> Event
initWithId topic id =
    Event [ Point topic (Just id) ]


push : String -> Event -> Event
push topic to =
    { to | route = Point topic Nothing :: to.route }


pushWithId : String -> Int -> Event -> Event
pushWithId topic id to =
    { to | route = Point topic (Just id) :: to.route }


pop : Event -> Maybe ( String, Event )
pop event =
    case event.route of
        point :: route ->
            Just ( point.topic, { event | route = route } )

        _ ->
            Nothing


popWithId : Event -> Maybe ( String, Maybe Int, Event )
popWithId event =
    case event.route of
        { topic, id } :: route ->
            Just ( topic, id, { event | route = route } )

        _ ->
            Nothing


topic_ : Event -> Maybe String
topic_ =
    .route
        >> List.head
        >> Maybe.map .topic


topicWithId : Event -> Maybe ( String, Maybe Int )
topicWithId =
    .route
        >> List.head
        >> Maybe.map (\{ topic, id } -> ( topic, id ))


id_ : Event -> Maybe Int
id_ =
    .route
        >> List.head
        >> Maybe.andThen .id


destructure : Event -> ( Maybe ( String, Maybe Int ), JE.Value )
destructure event =
    ( topicWithId event, event.message )


message : Event -> JE.Value
message =
    .message


encode : Event -> JE.Value
encode event =
    JE.object
        [ ( "route", JE.list encPoint event.route )
        , ( "message", event.message )
        ]


encPoint : Point -> JE.Value
encPoint { topic, id } =
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
