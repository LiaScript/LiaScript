module Lia.Markdown.Effect.Script.View exposing (view)

import Array
import Conditional.List as CList
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Lia.Markdown.Effect.Script.Input exposing (Input)
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.Effect.Script.Update exposing (Msg(..))
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, get, toAttribute)


view : Int -> Parameters -> Scripts -> Html Msg
view id attr scripts =
    case Array.get id scripts of
        Just node ->
            case node.result of
                Just (Ok str) ->
                    if node.input.active then
                        Html.input
                            (attr
                                |> annotation ""
                                |> List.append (input_ node.input id attr)
                            )
                            [ Html.text str ]

                    else
                        Html.span
                            (attr
                                |> annotation "lia-script"
                                |> List.append (script node.input id attr)
                            )
                            [ Html.text str ]

                Just (Err str) ->
                    Html.span [ Attr.style "color" "red" ] [ Html.text str ]

                Nothing ->
                    Html.text ""

        Nothing ->
            Html.text ""


script : Input -> Int -> Parameters -> List (Html.Attribute Msg)
script input id attr =
    []
        |> List.append (data_input input id attr)
        |> CList.addWhen
            (attr
                |> get "output"
                |> Maybe.map Attr.title
            )


input_ : Input -> Int -> Parameters -> List (Html.Attribute Msg)
input_ input id attr =
    case get "input" attr of
        Just str ->
            [ Attr.type_ str
            , Event.onInput (Value id)
            , Attr.value input.value
            , Event.onBlur (Deactivate id)
            , Attr.id "lia-focus"
            ]

        Nothing ->
            []


data_input : Input -> Int -> Parameters -> List (Html.Attribute Msg)
data_input input id attr =
    case get "input" attr of
        Just "button" ->
            [ Event.onClick (Click id)
            , Attr.style "cursor" "pointer"
            ]

        Just "date" ->
            [ Event.onClick (Activate id)
            , Attr.style "cursor" "pointer"
            ]

        Just "number" ->
            [ Event.onClick (Activate id)
            , Attr.style "cursor" "pointer"
            ]

        Just "range" ->
            [ Event.onClick (Activate id)
            , Attr.style "cursor" "pointer"
            ]

        Just "time" ->
            [ Event.onClick (Activate id)
            , Attr.style "cursor" "pointer"
            ]

        Just "week" ->
            [ Event.onClick (Activate id)
            , Attr.style "cursor" "pointer"
            ]

        _ ->
            []
