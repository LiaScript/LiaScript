module Lia.Markdown.Code.Log exposing
    ( Level(..)
    , Log
    , add
    , add_Eval
    , decoder
    , empty
    , encode
    , length
    , view
    )

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode as JD
import Json.Encode as JE
import Port.Eval exposing (Eval)


type Level
    = Debug -- for debug-related messages
    | Info -- for information of any kind
    | Warn -- for warnings
    | Error -- for errors
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


empty : Log
empty =
    Log True Debug Array.empty []


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
            Html.span [ Attr.style "color" "lightblue" ] [ Html.text text ]

        Info ->
            Html.span [ Attr.style "color" "white" ] [ Html.text text ]

        Warn ->
            Html.span [ Attr.style "color" "yellow" ] [ Html.text text ]

        Error ->
            Html.span [ Attr.style "color" "red" ] [ Html.text text ]

        HTML ->
            Html.div [ Attr.property "innerHTML" <| JE.string text ] []
    )


add : Level -> String -> Log -> Log
add level str log =
    { log
        | messages =
            log.messages
                |> Array.push (Message level str)
                |> crop
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
        |> JD.andThen
            (\int ->
                JD.succeed <|
                    case int of
                        0 ->
                            Info

                        1 ->
                            Warn

                        2 ->
                            Error

                        _ ->
                            Debug
            )


decMessage : JD.Decoder Message
decMessage =
    JD.map2 Message
        (JD.field "level" decLevel)
        (JD.field "text" JD.string)
