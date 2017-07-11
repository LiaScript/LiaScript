module Main exposing (..)

--import Html.Attribute (width)

import Html exposing (Html, br, button, div, h1, h2, h3, h4, h5, h6, p, text, textarea)
import Html.Attributes exposing (class, style, value)
import Html.Events exposing (onInput)
import Lia exposing (Lia(..))


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
    , lia : List Lia
    , debug : String
    , error : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model """# Main Course

...

## Subtitle 1

Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht, nur,
weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in denen
Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales Beispiel zu
nehmen, wer von uns unterzieht sich je anstrengender körperlicher Betätigung,
außer um Vorteile daraus zu ziehen? ...

## Subtitle 2

... Aber wer hat irgend ein Recht, einen Menschen zu tadeln, der die
Entscheidung trifft, eine Freude zu genießen, die keine unangenehmen Folgen hat,
oder einen, der Schmerz vermeidet, welcher keine daraus resultierende Freude
nach sich zieht? Auch gibt es niemanden, der den Schmerz an sich liebt, sucht
oder wünscht, nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen
Umständen, in denen Mühen und Schmerz ihm große Freude bereiten können.

## Subtitle 3

... Um ein triviales Beispiel zu nehmen, wer von uns unterzieht sich je
anstrengender körperlicher Betätigung, außer um Vorteile daraus zu ziehen? Aber
wer hat irgend ein Recht, einen Menschen zu tadeln, der die Entscheidung trifft,
eine Freude zu genießen, die keine unangenehmen Folgen hat, oder einen, der
Schmerz vermeidet, welcher keine daraus resultierende Freude nach sich
zieht?Auch gibt es niemanden, der den Schmerz an sich liebt, sucht oder wünscht,
nur, ...

""" [] "" ""
    , Cmd.none
    )



-- UPDATE


type Msg
    = Update String


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



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ textarea
            [ style
                [ ( "width", "100%" )
                , ( "height", "200px" )
                , ( "resize", "none" )
                ]
            , value model.script
            , onInput Update
            ]
            []
        , text model.error
        , text model.debug
        , div []
            [ div
                [ style
                    [ ( "width", "15%" )
                    , ( "float", "left" )
                    ]
                ]
                [ p [] [ text "dddd" ], p [] [ text "dddd" ] ]
            , div
                [ style
                    [ ( "width", "85%" )
                    , ( "float", "right" )
                    ]
                ]
                (List.map view_lia model.lia)
            ]
        ]


view_lia : Lia -> Html Msg
view_lia lia =
    case lia of
        LiaTitle i str ->
            case i of
                0 ->
                    h1 [] [ text str ]

                1 ->
                    h2 [] [ text str ]

                2 ->
                    h3 [] [ text str ]

                3 ->
                    h4 [] [ text str ]

                4 ->
                    h5 [] [ text str ]

                _ ->
                    h6 [] [ text str ]

        LiaText str ->
            text (str ++ " ")



-- SUBSCRIPTIONS
-- HTTP
