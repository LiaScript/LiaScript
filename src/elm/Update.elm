module Update exposing
    ( Msg(..)
    , download
    , load_readme
    , message
    , parse_error
    , parsing
    , start
    , update
    )

-- UPDATE

import Browser
import Browser.Navigation as Navigation
import Http
import Lia.Script
import Model exposing (Model, State(..))
import Process
import Task
import Url exposing (Url)


type Msg
    = LiaScript Lia.Script.Msg
    | LiaStart
    | LiaParse
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | Input String
    | Load
    | Load_ReadMe_Result (Result Http.Error String)
    | Load_Template_Result (Result Http.Error String)


message : msg -> Cmd msg
message msg =
    Process.sleep 0
        |> Task.andThen (always <| Task.succeed msg)
        |> Task.perform identity


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LiaScript childMsg ->
            let
                ( lia, cmd, slide_number ) =
                    Lia.Script.update childMsg model.lia
            in
            ( { model | lia = lia }
            , if slide_number < 0 then
                Cmd.map LiaScript cmd

              else
                Cmd.batch
                    [ Navigation.pushUrl model.key ("#" ++ String.fromInt slide_number)
                    , Cmd.map LiaScript cmd
                    ]
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , if url.query == model.url.query then
                        Url.toString url
                            |> Navigation.pushUrl model.key

                      else
                        Url.toString url
                            |> Navigation.load
                    )

                Browser.External href ->
                    ( model, Navigation.load href )

        UrlChanged url ->
            case url.fragment |> Maybe.andThen String.toInt of
                Just id ->
                    let
                        ( lia, cmd, _ ) =
                            Lia.Script.load_slide (id - 1) model.lia
                    in
                    ( { model | lia = lia }, Cmd.map LiaScript cmd )

                Nothing ->
                    ( model, Cmd.none )

        LiaStart ->
            start model

        LiaParse ->
            parsing model

        Input url ->
            let
                lia =
                    model.lia
            in
            ( { model | lia = { lia | readme = url } }
            , Cmd.none
            )

        Load ->
            ( { model | state = Loading }
            , Cmd.batch
                [ Navigation.replaceUrl model.key ("?" ++ model.lia.readme)
                , download Load_ReadMe_Result model.lia.readme
                ]
            )

        Load_ReadMe_Result (Ok readme) ->
            load_readme model readme

        Load_ReadMe_Result (Err info) ->
            ( { model | state = Error <| parse_error info }, Cmd.none )

        Load_Template_Result (Ok template) ->
            parsing
                { model
                    | lia =
                        template
                            |> String.replace "\u{000D}" ""
                            |> Lia.Script.add_imports model.lia
                    , state =
                        case model.state of
                            Parsing b templates ->
                                Parsing b (templates - 1)

                            _ ->
                                model.state
                }

        Load_Template_Result (Err info) ->
            ( { model | state = Error <| parse_error info }, Cmd.none )


start : Model -> ( Model, Cmd Msg )
start model =
    let
        ( parsed, cmd, slide_number ) =
            Lia.Script.load_first_slide model.lia
    in
    ( { model | state = Running, lia = parsed }
    , if slide_number < 0 then
        Cmd.map LiaScript cmd

      else
        Cmd.batch
            [ Navigation.replaceUrl model.key ("#" ++ String.fromInt slide_number)
            , Cmd.map LiaScript cmd
            ]
    )


parsing : Model -> ( Model, Cmd Msg )
parsing model =
    case model.state of
        Parsing False 0 ->
            update LiaStart model

        Parsing True templates_to_load ->
            case model.code of
                Nothing ->
                    parsing { model | state = Parsing False templates_to_load }

                Just code ->
                    let
                        ( lia, remaining_code ) =
                            Lia.Script.parse_section model.lia code

                        new_model =
                            { model | lia = lia, code = remaining_code }
                    in
                    if modBy 4 (Lia.Script.pages lia) == 0 then
                        ( new_model, message LiaParse )

                    else
                        parsing new_model

        _ ->
            ( model, Cmd.none )


load_readme : Model -> String -> ( Model, Cmd Msg )
load_readme model readme =
    case
        readme
            |> String.replace "\u{000D}" ""
            |> Lia.Script.init_script model.lia
    of
        ( lia, Just code, [] ) ->
            ( { model
                | lia = lia
                , state = Parsing True 0
                , code = Just code
                , size = String.length code |> toFloat
              }
            , message LiaParse
            )

        ( lia, Just code, templates ) ->
            ( { model
                | lia = lia
                , state = Parsing True <| List.length templates
                , code = Just code
                , size = String.length code |> toFloat
              }
            , templates
                |> List.map (download Load_Template_Result)
                |> (::) (message LiaParse)
                |> Cmd.batch
            )

        ( lia, Nothing, _ ) ->
            ( { model
                | state =
                    lia.error
                        |> Maybe.withDefault ""
                        |> Error
              }
            , Cmd.none
            )


parse_error : Http.Error -> String
parse_error msg =
    case msg of
        Http.BadUrl url ->
            "Bad Url " ++ url

        Http.Timeout ->
            "Network timeout"

        Http.BadStatus int ->
            "Bad status " ++ String.fromInt int

        Http.NetworkError ->
            "Network error"

        Http.BadBody body ->
            "Bad body " ++ body


download : (Result Http.Error String -> Msg) -> String -> Cmd Msg
download msg url =
    Http.get { url = url, expect = Http.expectString msg }
