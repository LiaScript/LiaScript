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

{-| The terminal output of a code project.
-}

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


{-| `ok` and `details` (editor annotations per file) come from the last
evaluation. `level` is stored but never changed.
-}
type alias Log =
    { ok : Bool
    , level : Level
    , messages : Array Message
    , details : List JE.Value
    }


{-| Level names as sent by JavaScript (`console.log`, `console.warn`, ...).
-}
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


{-| Every message keyed by its text, for `Html.Keyed`.
-}
view : Log -> List ( String, Html msg )
view =
    .messages >> Array.toList >> List.map viewMessage


viewMessage : Message -> ( String, Html msg )
viewMessage { level, text } =
    ( text
    , case level of
        Debug ->
            viewText "text-debug" Nothing text

        Info ->
            viewText "text-info" Nothing text

        Warn ->
            viewText "text-warning" (Just "warning") text

        Error ->
            viewText "text-error" (Just "error") text

        HTML ->
            Html.div
                [ Attr.class "text-info"
                , Attr.property "innerHTML" <| JE.string text
                ]
                []

        Stream ->
            viewText "text-info" Nothing text
    )


{-| Warnings and errors are not only shown by their color, their level is also
read out.
-}
viewText : String -> Maybe String -> String -> Html msg
viewText class label text =
    Html.div
        [ Attr.class class ]
        (case label of
            Just level ->
                [ Html.span [ Attr.class "hidden-visually" ] [ Html.text (level ++ ": ") ]
                , Html.text text
                ]

            Nothing ->
                [ Html.text text ]
        )


{-| Append a message, a `Stream` message continues a preceding `Stream`
message. Only the last 249 messages are kept.
-}
add : Level -> String -> Log -> Log
add level text log =
    { log
        | messages =
            crop <|
                case ( level, array_getLast log.messages ) of
                    ( Stream, Just last ) ->
                        if last.level == Stream then
                            array_setLast (Message Stream (last.text ++ text)) log.messages

                        else
                            Array.push (Message level text) log.messages

                    _ ->
                        Array.push (Message level text) log.messages
    }


crop : Array Message -> Array Message
crop messages =
    if Array.length messages < 250 then
        messages

    else
        Array.slice 1 250 messages


{-| Add the result of an evaluation as info or error and take over its
`ok` and `details`.
-}
add_Eval : Eval -> Log -> Log
add_Eval eval log =
    add
        (if eval.ok then
            Info

         else
            Error
        )
        eval.result
        { log | ok = eval.ok, details = eval.details }


{-| The number of line breaks within all messages.
-}
length : Array Message -> Int
length =
    Array.foldl (\message sum -> sum + List.length (String.indexes "\n" message.text)) 0


encode : Log -> JE.Value
encode log =
    JE.object
        [ ( "ok", JE.bool log.ok )
        , ( "level", encodeLevel log.level )
        , ( "messages", JE.array encodeMessage log.messages )
        , ( "details", JE.list identity log.details )
        ]


encodeLevel : Level -> JE.Value
encodeLevel level =
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


encodeMessage : Message -> JE.Value
encodeMessage { level, text } =
    JE.object
        [ ( "level", encodeLevel level )
        , ( "text", JE.string text )
        ]


decoder : JD.Decoder Log
decoder =
    JD.map4 Log
        (JD.field "ok" JD.bool)
        (JD.field "level" decodeLevel)
        (JD.field "messages" (JD.array decodeMessage))
        (JD.field "details" (JD.list JD.value))


{-| Inverse of `encodeLevel`, unknown numbers become `Debug`.
-}
decodeLevel : JD.Decoder Level
decodeLevel =
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


decodeMessage : JD.Decoder Message
decodeMessage =
    JD.map2 Message
        (JD.field "level" decodeLevel)
        (JD.field "text" JD.string)
