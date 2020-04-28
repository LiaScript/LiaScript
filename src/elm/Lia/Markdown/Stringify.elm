module Lia.Markdown.Stringify exposing (stringify)

import Lia.Markdown.Effect.Types exposing (isIn)
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Stringify as Inline
import Lia.Markdown.Table.Types exposing (Table(..))
import Lia.Markdown.Types exposing (Markdown(..))


stringify : Maybe Int -> Markdown -> String
stringify id markdown =
    case markdown of
        Paragraph _ inlines ->
            Inline.stringify_ id inlines

        Quote _ md ->
            block id md

        BulletList _ mds ->
            mds
                |> List.map (block id)
                |> String.concat

        OrderedList _ mds ->
            mds
                |> List.map (Tuple.second >> block id)
                |> String.concat

        Effect _ e ->
            if isIn id e then
                block id e.content

            else
                "\n"

        Table _ (Unformatted _ rows _) ->
            rows
                |> List.map (List.map .string >> String.concat)
                |> String.concat

        Table _ (Formatted _ header _ rows _) ->
            let
                head =
                    header
                        |> List.map (Inline.stringify_ id)
                        |> String.concat

                body =
                    rows
                        |> List.map (List.map .string >> String.concat)
                        |> String.concat
            in
            head ++ " " ++ body

        HTML _ node ->
            node
                |> HTML.getContent
                |> block id

        _ ->
            ""


block : Maybe Int -> List Markdown -> String
block id =
    List.map (stringify id)
        >> List.intersperse "\n"
        >> String.concat
