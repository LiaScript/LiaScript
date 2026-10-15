module Lia.Markdown.Survey.View exposing (view)

{-| Rendering of surveys and, within a classroom, of the shared answers as
diagrams and tables.
-}

import Accessibility.Aria as A11y_Aria
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
        , surveyUpdate
        )
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Chart.View as Chart
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation)
import Lia.Markdown.Inline.Config exposing (Config)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (dropHere, dropZoneLabel, viewer)
import Lia.Markdown.Quiz.View exposing (openState, syncAttributes, viewMatrixTableSync, viewTableSync)
import Lia.Markdown.Survey.Sync as Sync exposing (Sync)
import Lia.Markdown.Survey.Types
    exposing
        ( Analysis(..)
        , Element
        , State(..)
        , Survey
        , Type(..)
        , Vector
        , initOptions
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
        ( btn
        , combobox
        , dropdownList
        , icon
        , labeledOption
        , shuffle
        , string2Color
        )
import List.Extra


{-| Render a survey and return the id of its script, if it has one.
`renderedOptions` (used only for `Vector`) is pre-rendered by the caller
(`Lia.Markdown.View`, which recursively renders nested `Block` content via
`viewBlocks`), one `List (Html Main.Msg)` per option - exactly as with
Task-list items and Quiz-Vector options.
-}
view : Config Main.Msg -> Maybe String -> Parameters -> Survey Markdown.Block -> Vector -> List ( String, List (Html Main.Msg) ) -> ( Maybe Int, Html Main.Msg )
view config labeledBy attr survey model renderedOptions =
    let
        id =
            survey.id

        -- name of the inputs and prefix of the option ids
        base =
            "lia-survey-" ++ String.fromInt config.slide ++ "-" ++ String.fromInt id

        element =
            Array.get id model

        submitted =
            element
                |> Maybe.map .submitted
                |> Maybe.withDefault False

        opt =
            element
                |> Maybe.map .opt
                |> Maybe.withDefault initOptions

        state =
            Maybe.map .state element

        frame class body =
            viewSurvey config attr class element id body

        syncData =
            Sync_.get config.sync .survey config.slide id
    in
    ( Maybe.andThen .scriptID element
    , case survey.survey of
        Text lines ->
            (case state of
                Just (Text_State str) ->
                    str

                _ ->
                    ""
            )
                |> viewText config labeledBy lines id submitted
                |> Html.map Main.UpdateSurvey
                |> frame "text"
                |> viewTextSync config lines syncData

        Select options ->
            (case state of
                Just (Select_State open value) ->
                    ( open, value )

                _ ->
                    ( False, -1 )
            )
                |> viewSelect config opt.randomize options id submitted
                |> Html.map Main.UpdateSurvey
                |> frame "select"
                |> viewSelectSync config options syncData

        DragAndDrop options ->
            (case state of
                Just (DragAndDrop_State highlight active value) ->
                    ( highlight, active, value )

                _ ->
                    ( False, False, -1 )
            )
                |> viewDrop config opt.randomize options id submitted
                |> Html.map Main.UpdateSurvey
                |> frame "drop"
                |> viewSelectSync config options syncData

        Vector checkbox questions analysis ->
            renderedOptions
                |> List.indexedMap (viewOption base checkbox (isChecked state) (VectorUpdate id) submitted)
                |> shuffle opt.randomize
                |> Html.div
                    [ Attr.class "lia-quiz__answers"
                    , if checkbox then
                        A11y_Role.group

                      else
                        A11y_Role.radioGroup
                    , labeledBy
                        |> Maybe.map A11y_Aria.labelledBy
                        |> Maybe.withDefault (Attr.class "")
                    ]
                |> frame
                    (if checkbox then
                        "multiple-choice"

                     else
                        "single-choice"
                    )
                |> viewVectorSync config analysis (List.map Tuple.first questions) syncData

        Matrix checkbox header vars questions ->
            questions
                |> List.indexedMap (viewRow config base checkbox (isCheckedRow state) (MatrixUpdate id) submitted vars)
                |> shuffle opt.randomize
                |> viewMatrix config base header
                |> Html.map Main.UpdateSurvey
                |> frame "matrix"
                |> viewMatrixSync config questions vars syncData
    )


isChecked : Maybe State -> String -> Bool
isChecked state var =
    case state of
        Just (Vector_State _ dict) ->
            Dict.get var dict == Just True

        _ ->
            False


isCheckedRow : Maybe State -> Int -> String -> Bool
isCheckedRow state row var =
    case state of
        Just (Matrix_State _ matrix) ->
            (matrix
                |> Array.get row
                |> Maybe.andThen (Dict.get var)
            )
                == Just True

        _ ->
            False



-- SURVEY


{-| The survey `body` with its submit button and feedback.
-}
viewSurvey : Config Main.Msg -> Parameters -> String -> Maybe Element -> Int -> Html Main.Msg -> Html Main.Msg
viewSurvey config attr class element id body =
    let
        submitted =
            element
                |> Maybe.map .submitted
                |> Maybe.withDefault False
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
        [ body
        , element
            |> Maybe.map (.opt >> .updates_allowed)
            |> Maybe.withDefault False
            |> viewSubmitButton config submitted id
        , if submitted then
            Html.div
                [ Attr.class "lia-quiz__feedback text-success", Attr.id (feedbackID id) ]
                [ Html.text (surveySubmitted config.lang) ]

          else
            Html.text ""
        , case Maybe.andThen .errorMsg element of
            Just error ->
                Html.div [ Attr.class "lia-quiz__feedback text-error", Attr.id (feedbackID id) ]
                    [ Html.text <|
                        if error /= "" then
                            error

                        else if class == "matrix" then
                            Translations.surveyErrorMatrix config.lang

                        else
                            Translations.surveyError config.lang
                    ]

            Nothing ->
                Html.text ""
        ]


feedbackID : Int -> String
feedbackID id =
    "lia-survey-feedback-" ++ String.fromInt id


{-| Submit, or update a submitted survey, if this is allowed.
-}
viewSubmitButton : Config Main.Msg -> Bool -> Int -> Bool -> Html Main.Msg
viewSubmitButton config submitted id updatesAllowed =
    let
        ( msg, title, text ) =
            if not submitted then
                ( Just (Submit id), surveySubmit, surveySubmit )

            else if updatesAllowed then
                ( Just (Reactivate id), surveyUpdate, surveyUpdate )

            else
                ( Nothing, surveySubmitted, surveySubmit )
    in
    Html.div [ Attr.class "lia-quiz__control" ]
        [ btn
            { msg = Maybe.map Main.UpdateSurvey msg
            , tabbable = True
            , title = title config.lang
            }
            [ Attr.class "lia-btn--outline lia-quiz__check" ]
            [ Html.text (text config.lang) ]
        ]


{-| A single line input or, for more `lines`, a textarea.
-}
viewText : Config sub -> Maybe String -> Int -> Int -> Bool -> String -> Html (Msg sub)
viewText config labeledBy lines id submitted str =
    let
        attr =
            [ onInput <| TextUpdate id
            , labeledBy
                |> Maybe.map A11y_Aria.labelledBy
                |> Maybe.withDefault (A11y_Aria.label (surveyText config.lang))
            , Attr.placeholder (surveyText config.lang)
            , Attr.value str
            , Attr.disabled submitted
            ]
    in
    if lines == 1 then
        Html.input (Attr.class "lia-input lia-quiz__input" :: attr) []

    else
        Html.textarea
            (Attr.class "lia-input lia-quiz__input"
                :: Attr.rows lines
                :: attr
            )
            []


{-| A select-only combobox, the keyboard is handled by
`typescript/liascript/combobox.ts`, which clicks the existing elements.
-}
viewSelect : Config sub -> Maybe (List Int) -> List Inlines -> Int -> Bool -> ( Bool, Int ) -> Html (Msg sub)
viewSelect config randomize options id submitted ( open, value ) =
    let
        listID =
            "lia-survey-" ++ String.fromInt config.slide ++ "-" ++ String.fromInt id ++ "-select"
    in
    Html.div [ Attr.class "lia-quiz__answers" ]
        [ Html.div
            [ Attr.class "lia-dropdown" ]
            [ Html.span
                (combobox listID open submitted (A11y_Aria.label (Translations.quizSelection config.lang))
                    ++ [ if submitted then
                            Attr.class "is-disabled"

                         else
                            onClick <| SelectUpdate id Choose
                       ]
                )
                [ Html.span []
                    [ options
                        |> List.Extra.getAt value
                        |> Maybe.map (inlines config >> Html.span [])
                        |> Maybe.withDefault (Html.text (Translations.quizSelection config.lang))
                    ]
                , icon
                    (if open then
                        "icon-chevron-up"

                     else
                        "icon-chevron-down"
                    )
                    []
                ]
            , options
                |> List.indexedMap
                    (\i option ->
                        Html.div
                            [ Attr.class "lia-dropdown__option"
                            , Attr.id (listID ++ "-" ++ String.fromInt i)
                            , A11y_Role.option
                            , A11y_Aria.selected (i == value)
                            , onClick (SelectUpdate id (Update i))
                            ]
                            (inlines config option)
                    )
                |> shuffle randomize
                |> Html.div
                    (dropdownList listID
                        open
                        [ Attr.class "lia-dropdown__options"
                        , Attr.class <|
                            if open then
                                "is-visible"

                            else
                                "is-hidden"
                        ]
                    )
            ]
        ]


{-| A target and the remaining options, which can be dragged onto the target or
clicked. The option on the target can be dragged out or the target clicked to
remove it.
-}
viewDrop : Config sub -> Maybe (List Int) -> List Inlines -> Int -> Bool -> ( Bool, Bool, Int ) -> Html (Msg sub)
viewDrop config randomize options id submitted ( highlight, active, value ) =
    let
        unlessSubmitted msg =
            if submitted then
                None

            else
                DropUpdate id msg

        onKeys msg =
            A11y_Key.onKeyDown <|
                if submitted then
                    []

                else
                    [ A11y_Key.enter (DropUpdate id msg)
                    , A11y_Key.space (DropUpdate id msg)
                    ]

        on event msg =
            Html.Events.on event (JD.succeed (unlessSubmitted msg))

        draggable =
            Attr.draggable <|
                if submitted then
                    "false"

                else
                    "true"
    in
    Html.div []
        [ Html.div
            [ Attr.style "width" "100%"
            , Attr.style "padding" "0.5rem"
            , Attr.style "margin" "0.25rem"
            , Attr.style "position" "relative"
            , onClick (unlessSubmitted Target)
            , A11y_Role.button
            , dropZoneLabel config.lang "" (Maybe.map stringify (List.Extra.getAt value options))
            , onKeys Target

            -- only a filled drop zone does something, Enter clears it
            , Attr.tabindex <|
                if submitted || List.Extra.getAt value options == Nothing then
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
            [ case List.Extra.getAt value options of
                Just option ->
                    Html.div
                        [ Attr.style "border" "3px dotted #888"
                        , Attr.style "padding" "1rem"
                        , Attr.style "cursor" "pointer"
                        , Attr.style "background-color" "#88888822"
                        , Attr.style "border-radius" "4px"
                        , Attr.style "display" "flex"
                        , Attr.style "justify-content" "center"
                        , draggable
                        , on "dragend" (Drop value)
                        , on "dragstart" Start
                        ]
                        (inlines config option)

                Nothing ->
                    dropHere
                        [ A11y_Aria.hidden True
                        , Attr.style "height" "4rem"
                        , Attr.style "display" "flex"
                        , Attr.style "font-size" "4rem" -- fallback
                        , Attr.style "font-size" "min(10vw, 4rem)" -- scales with viewport
                        , Attr.style "line-height" "1"
                        ]
            , Html.div
                [ on "dragenter" (Enter True)
                , on "dragleave" (Enter False)
                , Attr.style "height" "100%"
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
                (\i option ->
                    if i == value then
                        Nothing

                    else
                        option
                            |> inlines config
                            |> Html.span
                                [ Attr.style "border" "3px dotted #888"
                                , Attr.style "margin" "0.25rem"
                                , Attr.style "padding" "1rem"
                                , Attr.style "cursor" "pointer"
                                , Attr.style "background-color" "#88888822"
                                , Attr.style "border-radius" "4px"
                                , draggable
                                , on "dragend" (Drop i)
                                , on "dragstart" Start
                                , onClick (unlessSubmitted (Source i))
                                , onKeys (Source i)
                                , Attr.style "display" "inline-flex"
                                , A11y_Role.button
                                , Attr.tabindex 0
                                ]
                            |> Just
                )
            |> shuffle randomize
            |> List.filterMap identity
            |> Html.div
                [ Attr.style "display" "flex"
                , Attr.style "flex-wrap" "wrap"
                , Attr.style "gap" "0.5rem"
                , Attr.style "align-items" "flex-start"
                , Attr.style "margin" "1rem 0px"
                ]
        ]


{-| A checkbox or radio button with the pre-rendered `body` of the option.
-}
viewOption : String -> Bool -> (String -> Bool) -> (String -> Msg Main.Msg) -> Bool -> Int -> ( String, List (Html Main.Msg) ) -> Html Main.Msg
viewOption base checkbox checked msg submitted i ( var, body ) =
    labeledOption (base ++ "-option-" ++ String.fromInt i)
        (\label ->
            input checkbox (msg var) (checked var) submitted [ Attr.name base, label ]
                |> Html.map Main.UpdateSurvey
        )
        body


{-| Every input is labeled by its row and column header (`base`-row-i and
`base`-col-j).
-}
viewMatrix : Config sub -> String -> List Inlines -> List (Html (Msg sub)) -> Html (Msg sub)
viewMatrix config base header rows =
    Html.div [ Attr.class "lia-table-responsive has-thead-sticky has-last-col-sticky" ]
        [ Html.table [ Attr.class "lia-table lia-survey-matrix is-alternating" ]
            [ header
                |> List.indexedMap
                    (\column ->
                        inlines config
                            >> Html.th
                                [ Attr.class "lia-table__head lia-survey-matrix__head"
                                , Attr.scope "col"
                                , Attr.id (base ++ "-col-" ++ String.fromInt column)
                                ]
                    )
                |> Html.tr []
                |> List.singleton
                |> Html.thead [ Attr.class "lia-table__head lia-survey-matrix__head" ]
            , Html.tbody [ Attr.class "lia-table__body lia-survey-matrix__body" ] rows
            ]
        ]


{-| One checkbox or radio button per variable and the statement of the row,
radio buttons of one row form a group.
-}
viewRow : Config sub -> String -> Bool -> (Int -> String -> Bool) -> (Int -> String -> Msg sub) -> Bool -> List String -> Int -> Inlines -> Html (Msg sub)
viewRow config base checkbox checked msg submitted vars row statement =
    let
        rowID =
            base ++ "-row-" ++ String.fromInt row
    in
    vars
        |> List.indexedMap
            (\column var ->
                Html.td [ Attr.class "lia-table__data lia-survey-matrix__data" ]
                    [ input checkbox
                        (msg row var)
                        (checked row var)
                        submitted
                        [ Attr.name rowID
                        , A11y_Aria.labelledBy (rowID ++ " " ++ base ++ "-col-" ++ String.fromInt column)
                        ]
                    ]
            )
        |> (\cells ->
                cells
                    ++ [ Html.th
                            [ Attr.class "lia-table__data lia-survey-matrix__data"
                            , Attr.scope "row"
                            , Attr.id rowID
                            ]
                            [ Html.span [] (inlines config statement) ]
                       ]
           )
        |> Html.tr [ Attr.class "lia-table__row lia-survey-matrix__row" ]


input : Bool -> Msg sub -> Bool -> Bool -> List (Html.Attribute (Msg sub)) -> Html (Msg sub)
input checkbox msg checked submitted attr =
    Html.input
        (List.append attr
            [ Attr.class <|
                if checkbox then
                    "lia-checkbox"

                else
                    "lia-radio"
            , Attr.type_ <|
                if checkbox then
                    "checkbox"

                else
                    "radio"
            , if submitted then
                Attr.disabled True

              else
                onClick msg
            , Attr.checked checked
            ]
        )
        []


inlines : Config sub -> Inlines -> List (Html (Msg sub))
inlines config =
    viewer config >> List.map (Html.map Script)



-- CLASSROOM


{-| Without a classroom, only the `fallback` is shown. An owner in Details mode
should see the pending roster immediately, even before `Sync.get` has any
container at all for this element (no sync event has arrived for it yet) --
mirrors `Quiz.View.viewSync`'s `Dict.empty` fallback. Everyone else (a
Shared-mode peer who hasn't answered yet, or a Summary-mode owner with no
container yet) still sees nothing, since `syncData == Nothing` there is a
genuine privacy gate, not just "no data yet".
-}
withSync : Config sub -> Maybe (Dict String Sync) -> (Sync_.Settings -> Dict String Sync -> Html msg) -> Html msg -> Html msg
withSync config syncData render fallback =
    case config.sync of
        Just sync ->
            case ( syncData, Sync_.isRoot sync ) of
                ( Nothing, False ) ->
                    fallback

                ( data, _ ) ->
                    render sync (Maybe.withDefault Dict.empty data)

        Nothing ->
            fallback


{-| The "Open" bar (how many known peers haven't answered yet), reusing
`Quiz.View.openState` -- only the Details-mode owner has the peer-roster
data to compute it, everyone else gets `Nothing` (no extra bar).
-}
openIfRoot : Sync_.Settings -> Dict String Sync -> Maybe ( JE.Value, JE.Value )
openIfRoot sync data =
    if Sync_.isRoot sync then
        Just (openState sync data)

    else
        Nothing


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


{-| Single line answers are summarized as a word cloud, longer texts are listed
(with the names of the peers for the owner).
-}
viewTextSync : Config sub -> Int -> Maybe (Dict String Sync) -> Html msg -> Html msg
viewTextSync config lines syncData survey =
    withSync config
        syncData
        (\sync data ->
            if lines == 1 then
                [ survey
                , data
                    |> Dict.values
                    |> Sync.wordCount
                    |> Maybe.withDefault []
                    |> wordCloud config
                ]
                    |> viewTableSync sync [ "Text" ] (toStringFn [ "Text" ]) data
                    |> Html.div []

            else
                [ survey
                , case
                    data
                        |> Dict.toList
                        |> List.filterMap (\( id, entry ) -> Sync.toText entry |> Maybe.map (Tuple.pair id))
                  of
                    [] ->
                        Html.text ""

                    answers ->
                        answers
                            |> List.map
                                (\( id, str ) ->
                                    textBlock
                                        (if Sync_.isRoot sync then
                                            Dict.get id sync.peersHistory

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
                    |> viewTableSync sync [] (\_ _ -> []) data
                    |> Html.div []
        )
        (Html.div [] [ survey ])


viewVectorSync : Config sub -> Analysis -> List String -> Maybe (Dict String Sync) -> Html msg -> Html msg
viewVectorSync config analysis ids syncData survey =
    withSync config
        syncData
        (\sync data ->
            let
                summary =
                    data
                        |> Dict.values
                        |> Sync.vector ids
                        |> Maybe.withDefault []
            in
            Html.div []
                [ survey
                , [ case analysis of
                        Categorical ->
                            barChart config (openIfRoot sync data) summary

                        Quantitative ->
                            ids
                                |> List.filterMap (String.split " " >> List.head >> Maybe.andThen String.toFloat)
                                |> distributionChart config summary
                  ]
                    |> viewTableSync sync ids (toStringFn ids) data
                    |> Html.div []
                ]
        )
        survey


viewMatrixSync : Config sub -> List Inlines -> List String -> Maybe (Dict String Sync) -> Html msg -> Html msg
viewMatrixSync config categories ids syncData survey =
    withSync config
        syncData
        (\sync data ->
            [ survey
            , data
                |> Dict.values
                |> Sync.matrix ids
                |> Maybe.withDefault []
                |> matrixChart config categories (openIfRoot sync data)
            ]
                |> viewMatrixTableSync sync
                    (List.map (\category -> ( stringify category, ids )) categories)
                    (toStringFn ids)
                    data
                |> Html.div []
        )
        survey


viewSelectSync : Config sub -> List Inlines -> Maybe (Dict String Sync) -> Html msg -> Html msg
viewSelectSync config options syncData survey =
    withSync config
        syncData
        (\sync data ->
            [ survey
            , data
                |> Dict.values
                |> Sync.select (List.length options)
                |> Maybe.withDefault []
                |> barChart config (openIfRoot sync data)
            ]
                |> viewTableSync sync [ "State" ] (toStringFn [ "State" ]) data
                |> Html.div []
        )
        survey


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



-- CHARTS


chart : Config sub -> JE.Value -> Html msg
chart config =
    Chart.eCharts
        { lang = config.lang
        , attr = syncAttributes
        , light = config.light
        }
        Nothing


{-| A bar with its relative value and, if it is not empty, a label with the
absolute and relative values.
-}
bar : List ( String, JE.Value ) -> Sync.Data -> JE.Value
bar label d =
    if d.absolute == 0 then
        JE.object [ ( "value", JE.float d.relative ) ]

    else
        JE.object
            [ ( "value", JE.float d.relative )
            , ( "label"
              , JE.object
                    (( "show", JE.bool True )
                        :: ( "formatter"
                           , String.fromInt d.absolute
                                ++ " ("
                                ++ String.fromFloat d.relative
                                ++ "%)"
                                |> JE.string
                           )
                        :: label
                    )
              )
            ]


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
          , JE.list JE.object
                [ [ ( "type", JE.string "wordCloud" )
                  , ( "layoutAnimation", JE.bool True )
                  , ( "gridSize", JE.int 5 )
                  , ( "shape", JE.string "pentagon" )
                  , ( "drawOutOfBound", JE.bool True )
                  , ( "sizeRange", JE.list JE.int [ 12, 50 ] )
                  , ( "emphasis", JE.object [ ( "focus", JE.string "self" ) ] )
                  , ( "data"
                    , data
                        |> JE.list
                            (\d ->
                                JE.object
                                    [ ( "name", JE.string d.value )
                                    , ( "value", JE.int d.absolute )
                                    , ( "textStyle", JE.object [ ( "color", JE.string (string2Color 160 d.value) ) ] )
                                    ]
                            )
                    )
                  ]
                ]
          )
        ]
        |> chart config


{-| One bar per option. `open`, when given, is `Quiz.View.openState`'s
("Open", <chart-value>) pair -- an extra bar showing how many known peers
haven't answered yet, exactly like the Quiz sync diagram. Only the
Details-mode owner has the peer-roster data (`peersHistory`) needed to compute
it, so callers pass `Nothing` for everyone else.
-}
barChart : Config sub -> Maybe ( JE.Value, JE.Value ) -> List Sync.Data -> Html msg
barChart config open data =
    let
        chartData =
            List.map (\d -> ( JE.string d.value, bar [] d )) data
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
          , JE.list JE.object
                [ [ ( "type", JE.string "bar" )
                  , ( "smooth", JE.bool True )
                  , ( "areaStyle", JE.object [ ( "opacity", JE.float 0.8 ) ] )
                  , ( "data", JE.list Tuple.second chartData )
                  ]
                ]
          )
        ]
        |> chart config


{-| The distribution of numeric options (`categories`), the probability
density is computed by `lia-chart` (`pdf`).
-}
distributionChart : Config sub -> List Sync.Data -> List Float -> Html msg
distributionChart config data categories =
    let
        sample =
            List.concatMap
                (\d ->
                    case d.value |> String.split " " |> List.head |> Maybe.andThen String.toFloat of
                        Just x ->
                            List.repeat d.absolute x

                        Nothing ->
                            []
                )
                data

        bound fn =
            categories
                |> fn
                |> Maybe.map JE.float
                |> Maybe.withDefault JE.null
    in
    JE.object
        [ ( "pdf"
          , JE.object
                [ ( "data", JE.list JE.float sample )
                , ( "min", bound List.minimum )
                , ( "max", bound List.maximum )
                , ( "size", JE.int (2 * List.length categories - 1) )
                , ( "width", JE.int 2 )
                ]
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
          , JE.list JE.object
                [ [ ( "type", JE.string "line" )
                  , ( "smooth", JE.bool True )
                  , ( "areaStyle", JE.object [ ( "opacity", JE.float 0.8 ) ] )
                  , ( "data", JE.null )
                  , ( "symbol", JE.string "none" )
                  ]
                ]
          )
        ]
        |> chart config


{-| One group of bars per row (`categories`) with one bar per option. `open`,
when given, is `Quiz.View.openState`'s ("Open", <chart-value>) pair. It's
rendered as one extra bar under its own "Open" category on the x-axis -- a
dedicated series holding `null` everywhere except that category, so it doesn't
get grouped in with the per-variable bars of the real questions (each of
those series is padded with a trailing `null` to match).
-}
matrixChart : Config sub -> List Inlines -> Maybe ( JE.Value, JE.Value ) -> List (List Sync.Data) -> Html msg
matrixChart config categories open data =
    let
        name =
            List.head >> Maybe.map .value >> Maybe.withDefault ""

        openName =
            open |> Maybe.map (Tuple.first >> List.singleton) |> Maybe.withDefault []

        openSeries =
            case open of
                Just ( openLabel, value ) ->
                    [ [ ( "type", JE.string "bar" )
                      , ( "name", openLabel )
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
                [ ( "data", JE.list identity (List.map (name >> JE.string) data ++ openName) ) ]
          )
        , ( "xAxis"
          , JE.object
                [ ( "type", JE.string "category" )
                , ( "data", JE.list identity (List.map (stringify >> JE.string) categories ++ openName) )
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
          , data
                |> List.map
                    (\row ->
                        [ ( "type", JE.string "bar" )
                        , ( "name", JE.string (name row) )
                        , ( "data"
                          , JE.list identity
                                (List.map (bar [ ( "rotate", JE.int 90 ) ]) row
                                    ++ (open |> Maybe.map (\_ -> [ JE.null ]) |> Maybe.withDefault [])
                                )
                          )
                        ]
                    )
                |> (\series -> series ++ openSeries)
                |> JE.list JE.object
          )
        ]
        |> chart config
