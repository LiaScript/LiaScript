port module Main exposing
    ( Model
    , Msg(..)
    , State(..)
    , getCourse
    , get_base
    , get_hash
    , init
    , main
    , style
    , subscriptions
    , update
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Http
import Lia
import Navigation


port initialize : ( String, String ) -> Cmd msg


main : Program { url : String, script : String, slide : Int } Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


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


init : { url : String, script : String, slide : Int } -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        url =
            String.dropLeft 1 location.search

        slide =
            if flags.slide <= 0 then
                get_hash location

            else
                Just flags.slide

        origin =
            location.origin ++ location.pathname
    in
    if flags.script /= "" then
        let
            lia =
                flags.script
                    |> Lia.set_script (Lia.init_presentation (get_base url) "" origin slide)
        in
        ( Model "" "" lia LoadOk "", initialize ( Lia.get_title lia, origin ) )

    else if flags.url /= "" then
        ( Model flags.url
            origin
            (Lia.init_presentation (get_base url) flags.url origin slide)
            Loading
            ""
        , getCourse flags.url
        )

    else if url == "" then
        ( Model "https://raw.githubusercontent.com/liaScript/docs/master/README.md"
            origin
            (Lia.init_presentation "" "" origin slide)
            Waiting
            ""
        , Cmd.none
        )

    else
        ( Model url origin (Lia.init_presentation (get_base url) url origin slide) Loading "", getCourse url )


get_base : String -> String
get_base url =
    url |> String.split "/" |> List.reverse |> List.drop 1 |> (::) "" |> List.reverse |> String.join "/"


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
    | Update String
    | Load
    | UrlChange Navigation.Location
    | Script String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LIA liaMsg ->
            let
                ( lia, cmd ) =
                    Lia.update liaMsg model.lia
            in
            ( { model | lia = lia }, Cmd.map LIA cmd )

        GET (Ok script) ->
            let
                lia =
                    Lia.set_script model.lia script
            in
            ( { model
                | lia = { lia | readme = model.url }
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
                , initialize ( Lia.get_title lia, model.url )
                ]
            )

        GET (Err msg) ->
            ( { model | error = toString msg, state = LoadFail }, Cmd.none )

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
                        ( lia, cmd ) =
                            Lia.load_slide model.lia (idx - 1)
                    in
                    ( { model | lia = lia }, Cmd.map LIA cmd )

                Nothing ->
                    ( model, Cmd.none )

        Script script ->
            update (GET (Result.Ok script)) model



-- VIEW


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            Html.div [ style ]
                [ Html.h2 [] [ Html.text "Loading ..." ] ]

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
    Sub.map LIA (Lia.subscriptions model.lia)
