port module Update exposing
    ( Msg(..)
    , download
    , initIndex
    , load_readme
    , message
    , parse_error
    , parsing
    , start
    , subscriptions
    , update
    )

-- UPDATE

import Browser
import Browser.Events
import Browser.Navigation as Navigation
import Http
import Index.Update as Index
import Json.Encode as JE
import Lia.Json.Decode
import Lia.Script
import Model exposing (Model, State(..))
import Port.Event as Event exposing (Event)
import Process
import Session exposing (Screen)
import Task
import Url exposing (Url)


port event2js : Event -> Cmd msg


port event2elm : (Event -> msg) -> Sub msg


type Msg
    = LiaScript Lia.Script.Msg
    | Handle Event
    | UpdateIndex Index.Msg
    | Resize Screen
    | LiaStart
    | LiaParse
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Load_ReadMe_Result String (Result Http.Error String)
    | Load_Template_Result (Result Http.Error String)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ event2elm Handle
        , Sub.map LiaScript (Lia.Script.subscriptions model.lia)
        , Sub.map Resize (Browser.Events.onResize Screen)
        ]


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
                ( lia, cmd, events ) =
                    Lia.Script.update childMsg model.lia
            in
            ( { model | lia = { lia | load_slide = -1 } }
            , events
                |> List.map event2js
                |> (::)
                    (if lia.load_slide < 0 then
                        Cmd.none

                     else
                        Session.navToSlide model.session lia.load_slide
                    )
                |> (::) (Cmd.map LiaScript cmd)
                |> Cmd.batch
            )

        Handle event ->
            case event.topic of
                "index" ->
                    update
                        (event.message
                            |> Index.handle
                            |> UpdateIndex
                        )
                        model

                "restore" ->
                    case Lia.Json.Decode.decode event.message of
                        Ok lia ->
                            start { model | lia = lia }

                        Err info ->
                            ( model, Cmd.none )

                _ ->
                    update
                        (event
                            |> Lia.Script.handle
                            |> LiaScript
                        )
                        model

        UpdateIndex childMsg ->
            let
                ( index, cmd, events ) =
                    Index.update childMsg model.index
            in
            ( { model | index = index }
            , events
                |> List.map (Event.encode >> Event "index" -1 >> event2js)
                |> (::) (Cmd.map UpdateIndex cmd)
                |> Cmd.batch
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , if url.query == model.session.url.query then
                        Session.navTo model.session url

                      else
                        Url.toString url
                            |> Navigation.load
                    )

                Browser.External href ->
                    ( model, Navigation.load href )

        UrlChanged url ->
            if url /= model.session.url then
                case url.fragment |> Maybe.andThen String.toInt of
                    Just id ->
                        let
                            ( lia, cmd, events ) =
                                Lia.Script.load_slide (id - 1) model.lia
                        in
                        ( { model
                            | lia = lia
                            , session = Session.setUrl url model.session
                          }
                        , events
                            |> List.map event2js
                            |> (::) (Cmd.map LiaScript cmd)
                            |> Cmd.batch
                        )

                    Nothing ->
                        ( model, Cmd.none )

            else
                ( model, Cmd.none )

        Resize screen ->
            let
                session =
                    model.session
            in
            ( { model | session = { session | screen = screen } }, Cmd.none )

        LiaStart ->
            start model

        LiaParse ->
            parsing model

        Load_ReadMe_Result _ (Ok readme) ->
            load_readme readme model

        Load_ReadMe_Result url (Err info) ->
            ( { model | state = Error <| parse_error info }
            , url
                |> JE.string
                |> Event "offline" -1
                |> event2js
            )

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
        ( parsed, cmd, events ) =
            Lia.Script.load_first_slide model.lia
    in
    ( { model | state = Running, lia = { parsed | load_slide = -1 } }
    , events
        |> List.map event2js
        |> (::)
            (if parsed.load_slide < 0 then
                Cmd.none

             else
                Navigation.pushUrl model.session.key ("#" ++ String.fromInt parsed.load_slide)
            )
        |> (::) (Cmd.map LiaScript cmd)
        |> Cmd.batch
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


load_readme : String -> Model -> ( Model, Cmd Msg )
load_readme readme model =
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


initIndex : Model -> ( Model, Cmd Msg )
initIndex model =
    ( model, event2js Index.init )
