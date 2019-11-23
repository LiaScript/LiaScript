module Index.View exposing (view)

import Dict exposing (Dict)
import Element
    exposing
        ( Element
        , centerX
        , column
        , el
        , fill
        , height
        , maximum
        , minimum
        , none
        , padding
        , paddingXY
        , px
        , row
        , scrollbarY
        , spacing
        , text
        , width
        )
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Index.Model exposing (Course, Model, Version)
import Index.Update exposing (Msg(..), restore)
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View as Inline
import Lia.Settings.Model exposing (Mode(..))
import Version


view : Model -> Html Msg
view model =
    [ text "Lia: Index"
        |> el
            [ centerX
            , Font.size 36
            , height <| px 30
            , padding 30
            ]
    , searchBar model.input
    , model.courses
        |> List.map card
        |> column
            [ width fill
            , height fill
            , padding 16
            , spacing 30
            , scrollbarY
            ]
    ]
        |> column
            [ width fill
            , spacing 20
            , height fill
            ]
        |> renderElmUi


searchBar : String -> Element Msg
searchBar url =
    [ Input.text
        [ fill
            |> maximum 400
            |> width
        ]
        { onChange = Input
        , text = url
        , placeholder = Just (Input.placeholder [] (text "course-url"))
        , label = Input.labelHidden "search input field"
        }
    , Element.link
        [ Border.shadow
            { offset = ( 0, 0 )
            , blur = 6
            , size = 1
            , color = Element.rgba 0 0 0 0.2
            }
        , height fill
        ]
        { url = href url
        , label = text "load course" |> el [ Element.paddingXY 20 0 ]
        }
    ]
        |> Element.wrappedRow [ spacing 20, width fill, height fill ]
        |> el [ centerX, height <| px 40 ]


card : Course -> Element Msg
card course =
    column
        [ width fill
        , height fill
        , spacing 10
        , Border.color <| Element.rgb 0 0 0
        , Element.clip
        , Border.rounded 10
        , Border.shadow
            { offset = ( 2, 2 )
            , blur = 6
            , size = 2
            , color = Element.rgba 0 0 0 0.2
            }
        , Background.color <| Element.rgb 0.95 0.95 0.95
        ]
    <|
        case get_active course of
            Just { title, definition } ->
                [ case ( String.trim definition.author, String.trim definition.logo ) of
                    ( str_a, "" ) ->
                        str_a
                            |> author

                    ( str_a, str_l ) ->
                        none
                            |> el
                                [ Background.image str_l
                                , width fill
                                , height <| px 200
                                , str_a
                                    |> author
                                    |> Element.inFront
                                ]
                , [ title
                        |> inlines
                        |> Html.div []
                        |> Element.html
                        |> el
                            [ Font.size 36
                            , width fill
                            , Font.bold
                            , padding 0
                            , Font.color <| Element.rgb 0.6 0 0
                            ]
                  , [ definition.comment
                        |> inlines
                        |> Html.p []
                        |> Element.html
                    ]
                        |> Element.paragraph
                            [ Element.paddingXY 10 0
                            ]
                  , viewVersions course
                  , [ Input.button
                        btn
                        { onPress = Just <| Delete course.id
                        , label =
                            text "Delete"
                                |> el [ Element.rgb 1 0 0 |> Font.color ]
                        }
                    , Input.button
                        btn
                        { onPress = Just <| Reset course.id course.active
                        , label =
                            text "Reset"
                                |> el [ Element.rgb 1 0 0 |> Font.color ]
                        }
                    , case course.active of
                        Nothing ->
                            Element.link
                                (Element.alignRight :: btn)
                                { url = href course.id, label = text "Open" }

                        Just ver ->
                            Input.button
                                (Element.alignRight :: btn)
                                { onPress = Just <| Restore course.id course.active
                                , label = text "Open"
                                }
                    ]
                        |> row [ width fill, padding 10, spacing 10 ]
                  ]
                    |> column [ width fill ]
                ]

            _ ->
                [ text "something went wrong" ]


btn =
    [ Font.color <| Element.rgba 0 0 0 0.7
    , Border.shadow
        { offset = ( 2, 2 )
        , blur = 1
        , size = 1
        , color = Element.rgba 0 0 0 0.2
        }
    , paddingXY 5 4
    , Border.rounded 5
    , Background.color <| Element.rgb 1 1 1
    ]


author : String -> Element msg
author str =
    (if str == "" then
        "by Annonymous"

     else
        "by " ++ str
    )
        |> text
        |> el
            [ padding 10
            , Font.size 24
            , width fill
            , Font.bold
            , Background.color <| Element.rgba 0.95 0.95 0.95 0.6
            ]


renderElmUi : Element msg -> Html msg
renderElmUi =
    Element.layoutWith
        { options =
            [ Element.focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        [ Element.width Element.fill
        , Element.height Element.fill
        ]


view2 : Model -> Html Msg
view2 model =
    model.courses
        |> List.map viewCard
        --  |> (::) (searchBar model.input)
        |> Html.div [ Attr.style "overflow-y" "auto", Attr.style "height" "100%" ]


href : String -> String
href url =
    "./?" ++ url


viewCard : Course -> Html Msg
viewCard course =
    case get_active course of
        Just { title, definition } ->
            Html.div [ Attr.class "course-container" ]
                [ Html.div [ Attr.class "course-body" ]
                    [ Html.div [ Attr.class "course-title" ]
                        [ title
                            |> inlines
                            |> Html.h1 []
                        ]
                    , Html.div [ Attr.class "course-summary" ]
                        [ definition.comment
                            |> inlines
                            |> Html.p []
                        ]
                    ]
                , Html.div
                    [ Attr.class "course-footer" ]
                    [ Html.ul []
                        [ Html.li [ Attr.class "published-date" ]
                            [ Html.text course.last_visit ]
                        , Html.li [ Attr.class "published-date" ]
                            [ Html.a [ onClick <| Delete course.id ] [ Html.text "delete" ] ]
                        , Html.li [ Attr.class "published-date" ]
                            [ Html.a [] [ Html.text "reset" ] ]
                        , Html.li [ Attr.class "published-date" ]
                            [ Html.a
                                []
                                --  [ href course.id ]
                                [ Html.text "open" ]
                            ]
                        ]
                    ]
                ]

        Nothing ->
            Html.text "something went wrong"


viewVersions : Course -> Element Msg
viewVersions course =
    let
        last =
            Dict.size course.versions - 1
    in
    course.versions
        |> Dict.toList
        |> List.map (\( key, value ) -> ( key, value.definition.version ))
        |> List.sortBy Tuple.first
        |> List.indexedMap
            (\i ( key, value ) ->
                let
                    color =
                        case course.active of
                            Just active ->
                                if active == key then
                                    Element.rgb 0 0 0

                                else
                                    Element.rgb 0.5 0.5 0.5

                            Nothing ->
                                if last == i then
                                    Element.rgb 0 0 0

                                else
                                    Element.rgb 0.5 0.5 0.5
                in
                Input.button
                    [ Font.color color
                    , Border.color color
                    , Border.width 1
                    , Font.size 14
                    , paddingXY 5 2
                    , Border.rounded 5
                    ]
                    { onPress =
                        Just <|
                            Activate course.id
                                (if last == i then
                                    Nothing

                                 else
                                    Just value
                                )
                    , label = "V " ++ value |> text
                    }
            )
        |> row [ padding 10, spacing 10 ]


get_active : Course -> Maybe Version
get_active course =
    case course.active of
        Nothing ->
            course.versions
                |> Dict.toList
                |> List.sortBy Tuple.first
                |> List.head
                |> Maybe.map Tuple.second

        Just id ->
            course.versions
                |> Dict.get id


inlines : Inlines -> List (Html msg)
inlines =
    List.map (Inline.view_inf Textbook)
