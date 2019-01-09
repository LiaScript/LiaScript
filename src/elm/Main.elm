module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
import Json.Decode
import Json.Encode


type alias Model =
    { code1 : String, code2 : String, mode : String }


initialModel : Model
initialModel =
    { code1 = "Hello world 1", code2 = "fucking", mode = "" }


type Msg
    = CodeChanged1 String
    | CodeChanged2 String
    | Mode String


update : Msg -> Model -> Model
update msg model =
    case msg of
        CodeChanged1 value ->
            { model | code1 = value }

        CodeChanged2 value ->
            { model | code2 = value }

        Mode value ->
            { model | mode = value }


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.node "katex-formula"
            [ Attr.attribute "displayMode" "true" ]
            [ Html.text "\\frac{a+b}{33} {" ]
        , Html.node "katex-formula"
            [ Attr.attribute "displayMode" "false" ]
            [ Html.text "\\frac{a+b}{33}" ]
        , Html.textarea [ Html.Events.onInput Mode ] [ Html.text model.mode ]
        , Html.node "code-editor"
            [ Attr.property "value" <|
                Json.Encode.string model.code2
            , Attr.property "mode" <|
                Json.Encode.string model.mode
            , Html.Events.on "editorChanged" <|
                Json.Decode.map CodeChanged2 <|
                    Json.Decode.at [ "target", "value" ] <|
                        Json.Decode.string
            ]
            []
        ]


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { view = view
        , update = update
        , model = initialModel
        }
