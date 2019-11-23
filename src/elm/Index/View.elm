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
        , paragraph
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
import Session exposing (Session)
import Version


scaled w start =
    (toFloat w / 200.0)
        |> round
        |> Element.modular start 1.1
        |> round


view : Session -> Model -> Html Msg
view session model =
    let
        scale =
            scaled session.screen.width
    in
    [ text "Lia: Index"
        |> el
            [ centerX
            , scale 20 |> Font.size
            , scale 10 |> padding
            ]
    , searchBar scale session.screen.width model.input
    , model.courses
        |> List.map (card scale)
        |> greedyGroupsOf (round (toFloat session.screen.width / 420))
        |> List.map (row [ scale 16 |> spacing, width fill ])
        |> column
            [ width fill
            , height fill
            , scale 10 |> padding
            , scale 16 |> spacing
            , scrollbarY
            ]
    ]
        |> column
            [ width fill
            , scale 10 |> spacing
            , height fill
            ]
        |> renderElmUi


greedyGroupsOf : Int -> List a -> List (List a)
greedyGroupsOf size xs =
    greedyGroupsOfWithStep size size xs


{-| Split list into groups of size given by the first argument "greedily" (don't throw the group away if not long enough). After each group, drop a number of elements given by the second argumet before starting the next group.
greedyGroupsOfWithStep 3 2 [1..6]
== [[1,2,3],[3,4,5],[5,6]]
-}
greedyGroupsOfWithStep : Int -> Int -> List a -> List (List a)
greedyGroupsOfWithStep size step xs =
    let
        group =
            List.take size xs

        xs_ =
            List.drop step xs

        okayArgs =
            size > 0 && step > 0

        okayXs =
            List.length xs > 0
    in
    if okayArgs && okayXs then
        group :: greedyGroupsOfWithStep size step xs_

    else
        []



--searchBar :  String -> Element Msg


searchBar scale wid_ url =
    [ Input.text
        [ fill
            |> width
        ]
        { onChange = Input
        , text = url
        , placeholder = Just (Input.placeholder [] (text "course-url"))
        , label = Input.labelHidden "search input field"
        }
    , Element.link
        ([ Border.shadow
            { offset = ( 0, 0 )
            , blur = 6
            , size = 1
            , color = Element.rgba 0 0 0 0.2
            }
         , scale 28 |> px |> height
         ]
            ++ (if wid_ > 400 then
                    []

                else
                    [ width fill ]
               )
        )
        { url = href url
        , label = text "load course" |> el [ Element.paddingXY 20 0, centerX ]
        }
    ]
        |> (if wid_ > 400 then
                Element.wrappedRow
                    [ scale 10 |> spacing
                    , width fill
                    ]

            else
                column
                    [ scale 10 |> spacing
                    , width fill
                    ]
           )
        |> el
            [ scale 10 |> Font.size
            , width fill
            , paddingXY (scale 10) 0
            ]



--card : Course -> Element Msg


card scale course =
    column
        [ width fill
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
                        none
                            |> el
                                [ width fill
                                , Background.color <| Element.rgb 0 0 0
                                , scale 90 |> px |> height
                                , str_a
                                    |> author scale
                                    |> Element.inFront
                                ]

                    ( str_a, str_l ) ->
                        none
                            |> el
                                [ width fill
                                , Background.color <| Element.rgb 0 0 0
                                , Background.image str_l
                                , scale 90 |> px |> height
                                , str_a
                                    |> author scale
                                    |> Element.inFront
                                ]
                , [ [ title
                        |> inlines
                        |> Html.div
                            [ Attr.style "white-space" "nowrap"
                            , Attr.style "overflow" "hidden"
                            , Attr.style "text-overflow" "ellipsis"
                            ]
                        |> Element.html
                    ]
                        |> paragraph
                            [ scale 16 |> Font.size
                            , width fill
                            , Font.bold
                            , Font.color <| Element.rgb 0.6 0 0
                            ]
                  , [ definition.comment
                        |> inlines
                        |> Html.div []
                        |> Element.html
                    ]
                        |> Element.paragraph
                            [ scale 10 |> Font.size
                            , scale 60 |> px |> height
                            , Element.scrollbarY
                            ]
                  , viewVersions scale course
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
                        |> row
                            [ width fill
                            , scale 10 |> spacing
                            , scale 11 |> Font.size
                            ]
                  ]
                    |> column [ width fill, scale 10 |> spacing, scale 10 |> padding ]
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



--author : String -> Element msg


author scale str =
    (if str == "" then
        "by Annonymous"

     else
        "by " ++ str
    )
        |> text
        |> el
            [ scale 10 |> padding
            , scale 12 |> Font.size
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


href : String -> String
href url =
    "./?" ++ url



--viewVersions : Course -> Element Msg


viewVersions scale course =
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
                    , scale 8 |> Font.size
                    , paddingXY (scale 5) 2
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
        |> row [ scale 10 |> spacing ]


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
