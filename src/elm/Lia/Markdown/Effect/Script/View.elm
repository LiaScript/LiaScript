module Lia.Markdown.Effect.Script.View exposing (view)

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Array
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Encode as JE
import Lia.Markdown.Code.Editor as Editor
import Lia.Markdown.Effect.Script.Input as Input
import Lia.Markdown.Effect.Script.Intl as Intl
import Lia.Markdown.Effect.Script.Types exposing (Modifiable(..), Msg(..), Script, Stdout(..))
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Section exposing (SubSection)
import Lia.Utils exposing (blockKeydown, icon, modal)
import List.Extra


{-| Render script `id` of `config.scripts`. Nothing is shown until the script
has a result. Depending on its state, the result, the input element (if the
`input` attribute is set and the input is active) or the code editor (after a
double click on a modifiable script) is shown.
-}
view : Config sub -> Int -> Parameters -> Html (Msg sub)
view config id attr =
    case Array.get id config.scripts of
        Just node ->
            case node.result of
                Just result ->
                    if node.edit then
                        Html.span [ Attr.class "flex items-center" ]
                            [ editor config.theme
                                node.highlighting
                                id
                                (case node.modify of
                                    Partially pattern ->
                                        Just pattern

                                    _ ->
                                        Nothing
                                )
                                node.script
                            , if Input.isHidden node.input then
                                Html.text ""

                              else
                                script config True attr id node result
                            ]

                    else if Input.isHidden node.input then
                        Html.text ""

                    else if node.input.active then
                        input config attr id node result

                    else
                        script config True attr id node result

                Nothing ->
                    Html.text ""

        Nothing ->
            Html.text ""


class : Script SubSection -> String
class node =
    case ( node.input.type_, node.modify ) of
        ( Just _, No ) ->
            "lia-script lia-script--border"

        ( Just _, _ ) ->
            "lia-script lia-script--with-border"

        ( Nothing, No ) ->
            ""

        ( Nothing, _ ) ->
            "lia-script"


{-| The result as `<output>`. Buttons execute the script on click, other inputs
get activated, modifiable scripts can be edited. Within an active input
(`withStyling = False`) it is prefixed with an arrow.
-}
script : Config sub -> Bool -> Parameters -> Int -> Script SubSection -> Stdout SubSection -> Html (Msg sub)
script config withStyling attr id node result =
    let
        modifiable =
            node.modify /= No
    in
    Html.output
        (annotation
            (if withStyling then
                class node

             else
                ""
            )
            attr
            |> List.append
                (case node.input.type_ of
                    Just (Input.Button_ _) ->
                        [ Event.onClick (Click id)
                        , [ A11y_Key.enter (Click id)
                          , A11y_Key.space (Click id)
                          ]
                            |> CList.appendIf modifiable
                                [ shiftEnter (Edit True id)
                                , shiftSpace (Edit True id)
                                ]
                            |> A11y_Key.onKeyDown
                        ]

                    _ ->
                        []
                )
            |> CList.addIf (modifiable || node.input.type_ /= Nothing) (Attr.tabindex 0)
            |> CList.addIf modifiable (Attr.id ("lia-script-" ++ String.fromInt id))
            |> CList.appendIf modifiable (onEdit id)
            |> CList.addIf
                (case result of
                    Error _ ->
                        True

                    _ ->
                        False
                )
                (Attr.style "color" "#dc0000")
            |> CList.appendIf
                (case node.input.type_ of
                    Nothing ->
                        False

                    Just (Input.Button_ _) ->
                        False

                    Just _ ->
                        True
                )
                (onActivate True id)
        )
        [ if withStyling then
            Html.text ""

          else
            icon "icon-chevron-double-right" []
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
                        inline config.slide id lia
                            |> Html.span []

                    Nothing ->
                        Html.text "todo"
        ]


{-| The active input element, followed by the result.
-}
input : Config sub -> Parameters -> Int -> Script SubSection -> Stdout SubSection -> Html (Msg sub)
input config attr id node result =
    let
        withResult control =
            Html.span
                [ Attr.class (class node) ]
                [ reset id
                , control
                , script config False attr id node result
                ]
    in
    case node.input.type_ of
        Just (Input.Button_ _) ->
            script config True attr id node result

        Just (Input.Checkbox_ []) ->
            [ Html.input
                (onActivate False id
                    ++ [ Attr.class "lia-checkbox"
                       , Attr.checked (node.input.value == "true")
                       , Attr.type_ "checkbox"
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
                )
                []
            ]
                |> Html.span [ Attr.class "flex items-center" ]
                |> withResult

        Just (Input.Checkbox_ list) ->
            let
                checked =
                    node.input.value
                        |> Input.decodeList
                        |> Maybe.withDefault []
            in
            list
                |> options "checkbox" Checkbox (\o -> List.member o checked) node.input.updateOnChange id
                |> withResult

        Just (Input.Radio_ list) ->
            list
                |> options "radio" Radio ((==) node.input.value) node.input.updateOnChange id
                |> withResult

        Just (Input.Select_ list) ->
            list
                |> List.map (\o -> Html.option [ Attr.value o ] [ Html.text o ])
                |> Html.select (Attr.class "lia-select" :: attributes True id node.input.value attr)
                |> withResult

        Just Input.Textarea_ ->
            Html.textarea (attributes node.input.updateOnChange id node.input.value attr) []
                |> withResult

        Just type_ ->
            base type_ node.input.updateOnChange id attr node.input.value
                |> withResult

        Nothing ->
            script config True attr id node result


{-| A labeled checkbox or radio button for every option.
-}
options : String -> (Int -> Bool -> String -> Msg sub) -> (String -> Bool) -> Bool -> Int -> List String -> Html (Msg sub)
options type_ msg checked updateOnChange id =
    List.map
        (\o ->
            Html.label [ Attr.class "lia-label mr-1" ]
                [ Html.input
                    (onActivate False id
                        ++ [ Attr.value o
                           , Attr.type_ type_
                           , Event.onCheck (always (msg id updateOnChange o))
                           , Attr.checked (checked o)
                           , Attr.autofocus True
                           , Attr.class ("lia-" ++ type_)
                           ]
                    )
                    []
                , Html.text o
                ]
        )
        >> Html.span [ Attr.class "flex items-center" ]


attributes : Bool -> Int -> String -> Parameters -> List (Html.Attribute (Msg sub))
attributes updateOnChange id value =
    annotation ""
        >> List.append
            [ Event.onInput (Value id updateOnChange)
            , Attr.value value
            , Attr.id "lia-focus"
            , blockKeydown NoOp
            ]
        >> List.append (onActivate False id)


reset : Int -> Html (Msg sub)
reset id =
    Html.button
        [ Attr.class "lia-script__refresh icon icon-refresh"
        , Event.onClick (Reset id)
        , A11y_Key.onKeyDown
            [ A11y_Key.enter (Click id)
            , A11y_Key.space (Click id)
            ]
        ]
        []


{-| A plain `<input>` of the given type, Enter executes the script, Escape
resets it.
-}
base : Input.Type_ -> Bool -> Int -> Parameters -> String -> Html (Msg sub)
base type_ updateOnChange id attr value =
    Html.input
        (onActivate False id
            ++ [ Event.onInput (Value id updateOnChange)
               , Attr.type_ (Input.type_ type_)
               , Attr.class
                    (case type_ of
                        Input.Range_ ->
                            "lia-range"

                        Input.Color_ ->
                            ""

                        _ ->
                            "lia-input"
                    )
               , Attr.value value
               , Attr.id "lia-focus"
               , blockKeydown NoOp
               , A11y_Key.onKeyUp
                    [ A11y_Key.enter (Activate False id)
                    , A11y_Key.escape (Reset id)
                    ]
               ]
            ++ toAttribute attr
        )
        []


{-| `True`: activate the input by click, Enter or Space on the result.
`False`: deactivate it when the input loses the focus or on Escape.
-}
onActivate : Bool -> Int -> List (Html.Attribute (Msg sub))
onActivate bool id =
    if bool then
        [ Event.onClick (Delay 200 (Activate True id))
        , A11y_Key.onKeyUp
            [ A11y_Key.enter (Delay 200 (Activate True id))
            , A11y_Key.space (Delay 200 (Activate True id))
            ]
        ]

    else
        [ Event.onBlur (Delay 200 (Activate False id))
        , A11y_Key.onKeyDown
            [ A11y_Key.escape (Delay 200 (Activate False id))
            ]
        ]


shiftEnter : msg -> A11y_Key.Event msg
shiftEnter msg =
    { keyCode = 13
    , shiftKey = True
    , msg = msg
    }


shiftSpace : msg -> A11y_Key.Event msg
shiftSpace msg =
    { keyCode = 32
    , shiftKey = True
    , msg = msg
    }


{-| Open the code editor by double click or Shift+Enter/Space.
-}
onEdit : Int -> List (Html.Attribute (Msg sub))
onEdit id =
    [ Event.onDoubleClick (Edit True id)
    , A11y_Key.onKeyDown
        [ shiftEnter (Edit True id)
        , shiftSpace (Edit True id)
        ]
    , A11y_Aria.keyShortcuts [ "Shift+Enter" ]
    ]


{-| Modal code editor, with a `Partially` modifiable script only the part
between the first two appearances of `subPattern` can be edited.
-}
editor : Maybe String -> String -> Int -> Maybe String -> String -> Html (Msg sub)
editor theme mode id subPattern code =
    let
        ( msg, value ) =
            case subPattern of
                Just str ->
                    String.split str code
                        |> List.Extra.getAt 1
                        |> Maybe.map (Tuple.pair (EditParam id str))
                        |> Maybe.withDefault ( EditCode id, code )

                _ ->
                    ( EditCode id, code )
    in
    modal True
        (Edit False id)
        Nothing
        [ Editor.editor
            [ Editor.onChange msg
            , Editor.value value
            , theme
                |> Maybe.withDefault "crimson_editor"
                |> Editor.theme
            , Editor.focusing
            , Editor.mode mode
            , Editor.maxLines 16
            , Editor.showGutter True
            , Editor.useSoftTabs False
            , Editor.enableBasicAutocompletion True
            , Editor.enableLiveAutocompletion True
            , Editor.enableSnippets True
            , Attr.style "width" "96%"
            , Attr.style "max-width" "900px"
            , Attr.class "notranslate"
            ]
            []
        ]
