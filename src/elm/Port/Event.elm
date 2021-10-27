module Port.Event exposing
    ( Event
    , decode
    , destructure
    , empty
    , encode
    , id
    , init
    , initWithId
    , message
    , pop
    , popWithId
    , push
    , pushWithId
    , store
    , topic
    , topicWithId
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Chart.Types exposing (Point)


type alias Event =
    { route : List Point
    , msg : JE.Value
    }


type alias Point =
    { topic_ : String
    , id_ : Maybe Int
    }


empty : String -> Event
empty topic_ =
    init topic_ JE.null


init : String -> JE.Value -> Event
init topic_ =
    Event [ Point topic_ Nothing ]


initWithId : String -> Int -> JE.Value -> Event
initWithId topic_ id_ =
    Event [ Point topic_ (Just id_) ]


push : String -> Event -> Event
push topic_ to =
    { to | route = Point topic_ Nothing :: to.route }


pushWithId : String -> Int -> Event -> Event
pushWithId topic_ id_ to =
    { to | route = Point topic_ (Just id_) :: to.route }


pop : Event -> Maybe ( String, Event )
pop event =
    case event.route of
        point :: route ->
            Just ( point.topic_, { event | route = route } )

        _ ->
            Nothing


popWithId : Event -> Maybe ( String, Maybe Int, Event )
popWithId event =
    case event.route of
        { topic_, id_ } :: route ->
            Just ( topic_, id_, { event | route = route } )

        _ ->
            Nothing


topic : Event -> Maybe String
topic =
    .route
        >> List.head
        >> Maybe.map .topic_


topicWithId : Event -> Maybe ( String, Maybe Int )
topicWithId =
    .route
        >> List.head
        >> Maybe.map (\{ topic_, id_ } -> ( topic_, id_ ))


id : Event -> Maybe Int
id =
    .route
        >> List.head
        >> Maybe.andThen .id_


destructure : Event -> ( Maybe ( String, Maybe Int ), JE.Value )
destructure event =
    ( topicWithId event, event.msg )


message : Event -> JE.Value
message =
    .msg


encode : Event -> JE.Value
encode { route, msg } =
    JE.object
        [ ( "route", JE.list encPoint route )
        , ( "message", msg )
        ]


encPoint : Point -> JE.Value
encPoint { topic_, id_ } =
    JE.object
        [ ( "topic", JE.string topic_ )
        , ( "id"
          , id_
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
