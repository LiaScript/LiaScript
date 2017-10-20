port module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Lia


port tx_log : ( String, JE.Value ) -> Cmd msg


port rx_log : (( String, JD.Value ) -> msg) -> Sub msg


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type State
    = Loading
    | Waiting
    | LoadOk
    | LoadFail


type alias Flags =
    { url : String
    , script : String
    }


type alias Model =
    { url : String
    , lia : Lia.Model
    , state : State
    , error : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    if flags.script /= "" then
        ( Model "" (Lia.init_slides Nothing |> Lia.parse flags.script) LoadOk ""
        , Cmd.none
        )
    else if flags.url /= "" then
        ( Model flags.url (Lia.init_slides (Just flags.url)) Loading ""
        , getCourse flags.url
        )
    else
        ( Model "https://raw.githubusercontent.com/liaScript/liascript.github.com/master/README.md" (Lia.init_slides (Just "https://raw.githubusercontent.com/liaScript/liascript.github.com/master/README.md")) Waiting ""
        , Cmd.none
        )



-- UPDATE


type Msg
    = GET (Result Http.Error String)
    | LIA Lia.Msg
    | RxLog ( String, JE.Value )
    | Update String
    | Load


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LIA liaMsg ->
            let
                ( lia, cmd, info ) =
                    Lia.update liaMsg model.lia
            in
            case info of
                Just m ->
                    ( { model | lia = lia }, tx_log m )

                _ ->
                    ( { model | lia = lia }, Cmd.map LIA cmd )

        GET (Ok script) ->
            ( { model
                | lia = Lia.parse script model.lia
                , error = ""
                , state = LoadOk
              }
            , Cmd.none
            )

        GET (Err msg) ->
            ( { model | error = toString msg, state = LoadFail }, Cmd.none )

        RxLog m ->
            ( { model | lia = Lia.restore model.lia m }, Cmd.none )

        Update url ->
            ( { model | url = url }, Cmd.none )

        Load ->
            ( { model | state = Loading }, getCourse model.url )



-- VIEW


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            Html.div [ style ]
                [ Html.h2 [] [ Html.text "Loading ..." ]
                , Html.img [ Attr.src "load.gif", Attr.width 350 ] []

                --, Html.a [ Attr.href model.url, Attr.align "center" ] [ Html.text model.url ]
                ]

        LoadOk ->
            Html.map LIA <| Lia.view model.lia

        LoadFail ->
            Html.div [ style ]
                [ Html.h2 [] [ Html.text "Load failed" ]
                , Html.h6 [] [ Html.text model.url ]
                , Html.text model.error
                ]

        Waiting ->
            Html.div [ style ]
                [ Html.h1 [] [ Html.text "LiaScript" ]
                , Html.br [] []
                , Html.br [] []
                , Html.button [ Attr.class "lia-btn", onClick Load ] [ Html.text "Load URL" ]
                , Html.input [ onInput Update, Attr.value model.url ] []
                , Html.br [] []
                , Html.br [] []
                , Html.br [] []
                , Html.a [ Attr.href "https://gitlab.com/OvGU-ESS/eLab_v2/lia_script" ] [ Html.text "https://gitlab.com/OvGU-ESS/eLab_v2/lia_script" ]
                ]


style : Html.Attribute msg
style =
    Attr.style
        [ ( "width", "350px" )
        , ( "height", "300px" )
        , ( "position", "absolute" )
        , ( "top", "0" )
        , ( "bottom", "0" )
        , ( "left", "0" )
        , ( "right", "0" )
        , ( "margin", "auto" )
        ]



-- SUBSCRIPTIONS
-- HTTP


getCourse : String -> Cmd Msg
getCourse url =
    Http.send GET <| Http.getString url


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ rx_log RxLog ]
