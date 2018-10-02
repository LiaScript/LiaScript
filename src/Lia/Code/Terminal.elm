module Lia.Code.Terminal exposing (Model, init, update, view)

import Array exposing (Array)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as JD
import Json.Encode as JE


type alias Model =
    { input : String
    , output : String
    , history : Array String
    , history_value : Int
    , max_length : Int
    }


init : Model
init =
    Model "" "" Array.empty 0 15



-- UPDATE


type Msg
    = KeyDown Int
    | Stdin String
    | Stdout String
    | Stderr String


update : Msg -> Model -> ( Model, Maybe String )
update msg model =
    case msg of
        KeyDown key ->
            if key == 13 then
                ( print2terminal model, Just model.input )

            else if key == 38 then
                ( restore_input True model, Nothing )

            else if key == 40 then
                ( restore_input False model, Nothing )

            else
                ( model, Nothing )

        Stdin str ->
            ( { model | input = str }, Nothing )

        Stdout str ->
            ( { model | output = add2output model.max_length model.output str }, Nothing )

        Stderr str ->
            ( { model | output = add2output model.max_length model.output str }, Nothing )



-- VIEW


view : Model -> Html Msg
view model =
    let
        px =
            model.output
                |> String.lines
                |> List.length
                |> (*) 16
                |> (+) 16
                |> toString
                |> JE.string
    in
    Html.div
        [ styling
        ]
        [ if model.output == "" then
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
                [ --List.indexedMap (,) model.output
                  --  |> List.map (\( i, s ) -> toString i ++ ": " ++ s)
                  --  |> String.concat
                  Html.text model.output
                ]
        , Html.code [] [ Html.text ">> " ]
        , Html.input
            [ onInput Stdin
            , onKeyDown KeyDown
            , Attr.value model.input
            , Attr.style
                [ ( "background-color", "black" )
                , ( "color", "white" )
                , ( "border", "0" )
                , ( "width", "calc(100% - 28px)" )
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


print2terminal : Model -> Model
print2terminal model =
    if
        (model.history
            |> Array.get model.history_value
            |> Maybe.map (\h -> h /= model.input)
            |> Maybe.withDefault True
        )
            && (model.input /= "")
    then
        { model
            | input = ""
            , output = add2output model.max_length model.output (model.input ++ "\n")
            , history = Array.push model.input model.history
            , history_value = Array.length model.history + 1
        }

    else
        { model
            | input = ""
            , output = add2output model.max_length model.output (model.input ++ "\n")
            , history_value = model.history_value + 1
        }


restore_input : Bool -> Model -> Model
restore_input up model =
    let
        new_hist =
            if up then
                model.history_value - 1

            else
                model.history_value + 1
    in
    case Array.get new_hist model.history of
        Just str ->
            { model | input = str, history_value = new_hist }

        Nothing ->
            model


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
