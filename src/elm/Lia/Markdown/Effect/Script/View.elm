module Lia.Markdown.Effect.Script.View exposing (view)

import Array
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Input as Input exposing (Input)
import Lia.Markdown.Effect.Script.Intl as Intl
import Lia.Markdown.Effect.Script.Types exposing (Script, Scripts)
import Lia.Markdown.Effect.Script.Update exposing (Msg(..))
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, get, toAttribute)
import Lia.Utils exposing (blockKeydown)


view : Int -> Parameters -> Scripts -> Html Msg
view id attr scripts =
    case Array.get id scripts of
        Just node ->
            case node.result of
                Just _ ->
                    if Input.isHidden node.input then
                        Html.text ""

                    else if node.edit then
                        edit id node.script

                    else if node.input.active then
                        input attr id node

                    else
                        script True attr id node

                Nothing ->
                    Html.text ""

        Nothing ->
            Html.text ""


script : Bool -> Parameters -> Int -> Script -> Html Msg
script withStyling attr id node =
    case node.result of
        Nothing ->
            Html.text ""

        Just result ->
            let
                ( str, err ) =
                    case result of
                        Ok rslt ->
                            ( rslt, False )

                        Err rslt ->
                            ( rslt, True )
            in
            Html.span
                (annotation "lia-script" attr
                    |> CList.addIf node.modify (Attr.style "background-color" "lightgray")
                    |> List.append
                        (if withStyling then
                            [ Attr.style "padding" "1px 5px 1px 5px"
                            , Attr.style "border-radius" "5px"
                            ]
                                |> CList.addIf (node.input.type_ /= Nothing) (Attr.style "border" "2px solid #73AD21")

                         else
                            [ Attr.style "margin" "5px" ]
                        )
                    |> List.append
                        (if node.input.type_ == Just Input.Button_ then
                            [ Event.onClick (Click id)
                            , Attr.style "cursor" "pointer"
                            ]

                         else
                            [ Attr.style "cursor" "cell" ]
                        )
                    |> CList.addIf node.modify (onEdit True id)
                    |> CList.addIf err (Attr.style "color" "red")
                    |> CList.addIf (node.input.type_ /= Just Input.Button_ && node.input.type_ /= Nothing) (onActivate True id)
                 --|> (::)
                 --    (Event.on "click"
                 --        (JD.maybe
                 --            (JD.field "detail" JD.int)
                 --            |> JD.map (Maybe.withDefault -1 >> Click)
                 --        )
                 --    )
                )
                [ if String.startsWith "HTML: " str then
                    Html.span
                        [ str
                            |> String.dropLeft 5
                            |> JE.string
                            |> Attr.property "innerHTML"
                        ]
                        []

                  else
                    Intl.view node.intl str
                ]


input_ : Input -> Int -> Parameters -> List (Html.Attribute Msg)
input_ html id attr =
    case get "input" attr of
        Just str ->
            [ Attr.type_ str
            , Event.onInput (Value id)
            , Attr.value html.value
            , onActivate False id
            , Attr.id "lia-focus"
            ]

        Nothing ->
            []


input : Parameters -> Int -> Script -> Html Msg
input attr id node =
    case node.input.type_ of
        Just Input.Button_ ->
            script True attr id node

        Just (Input.Checkbox_ []) ->
            [ Html.input
                [ Attr.checked (node.input.value == "true")
                , Attr.type_ "checkbox"
                , onActivate False id
                , Attr.id "lia-focus"
                , Event.onCheck
                    (\b ->
                        Value id <|
                            if b then
                                "true"

                            else
                                "false"
                    )
                ]
                []
            , Html.span
                [ Attr.class "lia-check-btn"
                , Attr.style "margin" "0px 4px 0px 4px"
                ]
                [ Html.text "check" ]
            ]
                |> Html.span []
                |> span attr id node

        Just (Input.Checkbox_ options) ->
            options
                |> select id node.input.value attr
                |> span attr id node

        Just (Input.Radio_ options) ->
            options
                |> select id node.input.value attr
                |> span attr id node

        Just (Input.Select_ options) ->
            options
                |> select id node.input.value attr
                |> span attr id node

        Just Input.Textarea_ ->
            textarea id node.input.value attr
                |> span attr id node

        Just type_ ->
            base type_ id attr node.input.value
                |> span attr id node

        Nothing ->
            script True attr id node


select : Int -> String -> Parameters -> List String -> Html Msg
select id value attr =
    List.map (\o -> Html.option [ Attr.value o ] [ Html.text o ])
        >> Html.select (attributes id value attr)


textarea : Int -> String -> Parameters -> Html Msg
textarea id value attr =
    Html.textarea (attributes id value attr) []


attributes : Int -> String -> Parameters -> List (Html.Attribute Msg)
attributes id value =
    annotation "lia-script"
        >> List.append
            [ Event.onInput (Value id)
            , onActivate False id
            , Attr.value value
            , Attr.id "lia-focus"
            ]


span : Parameters -> Int -> Script -> Html Msg -> Html Msg
span attr id node control =
    Html.span
        [ Attr.style "background-color" "lightgray"
        , Attr.style "padding" "1px 1px 3px 1px"
        , Attr.style "border-radius" "5px"
        , Attr.style "border" "2px solid #73AD21"
        ]
        [ reset id
        , control
        , script False attr id node
        ]


reset : Int -> Html Msg
reset id =
    Html.span
        [ Attr.class "lia-hint-btn"
        , Attr.style "position" "relative"
        , Attr.style "cursor" "pointer"
        , Event.onClick (Reset id)
        ]
        [ Html.text "clear" ]


base : Input.Type_ -> Int -> Parameters -> String -> Html Msg
base type_ id attr value =
    Html.span []
        [ Html.input
            (annotation "lia-script" attr
                |> List.append
                    [ Event.onInput (Value id)
                    , Attr.type_ <| Input.type_ type_
                    , Attr.value value
                    , onActivate False id
                    , Attr.id "lia-focus"
                    ]
            )
            []
        , Html.text " "
        ]


onActivate : Bool -> Int -> Html.Attribute Msg
onActivate bool =
    Activate bool
        >> Delay 200
        >> (if bool then
                Event.onClick

            else
                --JD.succeed >> Event.on "focusout"
                Event.onBlur
           )


onEdit : Bool -> Int -> Html.Attribute Msg
onEdit bool =
    Edit bool
        >> (if bool then
                Event.onDoubleClick

            else
                Delay 300 >> Event.onBlur
           )


edit : Int -> String -> Html Msg
edit id code =
    Html.input
        [ Attr.value code
        , Attr.id "lia-focus"
        , onEdit False id
        , Event.onInput (EditCode id)
        , blockKeydown NoOp
        ]
        []
