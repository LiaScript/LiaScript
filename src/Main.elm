module Main exposing (..)

--import Html.Attribute (width)

import Html
    exposing
        ( Html
        , a
        , b
        , br
        , button
        , div
        , em
        , h1
        , h2
        , h3
        , h4
        , h5
        , h6
        , img
        , p
        , text
        , textarea
        , u
        )
import Html.Attributes exposing (class, href, src, style, value)
import Html.Events exposing (onClick, onInput)
import Lia exposing (E(..))


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


script : String
script =
    """# Main Course

Paragraph example (sss)*test*~hallo~

```
def function(p = 12):
    p = p * p
    return p
```

## Subtitle 1

Auch *gibt es niemanden,* der den Schmerz an sich liebt, sucht oder wünscht,
nur, weil er Schmerz ist, es sei denn, es kommt zu zufälligen Umständen, in
denen Mühen und Schmerz ihm große Freude bereiten können. Um ein triviales
Beispiel zu nehmen, wer von uns unterzieht sich je anstrengender körperlicher
Betätigung, außer um Vorteile daraus zu ziehen? ...

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


### Subtitle 3

{image}("https://cdn-images-1.medium.com/max/720/1*I-3kbXzEIAPAPEGiMcAs0A.png")

"""


init : ( Model, Cmd Msg )
init =
    update (Update script) (Model "" "" "" [] 0)



-- UPDATE


type Msg
    = Update String
    | Load Int


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

        Load slide ->
            ( { model | slide = slide }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ textarea
            [ style
                [ ( "width", "50%" )
                , ( "height", "200px" )
                , ( "resize", "none" )
                ]
            , value model.script
            , onInput Update
            ]
            []
        , textarea
            [ style
                [ ( "width", "49%" )
                , ( "height", "200px" )
                , ( "resize", "none" )
                , ( "float", "right" )
                ]
            ]
            [ text model.debug ]
        , text model.error
        , div []
            [ div
                [ style
                    [ ( "width", "15%" )
                    , ( "float", "left" )
                    ]
                ]
                ((model.lia
                    |> Lia.get_headers
                    |> List.map
                        (\( n, ( h, i ) ) ->
                            div [ onClick (Load n) ]
                                [ a [] [ text (String.repeat i "-" ++ h) ] ]
                        )
                 )
                    ++ [ button [ onClick (Load (model.slide - 1)) ] [ text "<<" ]
                       , button [ onClick (Load (model.slide + 1)) ] [ text ">>" ]
                       ]
                )
            , div
                [ style
                    [ ( "width", "85%" )
                    , ( "float", "right" )
                    ]
                ]
                [ case Lia.get_slide model.slide model.lia of
                    Just slide ->
                        view_lia slide

                    Nothing ->
                        text ""
                ]
            ]
        ]


view_lia : Lia.Slide -> Html Msg
view_lia lia =
    div []
        ((case lia.indentation of
            0 ->
                h1 [] [ text lia.title ]

            1 ->
                h2 [] [ text lia.title ]

            2 ->
                h3 [] [ text lia.title ]

            3 ->
                h4 [] [ text lia.title ]

            4 ->
                h5 [] [ text lia.title ]

            _ ->
                h6 [] [ text lia.title ]
         )
            :: view_body lia.body
        )


view_body : List E -> List (Html Msg)
view_body body =
    List.map view_string body


view_string : E -> Html Msg
view_string string =
    case string of
        Paragraph xs ->
            p [] (List.map view_string xs)

        CodeBlock str ->
            Html.pre [] [ Html.code [] [ text str ] ]

        Code str ->
            Html.pre [] [ text str ]

        Base str ->
            text str

        Bold lia ->
            b [] [ view_string lia ]

        Italic lia ->
            em [] [ view_string lia ]

        Underline lia ->
            u [] [ view_string lia ]

        Link text_ url_ ->
            a [ href url_ ] [ text text_ ]

        Image alt_ url_ ->
            img [ src url_ ] [ text alt_ ]



--        Lia cmd params ->
--            text (cmd ++ " : " ++ toString params)
-- SUBSCRIPTIONS
-- HTTP
