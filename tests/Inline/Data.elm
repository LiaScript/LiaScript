module Inline.Data exposing (suite)

{-| `Stringify`, JSON en-/decoding and the html properties of
`Lia.Markdown.Inline.View` that `HtmlSnapshot` cannot see, recorded from the
implementation before the refactoring (see `Inline.DataSnapshots`).
-}

import Array
import Dict
import Expect
import Html
import Html.Attributes as Attr
import I18n.Translations exposing (Lang(..))
import Inline.DataSnapshots exposing (snapshots)
import Inline.View exposing (inlines)
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Inline.Config as Config
import Lia.Markdown.Inline.Json.Decode as Decode
import Lia.Markdown.Inline.Json.Encode as Encode
import Lia.Markdown.Inline.Stringify exposing (stringify, stringify_)
import Lia.Markdown.Inline.Types exposing (Inline(..), Reference(..), htmlBlock, mediaBlock)
import Lia.Markdown.Inline.View as View
import Lia.Markdown.Quiz.Block.Types exposing (State(..))
import Lia.Settings.Types exposing (Mode(..))
import Test exposing (Test, describe, test)
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, tag)


recorded : String -> String -> Test
recorded name actual =
    test name <|
        \_ ->
            case Dict.get name snapshots of
                Just expected ->
                    Expect.equal expected actual

                Nothing ->
                    Expect.fail ("RECORD:" ++ actual)


{-| Script 0 has a text result, script 1 none.
-}
scripts : Script.Scripts ()
scripts =
    Array.empty
        |> Script.push "en" 0 [] "1+1"
        |> Script.push "en" 0 [] "2"
        |> Array.indexedMap
            (\i s ->
                if i == 0 then
                    { s | result = Just (Script.Text "two") }

                else
                    s
            )


context visible =
    { scripts = scripts
    , visible = visible
    , input =
        { state = Array.fromList [ Text "typed", Select False [ 1 ], Select False [ -1 ], Drop False False [ 0 ], Select False [ 0, 1 ] ]
        , options = Array.repeat 5 [ [ Chars "o0" [] ], [ Italic (Chars "o1" []) [] ] ]
        }
    }


extra : List ( String, Inline )
extra =
    [ ( "script result", Script 0 [] )
    , ( "script no result", Script 1 [] )
    , ( "script out of range", Script 7 [] )
    ]
        ++ List.map (\i -> ( "quiz " ++ String.fromInt i, Quiz ( "", i ) [] )) (List.range 0 5)


all : List ( String, Inline )
all =
    inlines ++ extra


properties : Test
properties =
    let
        config =
            Config.init
                { mode = Textbook
                , visible = Nothing
                , slide = 0
                , speaking = Nothing
                , paused = Nothing
                , lang = En
                , theme = Nothing
                , light = True
                , tooltips = True
                , hideVideoComments = False
                , media = Dict.empty
                , scripts = Array.empty
                , translations = Nothing
                , formulas = Just (Dict.fromList [ ( "\\RR", "\\mathbb{R}" ) ])
                , sync = Nothing
                }

        has t props html =
            Query.fromHtml (Html.div [] [ html ]) |> Query.find [ tag t ] |> Query.has (List.map attribute props)

        embed option =
            View.view { config | oEmbed = option } (Ref (Embed [] "u" Nothing) [ ( "a", "b" ) ])
    in
    describe "properties"
        [ test "formula property (macros: int/object properties are invisible to Test.Html)" <|
            \_ ->
                View.view config (Formula "false" "x" [])
                    |> has "lia-formula" [ Attr.property "formula" (JE.string "x") ]
        , test "preview-link light" <|
            \_ ->
                View.view config (Ref (Link [] "https://a.org" Nothing) [])
                    |> has "preview-link" [ Attr.property "light" (JE.bool True) ]
        , test "oembed with options" <|
            \_ ->
                embed (Just { maxwidth = 300, maxheight = 200, scale = 0.5, thumbnail = True })
                    |> has "lia-embed" [ Attr.property "url" (JE.string "u"), Attr.property "thumbnail" (JE.bool True) ]
        , test "oembed without options" <|
            \_ ->
                embed Nothing
                    |> has "lia-embed" [ Attr.property "thumbnail" (JE.bool False) ]
        ]


suite : Test
suite =
    describe "Lia.Markdown.Inline data"
        [ all
            |> List.map (\( name, inline ) -> recorded ("stringify " ++ name) (stringify [ inline ]))
            |> describe "stringify"
        , all
            |> List.map (\( name, inline ) -> recorded ("stringify_ " ++ name) (stringify_ (context Nothing) [ inline ]))
            |> describe "stringify_"
        , all
            |> List.map (\( name, inline ) -> recorded ("stringify_ hidden " ++ name) (stringify_ (context (Just 0)) [ inline ]))
            |> describe "stringify_ hidden"
        , all
            |> List.map (\( name, inline ) -> recorded ("encode " ++ name) (JE.encode 0 (Encode.encode [ inline ])))
            |> describe "encode"
        , all
            |> List.map (\( name, inline ) -> recorded ("roundtrip " ++ name) (Debug.toString (JD.decodeValue Decode.decode (Encode.encode [ inline ]))))
            |> describe "roundtrip"
        , properties
        , test "mediaBlock" <|
            \_ ->
                all
                    |> List.filter (Tuple.second >> mediaBlock)
                    |> List.map Tuple.first
                    |> Expect.equal [ "image", "image no alt", "image title attr", "audio", "audio tube", "movie", "movie tube youtube", "movie tube youtube query", "movie tube other", "embed", "embed title attr", "qr", "qr title attr" ]
        , test "htmlBlock" <|
            \_ ->
                List.filterMap (Tuple.second >> htmlBlock) all
                    |> Expect.equal
                        [ ( "span", [ ( "id", "n" ) ], [ Container [ Chars "in" [], Bold (Chars "b" []) [] ] [] ] )
                        , ( "kbd", [], [ Container [ Chars "k" [] ] [ ( "class", "x" ), ( "style", "color:red" ) ] ] )
                        ]
        ]
