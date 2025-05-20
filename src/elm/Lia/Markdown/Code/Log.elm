module Lia.Markdown.Code.Log exposing
    ( Level(..)
    , Log
    , Message
    , add
    , add_Eval
    , decoder
    , empty
    , encode
    , fromString
    , isEmpty
    , length
    , view
    )

import Accessibility.Aria as A11y_Aria
import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode as JD
import Json.Encode as JE
import Lia.Utils exposing (array_getLast, array_setLast)
import Service.Script exposing (Eval)


type Level
    = Debug -- for debug-related messages
    | Info -- for information of any kind
    | Warn -- for warnings
    | Error -- for errors
    | Stream -- concatenates all outputs, usable for handling stdout from the console
    | HTML -- show html content


type alias Message =
    { level : Level
    , text : String
    }


type alias Log =
    { ok : Bool
    , level : Level
    , messages : Array Message
    , details : List JE.Value
    }


fromString : String -> Maybe Level
fromString level =
    case level of
        "debug" ->
            Just Debug

        "info" ->
            Just Info

        "warn" ->
            Just Warn

        "error" ->
            Just Error

        "html" ->
            Just HTML

        "stream" ->
            Just Stream

        _ ->
            Nothing


empty : Log
empty =
    Log True Debug Array.empty []


isEmpty : Log -> Bool
isEmpty =
    .messages >> Array.isEmpty


view : Log -> List ( String, Html msg )
view log =
    log.messages
        |> Array.toList
        |> List.map view_message


view_message : Message -> ( String, Html msg )
view_message { level, text } =
    ( text
    , case level of
        Debug ->
            viewLog { class = "text-debug", str = text, label = "debug" }

        Info ->
            viewLog { class = "text-info", str = text, label = "info" }

        Warn ->
            viewLog { class = "text-warning", str = text, label = "warning" }

        Error ->
            viewLog { class = "text-error", str = text, label = "error" }

        HTML ->
            Html.div
                [ Attr.class "text-info"
                , Attr.property "innerHTML" <| JE.string text
                ]
                []

        Stream ->
            viewLog { class = "text-info", str = text, label = "info" }
    )


viewLog : { class : String, str : String, label : String } -> Html msg
viewLog { class, str, label } =
    Html.div
        [ Attr.class class
        , A11y_Aria.label label
        ]
        [ Html.text str
        ]


add : Level -> String -> Log -> Log
add level str log =
    { log
        | messages =
            crop <|
                case level of
                    Stream ->
                        case array_getLast log.messages of
                            Just message ->
                                if message.level == Stream then
                                    log.messages
                                        |> array_setLast (Message level (message.text ++ str))

                                else
                                    Array.push (Message level str) log.messages

                            _ ->
                                Array.push (Message level str) log.messages

                    _ ->
                        Array.push (Message level str) log.messages
    }


crop : Array Message -> Array Message
crop messages =
    if Array.length messages < 250 then
        messages

    else
        Array.slice 1 250 messages


add_Eval : Eval -> Log -> Log
add_Eval eval log =
    (if eval.ok then
        add Info eval.result

     else
        add Error eval.result
    )
    <|
        { log | ok = eval.ok, details = eval.details }


encode : Log -> JE.Value
encode log =
    JE.object
        [ ( "ok", JE.bool log.ok )
        , ( "level", encLevel log.level )
        , ( "messages", JE.array encMessage log.messages )
        , ( "details", JE.list identity log.details )
        ]


length : Array Message -> Int
length =
    Array.map len
        >> Array.foldl (+) 0


len : Message -> Int
len =
    .text >> String.indexes "\n" >> List.length


encLevel : Level -> JE.Value
encLevel level =
    JE.int <|
        case level of
            Debug ->
                -1

            Info ->
                0

            Warn ->
                1

            Error ->
                2

            HTML ->
                3

            Stream ->
                4


encMessage : Message -> JE.Value
encMessage { level, text } =
    JE.object
        [ ( "level", encLevel level )
        , ( "text", JE.string text )
        ]


decoder : JD.Decoder Log
decoder =
    JD.map4 Log
        (JD.field "ok" JD.bool)
        (JD.field "level" decLevel)
        (JD.field "messages" (JD.array decMessage))
        (JD.field "details" (JD.list JD.value))


decLevel : JD.Decoder Level
decLevel =
    JD.int
        |> JD.map
            (\int ->
                case int of
                    0 ->
                        Info

                    1 ->
                        Warn

                    2 ->
                        Error

                    3 ->
                        HTML

                    4 ->
                        Stream

                    _ ->
                        Debug
            )


decMessage : JD.Decoder Message
decMessage =
    JD.map2 Message
        (JD.field "level" decLevel)
        (JD.field "text" JD.string)
