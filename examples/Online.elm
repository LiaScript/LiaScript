port module Main exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Lia
import Navigation


port tx_log : ( String, JE.Value ) -> Cmd msg


port rx_log : (( String, JD.Value ) -> msg) -> Sub msg


main : Program { url : String, script : String } Model Msg
main =
    Navigation.programWithFlags UrlChange
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


type alias Model =
    { url : String
    , origin : String
    , lia : Lia.Model
    , state : State
    , error : String
    }


init : { url : String, script : String } -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        url =
            String.dropLeft 1 location.search

        slide =
            get_hash location

        origin =
            location.origin
    in
    if flags.script /= "" then
        let
            ( lia, cmd, _ ) =
                flags.script
                    |> Lia.set_script (Lia.init_presentation Nothing Nothing)
                    |> Lia.init
        in
        ( Model "" "" lia LoadOk "", Cmd.map LIA cmd )
    else if url == "" then
        ( Model "https://raw.githubusercontent.com/liaScript/liascript.github.com/master/README.md"
            origin
            (Lia.init_presentation Nothing Nothing)
            Waiting
            ""
        , Cmd.none
        )
    else
        ( Model url origin (Lia.init_presentation (Just url) slide) Loading "", getCourse url )


get_hash : Navigation.Location -> Maybe Int
get_hash location =
    location.hash
        |> String.dropLeft 1
        |> String.toInt
        |> Result.toMaybe



-- UPDATE


type Msg
    = GET (Result Http.Error String)
    | LIA Lia.Msg
    | RxLog ( String, JE.Value )
    | Update String
    | Load
    | UrlChange Navigation.Location


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
            let
                ( lia, cmd, _ ) =
                    script
                        |> Lia.set_script model.lia
                        |> Lia.init
            in
            ( { model
                | lia = lia
                , error = ""
                , state = LoadOk
              }
            , Cmd.batch
                [ Navigation.newUrl
                    (model.origin
                        ++ "?"
                        ++ model.url
                        ++ "#"
                        ++ toString (lia.section_active + 1)
                    )
                , Cmd.map LIA cmd
                ]
            )

        GET (Err msg) ->
            ( { model | error = toString msg, state = LoadFail }, Cmd.none )

        RxLog m ->
            ( { model | lia = Lia.restore model.lia m }, Cmd.none )

        Update url ->
            ( { model | url = url }, Cmd.none )

        Load ->
            let
                x =
                    Navigation.newUrl model.url
            in
            ( { model | state = Loading }, getCourse model.url )

        UrlChange location ->
            case get_hash location of
                Just idx ->
                    let
                        ( lia, cmd, _ ) =
                            Lia.load_slide model.lia (idx - 1)
                    in
                    ( { model | lia = lia }, Cmd.map LIA cmd )

                Nothing ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            Html.div [ style ]
                [ Html.h2 [] [ Html.text "Loading ..." ]
                , Html.img [ Attr.src "/images/load.gif", Attr.width 350 ] []

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
