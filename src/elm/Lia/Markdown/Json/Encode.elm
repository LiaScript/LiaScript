module Lia.Markdown.Json.Encode exposing (..)

import Json.Encode as JE
import Lia.Markdown.HTML.Json as HTML
import Lia.Markdown.Inline.Json.Encode as Inline
import Lia.Markdown.Quiz.Json as Quiz
import Lia.Markdown.Survey.Json as Survey
import Lia.Markdown.Table.Json as Table
import Lia.Markdown.Task.Json as Task
import Lia.Markdown.Types exposing (Block(..), Blocks)


encode : Blocks -> JE.Value
encode =
    JE.list encBlock


encBlock : Block -> JE.Value
encBlock b =
    JE.object <|
        case b of
            Paragraph a elements ->
                [ ( "Paragraph", Inline.encode elements ) ]
                    |> HTML.maybeEncParameters a

            HLine a ->
                [ ( "HLine", JE.null ) ]
                    |> HTML.maybeEncParameters a

            Quote a blocks ->
                [ ( "Quote", encode blocks ) ]
                    |> HTML.maybeEncParameters a

            BulletList a blocksList ->
                [ ( "BulletList", JE.list encode blocksList ) ]
                    |> HTML.maybeEncParameters a

            OrderedList a list ->
                [ ( "OrderedList", JE.list ol list ) ]
                    |> HTML.maybeEncParameters a

            Header a ( level, elements ) ->
                [ ( "Header", Inline.encode elements )
                , ( "level", JE.int level )
                ]
                    |> HTML.maybeEncParameters a

            Citation a elements ->
                [ ( "Citation", Inline.encode elements ) ]
                    |> HTML.maybeEncParameters a

            Problem elements ->
                [ ( "Problem", Inline.encode elements ) ]

            Quiz a quiz solution ->
                [ ( "Quiz", Quiz.encode quiz )
                , ( "solution"
                  , case solution of
                        Nothing ->
                            JE.null

                        Just ( blocks, hidden_effects ) ->
                            JE.object
                                [ ( "hidden_effects", JE.int hidden_effects )
                                , ( "blocks", encode blocks )
                                ]
                  )
                ]
                    |> HTML.maybeEncParameters a

            Survey a survey ->
                [ ( "Survey", Survey.encode survey ) ]
                    |> HTML.maybeEncParameters a

            Task a tasks ->
                [ ( "Task", Task.encode tasks ) ]
                    |> HTML.maybeEncParameters a

            Gallery a { media, id } ->
                [ ( "Gallery"
                  , JE.object
                        [ ( "media", Inline.encode media )
                        , ( "id", JE.int id )
                        ]
                  )
                ]
                    |> HTML.maybeEncParameters a

            Effect a eBlock ->
                [ ( "Effect"
                  , JE.object
                        [ ( "id", JE.int eBlock.id )
                        , ( "begin", JE.int eBlock.begin )
                        , ( "end"
                          , eBlock.end
                                |> Maybe.map JE.int
                                |> Maybe.withDefault JE.null
                          )
                        , ( "content", encode eBlock.content )
                        , ( "playback", JE.bool eBlock.playback )
                        , ( "voice", JE.string eBlock.voice )
                        ]
                  )
                ]
                    |> HTML.maybeEncParameters a

            Table a table ->
                [ ( "Table", Table.encode table ) ]
                    |> HTML.maybeEncParameters a

            Chart a _ ->
                [ ( "Chart", JE.null ) ]
                    |> HTML.maybeEncParameters a

            Code _ ->
                [ ( "Code", JE.null ) ]

            Comment _ ->
                [ ( "Comment", JE.null ) ]

            ASCII a _ ->
                [ ( "ASCII", JE.null ) ]
                    |> HTML.maybeEncParameters a

            HTML a node ->
                [ ( "HTML", JE.object [ HTML.encode encBlock node ] ) ]
                    |> HTML.maybeEncParameters a

            HtmlComment ->
                []


ol : ( String, Blocks ) -> JE.Value
ol ( id, blocks ) =
    JE.object [ ( id, encode blocks ) ]
