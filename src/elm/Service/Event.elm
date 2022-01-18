module Service.Event exposing
    ( Event
    , decode
    , destructure
    , empty
    , encode
    , id
    , init
    , initGeneric
    , message
    , poi
    , pop
    , popWithId
    , push
    , pushWithId
    , todo
    , topic
    , withNoReply
    )

import Json.Decode as JD
import Json.Encode as JE


{-| An `Event` can be used to communicate via ports between Typescript and Elm.

  - The **`reply`** field is used to indicate if the `track` should be recorded.
    By default it is set to `True`, but you can use the function `withNoReply`
    to set this to `False`. This way, as Typescript service will not send a
    reply back.

  - A **`track`** is basically a way of communication from Typescript to Elm.
    Whenever an event is routed through the elm-infrastructure, via the update
    functions to the Main port to be send outside, this is used to attach
    points (POIs) like:

        ("section", Just 3) :: ("quiz", Just 12) :: ...

    When an answer is send back to elm, this trail is used to identify the
    appropriate receiver.

  - **`service`** on the other side is used to identify the recipient of the
    event on the Typescript side. It can be a string like `"TTS"`.

  - The **`message`** contains a record with a command as a simple string, while
    param is used to deliver the appropriate ... PARAMETERS. These can be
    arbitrary values, therefor it requires custom decoders on the elm-side.

    Use the function empty to initialize an event with an empty (null)
    parameter set.

-}
type alias Event =
    { reply : Bool
    , track : List POI
    , service : String
    , message :
        { cmd : String
        , param : JE.Value
        }
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


{-| Create an event for a specific `service` and `command`, the `param` will
be set to `null`.

    empty "TTS" "cancel"
        == { reply = True
           , route = []
           , service = "TTS"
           , message =
                { cmd = "cancel"
                , param = JE.null
                }
           }

-}
empty : String -> String -> Event
empty service command =
    init service { cmd = command, param = JE.null }


{-| Initialize a new event, a reply is awaited by default.

    init "ServiceID" { cmd = "name", param = JE.int 1 }

An event without response is generated via:

    { cmd = "name", param = JE.int 1 }
        |> init "ServiceID"
        |> withNoReply

-}
init : String -> { cmd : String, param : JE.Value } -> Event
init =
    Event True []


{-| This is a simplified event initialization to be used in pipes

    initGeneric "ServiceID" False "cmd" JE.null
        == ({ cmd = "cmd", param = JE.null }
                |> init "ServiceID"
                |> withNoReply
           )

-}
initGeneric : String -> Bool -> String -> JE.Value -> Event
initGeneric service doReply cmd param =
    Event doReply [] service { cmd = cmd, param = param }


{-| Simply set the default `reply` value to `False`, which will result in an
event to which no response message will be send from Typescript.
-}
withNoReply : Event -> Event
withNoReply e =
    { e | reply = False }


{-| Add a POI to the event track. The `i` value is set to -1.
-}
push : String -> Event -> Event
push po to =
    { to | track = ( po, -1 ) :: to.track }


{-| Add a `POI` to the `track`, which consists of a string and an additional
integer value.
-}
pushWithId : String -> Int -> Event -> Event
pushWithId po i to =
    { to | track = ( po, i ) :: to.track }


{-| Pop the latest point from the event track, while ignoring the integer
value.

    pop event == Just ( "stringPOI", newEvent )

    pop noTrail == Nothing

-}
pop : Event -> Maybe ( String, Event )
pop event =
    case event.track of
        ( po, _ ) :: track ->
            Just ( po, { event | track = track } )

        _ ->
            Nothing


{-| Similar to `pop`, but both `POI` values as well as the new event with the
shorter event track will be returned, if there is an POI within the `track`.
-}
popWithId : Event -> Maybe ( String, Int, Event )
popWithId event =
    case event.track of
        ( po, i ) :: track ->
            Just ( po, i, { event | track = track } )

        _ ->
            Nothing


{-| Get the entire `POI` only.
-}
poi : Event -> Maybe ( String, Int )
poi =
    .track >> List.head


{-| Return only the string part of the `POI`, but do not change the event track.
-}
topic : Event -> Maybe String
topic =
    poi >> Maybe.map Tuple.first


{-| Return only the integer part of the `POI`, but do not change the event track.
-}
id : Event -> Maybe Int
id =
    poi >> Maybe.andThen checkId


checkId : POI -> Maybe Int
checkId ( _, i ) =
    if i >= 0 then
        Just i

    else
        Nothing


{-| This can be used at the final decoding step of the event, if only the:

    destructure event
        == ( Just "topic", 12, ( "stop", JE.null ) )

    destructure event2
        == ( Nothing, -1, ( "stop", JE.null ) )

final values are required to react onto a message.

-}
destructure : Event -> ( Maybe String, Int, ( String, JE.Value ) )
destructure event =
    case poi event of
        Just ( po, i ) ->
            ( Just po, i, message event )

        _ ->
            ( Nothing, -1, message event )


{-| Return the message as a tuple of the string cmd and a json value, which
needs to be decoded. This comes handy within `case ... of` statements.
-}
message : Event -> ( String, JE.Value )
message event =
    ( event.message.cmd, event.message.param )


decPoint : JD.Decoder POI
decPoint =
    JD.map2 Tuple.pair
        (JD.index 0 JD.string)
        (JD.index 1 JD.int)


decMessage : JD.Decoder { cmd : String, param : JE.Value }
decMessage =
    JD.map2 (\c p -> { cmd = c, param = p })
        (JD.field "cmd" JD.string)
        (JD.field "param" JD.value)


decode : JD.Value -> Result JD.Error Event
decode =
    JD.decodeValue
        (JD.map4 Event
            (JD.field "reply" JD.bool)
            (JD.field "route" (JD.list decPoint))
            (JD.field "service" JD.string)
            (JD.field "message" decMessage)
        )


encode : Event -> JE.Value
encode event =
    JE.object
        [ ( "reply", JE.bool event.reply )
        , ( "route", JE.list encPoint event.track )
        , ( "service", JE.string event.service )
        , ( "message"
          , JE.object
                [ ( "cmd", JE.string event.message.cmd )
                , ( "param", event.message.param )
                ]
          )
        ]


encPoint : POI -> JE.Value
encPoint ( po, i ) =
    JE.list identity
        [ JE.string po
        , JE.int i
        ]


{-| Dummy event to replace current events while refactoring.
-}
todo : Event
todo =
    init "TODO" { cmd = "todo", param = JE.string "todo not implemented event" }
