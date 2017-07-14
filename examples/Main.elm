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
        , Html.map Child <| book model.lia model.slide
        ]


script : String
script =
    """{- Info: Einfaches Beispiel
-}

# Main Course

Einfache Modi zur textuellen Darstellung:

- Einfacher Text

- \\* dick \\* ->


Paragraph example (sss)*test*~hallo~

``` cpp
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
