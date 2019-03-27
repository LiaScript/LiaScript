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
    , templates : Int
    }


type State
    = Waiting -- Wait for user Input
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
            ( Model key url Loading (Lia.Script.init_textbook (get_base query) query "" slide) 0
            , download Load_ReadMe_Result query
            )

        ( _, Just query, _ ) ->
            ( Model key { url | query = Just query } Loading (Lia.Script.init_textbook (get_base query) query "" slide) 0
            , download Load_ReadMe_Result query
            )

        ( _, _, Just script ) ->
            ( Model key url Parsing (Lia.Script.init_textbook "" script "" slide) 0
            , Cmd.none
            )

        _ ->
            ( Model key url Waiting (Lia.Script.init_textbook "" "" "" slide) 0
            , Cmd.none
            )


get_base : String -> String
get_base url =
    url
        |> String.split "/"
        |> List.reverse
        |> List.drop 1
        |> (::) ""
        |> List.reverse
        |> String.join "/"



-- UPDATE


type Msg
    = LiaScript Lia.Script.Msg
    | LiaStart
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Input String
    | Load
    | Load_ReadMe_Result (Result Http.Error String)
    | Load_Template_Result (Result Http.Error String)


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

        LiaStart ->
            let
                ( parsed, cmd, slide_number ) =
                    Lia.Script.load_first_slide model.lia.section_active model.lia
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
                Just idx ->
                    let
                        ( lia, cmd, _ ) =
                            Lia.Script.load_slide (idx - 1) model.lia
                    in
                    ( { model | lia = lia }, Cmd.map LiaScript cmd )

                Nothing ->
                    ( model, Cmd.none )

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
            case
                readme
                    |> String.replace "\u{000D}" ""
                    |> Lia.Script.set_script model.lia
            of
                ( lia, [] ) ->
                    update LiaStart { model | lia = lia }

                ( lia, templates ) ->
                    ( { model
                        | state = Loading
                        , lia = lia
                        , templates = List.length templates
                      }
                    , templates
                        |> List.map (download Load_Template_Result)
                        |> Cmd.batch
                    )

        Load_ReadMe_Result (Err info) ->
            ( { model | state = Error <| parse_error info }, Cmd.none )

        Load_Template_Result (Ok template) ->
            let
                new_model =
                    { model
                        | templates = model.templates - 1
                        , lia =
                            template
                                |> String.replace "\u{000D}" ""
                                |> Lia.Script.add_imports model.lia
                    }
            in
            if model.templates == 1 then
                update LiaStart new_model

            else
                ( new_model, Cmd.none )

        Load_Template_Result (Err info) ->
            ( { model | state = Error <| parse_error info }, Cmd.none )


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



--download : Msg -> String -> Cmd Msg


download : (Result Http.Error String -> Msg) -> String -> Cmd Msg
download msg url =
    Http.get
        { url = url
        , expect = Http.expectString msg
        }



--    Http.request
--        { method = "GET"
--        , headers = []
--        , url = url
--        , body = Http.emptyBody
--        , expect = Http.expectString DownloadResult
--        , timeout = Nothing
--        , tracker = Nothing --Just "download"
--        }
-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map LiaScript (Lia.Script.subscriptions model.lia)



{-
   case model.state of
       Loading _ ->
           Http.track "download" Tracking

       _ ->
           Sub.none
-}
-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = model.lia.title
    , body =
        case model.state of
            Running ->
                [ Html.map LiaScript <| Lia.Script.view model.lia ]

            Waiting ->
                [ view_waiting model.lia.readme ]

            Loading ->
                [ base_div
                    [ Html.h1 [] [ Html.text "Loading" ]
                    , Html.br [] []
                    , Html.div [ Attr.class "lds-dual-ring" ] []
                    ]
                ]

            Parsing ->
                [ base_div
                    [ Html.h1 [] [ Html.text "Parsing" ]
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


view_waiting : String -> Html Msg
view_waiting url =
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
