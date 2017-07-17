module Main exposing (..)

--import Html.Attribute (width)

import Html exposing (Html)
import Html.Attributes exposing (class, href, src, style, value)
import Html.Events exposing (onClick, onInput)
import Lia
import LiaHtml exposing (book, plain)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { script : String
    , debug : String
    , error : String
    , lia : List Lia.Slide
    , slide : Int
    }


init : ( Model, Cmd Msg )
init =
    update (Update script) (Model "" "" "" [] 0)



-- UPDATE


type Msg
    = Update String
    | Child LiaHtml.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update script ->
            let
                m =
                    { model | script = script, error = "" }
            in
            case Lia.parse script of
                Ok lia ->
                    ( { m | lia = lia, debug = toString lia }, Cmd.none )

                Err msg ->
                    ( { m | error = msg }, Cmd.none )

        Child liaMsg ->
            ( { model | slide = LiaHtml.activated liaMsg }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.textarea
            [ style
                [ ( "width", "50%" )
                , ( "height", "200px" )
                , ( "resize", "none" )
                ]
            , value model.script
            , onInput Update
            ]
            []
        , Html.textarea
            [ style
                [ ( "width", "49%" )
                , ( "height", "200px" )
                , ( "resize", "none" )
                , ( "float", "right" )
                ]
            ]
            [ Html.text model.debug ]
        , Html.text model.error
        , Html.map Child <| book model.lia model.slide
        ]


script : String
script =
    """# Main Course

| h1  | h2 | h3 | h4 |
| aaa | bb | cc | dd |


"""
