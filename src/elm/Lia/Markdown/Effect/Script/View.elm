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
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Section exposing (SubSection(..))
import Lia.Utils exposing (blockKeydown, icon, modal, onEnter)


view : Config sub -> Int -> Parameters -> Html (Msg sub)
view config id attr =
    case Array.get id config.scripts of
        Just node ->
            case node.result of
                Just _ ->
                    if node.edit then
                        Html.span [ Attr.class "flex items-center" ]
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
        "lia-script lia-script--with-border"

    else if node.input.type_ /= Nothing then
        "lia-script lia-script--border"

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
            Html.output
                (annotation
                    (if withStyling then
                        class node

                     else
                        ""
                    )
                    attr
                    --|> CList.addIf (not withStyling) (Attr.style "margin-" "1rem")
                    |> List.append
                        (case node.input.type_ of
                            Just Input.Button_ ->
                                [ Event.onClick (Click id)
                                ]

                            Just _ ->
                                []

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
                [ if not withStyling then
                    icon "icon-chevron-double-right" []

                  else
                    Html.text ""
                , case result of
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
                [ Attr.class "lia-checkbox"
                , Attr.checked (node.input.value == "true")
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
            ]
                |> Html.span [ Attr.class "flex items-center" ]
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
        >> Html.select (Attr.class "lia-select" :: attributes True id value attr)


checkbox : Bool -> Int -> String -> Parameters -> List String -> Html (Msg sub)
checkbox updateOnChange id value _ =
    let
        list =
            value
                |> Input.decodeList
                |> Maybe.withDefault []
    in
    List.map
        (\o ->
            Html.label [ Attr.class "lia-label mr-1" ]
                [ Html.input
                    [ Attr.value o
                    , Attr.type_ "checkbox"
                    , Event.onCheck (always (Checkbox id updateOnChange o))
                    , Attr.checked (List.member o list)
                    , onActivate False id
                    , Attr.autofocus True
                    , Attr.class "lia-checkbox"
                    ]
                    []
                , Html.text o
                ]
        )
        >> Html.span [ Attr.class "flex items-center" ]


radio : Bool -> Int -> String -> Parameters -> List String -> Html (Msg sub)
radio updateOnChange id value _ =
    List.map
        (\o ->
            Html.label [ Attr.class "lia-label mr-1" ]
                [ Html.input
                    [ Attr.value o
                    , Attr.type_ "radio"
                    , Event.onCheck (always (Radio id updateOnChange o))
                    , Attr.checked (o == value)
                    , onActivate False id
                    , Attr.autofocus True
                    , Attr.class "lia-radio"
                    ]
                    []
                , Html.text o
                ]
        )
        >> Html.span [ Attr.class "flex items-center" ]


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
    Html.button
        [ Attr.class "lia-script__refresh icon icon-refresh"
        , Event.onClick (Reset id)
        ]
        []


base : Input -> Int -> Parameters -> String -> Html (Msg sub)
base input_ id attr value =
    Html.input
        (toAttribute attr
            |> List.append
                [ input_.updateOnChange
                    |> Value id
                    |> Event.onInput
                , input_.type_
                    |> Maybe.map Input.type_
                    |> Maybe.withDefault "text"
                    |> Attr.type_
                , input_.type_
                    |> Maybe.map
                        (\i ->
                            case Input.type_ i of
                                "range" ->
                                    "lia-range"

                                "radio" ->
                                    "lia-radio"

                                "color" ->
                                    ""

                                _ ->
                                    "lia-input"
                        )
                    |> Maybe.withDefault ""
                    |> Attr.class
                , Attr.value value
                , onActivate False id
                , Attr.id "lia-focus"
                , blockKeydown NoOp
                , onEnter (Activate False id)
                ]
        )
        []


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
    modal (Edit False id)
        Nothing
        [ Editor.editor
            [ Editor.onChange (EditCode id)
            , Editor.value code
            , theme
                |> Maybe.withDefault "crimson_editor"
                |> Editor.theme
            , Editor.focusing
            , Editor.mode "javascript"
            , Editor.maxLines 16
            , Editor.showGutter True
            , Editor.useSoftTabs False
            , Editor.enableBasicAutocompletion True
            , Editor.enableLiveAutocompletion True
            , Editor.enableSnippets True
            , Editor.extensions [ "language_tools" ]
            , Attr.style "width" "96%"
            , Attr.style "max-width" "900px"
            ]
            []
        ]
