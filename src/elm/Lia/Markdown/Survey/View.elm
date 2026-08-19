module Lia.Markdown.Survey.View exposing (view)

import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Array
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onClick, onInput)
import I18n.Translations as Translations
    exposing
        ( surveySubmit
        , surveySubmitted
        , surveyText
        )
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Chart.View as Chart
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View
    exposing
        ( dropHere
        , viewer
        )
import Lia.Markdown.Quiz.View exposing (openState, syncAttributes, viewTableSync)
import Lia.Markdown.Survey.Model
    exposing
        ( getErrorMessage
        , get_drop_state
        , get_matrix_state
        , get_select_state
        , get_submission_state
        , get_text_state
        , get_vector_state
        )
import Lia.Markdown.Survey.Sync as Sync exposing (Sync)
import Lia.Markdown.Survey.Types
    exposing
        ( Analysis(..)
        , Survey
        , Type(..)
        , Vector
        )
import Lia.Markdown.Survey.Update
    exposing
        ( DropMsg(..)
        , Msg(..)
        , SelectMsg(..)
        )
import Lia.Markdown.Types as Markdown
import Lia.Markdown.Update as Main
import Lia.Sync.Types as Sync_
import Lia.Utils
    exposing
        ( blockKeydown
        , btn
        , icon
        , string2Color
        )
import List.Extra


{-| Main Survey view function. `renderedOptions` (used only for `Vector`) is
pre-rendered by the caller (`Lia.Markdown.View`, which recursively renders
nested `Block` content via `viewBlocks`), one `List (Html Main.Msg)` per
option - exactly as with Task-list items and Quiz-Vector options.
-}
view : Config Main.Msg -> Parameters -> Survey Markdown.Block -> Vector -> List ( String, List (Html Main.Msg) ) -> ( Maybe Int, Html Main.Msg )
view config attr survey model renderedOptions =
    ( model
        |> Array.get survey.id
        |> Maybe.andThen .scriptID
    , case survey.survey of
        Text lines ->
            (view_text config (get_text_state model survey.id) lines survey.id
                >> Html.map Main.UpdateSurvey
            )
                |> view_survey config attr "text" model survey.id
                |> viewTextSync config lines (getSync config survey.id)

        Select inlines ->
            (view_select config inlines (get_select_state model survey.id) survey.id
                >> Html.map Main.UpdateSurvey
            )
                |> view_survey config attr "select" model survey.id
                |> viewSelectSync config inlines (getSync config survey.id)

        DragAndDrop inlines ->
            (view_drop config inlines (get_drop_state model survey.id) survey.id
                >> Html.map Main.UpdateSurvey
            )
                |> view_survey config attr "drop" model survey.id
                |> viewSelectSync config inlines (getSync config survey.id)

        Vector button questions analysis ->
            vector button (VectorUpdate survey.id) (get_vector_state model survey.id)
                |> view_vector renderedOptions
                |> view_survey
                    config
                    attr
                    (if button then
                        "single-choice"

                     else
                        "multiple-choice"
                    )
                    model
                    survey.id
                |> viewVectorSync config analysis questions (getSync config survey.id)

        --- IGNORE ---
        Matrix button header vars questions ->
            (matrix config button (MatrixUpdate survey.id) (get_matrix_state model survey.id) vars
                |> view_matrix config header questions
            )
                >> Html.map Main.UpdateSurvey
                |> view_survey config attr "matrix" model survey.id
                |> viewMatrixSync config questions vars (getSync config survey.id)
    )


getSync : Config sub -> Int -> Maybe (Dict String Sync)
getSync config id =
    Sync_.get config.sync .survey config.slide id


viewTextSync : Config sub -> Int -> Maybe (Dict String Sync) -> Html msg -> Html msg
viewTextSync config lines syncData survey =
    withSync config.sync
        syncData
        (\data ->
            case lines of
                1 ->
                    let
                        words =
                            data |> Dict.values |> Sync.wordCount |> Maybe.withDefault []
                    in
                    [ survey
                    , wordCloud config words
                    ]
                        |> viewSummary config.sync [ "Text" ] (toStringFn [ "Text" ]) data

                _ ->
                    let
                        isOwner =
                            config.sync |> Maybe.map Sync_.isRoot |> Maybe.withDefault False

                        peers =
                            config.sync |> Maybe.map .peersHistory |> Maybe.withDefault Dict.empty

                        answers =
                            data
                                |> Dict.toList
                                |> List.filterMap (\( id, entry ) -> Sync.toText entry |> Maybe.map (Tuple.pair id))
                    in
                    [ survey
                    , case answers of
                        [] ->
                            Html.text ""

                        list ->
                            list
                                |> List.map
                                    (\( id, str ) ->
                                        textBlock
                                            (if isOwner then
                                                Dict.get id peers

                                             else
                                                Nothing
                                            )
                                            str
                                    )
                                |> Html.div
                                    [ Attr.style "border" "1px solid rgb(var(--color-highlight))"
                                    , Attr.style "border-radius" "0.8rem"
                                    , Attr.style "max-height" "400px"
                                    , Attr.style "overflow" "auto"
                                    ]
                    ]
                        |> viewSummary config.sync [] (\_ _ -> []) data
        )
        (Html.div [] [ survey ])


{-| An owner in Details mode should see the pending roster immediately, even
before `Sync.get` has any container at all for this element (no sync event
has arrived for it yet) -- mirrors `Quiz.View.viewSync`'s `Dict.empty`
fallback. Everyone else (a Shared-mode peer who hasn't answered yet, or a
Summary-mode owner with no container yet) still sees nothing, since
`syncData == Nothing` there is a genuine privacy gate, not just "no data
yet".
-}
withSync : Maybe Sync_.Settings -> Maybe (Dict String Sync) -> (Dict String Sync -> Html msg) -> Html msg -> Html msg
withSync sync syncData render fallback =
    case sync of
        Nothing ->
            fallback

        Just sync_ ->
            case ( syncData, Sync_.isRoot sync_ ) of
                ( Nothing, False ) ->
                    fallback

                ( maybeData, _ ) ->
                    render (Maybe.withDefault Dict.empty maybeData)


viewSummary : Maybe Sync_.Settings -> List String -> (String -> Dict String Sync -> List (Html msg)) -> Dict String Sync -> List (Html msg) -> Html msg
viewSummary sync headers fn data =
    case sync of
        Just sync_ ->
            viewTableSync sync_ headers fn data
                >> Html.div []

        _ ->
            Html.div []


{-| The "Open" bar (how many known peers haven't answered yet), reusing
`Quiz.View.openState` -- only the Details-mode owner has the peer-roster
data to compute it, everyone else gets `Nothing` (no extra bar).
-}
openIfRoot : Config sub -> Dict String Sync -> Maybe ( JE.Value, JE.Value )
openIfRoot config data =
    config.sync
        |> Maybe.andThen
            (\sync_ ->
                if Sync_.isRoot sync_ then
                    Just (openState sync_ data)

                else
                    Nothing
            )


{-| Renders each user's answer(s) via `Sync.toString`, looked up by `keys` --
the "details" table row-fn shared by every survey type except the free-text
list (which shows each answer directly, not as a table column, see
`viewTextSync`).
-}
toStringFn : List String -> String -> Dict String Sync -> List (Html msg)
toStringFn keys id values =
    Dict.get id values
        |> Maybe.map (Sync.toString keys)
        |> Maybe.withDefault []
        |> List.map Html.text


viewVectorSync : Config sub -> Analysis -> List ( String, body ) -> Maybe (Dict String Sync) -> Html msg -> Html msg
viewVectorSync config analyze questions syncData survey =
    withSync config.sync
        syncData
        (\data ->
            let
                summary =
                    data
                        |> Dict.values
                        |> Sync.vector (List.map Tuple.first questions)
                        |> Maybe.withDefault []
            in
            Html.div []
                [ survey
                , case analyze of
                    Categorical ->
                        [ vectorBlockCategory config (openIfRoot config data) summary ]
                            |> viewSummary config.sync (questions |> List.map Tuple.first) (toStringFn (questions |> List.map Tuple.first)) data

                    Quantitative ->
                        [ questions
                            |> List.filterMap (Tuple.first >> String.split " " >> List.head >> Maybe.andThen String.toFloat)
                            |> vectorBlockQuantity config summary
                        ]
                            |> viewSummary config.sync (questions |> List.map Tuple.first) (toStringFn (questions |> List.map Tuple.first)) data
                ]
        )
        survey


viewMatrixSync : Config sub -> List Inlines -> List String -> Maybe (Dict String Sync) -> Html msg -> Html msg
viewMatrixSync config categories questions syncData survey =
    withSync config.sync
        syncData
        (\data ->
            let
                summary =
                    data
                        |> Dict.values
                        |> Sync.matrix questions
                        |> Maybe.withDefault []
            in
            [ survey
            , matrixBlock config categories (openIfRoot config data) summary
            ]
                |> viewSummary config.sync
                    (categories |> List.concatMap (\category -> questions |> List.map ((++) (stringify category ++ " / "))))
                    (toStringFn questions)
                    data
        )
        survey


viewSelectSync : Config sub -> List Inlines -> Maybe (Dict String Sync) -> Html msg -> Html msg
viewSelectSync config options syncData survey =
    withSync config.sync
        syncData
        (\data ->
            let
                summary =
                    data
                        |> Dict.values
                        |> Sync.select (List.length options)
                        |> Maybe.withDefault []
            in
            [ survey
            , vectorBlockCategory config (openIfRoot config data) summary
            ]
                |> viewSummary config.sync [ "State" ] (toStringFn [ "State" ]) data
        )
        survey


wordCloud : Config sub -> List Sync.Data -> Html msg
wordCloud config data =
    JE.object
        [ ( "tooltip"
          , JE.object
                [ ( "trigger", JE.string "item" )
                , ( "formatter", JE.string "{b} ({c})" )
                ]
          )
        , ( "series"
          , [ ( "type", JE.string "wordCloud" )
            , ( "layoutAnimation", JE.bool True )
            , ( "gridSize", JE.int 5 )
            , ( "shape", JE.string "pentagon" )
            , ( "drawOutOfBound", JE.bool True )
            , ( "sizeRange", JE.list JE.int [ 12, 50 ] )
            , ( "emphasis", JE.object [ ( "focus", JE.string "self" ) ] )
            , ( "data"
              , data
                    |> List.map
                        (\d ->
                            [ ( "name", JE.string d.value )
                            , ( "value", JE.int d.absolute )
                            , ( "textStyle"
                              , JE.object
                                    [ ( "color"
                                      , d.value
                                            |> string2Color 160
                                            |> JE.string
                                      )
                                    ]
                              )
                            ]
                        )
                    |> JE.list JE.object
              )
            ]
                |> List.singleton
                |> JE.list JE.object
          )
        ]
        |> Chart.eCharts
            { lang = config.lang
            , attr = syncAttributes
            , light = config.light
            }
            Nothing


{-| `open`, when given, is `Quiz.View.openState`'s ("Open", <chart-value>) pair
-- an extra bar showing how many known peers haven't answered yet, exactly
like the Quiz sync diagram. Only the Details-mode owner has the peer-roster
data (`peersHistory`) needed to compute it, so callers pass `Nothing` for
everyone else.
-}
vectorBlockCategory : Config sub -> Maybe ( JE.Value, JE.Value ) -> List Sync.Data -> Html msg
vectorBlockCategory config open data =
    let
        chartData =
            (data
                |> List.map
                    (\d ->
                        ( JE.string d.value
                        , case d.absolute of
                            0 ->
                                JE.object [ ( "value", JE.float d.relative ) ]

                            _ ->
                                JE.object
                                    [ ( "value", JE.float d.relative )
                                    , ( "label"
                                      , JE.object
                                            [ ( "show", JE.bool True )
                                            , ( "formatter"
                                              , String.fromInt d.absolute
                                                    ++ " ("
                                                    ++ String.fromFloat d.relative
                                                    ++ "%)"
                                                    |> JE.string
                                              )
                                            ]
                                      )
                                    ]
                        )
                    )
            )
                ++ (open |> Maybe.map List.singleton |> Maybe.withDefault [])
    in
    JE.object
        [ ( "grid"
          , JE.object
                [ ( "left", JE.int 10 )
                , ( "top", JE.int 20 )
                , ( "bottom", JE.int 20 )
                , ( "right", JE.int 10 )
                ]
          )
        , ( "xAxis"
          , JE.object
                [ ( "type", JE.string "category" )
                , ( "data", JE.list Tuple.first chartData )
                ]
          )
        , ( "yAxis"
          , JE.object
                [ ( "type", JE.string "value" )
                , ( "show", JE.bool False )
                ]
          )
        , ( "series"
          , [ [ ( "type", JE.string "bar" )
              , ( "smooth", JE.bool True )
              , ( "areaStyle", JE.object [ ( "opacity", JE.float 0.8 ) ] )
              , ( "data", JE.list Tuple.second chartData )
              ]
            ]
                |> JE.list JE.object
          )
        ]
        |> Chart.eCharts
            { lang = config.lang
            , attr = syncAttributes
            , light = config.light
            }
            Nothing


vectorBlockQuantity : Config sub -> List Sync.Data -> List Float -> Html msg
vectorBlockQuantity config data categories =
    let
        sample =
            data
                |> List.filterMap
                    (\v ->
                        case v.value |> String.split " " |> List.head |> Maybe.andThen String.toFloat of
                            Just i ->
                                Just (List.repeat v.absolute i)

                            _ ->
                                Nothing
                    )
                |> List.concat

        size =
            (2 * List.length categories) - 1
    in
    JE.object
        [ ( "pdf"
          , [ ( "data", JE.list JE.float sample )
            , ( "min"
              , categories
                    |> List.minimum
                    |> Maybe.map JE.float
                    |> Maybe.withDefault JE.null
              )
            , ( "max"
              , categories
                    |> List.maximum
                    |> Maybe.map JE.float
                    |> Maybe.withDefault JE.null
              )
            , ( "size", JE.int size )
            , ( "width", JE.int 2 )
            ]
                |> JE.object
          )
        , ( "grid"
          , JE.object
                [ ( "left", JE.int 50 )
                , ( "top", JE.int 20 )
                , ( "bottom", JE.int 20 )
                , ( "right", JE.int 20 )
                ]
          )
        , ( "tooltip", JE.object [ ( "trigger", JE.string "axis" ) ] )
        , ( "xAxis"
          , JE.object
                [ ( "type", JE.string "category" )
                , ( "data", JE.null )
                , ( "boundaryGap", JE.bool False )
                ]
          )
        , ( "yAxis"
          , JE.object
                [ ( "type", JE.string "value" )
                , ( "show", JE.bool True )
                ]
          )
        , ( "series"
          , [ [ ( "type", JE.string "line" )
              , ( "smooth", JE.bool True )
              , ( "areaStyle", JE.object [ ( "opacity", JE.float 0.8 ) ] )
              , ( "data", JE.null )
              , ( "symbol", JE.string "none" )
              ]
            ]
                |> JE.list JE.object
          )
        ]
        |> Chart.eCharts
            { lang = config.lang
            , attr = syncAttributes
            , light = config.light
            }
            Nothing


{-| `open`, when given, is `Quiz.View.openState`'s ("Open", <chart-value>)
pair. It's rendered as one extra bar under its own "Open" category on the
x-axis -- a dedicated series holding `null` everywhere except that category,
so it doesn't get grouped in with the per-variable bars of the real
questions (each of those series is padded with a trailing `null` to match).
-}
matrixBlock : Config sub -> List Inlines -> Maybe ( JE.Value, JE.Value ) -> List (List Sync.Data) -> Html msg
matrixBlock config categories open data =
    let
        openSeries =
            case open of
                Just ( name, value ) ->
                    [ [ ( "type", JE.string "bar" )
                      , ( "name", name )
                      , ( "data", JE.list identity (List.repeat (List.length categories) JE.null ++ [ value ]) )
                      ]
                    ]

                Nothing ->
                    []
    in
    JE.object
        [ ( "grid"
          , JE.object
                [ ( "left", JE.int 10 )
                , ( "top", JE.int 30 )
                , ( "bottom", JE.int 28 )
                , ( "right", JE.int 30 )
                ]
          )
        , ( "legend"
          , JE.object
                [ ( "data"
                  , (data |> List.map (List.head >> Maybe.map .value >> Maybe.withDefault "") |> List.map JE.string)
                        ++ (open |> Maybe.map (Tuple.first >> List.singleton) |> Maybe.withDefault [])
                        |> JE.list identity
                  )
                ]
          )
        , ( "xAxis"
          , JE.object
                [ ( "type", JE.string "category" )
                , ( "data"
                  , (categories |> List.map (stringify >> JE.string))
                        ++ (open |> Maybe.map (Tuple.first >> List.singleton) |> Maybe.withDefault [])
                        |> JE.list identity
                  )
                ]
          )
        , ( "yAxis"
          , JE.object
                [ ( "type", JE.string "value" )
                , ( "show", JE.bool False )
                ]
          )
        , ( "toolbox"
          , JE.object
                [ ( "orient", JE.string "vertical" )
                , Chart.feature
                    { saveAsImage = True
                    , dataView = True
                    , dataZoom = False
                    , magicType = True
                    , restore = False
                    }
                ]
          )
        , ( "tooltip", JE.object [] )
        , ( "series"
          , (data
                |> List.map
                    (\data_ ->
                        [ ( "type", JE.string "bar" )
                        , ( "name"
                          , data_
                                |> List.head
                                |> Maybe.map .value
                                |> Maybe.withDefault ""
                                |> JE.string
                          )
                        , ( "data"
                          , ((data_
                                |> List.map
                                    (\d ->
                                        case d.absolute of
                                            0 ->
                                                JE.object [ ( "value", JE.float d.relative ) ]

                                            _ ->
                                                JE.object
                                                    [ ( "value", JE.float d.relative )
                                                    , ( "label"
                                                      , JE.object
                                                            [ ( "show", JE.bool True )
                                                            , ( "formatter"
                                                              , String.fromInt d.absolute
                                                                    ++ " ("
                                                                    ++ String.fromFloat d.relative
                                                                    ++ "%)"
                                                                    |> JE.string
                                                              )
                                                            , ( "rotate", JE.int 90 )
                                                            ]
                                                      )
                                                    ]
                                    )
                             )
                                ++ (open |> Maybe.map (\_ -> [ JE.null ]) |> Maybe.withDefault [])
                            )
                                |> JE.list identity
                          )
                        ]
                    )
            )
                ++ openSeries
                |> JE.list JE.object
          )
        ]
        |> Chart.eCharts
            { lang = config.lang
            , attr = syncAttributes
            , light = config.light
            }
            Nothing


textBlock : Maybe String -> String -> Html msg
textBlock name str =
    Html.div
        [ Attr.style "background-color" "rgb(var(--color-background))"
        , Attr.style "border" "2px solid rgb(var(--color-border))"
        , Attr.style "border-radius" "0.6rem"
        , Attr.style "padding" "0.8rem"
        , Attr.style "margin" "0.5rem"
        ]
        [ Html.div [ Attr.style "white-space" "pre" ] [ Html.text str ]
        , case name of
            Just user ->
                Html.div
                    [ Attr.style "border-top" "1px solid rgb(var(--color-border))"
                    , Attr.style "margin-top" "0.5rem"
                    , Attr.style "padding-top" "0.4rem"
                    , Attr.style "text-align" "right"
                    , Attr.style "font-style" "italic"
                    , Attr.style "font-size" "0.85em"
                    , Attr.style "color" "rgb(var(--color-highlight-dark))"
                    ]
                    [ Html.text ("— " ++ user) ]

            Nothing ->
                Html.text ""
        ]


viewError : Maybe String -> Html msg
viewError message =
    case message of
        Nothing ->
            Html.text ""

        Just error ->
            Html.div [ Attr.class "lia-quiz__feedback text-error" ] [ Html.text error ]


view_survey :
    Config Main.Msg
    -> Parameters
    -> String
    -> Vector
    -> Int
    -> (Bool -> Html Main.Msg)
    -> Html Main.Msg
view_survey config attr class model idx fn =
    let
        submitted =
            get_submission_state model idx
    in
    Html.div
        (annotation
            ("lia-quiz lia-quiz-"
                ++ class
                ++ (if submitted then
                        ""

                    else
                        " open"
                   )
            )
            attr
        )
        [ fn submitted
        , submit_button config submitted idx
        , model
            |> getErrorMessage idx
            |> viewError
        ]


submit_button : Config Main.Msg -> Bool -> Int -> Html Main.Msg
submit_button config submitted idx =
    Html.div [ Attr.class "lia-quiz__control" ]
        [ if submitted then
            btn
                { msg = Nothing
                , tabbable = False
                , title = surveySubmitted config.lang
                }
                [ Attr.class "lia-btn--outline lia-quiz__check"
                , A11y_Role.button
                ]
                [ Html.text (surveySubmitted config.lang) ]

          else
            btn
                { msg = Just <| Main.UpdateSurvey (Submit idx)
                , tabbable = True
                , title = surveySubmit config.lang
                }
                [ Attr.class "lia-btn--outline lia-quiz__check"
                , A11y_Role.button
                ]
                [ Html.text (surveySubmit config.lang) ]
        ]


view_select : Config sub -> List Inlines -> ( Bool, Int ) -> Int -> Bool -> Html (Msg sub)
view_select config options ( open, value ) id submitted =
    Html.div [ Attr.class "lia-quiz__answers" ]
        [ Html.div
            [ Attr.class "lia-dropdown" ]
            [ Html.span
                [ Attr.class "lia-dropdown__selected"
                , if submitted then
                    Attr.disabled True

                  else
                    onClick <| SelectUpdate id Choose
                ]
                [ Html.span [] [ get_option config value options ]
                , icon
                    (if open then
                        "icon-chevron-up"

                     else
                        "icon-chevron-down"
                    )
                    []
                ]
            , options
                |> List.indexedMap (option config id)
                |> Html.div
                    [ Attr.class "lia-dropdown__options"
                    , Attr.tabindex -1
                    , Attr.class <|
                        if open then
                            "is-visible"

                        else
                            "is-hidden"
                    ]
            ]
        ]


view_drop : Config sub -> List Inlines -> ( Bool, Bool, Int ) -> Int -> Bool -> Html (Msg sub)
view_drop config options ( highlight, active, value ) id submitted =
    Html.div []
        [ Html.div
            [ Attr.style "width" "100%"
            , Attr.style "padding" "0.5rem"
            , Attr.style "margin" "0.25rem"
            , Attr.style "position" "relative"
            , Html.Events.onClick
                (if submitted then
                    None

                 else
                    DropUpdate id Target
                )
            , A11y_Role.button
            , A11y_Key.onKeyDown
                (if submitted then
                    []

                 else
                    [ A11y_Key.enter <| DropUpdate id Target
                    , A11y_Key.space <| DropUpdate id Target
                    ]
                )
            , Attr.tabindex <|
                if submitted then
                    -1

                else
                    0
            , Attr.style "border"
                (if highlight then
                    "5px dotted #888"

                 else
                    "3px dotted #888"
                )
            , Attr.style "border-radius" "5px"
            ]
            [ options
                |> List.Extra.getAt value
                |> Maybe.map
                    (viewer config
                        >> List.map (Html.map Script)
                        >> Html.div
                            [ Attr.style "border" "3px dotted #888"
                            , Attr.style "padding" "1rem"
                            , Attr.style "cursor" "pointer"
                            , Attr.style "background-color" "#f9f9f9"
                            , Attr.style "border-radius" "4px"
                            , Attr.style "display" "flex"
                            , Attr.style "justify-content" "center"
                            , Attr.style "display" "flex"
                            , Attr.draggable <|
                                if submitted then
                                    "false"

                                else
                                    "true"
                            , Html.Events.on "dragend"
                                (JD.succeed
                                    (if submitted then
                                        None

                                     else
                                        DropUpdate id (Drop value)
                                    )
                                )
                            , Html.Events.on "dragstart"
                                (JD.succeed
                                    (if submitted then
                                        None

                                     else
                                        DropUpdate id Start
                                    )
                                )
                            , A11y_Role.button
                            , Attr.tabindex 0
                            ]
                    )
                |> Maybe.withDefault
                    (dropHere
                        [ Attr.style "height" "4rem"
                        , Attr.style "display" "flex"
                        , Attr.style "font-size" "4rem" -- fallback
                        , Attr.style "font-size" "min(10vw, 4rem)" -- scales with viewport
                        , Attr.style "line-height" "1"
                        ]
                    )
            , Html.div
                [ Html.Events.on "dragenter"
                    (JD.succeed
                        (if submitted then
                            None

                         else
                            DropUpdate id (Enter True)
                        )
                    )
                , Html.Events.on "dragleave"
                    (JD.succeed
                        (if submitted then
                            None

                         else
                            DropUpdate id (Enter False)
                        )
                    )
                , Attr.style
                    "height"
                    "100%"
                , Attr.style "width" "100%"
                , Attr.style "position" "absolute"
                , Attr.style "top" "0"
                , Attr.style "left" "0"
                , Attr.style "z-index" "10"
                , Attr.style "display"
                    (if active then
                        "block"

                     else
                        "none"
                    )
                ]
                []
            ]
        , options
            |> List.indexedMap
                (\i a ->
                    if i == value then
                        Nothing

                    else
                        viewer config a
                            |> List.map (Html.map Script)
                            |> Html.span
                                [ Attr.style "border" "3px dotted #888"
                                , Attr.style "margin" "0.25rem"
                                , Attr.style "padding" "1rem"
                                , Attr.style "cursor" "pointer"
                                , Attr.style "background-color" "#f9f9f9"
                                , Attr.style "border-radius" "4px"
                                , Attr.draggable <|
                                    if submitted then
                                        "false"

                                    else
                                        "true"
                                , Html.Events.on "dragend"
                                    (JD.succeed
                                        (if submitted then
                                            None

                                         else
                                            DropUpdate id (Drop i)
                                        )
                                    )
                                , Html.Events.on "dragstart"
                                    (JD.succeed <|
                                        if submitted then
                                            None

                                        else
                                            DropUpdate id Start
                                    )
                                , Html.Events.onClick
                                    (if submitted then
                                        None

                                     else
                                        DropUpdate id (Source i)
                                    )
                                , A11y_Key.onKeyDown
                                    (if submitted then
                                        []

                                     else
                                        [ A11y_Key.enter (DropUpdate id (Source i))
                                        , A11y_Key.space (DropUpdate id (Source i))
                                        ]
                                    )
                                , Attr.style "display" "inline-flex"
                                , A11y_Role.button
                                , Attr.tabindex 0
                                ]
                            |> Just
                )
            |> List.filterMap identity
            |> Html.div
                [ Attr.style "display" "flex"
                , Attr.style "flex-wrap" "wrap"
                , Attr.style "gap" "0.5rem"
                , Attr.style "align-items" "flex-start"
                , Attr.style "margin" "1rem 0px"
                ]
        ]


option : Config sub -> Int -> Int -> Inlines -> Html (Msg sub)
option config id1 id2 opt =
    opt
        |> viewer config
        |> List.map (Html.map Script)
        |> Html.div
            [ Attr.class "lia-dropdown__option"
            , Update id2
                |> SelectUpdate id1
                |> onClick
            ]


get_option : Config sub -> Int -> List Inlines -> Html (Msg sub)
get_option config id list =
    case ( id, list ) of
        ( 0, x :: _ ) ->
            x |> viewer config |> List.map (Html.map Script) |> Html.span []

        ( i, _ :: xs ) ->
            get_option config (i - 1) xs

        ( _, [] ) ->
            Html.text <| Translations.quizSelection config.lang


view_text : Config sub -> String -> Int -> Int -> Bool -> Html (Msg sub)
view_text config str lines idx submitted =
    let
        attr =
            [ onInput <| TextUpdate idx
            , Attr.placeholder (surveyText config.lang)
            , Attr.value str
            , Attr.disabled submitted
            ]
    in
    case lines of
        1 ->
            Html.input
                (Attr.class "lia-input lia-quiz__input"
                    --:: onKeyDown (KeyDown idx)
                    :: attr
                )
                []

        _ ->
            Html.textarea
                (Attr.class "lia-input lia-quiz__input"
                    :: blockKeydown (TextUpdate idx str)
                    :: Attr.rows lines
                    :: attr
                )
                []


view_vector : List ( String, List (Html Main.Msg) ) -> (Bool -> ( String, List (Html Main.Msg) ) -> Html Main.Msg) -> Bool -> Html Main.Msg
view_vector options fn submitted =
    let
        fnX =
            fn submitted
    in
    List.map fnX options
        |> Html.div [ Attr.class "lia-quiz__answers" ]


view_matrix :
    Config sub
    -> List Inlines
    -> List Inlines
    -> (Bool -> ( Int, Inlines ) -> Html (Msg sub))
    -> Bool
    -> Html (Msg sub)
view_matrix config header questions fn submitted =
    let
        fnX =
            fn submitted
    in
    Html.div [ Attr.class "lia-table-responsive has-thead-sticky has-last-col-sticky" ]
        [ Html.table [ Attr.class "lia-table lia-survey-matrix is-alternating" ]
            [ header
                |> List.map ((viewer config >> List.map (Html.map Script)) >> Html.th [ Attr.class "lia-table__head lia-survey-matrix__head" ])
                |> Html.thead [ Attr.class "lia-table__head lia-survey-matrix__head", A11y_Role.columnHeader ]
            , questions
                |> List.indexedMap Tuple.pair
                |> List.map fnX
                |> Html.tbody [ Attr.class "lia-table__body lia-survey-matrix__body", A11y_Role.rowHeader ]
            ]
        ]


vector :
    Bool
    -> (String -> Msg Main.Msg)
    -> (String -> Bool)
    -> Bool
    -> ( String, List (Html Main.Msg) )
    -> Html Main.Msg
vector button msg fn submitted ( var, body ) =
    Html.label [ Attr.class "lia-label lia-label--top" ]
        [ input button (msg var) (fn var) submitted
            |> Html.map Main.UpdateSurvey
        , Html.div [ Attr.style "width" "100%" ] body
        ]


matrix :
    Config sub
    -> Bool
    -> (Int -> String -> Msg sub)
    -> (Int -> String -> Bool)
    -> List String
    -> Bool
    -> ( Int, Inlines )
    -> Html (Msg sub)
matrix config button msg fn vars submitted ( row, elements ) =
    let
        msgX =
            msg row

        fnX =
            fn row
    in
    Html.tr [ Attr.class "lia-table__row lia-survey-matrix__row" ] <|
        List.append
            (List.map
                (\var ->
                    Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
                        [ input button (msgX var) (fnX var) submitted ]
                )
                vars
            )
            [ Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ] [ inline config elements ] ]


input : Bool -> Msg sub -> Bool -> Bool -> Html (Msg sub)
input button msg checked submitted =
    Html.input
        [ Attr.class <|
            if button then
                "lia-checkbox"

            else
                "lia-radio"
        , Attr.type_ <|
            if button then
                "checkbox"

            else
                "radio"
        , if submitted then
            Attr.disabled True

          else
            onClick msg
        , Attr.checked checked
        ]
        []


inline : Config sub -> Inlines -> Html (Msg sub)
inline config elements =
    Html.span [] <| (viewer config >> List.map (Html.map Script)) elements
