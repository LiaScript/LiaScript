module Main exposing (..)

import Bound exposing (createBound)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Lia
import Lia.Types exposing (Mode(..))
import SplitPane exposing (Orientation(..), ViewConfig, createViewConfig, percentage, withResizeLimits, withSplitterAt)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { update = update
        , init = init
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Msg
    = Outer SplitPane.Msg
    | Inner SplitPane.Msg
    | Update String
    | Render Mode
    | Child Lia.Msg


type alias Model =
    { outer : SplitPane.State
    , inner : SplitPane.State
    , lia : Lia.Model
    }


type alias Flags =
    {
    }



-- INIT


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        script = "TODO: Load ReadMe.md"
    in
    update (Update script)
        { outer =
            SplitPane.init Horizontal
                |> withResizeLimits (createBound (percentage 0.2) (percentage 0.8))
        , inner =
            SplitPane.init Vertical
                |> withSplitterAt (percentage 0.75)
        , lia = Lia.init_slides script
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Update script ->
            ( { model | lia = Lia.parse <| Lia.set_script model.lia script }, Cmd.none )

        Render mode ->
            ( { model | lia = Lia.switch_mode mode model.lia }, Cmd.none )

        Child liaMsg ->
            let
                ( lia, cmd, log ) =
                    Lia.update liaMsg model.lia
            in
            ( { model | lia = lia }, Cmd.map Child cmd )

        Outer m ->
            { model
                | outer = SplitPane.update m model.outer
            }
                ! []

        Inner m ->
            { model
                | inner = SplitPane.update m model.inner
            }
                ! []



-- VIEW


view : Model -> Html Msg
view model =
    Html.div
        [ Attr.style
            [ ( "width", "100%" )
            , ( "height", "100%" )
            ]
        ]
        [ SplitPane.view outerViewConfig (leftView model model.inner) (rightView model) model.outer ]


rightView : Model -> Html Msg
rightView model =
    Html.div
        [ Attr.style
            [ ( "height", "100%" )
            , ( "width", "100%" )
            ]
        ]
        [ Html.map Child <| Lia.view model.lia ]


leftView : Model -> SplitPane.State -> Html Msg
leftView model =
    SplitPane.view innerViewConfig
        (Html.div
            [ Attr.style
                [ ( "resize", "horizontal" )
                , ( "overflow", "auto" )
                , ( "width", "100%" )
                , ( "height", "100%" )
                , ( "resize", "none" )
                ]
            ]
            [ Html.div
                [ Attr.style
                    [ ( "margin", "10px" )
                    ]
                ]
                [ Html.button [] [ Html.text "Load File" ]
                , Html.fieldset
                    [ Attr.style
                        [ ( "float", "right" ) ]
                    ]
                    [ Html.input
                        [ Attr.type_ "radio"
                        , onClick (Render Slides)
                        , Attr.checked (model.lia.mode == Lia.Types.Slides)
                        ]
                        []
                    , Html.text "Slides"
                    , Html.input
                        [ Attr.type_ "radio"
                        , onClick (Render Plain)
                        , Attr.checked (model.lia.mode == Plain)
                        ]
                        []
                    , Html.text "Book"
                    ]
                ]
            , Html.textarea
                [ Attr.style
                    [ ( "height", "calc(100% - 78px)" )
                    , ( "width", "calc(100% - 24px)" )
                    , ( "margin", "10px" )
                    , ( "resize", "none" )
                    ]
                , Attr.value model.lia.script
                , onInput Update
                ]
                []
            ]
        )
        (Html.textarea
            [ Attr.style
                [ ( "height", "calc(100% - 24px)" )
                , ( "width", "calc(100% - 24px)" )
                , ( "margin", "10px" )
                , ( "resize", "none" )
                ]
            ]
            (let
                slide =
                    model.lia.slides
                        |> list_get model.lia.current_slide
                        |> Maybe.map toString
                        |> Maybe.withDefault ""
             in
             [ Html.text (model.lia.error ++ "\n" ++ slide) ]
            )
        )


list_get : Int -> List a -> Maybe a
list_get i list =
    case ( i, list ) of
        ( 0, x :: xs ) ->
            Just x

        ( _, x :: xs ) ->
            list_get (i - 1) xs

        ( _, [] ) ->
            Nothing


outerViewConfig : ViewConfig Msg
outerViewConfig =
    createViewConfig
        { toMsg = Outer
        , customSplitter = Nothing
        }


innerViewConfig : ViewConfig Msg
innerViewConfig =
    createViewConfig
        { toMsg = Inner
        , customSplitter = Nothing
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Outer <| SplitPane.subscriptions model.outer
        , Sub.map Inner <| SplitPane.subscriptions model.inner
        ]
