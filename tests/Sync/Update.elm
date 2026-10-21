module Sync.Update exposing (suite)

import Array
import Expect
import Json.Encode as JE
import Lia.Chat.Model as Chat
import Lia.Definition.Types as Definition
import Lia.Markdown.Quiz.Solution as Solution
import Lia.Markdown.Quiz.Sync as QuizSync
import Lia.Parser.Parser exposing (parse_section)
import Lia.Section as Section
import Lia.Settings.Types as Settings
import Lia.Sync.Types as Sync
import Lia.Sync.Update exposing (synchronize)
import Test exposing (Test, describe, test)


{-| A page with two independent quiz blocks (index 0 and index 1 in
`quiz_vector`), both unanswered locally - as if this peer had just joined
the room and this section is the currently active one, already parsed
before the classroom sync data arrived.
-}
parsedSection : Section.Section
parsedSection =
    "[[X]] correct\n[[ ]] wrong\n\nsome text in between\n\n[[X]] yes\n[[ ]] no\n"
        |> Section.Base 2 []
        |> Section.init 0 0
        |> parse_section identity (Definition.default "" "")
        |> Result.withDefault (Section.init 0 0 (Section.Base 2 [] ""))


baseModel :
    { sync : Sync.Settings
    , sections : Section.Sections
    , chat : Chat.Model
    , search_index : String -> String
    , definition : Definition.Definition
    , settings : Settings.Settings
    , readme : String
    }
baseModel =
    let
        sync =
            Sync.init []
    in
    { sync = { sync | state = Sync.Connected "peer-2" }
    , sections = Array.fromList [ parsedSection ]
    , chat = Chat.init
    , search_index = identity
    , definition = Definition.default "" ""
    , settings = Settings.init Nothing True Settings.Slides
    , readme = ""
    }


suite : Test
suite =
    describe "Lia.Sync.Update.synchronize"
        [ test "a 'quiz' sync event for an already-parsed section updates that section's own quiz_vector, not just sync.data" <|
            \_ ->
                case Array.get 0 parsedSection.quiz_vector of
                    Nothing ->
                        Expect.fail "fixture did not parse into two quiz blocks"

                    Just answeredElsewhere ->
                        let
                            -- Simulate: this peer ("peer-2") already answered
                            -- quiz #0 on another device/session; quiz #1 is
                            -- still unanswered by anyone. This is exactly the
                            -- payload the classroom's initial state dump
                            -- sends right after joining.
                            event =
                                JE.object
                                    [ ( "cmd", JE.string "quiz" )
                                    , ( "param"
                                      , JE.list identity
                                            [ JE.object
                                                [ ( "id", JE.int 0 )
                                                , ( "data"
                                                  , JE.list identity
                                                        [ JE.object
                                                            [ ( "peer-2"
                                                              , QuizSync.encoder { trial = Just 1, state = answeredElsewhere.state }
                                                              )
                                                            ]
                                                        , JE.object []
                                                        ]
                                                  )
                                                ]
                                            ]
                                      )
                                    ]

                            vector =
                                synchronize baseModel event
                                    |> .value
                                    |> .sections
                                    |> Array.get 0
                                    |> Maybe.map .quiz_vector
                                    |> Maybe.withDefault Array.empty

                            solved =
                                Array.map .solved vector
                        in
                        Expect.equal
                            [ Solution.Solved, Solution.Open ]
                            (Array.toList solved)
        ]
