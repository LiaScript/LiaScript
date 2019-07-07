module App exposing
    ( Model
    , Msg(..)
    , init
    , main
    , subscriptions
    , update
    , view
    , viewLink
    )

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Http
import Lia.Script
import Process
import Task
import Url


project_url : String
project_url =
    "https://gitlab.com/Freinet/LiaScript"



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , state : State
    , lia : Lia.Script.Model
    , templates : Maybe Int
    , code : Maybe ( String, Int )
    , size : Float
    }


type State
    = Idle -- Wait for user Input
    | Loading -- Start to download the course if course url is defined
    | Parsing -- Running the PreParser
    | Running -- Pass all action to Lia
    | Error String -- What has happend


type alias Flags =
    { course : Maybe String
    , script : Maybe String
    , spa : Bool
    , debug : Bool
    }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        slide =
            url.fragment |> Maybe.andThen String.toInt
    in
    case ( url.query, flags.course, flags.script ) of
        ( Just query, _, _ ) ->
            ( Model key
                url
                Loading
                (Lia.Script.init_textbook
                    (get_base url)
                    query
                    (get_origin url.query)
                    slide
                )
                Nothing
                Nothing
                0
            , download Load_ReadMe_Result query
            )

        ( _, Just query, _ ) ->
            ( Model key
                { url | query = Just query }
                Loading
                (Lia.Script.init_textbook
                    (get_base url)
                    query
                    (get_origin url.query)
                    slide
                )
                Nothing
                Nothing
                0
            , download Load_ReadMe_Result query
            )

        ( _, _, Just script ) ->
            ( Model key
                url
                Parsing
                (Lia.Script.init_textbook "" script "" slide)
                Nothing
                (Just ( script, 0 ))
                (String.length script |> toFloat)
            , Cmd.none
            )

        _ ->
            ( Model key
                url
                Idle
                (Lia.Script.init_textbook "" "" "" slide)
                Nothing
                Nothing
                0
            , Cmd.none
            )


get_origin : Maybe String -> String
get_origin query =
    case query of
        Just url ->
            (url
                |> String.split "/"
                |> List.reverse
                |> List.drop 1
                |> List.reverse
                |> String.join "/"
            )
                ++ "/"

        Nothing ->
            ""


get_base : Url.Url -> String
get_base url =
    Url.toString { url | fragment = Nothing }



-- UPDATE


type Msg
    = LiaScript Lia.Script.Msg
    | LiaStart
    | LiaParse
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
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
                    [ Nav.pushUrl model.key ("#" ++ String.fromInt slide_number)
                    , Cmd.map LiaScript cmd
                    ]
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , if url.query == model.url.query then
                        Url.toString url
                            |> Nav.pushUrl model.key

                      else
                        Url.toString url
                            |> Nav.load
                    )

                Browser.External href ->
                    ( model, Nav.load href )

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
                [ Nav.replaceUrl model.key ("?" ++ model.lia.readme)
                , download Load_ReadMe_Result model.lia.readme
                ]
            )

        Load_ReadMe_Result (Ok readme) ->
            load_readme model readme

        Load_ReadMe_Result (Err info) ->
            ( { model | state = Error <| parse_error info }, Cmd.none )

        Load_Template_Result (Ok template) ->
            update
                LiaParse
                { model
                    | templates = Maybe.map ((-) 1) model.templates
                    , lia =
                        template
                            |> String.replace "\u{000D}" ""
                            |> Lia.Script.add_imports model.lia
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
            [ Nav.replaceUrl model.key ("#" ++ String.fromInt slide_number)
            , Cmd.map LiaScript cmd
            ]
    )


parsing : Model -> ( Model, Cmd Msg )
parsing model =
    case Maybe.map (Lia.Script.parse_section model.lia) model.code of
        Just ( lia, Just code ) ->
            --if modBy 4 (Lia.Script.pages model.lia) == 0 then
            --    ( { model | lia = lia, code = Just code }, message LiaParse )
            --else
            update LiaParse { model | lia = lia, code = Just code }

        Just ( lia, Nothing ) ->
            --if model.templates == Nothing then
            update LiaStart { model | lia = lia, templates = Nothing }

        --else
        --    ( { model | lia = lia }, message LiaParse )
        Nothing ->
            update LiaStart model


load_readme : Model -> String -> ( Model, Cmd Msg )
load_readme model readme =
    case
        readme
            |> String.replace "\u{000D}" ""
            |> Lia.Script.init_script model.lia
    of
        ( lia, Just ( code, line ), [] ) ->
            ( { model
                | lia = lia
                , state = Parsing
                , code = Just ( code, line )
                , size = String.length code |> toFloat
              }
            , message LiaParse
            )

        ( lia, Just ( code, line ), templates ) ->
            ( { model
                | state = Parsing
                , lia = lia
                , code = Just ( code, line )
                , size = String.length code |> toFloat
                , templates = Just <| List.length templates
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map LiaScript (Lia.Script.subscriptions model.lia)


view : Model -> Browser.Document Msg
view model =
    { title = model.lia.title
    , body =
        case model.state of
            Running ->
                [ Html.map LiaScript <| Lia.Script.view model.lia ]

            Idle ->
                [ view_idle model.lia.readme ]

            Loading ->
                [ base_div
                    [ Html.h1 [] [ Html.text "Loading" ]
                    , Html.br [] []
                    , Html.div [ Attr.class "lds-dual-ring" ] []
                    ]
                ]

            Parsing ->
                let
                    percent =
                        model.code
                            |> Maybe.map Tuple.first
                            |> Maybe.withDefault ""
                            |> String.length
                            |> toFloat
                in
                [ base_div
                    [ -- Html.h1 [] [ Html.text ("Parsing - " ++ (String.fromInt <| Array.length model.lia.sections)) ]
                      Html.h1 [] [ Html.text ("Parsing : " ++ (String.slice 0 5 <| String.fromFloat (100 - (percent / model.size * 100))) ++ "%") ]
                    , Html.br [] []
                    , Html.div [ Attr.class "lds-dual-ring" ] []
                    ]
                ]

            Error info ->
                [ base_div
                    [ Html.h1 [] [ Html.text "Load failed" ]
                    , Html.h6 [] [ Html.text model.lia.readme ]
                    , Html.p
                        [ Attr.style "margin-left" "20%"
                        , Attr.style "margin-right" "20%"
                        ]
                        [ Html.text info ]
                    ]
                ]
    }


view_idle : String -> Html Msg
view_idle url =
    base_div
        [ Html.h1 [] [ Html.text "Lia" ]
        , Html.br [] []
        , Html.br [] []
        , Html.input [ Attr.placeholder "enter course URL", Attr.value url, onInput Input ] []
        , Html.button [ Attr.class "lia-btn", onClick Load ] [ Html.text "load URL" ]
        , Html.br [] []
        , Html.br [] []
        , Html.br [] []
        , Html.a [ Attr.href project_url ] [ Html.text project_url ]
        ]


viewLink : String -> Html msg
viewLink path =
    Html.li [] [ Html.a [ Attr.href path ] [ Html.text path ] ]


base_div : List (Html msg) -> Html msg
base_div =
    Html.div
        [ Attr.style "width" "100%"
        , Attr.style "text-align" "center"
        , Attr.style "top" "25%"
        , Attr.style "position" "absolute"
        ]
