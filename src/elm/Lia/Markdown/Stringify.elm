module Lia.Markdown.Stringify exposing (stringify)

import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.Effect.Types exposing (isIn)
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Stringify as Inline
import Lia.Markdown.Types exposing (Markdown(..))


stringify : Scripts a -> Maybe Int -> Markdown -> String
stringify effects id markdown =
    case markdown of
        Paragraph _ inlines ->
            Inline.stringify_ effects id inlines

        Quote _ md ->
            block effects id md

        BulletList _ mds ->
            mds
                |> List.map (block effects id)
                |> String.concat

        OrderedList _ mds ->
            mds
                |> List.map (Tuple.second >> block effects id)
                |> String.concat

        Effect _ e ->
            if isIn id e then
                block effects id e.content

            else
                "\n"

        Table _ table ->
            let
                head =
                    table.head
                        |> List.map (Tuple.second >> Inline.stringify_ effects id)
                        |> String.concat

                body =
                    table.body
                        |> List.map (List.map (Tuple.second >> Inline.stringify_ effects id) >> String.concat)
                        |> String.concat
            in
            head ++ " " ++ body

        HTML _ node ->
            node
                |> HTML.getContent
                |> block effects id

        Header _ ( title, _ ) ->
            Inline.stringify_ effects id title

        _ ->
            ""


block : Scripts a -> Maybe Int -> List Markdown -> String
block effects id =
    List.map (stringify effects id)
        >> List.intersperse "\n"
        >> String.concat
