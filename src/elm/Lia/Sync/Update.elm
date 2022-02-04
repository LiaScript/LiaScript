module Lia.Sync.Update exposing
    ( Msg(..)
    , SyncMsg(..)
    , handle
    , isConnected
    , update
    )

import Array exposing (Array)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Quiz.Sync as Quiz
import Lia.Markdown.Survey.Sync as Survey
import Lia.Section as Section exposing (Sections)
import Lia.Sync.Container.Global as Global
import Lia.Sync.Types exposing (Settings, State(..), id)
import Lia.Sync.Via as Via exposing (Backend)
import Random
import Return exposing (Return)
import Service.Event as Event exposing (Event)
import Service.Sync
import Session exposing (Session)
import Set


type Msg
    = Room String
    | Username String
    | Password String
    | Backend SyncMsg
    | Connect
    | Disconnect
    | Handle Event
    | Random_Generate
    | Random_Result String


type SyncMsg
    = Open Bool -- Backend selection
    | Select (Maybe Backend)


handle :
    Session
    -> { model | sync : Settings, sections : Sections, readme : String }
    -> Event
    -> Return { model | sync : Settings, sections : Sections, readme : String } Msg sub
handle session model =
    Handle >> update session model


update :
    Session
    -> { model | sync : Settings, sections : Sections, readme : String }
    -> Msg
    -> Return { model | sync : Settings, sections : Sections, readme : String } Msg sub
update session model msg =
    let
        sync =
            model.sync
    in
    case msg of
        Handle event ->
            case Event.message event of
                ( "connect", param ) ->
                    case ( JD.decodeValue JD.string param, sync.sync.select ) of
                        ( Ok hashID, Just backend ) ->
                            { model
                                | sync =
                                    { sync
                                        | state = Connected hashID
                                        , peers = Set.empty
                                    }
                            }
                                |> join
                                |> Return.cmd
                                    (session
                                        |> Session.setClass
                                            { backend = Via.toString backend
                                            , course = model.readme
                                            , room = sync.room
                                            }
                                        |> Session.update
                                    )

                        _ ->
                            { model
                                | sync =
                                    { sync
                                        | state = Disconnected
                                        , peers = Set.empty
                                    }
                            }
                                |> Return.val
                                |> Return.cmd
                                    (session
                                        |> Session.setQuery model.readme
                                        |> Session.update
                                    )

                ( "disconnect", _ ) ->
                    { model
                        | sync =
                            { sync
                                | state = Disconnected
                                , peers = Set.empty
                            }
                    }
                        |> Return.val
                        |> Return.cmd
                            (session
                                |> Session.setQuery model.readme
                                |> Session.update
                            )

                --|> leave (id model.sync.state)
                ( "join", param ) ->
                    case ( JD.decodeValue (JD.field "id" JD.string) param, id sync.state ) of
                        ( Ok peerID, Just ownID ) ->
                            if ownID == peerID then
                                Return.val model

                            else
                                case
                                    ( param
                                        |> JD.decodeValue (JD.at [ "data", "quiz" ] (Global.decoder Quiz.decoder))
                                        |> Result.map (Global.union (globalGet .quiz model.sections))
                                    , param
                                        |> JD.decodeValue (JD.at [ "data", "survey" ] (Global.decoder Survey.decoder))
                                        |> Result.map (Global.union (globalGet .survey model.sections))
                                    )
                                of
                                    ( Ok ( quizUpdate, quizState ), Ok ( surveyUpdate, surveyState ) ) ->
                                        { model
                                            | sync = { sync | peers = Set.insert peerID sync.peers }
                                            , sections = Section.sync quizState surveyState model.sections
                                        }
                                            |> (if quizUpdate || surveyUpdate || not (Set.member peerID sync.peers) then
                                                    globalSync

                                                else
                                                    Return.val
                                               )

                                    _ ->
                                        Return.val model

                        _ ->
                            Return.val model

                ( "leave", param ) ->
                    { model
                        | sync =
                            { sync
                                | peers =
                                    case JD.decodeValue JD.string param of
                                        Ok peerID ->
                                            Set.remove peerID sync.peers

                                        _ ->
                                            sync.peers
                            }
                    }
                        |> Return.val

                _ ->
                    model
                        |> Return.val

        Password str ->
            { model | sync = { sync | password = str } }
                |> Return.val

        Username str ->
            { model | sync = { sync | username = str } }
                |> Return.val

        Room str ->
            { model | sync = { sync | room = str } }
                |> Return.val

        Random_Generate ->
            model
                |> Return.val
                |> Return.cmd (Random.generate Random_Result random)

        Random_Result roomName ->
            { model | sync = { sync | room = roomName } }
                |> Return.val

        Backend sub ->
            { model | sync = { sync | sync = updateSync sub sync.sync } }
                |> Return.val

        Connect ->
            case ( sync.sync.select, sync.state ) of
                ( Just backend, Disconnected ) ->
                    { model | sync = { sync | state = Pending, sync = closeSelect sync.sync } }
                        |> Return.val
                        |> Return.batchEvent
                            (Service.Sync.connect
                                { backend = backend
                                , course = model.readme
                                , room = sync.room
                                , username = sync.username
                                , password = sync.password
                                }
                            )

                _ ->
                    model |> Return.val

        Disconnect ->
            --
            { model | sync = { sync | state = Pending } }
                |> Return.val
                |> Return.batchEvent
                    (model.sync.state
                        |> id
                        |> Maybe.map Service.Sync.disconnect
                        |> Maybe.withDefault Event.none
                    )


updateSync msg sync =
    case msg of
        Open open ->
            { sync | open = open }

        Select backend ->
            { sync
                | select = backend
                , open = False
            }


closeSelect sync =
    { sync | open = False }


isConnected : Settings -> Bool
isConnected sync =
    case sync.state of
        Connected _ ->
            True

        _ ->
            False


join : { model | sync : Settings, sections : Sections } -> Return { model | sync : Settings, sections : Sections } msg sub
join model =
    case model.sync.state of
        Connected id ->
            { model | sections = Array.map (Section.syncInit id) model.sections }
                |> globalSync

        _ ->
            Return.val model


globalSync :
    { model | sync : Settings, sections : Sections }
    -> Return { model | sync : Settings, sections : Sections } msg sub
globalSync model =
    case model.sync.state of
        Connected id ->
            model
                |> Return.val
                |> Return.batchEvent
                    ([ ( "quiz"
                       , model.sections
                            |> globalGet .quiz
                            |> Global.encode Quiz.encoder
                       )
                     , ( "survey"
                       , model.sections
                            |> globalGet .survey
                            |> Global.encode Survey.encoder
                       )
                     ]
                        |> JE.object
                        |> Service.Sync.join id
                    )

        _ ->
            Return.val model


globalGet fn =
    Array.map (.sync >> Maybe.andThen fn)


random : Random.Generator String
random =
    positiveWords
        |> Array.length
        |> Random.int 0
        |> Random.list 4
        |> Random.map toSentence


positiveWords : Array String
positiveWords =
    Array.fromList
        -- A
        [ "Accommodating" -- Teachers should always be accommodating to your needs. This means they will change the way they teach you to make sure you learn to the best of your ability.
        , "Accomplished"
        , "Authentic"
        , "Awesome"
        , "Awe-Inspiring" -- An awe-inspiring education is one that makes you wonder at the amazement of the world and all the knowledge in it.

        -- B
        , "Brave"
        , "Bright"
        , "Brilliant"

        -- C
        , "Caring"
        , "Creative"

        -- D
        , "Delightful"
        , "Dreamy"

        -- E
        , "Easy" -- You might use this word if you feel as if you don’t have to make much of an effort and still get good grades.
        , "Education"
        , "Effortless" -- You would similarly use this one if you think perhaps you’re in a class that’s too easy for you and so you don’t study or try, but will still pass with flying colors.
        , "Empathy"
        , "Empowering"
        , "Engaging" -- An engaging lesson is usually one where the students can actually participate, rather than sitting and watching.
        , "Epic"
        , "Exciting" -- If you find learning to be enjoyable and you just can’t wait for the next lesson, you might call school an exciting place.
        , "Exhilarating" -- If you’re doing a science project and feel like you’re on the verge of a breakthrough, you might consider the project to be exhilarating.
        , "Eye-Opening" -- At school, we learn a lot of new things that expand our horizons and change how we look at things. In these situations, we might walk out of a lesson and say ‘that was eye opening!’

        -- F
        , "Fabulous"
        , "Fair"
        , "Fantastical" -- This is a term you might use in a library when you walk in and know you’re going to find another book that will draw you into a fantasy world.
        , "Flexible" -- A school that will make accommodations for you and your specific learning needs might be described as one that is ‘flexible’.
        , "Free"
        , "Friendly" -- We always hope when we walk into a classroom that there will be lots of friendly faces around us. As a teacher, I always strive to create a friendly environment.
        , "Fun" -- If you really enjoy all the adventures and activities you’re assigned in class, you might come home and tell your parents: ‘school was fun today!’

        -- G
        , "Genius"
        , "Great"
        , "Good"

        -- H
        , "Hands-On" -- A hands-on classroom is one that lets all the students be active participants in their learning, which will help them learn and be engaged.
        , "Happy"
        , "High-Expectations" -- A school that sets high expectations is one that wants you to do the best you possibly can, and won’t accept anything less.
        , "Hilarious"
        , "Honest"

        -- I
        , "Idyllic"
        , "Important" -- Most of us believe that learning is one of the most important things we can do so that we can succeed at life.
        , "Inclusive" -- An inclusive environment is one that ensures everyone is welcomed and a wide variety of views are encouraged.
        , "Inspiring" -- An inspiring environment is one that will always be teaching you in ways that make you lean in and take interest in the amazing things they’re teaching you.
        , "Interactive" -- Sometimes schools are not very interactive and students just have to sit and watch. But the good ones make sure everyone gets involved and can do some hands-on activities.
        , "Inviting" -- An inviting school might be one with lovely artworks of the students around the walls and kind teachers who make you feel welcome.

        -- J
        , "Joyful"

        -- K
        , "Kind" -- A kind school would have teachers who are generous, smiling and patient with you while you learn. It may also focus on teaching the values of kindness.
        , "Knowledge"

        -- L
        , "Learning"
        , "LiaScript"
        , "Life-Changing" -- A life-changing education would be one that gives you skills to go out and make the sort of life you wouldn’t have been able to otherwise.
        , "Lucky"

        -- M
        , "Magical"
        , "Marvelous"
        , "Mind-Blowing" -- You might find a lesson to be mind-blowing if you come out of it feeling as if everything you thought you knew has been totally upended by your new knowledge.
        , "Motivating" -- You would find it motivating if you really want to wake up every day and go to learn something new.

        -- N
        , "New"

        -- O
        , "Open"
        , "Optimistic"
        , "Outstanding"

        -- P
        , "Passion"
        , "Participatory" -- A participatory classroom would be one that allows students to actively be involved in learning and share their opinions.
        , "Playful"
        , "Polite"

        -- Q
        -- R
        , "Relaxing"
        , "Reliable"
        , "Respectful"

        -- S
        , "Safe" -- Safety is incredibly important in an institution and should be first and foremost. According to Maslow’s Hierarchy of Needs, people need to feel safe and comfortable in order to learn.
        , "Social" -- A social learning environment would be one were people get to talk to one another while learning. You might also consider school to be social if your favorite part about it is making new friends.
        , "Successful"

        -- T
        , "Thankful"
        , "Thoughtful"
        , "Trustworthy"

        -- U
        , "Ultimate"
        , "United"
        , "Useful"

        -- V
        , "Varied" -- A varied educational experience might occur if you get to learn about a lot of different things in a lot of different ways.

        -- W
        , "Warm"
        , "Welcoming" -- You might feel like a classroom is warm and welcoming if you walked in and were instantly greeted by a kind teacher.

        -- X
        -- Y
        , "Yummy"

        -- Z
        ]


toSentence : List Int -> String
toSentence =
    List.filterMap (\id -> Array.get id positiveWords)
        >> String.concat
