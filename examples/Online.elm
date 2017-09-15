module Main exposing (..)

import Html exposing (Html)
import Http
import Lia


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type State
    = Loading
    | LoadOk
    | LoadFail


type alias Flags =
    { url : String
    }


type alias Model =
    { url : String
    , lia : Lia.Model
    , state : State
    , error : String
    }


init : Flags -> ( Model, Cmd Msg )
init flag =
    ( Model flag.url (Lia.init_slides "") Loading ""
    , getCourse flag.url
    )



-- UPDATE


type Msg
    = GET (Result Http.Error String)
    | LIA Lia.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LIA liaMsg ->
            let
                ( lia, cmd, info ) =
                    Lia.update liaMsg model.lia
            in
            ( { model | lia = lia, error = toString model.lia.quiz_model }, Cmd.map LIA cmd )

        GET (Ok script) ->
            ( { model
                | lia = Lia.parse <| Lia.set_script (Lia.init_slides script) script
                , error = ""
                , state = LoadOk
              }
            , Cmd.none
            )

        GET (Err msg) ->
            ( { model | error = toString msg, state = LoadFail }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.state of
        Loading ->
            Html.div []
                [ Html.h2 [] [ Html.text "Loading Course" ]
                ]

        LoadOk ->
            Html.div []
                [ Html.text model.error
                , Html.map LIA <| Lia.view model.lia
                ]

        LoadFail ->
            Html.div []
                [ Html.h2 [] [ Html.text "Load failed" ]
                , Html.text model.error
                ]



-- SUBSCRIPTIONS
-- HTTP


getCourse : String -> Cmd Msg
getCourse url =
    Http.send GET <| Http.getString url
