module Lia.Markdown.Code.Log exposing
    ( Log
    , add_Debug
    , add_Error
    , add_Eval
    , add_Info
    , add_Warn
    , clear
    , decode
    , decoder
    , empty
    , encode
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode as JD
import Json.Encode as JE
import Lia.Event exposing (Eval)


type Level
    = Debug -- for debug-related messages
    | Info -- for information of any kind
    | Warn -- for warnings
    | Error -- for errors


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


view : Log -> List (Html msg)
view log =
    log.messages
        |> List.reverse
        |> List.map view_message


view_message : Message -> Html msg
view_message { level, text } =
    Html.span [ view_level level ] [ Html.text text ]


view_level : Level -> Html.Attribute msg
view_level level =
    Attr.style "color" <|
        case level of
            Debug ->
                "lightblue"

            Info ->
                "white"

            Warn ->
                "yellow"

            Error ->
                "red"


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


clear : Log -> Log
clear log =
    { log | lines = 0, messages = [] }


add_ : Level -> String -> Log -> Log
add_ level str log =
    let
        lines =
            str
                |> String.lines
                |> List.length
    in
    --    shrink <|
    case log.messages of
        x :: xs ->
            { log
                | lines = log.lines + lines - 1
                , messages =
                    if x.level == level then
                        { x | text = x.text ++ str } :: xs

                    else
                        Message level str :: x :: xs
            }

        [] ->
            { log | lines = lines, messages = [ Message level str ] }


add_Eval : Eval -> Log -> Log
add_Eval eval log =
    { log | ok = eval.ok, details = eval.details }
        |> (if eval.ok then
                add_Info

            else
                add_Error
           )
            eval.result



-- max_lines : Int
-- max_lines =
--     1000
--
--
-- shrink : Log -> Log
-- shrink log =
--     if log.lines <= max_lines then
--         log
--
--     else
--         { log
--             | lines = max_lines
--             , messages =
--                 log.messages
--                     |> List.reverse
--                     |> cut_log log.lines
--                     |> List.reverse
--         }
--
--
-- cut_log : Int -> List Message -> List Message
-- cut_log lines list =
--     case list of
--         [] ->
--             []
--
--         msg :: msgs ->
--             let
--                 msg_text =
--                     Debug.log "Text" <| String.lines msg.text
--
--                 msg_lines =
--                     Debug.log "Lines" <| List.length msg_text
--
--                 offset =
--                     Debug.log "Offset" (lines - msg_lines)
--             in
--             if offset < max_lines then
--                 { msg
--                     | text =
--                         msg_text
--                             |> List.drop (max_lines - offset)
--                             |> List.intersperse "\n"
--                             |> String.concat
--                 }
--                     :: msgs
--
--             else
--                 cut_log offset msgs


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


encMessage : Message -> JE.Value
encMessage { level, text } =
    JE.object
        [ ( "level", encLevel level )
        , ( "text", JE.string text )
        ]


decode : JD.Value -> Result JD.Error Log
decode json =
    JD.decodeValue decoder json


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
