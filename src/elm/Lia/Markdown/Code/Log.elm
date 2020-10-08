module Lia.Markdown.Code.Log exposing
    ( Log
    , add_Debug
    , add_Error
    , add_Eval
    , add_HTML
    , add_Info
    , add_Warn
    , decoder
    , empty
    , encode
    , view
    )

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
    , messages : List Message
    , lines : Int
    , details : List JE.Value
    }


empty : Log
empty =
    Log True Debug [] 0 []


maxLines : Int
maxLines =
    250


view : Log -> List (Html msg)
view log =
    log.messages
        |> List.reverse
        |> List.map view_message


view_message : Message -> Html msg
view_message { level, text } =
    case level of
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


add_Debug : String -> Log -> Log
add_Debug =
    add_ Debug


add_Info : String -> Log -> Log
add_Info =
    add_ Info


add_Warn : String -> Log -> Log
add_Warn =
    add_ Warn


add_Error : String -> Log -> Log
add_Error =
    add_ Error


add_HTML : String -> Log -> Log
add_HTML =
    add_ HTML


add_ : Level -> String -> Log -> Log
add_ level str log =
    let
        lines =
            str
                |> String.lines
                |> List.length
    in
    --shrink <|
    case log.messages of
        x :: xs ->
            { log
                | lines = log.lines + lines - 1
                , messages =
                    if x.level == level && x.level /= HTML then
                        { x | text = x.text ++ str } :: xs

                    else
                        Message level str :: x :: xs
            }

        [] ->
            { log
                | lines = lines
                , messages = [ Message level str ]
            }


add_Eval : Eval -> Log -> Log
add_Eval eval log =
    (if eval.ok then
        add_Info eval.result

     else
        add_Error eval.result
    )
    <|
        { log | ok = eval.ok, details = eval.details }


shrink : Log -> Log
shrink log =
    if log.lines < maxLines then
        log

    else
        let
            ( lines, messages ) =
                log.messages
                    |> List.reverse
                    |> cut_log log.lines
        in
        { log
            | lines = lines
            , messages =
                messages
                    |> List.reverse
        }


cut_log : Int -> List Message -> ( Int, List Message )
cut_log lines list =
    if lines < maxLines then
        ( lines, list )

    else
        case list of
            [] ->
                ( 0, [] )

            msg :: msgs ->
                if msg.level == HTML then
                    cut_log (lines - 1) msgs

                else
                    let
                        text_ =
                            String.lines msg.text

                        lines_ =
                            List.length text_

                        offset =
                            --10005 - 12 = 99993
                            lines - lines_
                    in
                    if offset >= maxLines then
                        cut_log offset msgs

                    else
                        ( offset
                        , { msg
                            | text =
                                text_
                                    |> List.drop (maxLines - offset)
                                    |> List.intersperse "\n"
                                    |> String.concat
                          }
                            :: msgs
                        )


encode : Log -> JE.Value
encode log =
    JE.object
        [ ( "ok", JE.bool log.ok )
        , ( "level", encLevel log.level )
        , ( "messages", JE.list encMessage log.messages )
        , ( "lines", JE.int log.lines )
        , ( "details", JE.list identity log.details )
        ]


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
    JD.map5 Log
        (JD.field "ok" JD.bool)
        (JD.field "level" decLevel)
        (JD.field "messages" (JD.list decMessage))
        (JD.field "lines" JD.int)
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
