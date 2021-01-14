module Lia.Markdown.Effect.Script.View exposing (view)

import Array
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Encode as JE
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Effect.Script.Input as Input exposing (Input)
import Lia.Markdown.Effect.Script.Intl as Intl
import Lia.Markdown.Effect.Script.Types exposing (Script, Stdout(..), isError)
import Lia.Markdown.Effect.Script.Update exposing (Msg(..))
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Section exposing (SubSection(..))
import Lia.Utils exposing (blockKeydown, onEnter)


view : Config sub -> Int -> Parameters -> Html (Msg sub)
view config id attr =
    case Array.get id config.scripts of
        Just node ->
            case node.result of
                Just _ ->
                    if node.edit then
                        Html.span []
                            [ editor config.theme id node.script
                            , if Input.isHidden node.input then
                                Html.text ""

                              else
                                script config True attr id node
                            ]

                    else if Input.isHidden node.input then
                        Html.text ""

                    else if node.input.active then
                        input config attr id node

                    else
                        script config True attr id node

                Nothing ->
                    Html.text ""

        Nothing ->
            Html.text ""


class : Script SubSection -> String
class node =
    if node.input.type_ /= Nothing && node.modify then
        "lia-script-with-border"

    else if node.input.type_ /= Nothing then
        "lia-script-border"

    else if node.modify then
        "lia-script"

    else
        ""


script : Config sub -> Bool -> Parameters -> Int -> Script SubSection -> Html (Msg sub)
script config withStyling attr id node =
    case node.result of
        Nothing ->
            Html.text ""

        Just result ->
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
                    |> CList.addIf (isError result) (Attr.style "color" "red")
                    |> CList.addIf (node.input.type_ /= Just Input.Button_ && node.input.type_ /= Nothing) (onActivate True id)
                 --|> (::)
                 --    (Event.on "click"
                 --        (JD.maybe
                 --            (JD.field "detail" JD.int)
                 --            |> JD.map (Maybe.withDefault -1 >> Click)
                 --        )
                 --    )
                )
                [ case result of
                    Text str ->
                        Intl.view node.intl str

                    Error str ->
                        Html.text str

                    HTML str ->
                        Html.span
                            [ str
                                |> JE.string
                                |> Attr.property "innerHTML"
                            ]
                            []

                    IFrame lia ->
                        case config.view of
                            Just inline ->
                                inline id lia
                                    |> Html.span []

                            Nothing ->
                                Html.text "todo"
                ]


input : Config sub -> Parameters -> Int -> Script SubSection -> Html (Msg sub)
input config attr id node =
    case node.input.type_ of
        Just Input.Button_ ->
            script config True attr id node

        Just (Input.Checkbox_ []) ->
            [ Html.input
                [ Attr.checked (node.input.value == "true")
                , Attr.type_ "checkbox"
                , onActivate False id
                , Attr.id "lia-focus"
                , Event.onCheck
                    (\b ->
                        Value id node.input.updateOnChange <|
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
                |> span config attr id node

        Just (Input.Checkbox_ options) ->
            options
                |> checkbox node.input.updateOnChange id node.input.value attr
                |> span config attr id node

        Just (Input.Radio_ options) ->
            options
                |> radio node.input.updateOnChange id node.input.value attr
                |> span config attr id node

        Just (Input.Select_ options) ->
            options
                |> select id node.input.value attr
                |> span config attr id node

        Just Input.Textarea_ ->
            textarea id node.input.value attr node.input.updateOnChange
                |> span config attr id node

        Just _ ->
            base node.input id attr node.input.value
                |> span config attr id node

        Nothing ->
            script config True attr id node


select : Int -> String -> Parameters -> List String -> Html (Msg sub)
select id value attr =
    List.map (\o -> Html.option [ Attr.value o ] [ Html.text o ])
        >> Html.select (attributes True id value attr)


checkbox : Bool -> Int -> String -> Parameters -> List String -> Html (Msg sub)
checkbox updateOnChange id value _ =
    let
        list =
            value
                |> Input.decodeList
                |> Maybe.withDefault []
    in
    List.concatMap
        (\o ->
            [ Html.text (" " ++ o ++ " ")
            , Html.input
                [ Attr.value o
                , Attr.type_ "checkbox"
                , Event.onCheck (always (Checkbox id updateOnChange o))
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
        >> Html.span []


radio : Bool -> Int -> String -> Parameters -> List String -> Html (Msg sub)
radio updateOnChange id value _ =
    List.concatMap
        (\o ->
            [ Html.text (" " ++ o ++ " ")
            , Html.input
                [ Attr.value o
                , Attr.type_ "radio"
                , Event.onCheck (always (Radio id updateOnChange o))
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
        >> Html.span []


textarea : Int -> String -> Parameters -> Bool -> Html (Msg sub)
textarea id value attr updateOnChange =
    Html.textarea (attributes updateOnChange id value attr) []


attributes : Bool -> Int -> String -> Parameters -> List (Html.Attribute (Msg sub))
attributes updateOnChange id value =
    annotation ""
        >> List.append
            [ Event.onInput (Value id updateOnChange)
            , onActivate False id
            , Attr.value value
            , Attr.id "lia-focus"
            , blockKeydown NoOp
            ]


span : Config sub -> Parameters -> Int -> Script SubSection -> Html (Msg sub) -> Html (Msg sub)
span config attr id node control =
    Html.span
        [ Attr.class (class node)
        ]
        [ reset id
        , control
        , script config False attr id node
        ]


reset : Int -> Html (Msg sub)
reset id =
    Html.span
        [ Attr.class "lia-hint-btn"
        , Attr.style "position" "relative"
        , Attr.style "cursor" "pointer"
        , Event.onClick (Reset id)
        ]
        [ Html.text "clear" ]


base : Input -> Int -> Parameters -> String -> Html (Msg sub)
base input_ id attr value =
    Html.span []
        [ Html.input
            (annotation "lia-script" attr
                |> List.append
                    [ input_.updateOnChange
                        |> Value id
                        |> Event.onInput
                    , input_.type_
                        |> Maybe.map Input.type_
                        |> Maybe.withDefault "text"
                        |> Attr.type_
                    , Attr.value value
                    , onActivate False id
                    , Attr.id "lia-focus"
                    , blockKeydown NoOp
                    , onEnter (Activate False id)
                    ]
            )
            []
        , Html.text " "
        ]


onActivate : Bool -> Int -> Html.Attribute (Msg sub)
onActivate bool =
    Activate bool
        >> Delay 200
        >> (if bool then
                Event.onClick

            else
                --JD.succeed >> Event.on "focusout"
                Event.onBlur
           )


onEdit : Bool -> Int -> Html.Attribute (Msg sub)
onEdit bool =
    Edit bool
        >> (if bool then
                Event.onDoubleClick

            else
                Delay 300 >> Event.onBlur
           )


editor : Maybe String -> Int -> String -> Html (Msg sub)
editor theme id code =
    Html.div
        [ Attr.style "position" "fixed"
        , Attr.style "display" "block"
        , Attr.style "width" "100%"
        , Attr.style "height" "100%"
        , Attr.style "top" "0"
        , Attr.style "left" "0"
        , Attr.style "right" "0"
        , Attr.style "bottom" "0"
        , Attr.style "background-color" "rgba(0,0,0,0.6)"
        , Attr.style "z-index" "2"
        , Attr.style "cursor" "pointer"
        , Attr.style "overflow" "auto"
        ]
        [ Html.div
            [ Attr.style "position" "absolute"
            , Attr.style "top" "90px"
            , Attr.style "left" "50%"
            , Attr.style "width" "90%"
            , Attr.style "max-width" "800px"
            , Attr.style "transform" "translate(-50%,0%)"
            , Attr.style "-ms-transform" "translate(-50%,0%)"
            ]
            [ Editor.editor
                [ Editor.onChange (EditCode id)
                , Editor.value code
                , theme
                    |> Maybe.withDefault "crimson_editor"
                    |> Editor.theme
                , Editor.onBlur (Edit False id)
                , Editor.focusing
                , Editor.mode "javascript"
                , Editor.maxLines 16
                , Editor.showGutter True
                , Editor.useSoftTabs False
                , Editor.enableBasicAutocompletion True
                , Editor.enableLiveAutocompletion True
                , Editor.enableSnippets True
                , Editor.extensions [ "language_tools" ]
                ]
                []
            ]
        ]
