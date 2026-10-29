port module Lia.Markdown.Update exposing
    ( Msg(..)
    , handle
    , handleAll
    , initEffect
    , nextEffect
    , previousEffect
    , revealSolutions
    , solutions
    , solved
    , subscriptions
    , ttsReplay
    , update
    , updateScript
    )

import Array
import Conditional.List as CList
import Dict
import Json.Encode as JE
import Lia.Definition.Types exposing (Definition)
import Lia.Markdown.Code.Update as Code
import Lia.Markdown.Effect.Model as E
import Lia.Markdown.Effect.Script.Types as Script exposing (Scripts)
import Lia.Markdown.Effect.Script.Update as ScriptUpdate
import Lia.Markdown.Effect.Update as Effect
import Lia.Markdown.Gallery.Update as Gallery
import Lia.Markdown.Quiz.Types as QuizTypes
import Lia.Markdown.Quiz.Update as Quiz
import Lia.Markdown.Survey.Types as SurveyTypes
import Lia.Markdown.Survey.Update as Survey
import Lia.Markdown.Table.Update as Table
import Lia.Markdown.Task.Update as Task
import Lia.Markdown.Types as Markdown
import Lia.Section exposing (Section, Sections, SubSection(..))
import Lia.Sync.Types as Sync
import Lia.Utils exposing (focus)
import Return exposing (Return)
import Service.Console
import Service.Event as Event exposing (Event)
import Service.TTS


{-| Footnotes are opened via JavaScript (`onclick` within the inline HTML).
-}
port footnote : (String -> msg) -> Sub msg


{-| Messages of all interactive blocks of a section, they are routed to the
vectors of the section.
-}
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


{-| The sync (classroom) state and data that quizzes, surveys and code blocks
require.
-}
type alias Classroom sync =
    { sync
        | state : Sync.State
        , data : Sync.Data
    }


{-| Clicks on footnotes.
-}
subscriptions : Section -> Sub Msg
subscriptions _ =
    footnote FootnoteShow


{-| Update the section. Script messages of quizzes, surveys, tasks and
galleries (scripts within them) are applied to the scripts of the section by
`updateScript`. `globals` are only used if the section has no own definition.
-}
update :
    Classroom sync
    -> Definition
    -> Msg
    -> Section
    -> Return Section Msg Msg
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
                |> Code.update
                    (sync.data.code
                        |> Dict.get section.id
                        |> Maybe.withDefault Array.empty
                    )
                    (Just section.id)
                    section.effect_model.javascript
                    childMsg
                |> Return.mapValCmd (\v -> { section | code_model = v }) UpdateCode
                |> Return.mapEvents "code" section.id

        UpdateQuiz childMsg ->
            section.quiz_vector
                |> Quiz.update sync (Just section.id) section.effect_model.javascript childMsg
                |> Return.mapVal (\v -> { section | quiz_vector = v })
                |> Return.mapEvents "quiz" section.id
                |> Return.mapCmd UpdateQuiz
                |> updateScript

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
                |> updateScript

        UpdateSurvey childMsg ->
            section.survey_vector
                |> Survey.update sync (Just section.id) section.effect_model.javascript childMsg
                |> Return.mapVal (\v -> { section | survey_vector = v })
                |> Return.mapEvents "survey" section.id
                |> Return.mapCmd UpdateSurvey
                |> updateScript

        UpdateTable childMsg ->
            section.table_vector
                |> Table.update childMsg
                |> Return.mapVal (\v -> { section | table_vector = v })
                |> Return.mapEvents "table" section.id

        FootnoteShow key ->
            { section | footnote2show = Just key }
                |> Return.val
                |> Return.cmd (focus NoOp "lia-modal__close")

        FootnoteHide ->
            -- the modal returns the focus to the mark that opened it
            { section | footnote2show = Nothing }
                |> Return.val

        Script childMsg ->
            section
                |> Return.val
                |> Return.script childMsg
                |> updateScript

        NoOp ->
            Return.val section


{-| The update and handle functions for the sub-sections of scripts.
-}
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


{-| Like `update`, but for the LiaScript results of scripts, which have no
classroom and no own definition. The scripts passed in are the ones of the
parent, quizzes, surveys, tasks and code blocks refer to their own scripts.
-}
subUpdate :
    Scripts SubSection
    -> Msg
    -> SubSection
    -> Return SubSection Msg Msg
subUpdate _ msg section =
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
                        |> Code.update Array.empty Nothing subsection.effect_model.javascript childMsg
                        |> Return.mapValCmd (\v -> SubSection { subsection | code_model = v }) UpdateCode
                        |> Return.mapEvents "code" subsection.id

                UpdateGallery childMsg ->
                    subsection.gallery_vector
                        |> Gallery.update childMsg
                        |> Return.mapVal (\v -> SubSection { subsection | gallery_vector = v })

                UpdateQuiz childMsg ->
                    subsection.quiz_vector
                        |> Quiz.update Sync.disconnected Nothing subsection.effect_model.javascript childMsg
                        |> Return.mapVal (\v -> { subsection | quiz_vector = v })
                        |> Return.mapEvents "quiz" subsection.id
                        |> Return.mapCmd UpdateQuiz
                        |> subScript
                        |> Return.mapVal SubSection

                UpdateSurvey childMsg ->
                    subsection.survey_vector
                        |> Survey.update Sync.disconnected Nothing subsection.effect_model.javascript childMsg
                        |> Return.mapVal (\v -> { subsection | survey_vector = v })
                        |> Return.mapEvents "survey" subsection.id
                        |> Return.mapCmd UpdateSurvey
                        |> subScript
                        |> Return.mapVal SubSection

                UpdateTask childMsg ->
                    subsection.task_vector
                        |> Task.update Nothing subsection.effect_model.javascript childMsg
                        |> Return.mapVal (\v -> { subsection | task_vector = v })
                        |> Return.mapEvents "task" subsection.id
                        |> subScript
                        |> Return.mapVal SubSection

                Script childMsg ->
                    subsection.effect_model
                        |> Effect.updateSub (subs Nothing) childMsg
                        |> Return.mapValCmd (\v -> SubSection { subsection | effect_model = v }) (UpdateEffect True)
                        |> Return.mapEvents "effect" subsection.id

                _ ->
                    Return.val section

        SubSubSection sub ->
            case msg of
                Script childMsg ->
                    sub.effect_model
                        |> Effect.updateSub (subs Nothing) childMsg
                        |> Return.mapValCmd (\v -> SubSubSection { sub | effect_model = v }) (UpdateEffect True)
                        |> Return.mapEvents "effect" sub.id

                UpdateEffect sound childMsg ->
                    sub.effect_model
                        |> Effect.update (subs Nothing) sound childMsg
                        |> Return.mapValCmd (\v -> SubSubSection { sub | effect_model = v }) (UpdateEffect sound)
                        |> Return.mapEvents "effect" sub.id

                _ ->
                    Return.val section


{-| Like `updateScript`, but the script message belongs to the scripts of the
sub-section, it must not reach the scripts of the section.
-}
subScript :
    Return { sec | id : Int, effect_model : E.Model SubSection } Msg Msg
    -> Return { sec | id : Int, effect_model : E.Model SubSection } Msg Msg
subScript return =
    updateScript return
        |> (\r -> { r | sub = Nothing })


{-| Apply the script message `sub` of a return to the effect model.
-}
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


{-| Show the next effect (or go to the next slide, handled by the caller).
-}
nextEffect :
    Classroom sync
    -> Definition
    -> Bool
    -> Section
    -> Return Section Msg Msg
nextEffect sync globals sound =
    update sync globals (UpdateEffect sound Effect.next)


{-| Show the previous effect.
-}
previousEffect :
    Classroom sync
    -> Definition
    -> Bool
    -> Section
    -> Return Section Msg Msg
previousEffect sync globals sound =
    update sync globals (UpdateEffect sound Effect.previous)


{-| Initialize the effects of a section, run all scripts or only the visible
ones.
-}
initEffect :
    Classroom sync
    -> Definition
    -> Bool
    -> Bool
    -> Section
    -> Return Section Msg Msg
initEffect sync globals run_all_javascript sound =
    update sync globals (UpdateEffect sound (Effect.init run_all_javascript))


{-| An event from JavaScript for a sub-section, it was encoded with its
remaining track by the script that owns the sub-section.
-}
subHandle : Scripts SubSection -> JE.Value -> SubSection -> Return SubSection Msg Msg
subHandle js json section =
    case
        json
            |> Event.decode
            |> Result.toMaybe
            |> Maybe.andThen (Event.pop >> (\( topic, event ) -> Maybe.andThen (toMsg event) topic))
    of
        Just msg ->
            subUpdate js msg section

        Nothing ->
            section
                |> Return.val
                |> Return.batchEvent (Service.Console.warn "subHandle Problem")


{-| An event from JavaScript, `topic` is the type of block it belongs to.
-}
handle :
    Classroom sync
    -> Definition
    -> String
    -> Event
    -> Section
    -> Return Section Msg Msg
handle sync globals topic event section =
    case toMsg event topic of
        Just msg ->
            update sync globals msg section

        Nothing ->
            Return.val section


{-| The message for an event of block type `topic`.
-}
toMsg : Event -> String -> Maybe Msg
toMsg event topic =
    case topic of
        "code" ->
            Just (UpdateCode (Code.handle event))

        "quiz" ->
            Just (UpdateQuiz (Quiz.handle event))

        "survey" ->
            Just (UpdateSurvey (Survey.handle event))

        "effect" ->
            Just (UpdateEffect True (Effect.handle event))

        "task" ->
            Just (UpdateTask (Task.handle event))

        "table" ->
            Just (UpdateTable (Table.handle event))

        _ ->
            Nothing


{-| Like `handle`, but applies one `topic` (`"quiz"`/`"survey"`) `"load"`
event per `(sectionId, data)` entry to a whole `Sections` array, folding the
resulting `Return`s together. Used to fan out a single bulk `load_all`
reply to every affected section, instead of routing one event per section
through the port bus. Only sections that haven't been parsed yet are
touched - already-parsed sections already got their data through the
normal per-section load.
-}
handleAll :
    Classroom sync
    -> Definition
    -> String
    -> List ( Int, JE.Value )
    -> Sections
    -> Return Sections Msg Msg
handleAll sync globals topic entries sections =
    entries
        |> List.filter
            (\( id, _ ) ->
                Array.get id sections
                    |> Maybe.map (.parsed >> not)
                    |> Maybe.withDefault False
            )
        |> List.foldl
            (\( id, data ) acc ->
                case Array.get id acc.value of
                    Just section ->
                        handle sync
                            globals
                            topic
                            { reply = False
                            , track = []
                            , service = ""
                            , message = { cmd = "load", param = data }
                            }
                            section
                            |> mergeInto id acc

                    Nothing ->
                        acc
            )
            (Return.val sections)


{-| Store the updated section `id` and collect its commands and events.
-}
mergeInto : Int -> Return Sections Msg Msg -> Return Section Msg Msg -> Return Sections Msg Msg
mergeInto id acc r =
    { value = Array.set id r.value acc.value
    , command = Cmd.batch [ acc.command, r.command ]
    , events = acc.events ++ r.events
    , sub =
        case r.sub of
            Just s ->
                Just s

            Nothing ->
                acc.sub
    }


{-| All quizzes and surveys with a solution block, whether they are solved
(submitted), the class of their comments, and the comments within the solution.

ponytail: only top-level blocks and blocks within effects are checked, recurse
into lists, quotes and HTML if quizzes or surveys are used there.
-}
solutions :
    { s | quiz_vector : QuizTypes.Vector, survey_vector : SurveyTypes.Vector }
    -> Markdown.Blocks
    -> List { solved : Bool, class : String, comments : List ( Int, Int ) }
solutions vectors =
    let
        toSolution isSolved name id blocks =
            [ { solved = Maybe.withDefault False isSolved
              , class = "lia-tts-" ++ name ++ "-" ++ String.fromInt id
              , comments =
                    List.filterMap
                        (\b ->
                            case b of
                                Markdown.Comment id_ ->
                                    Just id_

                                _ ->
                                    Nothing
                        )
                        blocks
              }
            ]
    in
    List.concatMap
        (\block ->
            case block of
                Markdown.Quiz _ quiz (Just ( solution, _ )) ->
                    toSolution
                        (vectors.quiz_vector |> Array.get quiz.id |> Maybe.map QuizTypes.isSolved)
                        "quiz"
                        quiz.id
                        solution

                Markdown.Survey _ survey (Just ( solution, _ )) ->
                    toSolution
                        (vectors.survey_vector |> Array.get survey.id |> Maybe.map .submitted)
                        "survey"
                        survey.id
                        solution

                Markdown.Effect _ effect ->
                    solutions vectors effect.content

                _ ->
                    []
        )


{-| Classes of all solutions that are currently visible.
-}
solved : Section -> List String
solved section =
    solutions section section.body
        |> List.filter .solved
        |> List.map .class


{-| A solution that got visible (quiz solved or resolved, survey submitted),
which was not within the list of solved classes before, gets its scripts
released and executed (only visible ones, unless `runAll`), and only its
comments are read out loud.
-}
revealSolutions : { sound : Bool, runAll : Bool } -> List String -> Return Section msg sub -> Return Section msg sub
revealSolutions { sound, runAll } before return =
    solutions return.value return.value.body
        |> List.filter (\q -> q.solved && not (List.member q.class before))
        |> List.foldl
            (\q ret ->
                let
                    section =
                        ret.value

                    effect_model =
                        section.effect_model

                    ( javascript, scripts ) =
                        ScriptUpdate.revealSolution runAll effect_model.visible q.class effect_model.javascript
                in
                { ret | value = { section | effect_model = { effect_model | javascript = javascript } } }
                    |> Return.batchEvents
                        (scripts
                            -- delayed, so that the solution is rendered before
                            |> List.map (ScriptUpdate.execute 100 >> Event.pushWithId "effect" section.id)
                            |> CList.addIf (sound && not (List.isEmpty q.comments))
                                (q.class
                                    |> Service.TTS.readClass
                                    |> Event.pushWithId "settings" section.id
                                )
                        )
            )
            return


{-| With sound turned on, read the comments of the current effect again
(`replay`) or stop reading.
-}
ttsReplay : Bool -> Bool -> Maybe Section -> Maybe Event
ttsReplay sound replay section =
    if not sound then
        Nothing

    else if replay then
        Maybe.map (\s -> Event.pushWithId "settings" s.id (Service.TTS.readFrom s.effect_model.visible)) section

    else
        section
            |> Maybe.map .id
            |> Maybe.withDefault -1
            |> (\id -> Event.pushWithId "settings" id Service.TTS.cancel)
            |> Just
