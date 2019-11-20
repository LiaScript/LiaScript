module Index.View exposing (view)

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import Index.Model exposing (Course, Model, Version)
import Index.Update exposing (Msg(..))
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View as Inline
import Lia.Settings.Model exposing (Mode(..))
import Version


view : Model -> Html Msg
view model =
    model.courses
        |> List.map viewCard
        |> (::) (searchBar model.input)
        |> Html.div [ Attr.style "overflow-y" "auto", Attr.style "height" "100%" ]


href : String -> Html.Attribute msg
href url =
    Attr.href <| "./?" ++ url


searchBar : String -> Html Msg
searchBar url =
    Html.div
        [ Attr.style "width" "100%"
        , Attr.style "text-align" "center"
        ]
        [ Html.h1 [] [ Html.text "Lia: Index" ]
        , Html.input [ onInput Input, Attr.placeholder "enter course URL" ] []
        , Html.a
            [ Attr.class "published-date"
            , href url
            ]
            [ Html.text "load URL" ]
        ]


viewCard : Course -> Html Msg
viewCard course =
    case get_active course of
        Just { title, definition } ->
            Html.div [ Attr.class "course-container" ]
                [ viewHeader definition.author definition.logo
                , Html.div [ Attr.class "course-body" ]
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
                    , viewVersions course
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
                                [ href course.id ]
                                [ Html.text "open" ]
                            ]
                        ]
                    ]
                ]

        Nothing ->
            Html.text "something went wrong"


viewVersions : Course -> Html Msg
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
                "V "
                    ++ value
                    |> Html.text
                    |> List.singleton
                    |> Html.li
                        [ onClick <| Activate course.id value
                        , case course.active of
                            Just active ->
                                if active == key then
                                    Attr.style "color" "green"

                                else
                                    Attr.style "color" "black"

                            Nothing ->
                                if i == last then
                                    Attr.style "color" "green"

                                else
                                    Attr.style "color" "black"
                        ]
            )
        |> Html.ul []
        |> List.singleton
        |> Html.div [ Attr.class "course-tags" ]


viewHeader : String -> String -> Html msg
viewHeader author logo =
    Html.div [ Attr.class "course-header" ]
        [ case ( String.trim author, String.trim logo ) of
            ( str_a, "" ) ->
                Html.div [ Attr.class "course-author--no-cover" ]
                    [ Html.h3 []
                        [ Html.text <|
                            "by "
                                ++ (if str_a == "" then
                                        "annonymous"

                                    else
                                        str_a
                                   )
                        ]
                    ]

            ( str_a, str_l ) ->
                Html.div
                    [ Attr.class "course-cover"
                    , Attr.style "background" <| "url('" ++ str_l ++ "')"
                    , Attr.style "background-size" "cover"
                    ]
                    [ Html.div [ Attr.class "course-author" ]
                        [ Html.h3 [] [ Html.text <| "by " ++ str_a ]
                        ]
                    ]
        ]


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
