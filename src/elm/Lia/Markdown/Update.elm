port module Lia.Markdown.Update exposing
    ( Msg(..)
    , handle
    , initEffect
    , nextEffect
    , previousEffect
    , subscriptions
    , synchronize
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
import Lia.Markdown.Quiz.Sync as Quiz_
import Lia.Markdown.Quiz.Update as Quiz
import Lia.Markdown.Survey.Sync as Survey_
import Lia.Markdown.Survey.Update as Survey
import Lia.Markdown.Table.Update as Table
import Lia.Markdown.Task.Update as Task
import Lia.Section as Section exposing (Section, SubSection(..))
import Lia.Sync.Container.Local as Container
import Lia.Sync.Types as Sync
import Lia.Utils exposing (focus)
import Return exposing (Return)
import Service.Console
import Service.Event as Event exposing (Event)
import Service.Sync
import Service.TTS
import Translations exposing (Lang(..))


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
    | Sync Event
    | NoOp


synchronize : Event -> Msg
synchronize event =
    Sync event


subscriptions : Section -> Sub Msg
subscriptions _ =
    footnote FootnoteShow


update : Sync.State -> Definition -> Msg -> Section -> Return Section Msg Msg
update sync globals msg section =
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
                |> Return.mapValCmd (\v -> { section | effect_model = v }) (UpdateEffect sound)
                |> Return.mapEvents "effect" section.id

        UpdateCode childMsg ->
            section.code_model
                |> Code.update section.effect_model.javascript childMsg
                |> Return.mapVal (\v -> { section | code_model = v })
                |> Return.mapEvents "code" section.id
                |> updateScript

        UpdateQuiz childMsg ->
            section.quiz_vector
                |> Quiz.update (Just section.id) section.effect_model.javascript childMsg
                |> Return.mapVal (\v -> { section | quiz_vector = v })
                |> Return.mapEvents "quiz" section.id
                |> updateScript
                |> syncQuiz sync

        UpdateTask childMsg ->
            section.task_vector
                |> Task.update (Just section.id) section.effect_model.javascript childMsg
                |> Return.mapVal (\v -> { section | task_vector = v })
                |> Return.mapEvents "task" section.id
                |> updateScript

        UpdateGallery childMsg ->
            section.gallery_vector
                |> Gallery.update childMsg
                |> Return.mapVal (\v -> { section | gallery_vector = v })
                |> Return.mapEvents "gallery" section.id
                |> updateScript

        UpdateSurvey childMsg ->
            section.survey_vector
                |> Survey.update (Just section.id) section.effect_model.javascript childMsg
                |> Return.mapVal (\v -> { section | survey_vector = v })
                |> Return.mapEvents "survey" section.id
                |> updateScript
                |> syncSurvey sync

        UpdateTable childMsg ->
            section.table_vector
                |> Table.update childMsg
                |> Return.mapVal (\v -> { section | table_vector = v })
                |> Return.mapEvents "table" section.id

        Sync event ->
            case Event.topic event of
                Just "quiz" ->
                    case
                        ( Maybe.andThen .quiz section.sync
                        , event
                            |> Event.message
                            -- TODO
                            |> Tuple.second
                            |> Container.decode Quiz_.decoder
                        )
                    of
                        ( Just old, Ok new ) ->
                            case Container.union old new of
                                ( True, state ) ->
                                    section
                                        |> Section.syncQuiz state
                                        |> Return.val
                                        |> Return.batchEvent
                                            (state
                                                |> Container.encode Quiz_.encoder
                                                |> Service.Sync.publish "quiz"
                                                |> Event.pushWithId "local" section.id
                                            )

                                ( False, state ) ->
                                    section
                                        |> Section.syncQuiz state
                                        |> Return.val

                        ( Nothing, Ok state ) ->
                            section
                                |> Section.syncQuiz state
                                |> Return.val

                        _ ->
                            section
                                |> Return.val

                Just "survey" ->
                    case
                        ( Maybe.andThen .survey section.sync
                        , event
                            |> Event.message
                            -- TODO
                            |> Tuple.second
                            |> Container.decode Survey_.decoder
                        )
                    of
                        ( Just old, Ok new ) ->
                            case Container.union old new of
                                ( True, state ) ->
                                    section
                                        |> Section.syncSurvey state
                                        |> Return.val
                                        |> Return.batchEvent
                                            (state
                                                |> Container.encode Survey_.encoder
                                                |> Service.Sync.publish "survey"
                                                |> Event.pushWithId "local" section.id
                                            )

                                ( False, state ) ->
                                    section
                                        |> Section.syncSurvey state
                                        |> Return.val

                        ( Nothing, Ok state ) ->
                            section
                                |> Section.syncSurvey state
                                |> Return.val

                        _ ->
                            section
                                |> Return.val

                _ ->
                    section
                        |> Return.val

        FootnoteShow key ->
            { section | footnote2show = Just key }
                |> Return.val
                |> Return.cmd (focus NoOp "lia-modal__close")

        FootnoteHide ->
            { section | footnote2show = Nothing }
                |> Return.val
                |> Return.cmd
                    (section.footnote2show
                        |> Maybe.map (Footnote.byKey >> focus NoOp)
                        |> Maybe.withDefault Cmd.none
                    )

        Script childMsg ->
            section
                |> Return.val
                |> Return.script childMsg
                |> updateScript

        NoOp ->
            Return.val section


syncQuiz : Sync.State -> Return Section msg sub -> Return Section msg sub
syncQuiz sync ret =
    case ( ret.synchronize, Sync.id sync ) of
        ( True, Just id ) ->
            case
                ret.value.quiz_vector
                    |> Container.init id Quiz_.sync
                    |> Container.union
                        (ret.value.sync
                            |> Maybe.andThen .quiz
                            |> Maybe.withDefault Container.empty
                        )
            of
                ( True, state ) ->
                    { ret | synchronize = False }
                        |> Return.mapVal (Section.syncQuiz state)
                        |> Return.batchEvent
                            (state
                                |> Container.encode Quiz_.encoder
                                |> Service.Sync.publish "quiz"
                                |> Event.pushWithId "local" ret.value.id
                            )

                ( False, state ) ->
                    { ret | synchronize = False }
                        |> Return.mapVal (Section.syncQuiz state)

        _ ->
            { ret | synchronize = False }


syncSurvey : Sync.State -> Return Section msg sub -> Return Section msg sub
syncSurvey sync ret =
    case ( ret.synchronize, Sync.id sync ) of
        ( True, Just id ) ->
            case
                ret.value.survey_vector
                    |> Container.init id Survey_.sync
                    |> Container.union
                        (ret.value.sync
                            |> Maybe.andThen .survey
                            |> Maybe.withDefault Container.empty
                        )
            of
                ( True, state ) ->
                    { ret | synchronize = False }
                        |> Return.mapVal (Section.syncSurvey state)
                        |> Return.batchEvent
                            (state
                                |> Container.encode Survey_.encoder
                                |> Service.Sync.publish "survey"
                                |> Event.pushWithId "local" ret.value.id
                            )

                ( False, state ) ->
                    { ret | synchronize = False }
                        |> Return.mapVal (Section.syncSurvey state)

        _ ->
            ret


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
                        |> Return.mapValCmd (\v -> SubSection { subsection | effect_model = v }) (UpdateEffect sound)
                        |> Return.mapEvents "effect" subsection.id

                UpdateTable childMsg ->
                    subsection.table_vector
                        |> Table.update childMsg
                        |> Return.mapVal (\v -> SubSection { subsection | table_vector = v })
                        |> Return.mapEvents "table" subsection.id

                UpdateCode childMsg ->
                    subsection.code_model
                        |> Code.update js childMsg
                        |> Return.mapValCmd (\v -> SubSection { subsection | code_model = v }) UpdateCode
                        |> Return.mapEvents "code" subsection.id

                UpdateQuiz childMsg ->
                    let
                        result =
                            Quiz.update Nothing js childMsg subsection.quiz_vector
                    in
                    case result.sub of
                        Just _ ->
                            subUpdate js
                                (UpdateQuiz childMsg)
                                (SubSection { subsection | quiz_vector = result.value })

                        _ ->
                            result
                                |> Return.mapVal (\v -> SubSection { subsection | quiz_vector = v })
                                |> Return.mapEvents "quiz" subsection.id

                UpdateSurvey childMsg ->
                    let
                        result =
                            Survey.update Nothing js childMsg subsection.survey_vector
                    in
                    case result.sub of
                        Just _ ->
                            subUpdate js
                                (UpdateSurvey childMsg)
                                (SubSection { subsection | survey_vector = result.value })

                        _ ->
                            result
                                |> Return.mapVal (\v -> SubSection { subsection | survey_vector = v })
                                |> Return.mapEvents "survey" subsection.id

                UpdateTask childMsg ->
                    let
                        result =
                            Task.update Nothing js childMsg subsection.task_vector
                    in
                    case result.sub of
                        Just _ ->
                            subUpdate js
                                (UpdateTask childMsg)
                                (SubSection { subsection | task_vector = result.value })

                        _ ->
                            result
                                |> Return.mapVal (\v -> SubSection { subsection | task_vector = v })
                                |> Return.mapEvents "task" subsection.id

                Script childMsg ->
                    subsection.effect_model
                        |> Effect.updateSub (subs Nothing) childMsg
                        |> Return.mapValCmd (\v -> SubSection { subsection | effect_model = v }) (UpdateEffect True)
                        |> Return.mapEvents "script" subsection.id

                _ ->
                    Return.val section

        SubSubSection sub ->
            case msg of
                Script childMsg ->
                    sub.effect_model
                        |> Effect.updateSub (subs Nothing) childMsg
                        |> Return.mapValCmd (\v -> SubSubSection { sub | effect_model = v }) (UpdateEffect True)
                        |> Return.mapEvents "script" sub.id

                UpdateEffect sound childMsg ->
                    sub.effect_model
                        |> Effect.update (subs Nothing) sound childMsg
                        |> Return.mapValCmd (\v -> SubSubSection { sub | effect_model = v }) (UpdateEffect sound)
                        |> Return.mapEvents "effect" sub.id

                _ ->
                    Return.val section


updateScript :
    Return { sec | id : Int, effect_model : E.Model SubSection } Msg Msg
    -> Return { sec | id : Int, effect_model : E.Model SubSection } Msg Msg
updateScript return =
    case return.sub of
        Nothing ->
            return

        Just sub ->
            let
                ret =
                    return.value.effect_model
                        |> Effect.updateSub (subs Nothing) sub
                        |> Return.mapEvents "effect" section.id
                        |> Return.mapCmd (UpdateEffect True)

                section =
                    return.value
            in
            { section | effect_model = ret.value }
                |> Return.replace return
                |> Return.batchCmd [ ret.command ]
                |> Return.batchEvents ret.events


nextEffect : Sync.State -> Definition -> Bool -> Section -> Return Section Msg Msg
nextEffect sync globals sound =
    update sync globals (UpdateEffect sound Effect.next)


previousEffect : Sync.State -> Definition -> Bool -> Section -> Return Section Msg Msg
previousEffect sync globals sound =
    update sync globals (UpdateEffect sound Effect.previous)


initEffect : Sync.State -> Definition -> Bool -> Bool -> Section -> Return Section Msg Msg
initEffect sync globals run_all_javascript sound =
    update sync globals (UpdateEffect sound (Effect.init run_all_javascript))


subHandle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection Msg Msg
subHandle js json section =
    case
        json
            |> Event.decode
            |> Result.toMaybe
            |> Maybe.andThen Event.pop
    of
        Just ( "code", event ) ->
            subUpdate js (UpdateCode (Code.handle event)) section

        Just ( "quiz", event ) ->
            subUpdate js (UpdateQuiz (Quiz.handle event)) section

        Just ( "survey", event ) ->
            subUpdate js (UpdateSurvey (Survey.handle event)) section

        Just ( "effect", event ) ->
            subUpdate js (UpdateEffect True (Effect.handle event)) section

        Just ( "task", event ) ->
            subUpdate js (UpdateTask (Task.handle event)) section

        Just ( "table", event ) ->
            subUpdate js (UpdateTable (Table.handle event)) section

        _ ->
            section
                |> Return.val
                |> Return.batchEvent (Service.Console.error "subHandle Problem")


handle : Sync.State -> Definition -> String -> Event -> Section -> Return Section Msg Msg
handle sync globals topic event section =
    case topic of
        "code" ->
            update sync globals (UpdateCode (Code.handle event)) section

        "quiz" ->
            update sync globals (UpdateQuiz (Quiz.handle event)) section

        "survey" ->
            update sync globals (UpdateSurvey (Survey.handle event)) section

        "effect" ->
            update sync globals (UpdateEffect True (Effect.handle event)) section

        "task" ->
            update sync globals (UpdateTask (Task.handle event)) section

        "table" ->
            update sync globals (UpdateTable (Table.handle event)) section

        "gallery" ->
            update sync globals (UpdateGallery (Gallery.handle event)) section

        _ ->
            Return.val section


ttsReplay : Bool -> Bool -> Maybe Section -> Maybe Event
ttsReplay sound true section =
    -- replay if possible
    if sound then
        if true then
            section
                |> Maybe.andThen
                    (\s ->
                        s.effect_model
                            |> Effect.ttsReplay
                            |> Maybe.map (Event.pushWithId "effect" s.id)
                    )

        else
            Service.TTS.cancel
                |> Event.pushWithId "tts" 0
                |> Event.pushWithId "effect"
                    (section
                        |> Maybe.map .id
                        |> Maybe.withDefault -1
                    )
                |> Just

    else
        Nothing
