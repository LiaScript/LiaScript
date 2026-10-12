module Effect exposing (suite)

{-| Cases of `Lia.Markdown.Effect` that do not occur in the LiaBooks and
LiaTemplates corpora, which are otherwise used as a golden master.
-}

import Array
import Dict
import Expect
import Html.Attributes as Attr
import I18n.Translations exposing (Lang(..))
import Lia.Markdown.Effect.Model as Model
import Lia.Markdown.Effect.Types as Effect exposing (Class(..))
import Lia.Markdown.Effect.View as View
import Lia.Markdown.Inline.Config as Config
import Lia.Settings.Types exposing (Mode(..))
import Parser.Block.Fixtures exposing (parseWithState)
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector as Selector


suite : Test
suite =
    describe "Effect cases missing in the corpora"
        [ test "playback at step 0 is still animated" <|
            \_ ->
                Effect.init "v"
                    |> (\e -> { e | playback = True, begin = 0 })
                    |> Effect.class
                    |> Expect.equal PlayBackAnimation
        , test "set_annotation appends to existing attributes" <|
            \_ ->
                Dict.singleton 1
                    { narrator = "v"
                    , content = Array.fromList [ { visible = True, attr = [ ( "a", "1" ) ], content = [], audio = Array.empty, video = Array.empty } ]
                    }
                    |> (\d -> Model.set_annotation 1 0 d [ ( "b", "2" ) ])
                    |> Dict.get 1
                    |> Maybe.andThen (.content >> Array.get 0)
                    |> Maybe.map .attr
                    |> Expect.equal (Just [ ( "a", "1" ), ( "b", "2" ) ])
        , test "current_narrator returns the narrator and only data-* annotations" <|
            \_ ->
                { visible = 1
                , effects = 1
                , comments =
                    Dict.singleton 1
                        { narrator = "Deutsch Female"
                        , content =
                            Array.fromList
                                [ { visible = True, attr = [ ( "data-speaker", "anna" ), ( "style", "color: red" ) ], content = [], audio = Array.empty, video = Array.empty }
                                , { visible = True, attr = [ ( "data-mood", "happy" ) ], content = [], audio = Array.empty, video = Array.empty }
                                ]
                        }
                , javascript = Array.empty
                , speaking = Nothing
                , paused = Nothing
                }
                    |> Model.current_narrator
                    |> Expect.equal (Just ( "Deutsch Female", [ ( "data-speaker", "anna" ), ( "data-mood", "happy" ) ] ))
        , test "current_narrator is Nothing without comments at the current step" <|
            \_ ->
                Model.init
                    |> Model.current_narrator
                    |> Expect.equal Nothing
        , test "an annotation in front of a comment is attached to it" <|
            \_ ->
                parseWithState "    <!-- data-speaker=\"anna\" -->\n    --{{1}}--\nHello\n"
                    |> Tuple.second
                    |> .effect_model
                    |> (\e -> { e | visible = 1 })
                    |> Model.current_narrator
                    |> Maybe.map Tuple.second
                    |> Expect.equal (Just [ ( "data-speaker", "anna" ) ])
        , test "hidden comment with a tab after <!--" <|
            \_ ->
                parseWithState "Text <!--\t--{{2}}-- hidden -->\n"
                    |> Tuple.second
                    |> .effect_model
                    |> .comments
                    |> Dict.keys
                    |> Expect.equal [ 2 ]
        , test "a paused block playback can be stopped and resumed" <|
            \_ ->
                Effect.init "v"
                    |> (\e -> { e | playback = True, id = 0 })
                    |> (\e -> View.block (config (Just 0)) Model.init [] e [])
                    |> Query.fromHtml
                    |> Expect.all
                        [ Query.has [ Selector.attribute (Attr.title "Stop") ]
                        , Query.has [ Selector.attribute (Attr.title "Resume") ]
                        ]
        ]


config : Maybe Int -> Config.Config sub
config paused =
    Config.init
        { mode = Textbook
        , visible = Nothing
        , slide = 0
        , speaking = Nothing
        , paused = paused
        , lang = En
        , theme = Nothing
        , light = True
        , tooltips = False
        , hideVideoComments = False
        , media = Dict.empty
        , scripts = Array.empty
        , translations = Nothing
        , formulas = Nothing
        , sync = Nothing
        }
