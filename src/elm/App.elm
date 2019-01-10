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

--import Lia.Model

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Http
import Lia.Script
import Url


project_url : String
project_url =
    "https://gitlab.com/OvGU-ESS/eLab_v2/lia_script"



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
    case ( url.query, flags.course, flags.script ) of
        ( Just query, _, _ ) ->
            ( Model key url Loading (Lia.Script.init_textbook query "" "")
            , Cmd.none
            )

        ( _, Just query, _ ) ->
            ( Model key { url | query = Just query } Loading (Lia.Script.init_textbook query "" "")
            , Cmd.none
            )

        ( _, _, Just script ) ->
            ( Model key url Parsing (Lia.Script.init_textbook "" script "")
            , Cmd.none
            )

        _ ->
            ( Model key url Waiting (Lia.Script.init_textbook "" "" ""), Cmd.none )



-- UPDATE


type Msg
    = LiaScript Lia.Script.Msg
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Input String
    | Download
    | DownloadResult (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LiaScript childMsg ->
            --            let
            --                ( lia, cmd ) =
            --                    Lia.Script.update childMsg model.lia
            --            in
            ( model, Cmd.none )

        -- LiaScript cmd )
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )

        Input url ->
            let
                lia =
                    model.lia
            in
            ( { model | lia = { lia | readme = url } }
            , Cmd.none
            )

        Download ->
            ( { model | state = Loading }
            , get_course model.lia.readme
            )

        DownloadResult (Ok readme) ->
            let
                lia =
                    Lia.Script.set_script model.lia readme
            in
            ( { model
                | state = Running
                , lia = lia
              }
            , Cmd.none
            )

        DownloadResult (Err error) ->
            let
                info =
                    case error of
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
            in
            ( { model | state = Error info }, Cmd.none )


get_course : String -> Cmd Msg
get_course url =
    Http.get
        { url = url
        , expect = Http.expectString DownloadResult
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
    Sub.none



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
    { title = "Lia"
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
                        [ text info ]
                    ]
                ]
    }


view_waiting : String -> Html Msg
view_waiting url =
    base_div
        [ h1 [] [ text "Lia" ]
        , br [] []
        , br [] []
        , input [ Attr.placeholder "enter course URL", Attr.value url, onInput Input ] []
        , button [ Attr.class "lia-btn", onClick Download ] [ text "load URL" ]
        , br [] []
        , br [] []
        , br [] []
        , a [ Attr.href project_url ] [ text project_url ]
        ]


viewLink : String -> Html msg
viewLink path =
    li [] [ a [ Attr.href path ] [ text path ] ]


base_div : List (Html msg) -> Html msg
base_div =
    Html.div
        [ Attr.style "width" "100%"
        , Attr.style "text-align" "center"
        , Attr.style "top" "25%"
        , Attr.style "position" "absolute"
        ]
