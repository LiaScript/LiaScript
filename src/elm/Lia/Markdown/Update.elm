port module Lia.Markdown.Update exposing
    ( Msg(..)
    , handle
    , initEffect
    , nextEffect
    , previousEffect
    , subscriptions
    , ttsReplay
    , update
    , updateScript
    )

import Json.Encode as JE
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Update as Code
import Lia.Markdown.Effect.Model as E
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts)
import Lia.Markdown.Effect.Update as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.Gallery.Update as Gallery
import Lia.Markdown.Quiz.Update as Quiz
import Lia.Markdown.Survey.Update as Survey
import Lia.Markdown.Table.Update as Table
import Lia.Markdown.Task.Update as Task
import Lia.Section exposing (Section, SubSection(..))
import Lia.Utils exposing (focus)
import Port.Event as Event exposing (Event)
import Return exposing (Return, upgrade)


port footnote : (String -> msg) -> Sub msg


type Msg
    = UpdateEffect Bool (Effect.Msg Msg)
    | UpdateCode Code.Msg
    | UpdateQuiz (Quiz.Msg Msg)
    | UpdateSurvey (Survey.Msg Msg)
    | UpdateTable (Table.Msg Msg)
    | UpdateTask (Task.Msg Msg)
    | UpdateGallery (Gallery.Msg Msg)
    | FootnoteHide
    | FootnoteShow String
    | Script (Script.Msg Msg)
    | NoOp


subscriptions : Section -> Sub Msg
subscriptions _ =
    footnote FootnoteShow


send : String -> Int -> List Event -> List Event
send name id =
    List.map (Event.encode >> Event name id)


update : Definition -> Msg -> Section -> Return Section Msg Msg
update globals msg section =
    case msg of
        UpdateEffect sound childMsg ->
            section.effect_model
                |> Effect.update
                    (section.definition
                        |> Maybe.withDefault globals
                        |> Just
                        |> subs
                    )
                    sound
                    childMsg
                |> Return.map (\v -> { section | effect_model = v })
                |> Return.cmdMap (UpdateEffect sound)
                |> Return.upgrade "effect" section.id

        UpdateCode childMsg ->
            section.code_model
                |> Code.update section.effect_model.javascript childMsg
                |> Return.map (\v -> { section | code_model = v })
                |> Return.upgrade "code" section.id

        UpdateQuiz childMsg ->
            section.quiz_vector
                |> Quiz.update section.effect_model.javascript childMsg
                |> Return.map (\v -> { section | quiz_vector = v })
                |> Return.upgrade "quiz" section.id
                |> updateScript

        UpdateTask childMsg ->
            section.task_vector
                |> Task.update section.effect_model.javascript childMsg
                |> Return.map (\v -> { section | task_vector = v })
                |> Return.upgrade "task" section.id
                |> updateScript

        UpdateGallery childMsg ->
            section.gallery_vector
                |> Gallery.update childMsg
                |> Return.map (\v -> { section | gallery_vector = v })
                |> updateScript

        UpdateSurvey childMsg ->
            section.survey_vector
                |> Survey.update section.effect_model.javascript childMsg
                |> Return.map (\v -> { section | survey_vector = v })
                |> Return.upgrade "survey" section.id
                |> updateScript

        UpdateTable childMsg ->
            section.table_vector
                |> Table.update childMsg
                |> Return.map (\v -> { section | table_vector = v })

        FootnoteShow key ->
            { section | footnote2show = Just key }
                |> Return.value
                |> Return.cmd (focus NoOp "lia-modal__close")

        FootnoteHide ->
            { section | footnote2show = Nothing }
                |> Return.value
                |> Return.cmd
                    (section.footnote2show
                        |> Maybe.map (Footnote.byKey >> focus NoOp)
                        |> Maybe.withDefault Cmd.none
                    )

        Script childMsg ->
            section
                |> Return.value
                |> Return.script childMsg
                |> updateScript

        NoOp ->
            Return.value section


subs :
    Maybe Definition
    ->
        { update : Scripts SubSection -> Msg -> SubSection -> Return SubSection Msg Msg
        , handle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection Msg Msg
        , globals : Maybe Definition
        }
subs globals =
    { update = subUpdate
    , handle = subHandle
    , globals = globals
    }


subUpdate :
    Scripts SubSection
    -> Msg
    -> SubSection
    -> Return SubSection Msg Msg
subUpdate js msg section =
    case section of
        SubSection subsection ->
            case msg of
                UpdateEffect sound childMsg ->
                    subsection.effect_model
                        |> Effect.update (subs Nothing) sound childMsg
                        |> Return.map (\v -> SubSection { subsection | effect_model = v })
                        |> Return.cmdMap (UpdateEffect sound)
                        |> Return.upgrade "effect" subsection.id

                UpdateTable childMsg ->
                    subsection.table_vector
                        |> Table.update childMsg
                        |> Return.map (\v -> SubSection { subsection | table_vector = v })

                UpdateCode childMsg ->
                    subsection.code_model
                        |> Code.update js childMsg
                        |> Return.map (\v -> SubSection { subsection | code_model = v })
                        |> Return.cmdMap UpdateCode
                        |> Return.upgrade "code" subsection.id

                UpdateQuiz childMsg ->
                    let
                        result =
                            Quiz.update js childMsg subsection.quiz_vector
                    in
                    case result.script of
                        Just _ ->
                            subUpdate js
                                (UpdateQuiz childMsg)
                                (SubSection { subsection | quiz_vector = result.value })

                        _ ->
                            result
                                |> Return.map (\v -> SubSection { subsection | quiz_vector = v })
                                |> upgrade "quiz" subsection.id

                UpdateSurvey childMsg ->
                    let
                        result =
                            Survey.update js childMsg subsection.survey_vector
                    in
                    case result.script of
                        Just _ ->
                            subUpdate js
                                (UpdateSurvey childMsg)
                                (SubSection { subsection | survey_vector = result.value })

                        _ ->
                            result
                                |> Return.map (\v -> SubSection { subsection | survey_vector = v })
                                |> upgrade "survey" subsection.id

                UpdateTask childMsg ->
                    let
                        result =
                            Task.update js childMsg subsection.task_vector
                    in
                    case result.script of
                        Just _ ->
                            subUpdate js
                                (UpdateTask childMsg)
                                (SubSection { subsection | task_vector = result.value })

                        _ ->
                            result
                                |> Return.map (\v -> SubSection { subsection | task_vector = v })
                                |> upgrade "task" subsection.id

                Script childMsg ->
                    subsection.effect_model
                        |> Effect.updateSub (subs Nothing) childMsg
                        |> Return.map (\v -> SubSection { subsection | effect_model = v })
                        |> Return.cmdMap (UpdateEffect True)
                        |> Return.upgrade "script" subsection.id

                _ ->
                    Return.value section

        SubSubSection sub ->
            case msg of
                Script childMsg ->
                    sub.effect_model
                        |> Effect.updateSub (subs Nothing) childMsg
                        |> Return.map (\v -> SubSubSection { sub | effect_model = v })
                        |> Return.cmdMap (UpdateEffect True)
                        |> Return.upgrade "script" sub.id

                UpdateEffect sound childMsg ->
                    sub.effect_model
                        |> Effect.update (subs Nothing) sound childMsg
                        |> Return.map (\v -> SubSubSection { sub | effect_model = v })
                        |> Return.cmdMap (UpdateEffect sound)
                        |> Return.upgrade "effect" sub.id

                _ ->
                    Return.value section


updateScript :
    Return { sec | id : Int, effect_model : E.Model SubSection } Msg Msg
    -> Return { sec | id : Int, effect_model : E.Model SubSection } Msg Msg
updateScript return =
    case return.script of
        Nothing ->
            return

        Just sub ->
            let
                ret =
                    return.value.effect_model
                        |> Effect.updateSub (subs Nothing) sub
                        |> Return.upgrade "effect" section.id
                        |> Return.cmdMap (UpdateEffect True)

                section =
                    return.value
            in
            { section | effect_model = ret.value }
                |> Return.replace return
                |> Return.cmdBatch [ ret.cmd ]
                |> Return.events ret.events


nextEffect : Definition -> Bool -> Section -> Return Section Msg Msg
nextEffect globals sound =
    update globals (UpdateEffect sound Effect.next)


previousEffect : Definition -> Bool -> Section -> Return Section Msg Msg
previousEffect globals sound =
    update globals (UpdateEffect sound Effect.previous)


initEffect : Definition -> Bool -> Bool -> Section -> Return Section Msg Msg
initEffect globals run_all_javascript sound =
    update globals (UpdateEffect sound (Effect.init run_all_javascript))


subHandle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection Msg Msg
subHandle js json section =
    case Event.decode json of
        Ok event ->
            case Event.decode event.message of
                Ok message ->
                    case event.topic of
                        "code" ->
                            subUpdate js (UpdateCode (Code.handle message)) section

                        "quiz" ->
                            subUpdate js (UpdateQuiz (Quiz.handle message)) section

                        "survey" ->
                            subUpdate js (UpdateSurvey (Survey.handle message)) section

                        "effect" ->
                            subUpdate js (UpdateEffect True (Effect.handle message)) section

                        "task" ->
                            subUpdate js (UpdateTask (Task.handle message)) section

                        _ ->
                            Return.value section

                _ ->
                    Return.value section

        _ ->
            Return.value section


handle : Definition -> String -> Event -> Section -> Return Section Msg Msg
handle globals topic event section =
    case topic of
        "code" ->
            update globals (UpdateCode (Code.handle event)) section

        "quiz" ->
            update globals (UpdateQuiz (Quiz.handle event)) section

        "survey" ->
            update globals (UpdateSurvey (Survey.handle event)) section

        "effect" ->
            update globals (UpdateEffect True (Effect.handle event)) section

        "task" ->
            update globals (UpdateTask (Task.handle event)) section

        _ ->
            Return.value section


ttsReplay : Bool -> Bool -> Maybe Section -> Maybe Event
ttsReplay sound true section =
    -- replay if possible
    if sound then
        if true then
            section
                |> Maybe.andThen
                    (\s ->
                        s.effect_model
                            |> Effect.ttsReplay sound
                            |> Maybe.map (Event.encode >> Event "effect" s.id)
                    )

        else
            Effect.ttsCancel
                |> Event.encode
                |> Event "effect" -1
                |> Just

    else
        Nothing
