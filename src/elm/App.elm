module App exposing (Model, Msg(..), init, main, subscriptions, update, view, viewLink)

--import Lia
--import Lia.Model

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Http
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
    , lia : Lia
    }


type alias Lia =
    { readme : String
    , script : String
    }


type State
    = Waiting -- Wait for user Input
    | Loading Int -- Start to download the course if course url is defined
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
            ( Model key url (Loading 0) (Lia query "")
            , Cmd.none
            )

        ( _, Just query, _ ) ->
            ( Model key { url | query = Just query } (Loading 0) (Lia query "")
            , Cmd.none
            )

        ( _, _, Just script ) ->
            ( Model key url Parsing (Lia "" script)
            , Cmd.none
            )

        _ ->
            ( Model key url Waiting (Lia "" ""), Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | Input String
    | Download
    | DownloadResult (Result Http.Error String)
    | Tracking Http.Progress


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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

        Tracking progress ->
            case progress of
                Http.Receiving data ->
                    ( { model | state = Loading data.received }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Download ->
            ( { model | state = Loading 0 }
            , get_course model.lia.readme
            )

        DownloadResult result ->
            let
                lia =
                    model.lia
            in
            case result of
                Ok readme ->
                    ( { model | state = Parsing, lia = { lia | readme = readme } }, Cmd.none )

                Err error ->
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
            Waiting ->
                [ view_waiting model.lia.readme ]

            Loading percent ->
                [ base_div
                    [ Html.h1 [] [ Html.text ("Loading " ++ String.fromInt percent) ]
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

            _ ->
                [ text "The current URL is: "
                , b [] [ text (Url.toString model.url) ]
                , ul []
                    [ viewLink "/home"
                    , viewLink "/profile"
                    , viewLink "/reviews/the-century-of-the-self"
                    , viewLink "/reviews/public-opinion"
                    , viewLink "/reviews/shah-of-shahs"
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
