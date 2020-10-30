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


class : Script -> String
class node =
    if node.input.type_ /= Nothing && node.modify then
        "lia-script-with-border"

    else if node.input.type_ /= Nothing then
        "lia-script-border"

    else if node.modify then
        "lia-script"

    else
        ""


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
                (annotation
                    (if withStyling then
                        class node

                     else
                        ""
                    )
                    attr
                    |> CList.addIf (not withStyling) (Attr.style "margin" "5px")
                    |> List.append
                        (case node.input.type_ of
                            Just Input.Button_ ->
                                [ Event.onClick (Click id)
                                , Attr.style "cursor" "pointer"
                                ]

                            Just _ ->
                                [ Attr.style "cursor" "cell" ]

                            _ ->
                                []
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
                        Value id True <|
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
                |> checkbox id node.input.value attr
                |> span attr id node

        Just (Input.Radio_ options) ->
            options
                |> radio id node.input.value attr
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


checkbox : Int -> String -> Parameters -> List String -> Html Msg
checkbox id value attr =
    let
        list =
            value
                |> Input.decodeList
                |> Maybe.withDefault []
    in
    List.map
        (\o ->
            [ Html.text (" " ++ o ++ " ")
            , Html.input
                [ Attr.value o
                , Attr.type_ "checkbox"
                , Event.onCheck (always (Checkbox id o))
                , Attr.checked (List.member o list)
                , onActivate False id
                , Attr.autofocus True
                ]
                []
            , Html.span
                [ Attr.class "lia-check-btn" ]
                [ Html.text "check" ]
            ]
        )
        >> List.concat
        >> Html.span []


radio : Int -> String -> Parameters -> List String -> Html Msg
radio id value attr =
    List.map
        (\o ->
            [ Html.text (" " ++ o ++ " ")
            , Html.input
                [ Attr.value o
                , Attr.type_ "radio"
                , Event.onCheck (always (Radio id o))
                , Attr.checked (o == value)
                , onActivate False id
                , Attr.autofocus True
                ]
                []
            , Html.span
                [ Attr.class "lia-radio-btn" ]
                []
            ]
        )
        >> List.concat
        >> Html.span []


textarea : Int -> String -> Parameters -> Html Msg
textarea id value attr =
    Html.textarea (attributes id value attr) []


attributes : Int -> String -> Parameters -> List (Html.Attribute Msg)
attributes id value =
    annotation ""
        >> List.append
            [ Event.onInput (Value id True)
            , onActivate False id
            , Attr.value value
            , Attr.id "lia-focus"
            ]


span : Parameters -> Int -> Script -> Html Msg -> Html Msg
span attr id node control =
    Html.span
        [ Attr.class (class node)
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
                    [ type_
                        |> Input.runnable
                        |> Value id
                        |> Event.onInput
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
