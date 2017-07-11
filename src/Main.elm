module Main exposing (..)

--import Html.Attribute (width)

import Html exposing (Html, br, button, div, h2, p, text, textarea)
import Html.Attributes exposing (style, value)
import Html.Events exposing (onInput)
import Lia exposing (Lia(..))


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { script : String
    , lia : List Lia
    , debug : String
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "# Hello World" [] "" ""
    , Cmd.none
    )



-- UPDATE


type Msg
    = Update String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update script ->
            let
                m =
                    { model | script = script, error = "" }
            in
            case Lia.parse script of
                Ok lia ->
                    ( { m | lia = lia, debug = toString lia }, Cmd.none )

                Err msg ->
                    ( { m | error = msg }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ textarea
            [ style
                [ ( "width", "100%" )
                , ( "height", "200px" )
                , ( "resize", "none" )
                ]
            , value model.script
            , onInput Update
            ]
            []
        , text model.error
        , text model.debug
        , div [] (List.map view_lia model.lia)
        ]


view_lia : Lia -> Html Msg
view_lia lia =
    case lia of
        LiaTitle str ->
            h2 [] [ text str ]

        LiaText str ->
            p [] [ text str ]



-- SUBSCRIPTIONS
-- HTTP
