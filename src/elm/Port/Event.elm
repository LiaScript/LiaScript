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


type alias Event =
    { route : List POI
    , message : JE.Value
    }


{-| A `POI` in this case is only a tuple of a string, which defines where
an event comes from. The usage of the additional `Int` parameter is mostly
used, if there is an array involved. For example by using quizzes, the
additional number is used to identify the quiz on vector position 12.
A default value is -1, which in turn will also result as `Nothing`, if an
Array is queried ...

    ( "quiz", 12 )

-}
type alias POI =
    ( String, Int )


empty : String -> Event
empty topic =
    init topic JE.null


init : String -> JE.Value -> Event
init topic =
    Event [ ( topic, -1 ) ]


initWithId : String -> Int -> JE.Value -> Event
initWithId topic id =
    Event [ ( topic, id ) ]


push : String -> Event -> Event
push topic to =
    { to | route = ( topic, -1 ) :: to.route }


pushWithId : String -> Int -> Event -> Event
pushWithId topic id to =
    { to | route = ( topic, id ) :: to.route }


pop : Event -> Maybe ( String, Event )
pop event =
    case event.route of
        ( topic, _ ) :: route ->
            Just ( topic, { event | route = route } )

        _ ->
            Nothing


popWithId : Event -> Maybe ( String, Int, Event )
popWithId event =
    case event.route of
        ( topic, id ) :: route ->
            Just ( topic, id, { event | route = route } )

        _ ->
            Nothing


topic_ : Event -> Maybe String
topic_ =
    .route
        >> List.head
        >> Maybe.map Tuple.first


topicWithId : Event -> Maybe ( String, Int )
topicWithId =
    .route >> List.head


id_ : Event -> Maybe Int
id_ =
    .route
        >> List.head
        >> Maybe.andThen checkId


checkId : POI -> Maybe Int
checkId ( _, i ) =
    if i >= 0 then
        Just i

    else
        Nothing


destructure : Event -> Maybe ( String, Int, JE.Value )
destructure event =
    case topicWithId event of
        Just ( topic, id ) ->
            Just ( topic, id, event.message )

        _ ->
            Nothing


message : Event -> JE.Value
message =
    .message


store : JE.Value -> Event
store =
    init "store"


decPoint : JD.Decoder POI
decPoint =
    JD.map2 Tuple.pair
        (JD.index 0 JD.string)
        (JD.index 1 JD.int)


decode : JD.Value -> Result JD.Error Event
decode =
    JD.decodeValue
        (JD.map2 Event
            (JD.field "route" (JD.list decPoint))
            (JD.field "message" JD.value)
        )


encode : Event -> JE.Value
encode event =
    JE.object
        [ ( "route", JE.list encPoint event.route )
        , ( "message", event.message )
        ]


encPoint : POI -> JE.Value
encPoint ( topic, id ) =
    JE.list identity
        [ JE.string topic
        , JE.int id
        ]
