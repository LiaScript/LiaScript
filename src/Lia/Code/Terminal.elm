module Lia.Code.Terminal exposing (Msg(..), Terminal, init, update, view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as JD
import Json.Encode as JE


type alias Terminal =
    { input : String
    , output : String
    , history : Array String
    , history_value : Int
    , max_length : Int
    }


init : Terminal
init =
    Terminal "" "" Array.empty 0 250



-- UPDATE


type Msg
    = KeyDown Int
    | Stdin String
    | Stdout String
    | Stderr String


update : Msg -> Terminal -> ( Terminal, Maybe String )
update msg terminal =
    case msg of
        KeyDown key ->
            if key == 13 then
                ( print_to terminal, Just terminal.input )

            else if key == 38 then
                ( restore_input True terminal, Nothing )

            else if key == 40 then
                ( restore_input False terminal, Nothing )

            else
                ( terminal, Nothing )

        Stdin str ->
            ( { terminal | input = str }, Nothing )

        Stdout str ->
            ( { terminal | output = add2output terminal.max_length terminal.output str }, Nothing )

        Stderr str ->
            ( { terminal | output = add2output terminal.max_length terminal.output str }, Nothing )



-- VIEW


view : Terminal -> Html Msg
view terminal =
    let
        px =
            terminal.output
                |> String.lines
                |> List.length
                |> (*) 16
                |> (+) 16
                |> toString
                |> JE.string
    in
    Html.div
        [ Attr.class "lia-code-stdout"
        , styling
        ]
        [ if terminal.output == "" then
            Html.text ""

          else
            Html.pre
                [ Attr.style
                    [ ( "margin", "0px" )
                    , ( "overflow-y", "auto" )
                    , ( "max-height", "250px" )
                    , ( "word-wrap", "normal" )
                    , ( "word-break", "keep-all" )
                    , ( "white-space", "pre-wrap" )
                    , ( "border-bottom", "1px solid white" )
                    ]
                , Attr.property "scrollTop" px
                ]
                [ --List.indexedMap (,) terminal.output
                  --  |> List.map (\( i, s ) -> toString i ++ ": " ++ s)
                  --  |> String.concat
                  Html.text terminal.output
                ]
        , Html.code [] [ Html.text ">> " ]
        , Html.input
            [ onInput Stdin
            , onKeyDown KeyDown
            , Attr.value terminal.input
            , Attr.style
                [ ( "background-color", "black" )
                , ( "color", "white" )
                , ( "border", "0" )
                , ( "width", "calc(100% - 30px)" )
                ]
            ]
            []
        ]


styling : Html.Attribute msg
styling =
    Attr.style
        [ ( "width", "100%" )
        , ( "min-height", "20px" )
        , ( "max-height", "280px" )
        , ( "background-color", "black" )
        , ( "color", "white" )
        ]


print_to : Terminal -> Terminal
print_to terminal =
    if
        (terminal.history
            |> Array.get terminal.history_value
            |> Maybe.map (\h -> h /= terminal.input)
            |> Maybe.withDefault True
        )
            && (terminal.input /= "")
    then
        { terminal
            | input = ""
            , output = add2output terminal.max_length terminal.output (terminal.input ++ "\n")
            , history = Array.push terminal.input terminal.history
            , history_value = Array.length terminal.history + 1
        }

    else
        { terminal
            | input = ""
            , output = add2output terminal.max_length terminal.output (terminal.input ++ "\n")
            , history_value = terminal.history_value + 1
        }


restore_input : Bool -> Terminal -> Terminal
restore_input up terminal =
    let
        new_hist =
            if up then
                terminal.history_value - 1

            else
                terminal.history_value + 1
    in
    case Array.get new_hist terminal.history of
        Just str ->
            { terminal | input = str, history_value = new_hist }

        Nothing ->
            terminal


add2output : Int -> String -> String -> String
add2output max_length output input =
    let
        new_output =
            output
                ++ input
                |> String.lines

        len =
            List.length new_output
    in
    if len < max_length then
        output ++ input

    else
        new_output
            |> List.drop (len - max_length)
            |> List.intersperse "\n"
            |> String.concat


onKeyDown : (Int -> msg) -> Html.Attribute msg
onKeyDown tagger =
    on "keydown" (JD.map tagger keyCode)
