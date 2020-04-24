module Lia.Markdown.Stringify exposing (stringify)

import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Stringify as Inline
import Lia.Markdown.Table.Types exposing (Table(..))
import Lia.Markdown.Types exposing (Markdown(..))


stringify : Markdown -> String
stringify markdown =
    case markdown of
        Paragraph _ inlines ->
            Inline.stringify inlines

        Quote _ md ->
            block md

        BulletList _ mds ->
            mds
                |> List.map block
                |> String.concat

        OrderedList _ mds ->
            mds
                |> List.map (Tuple.second >> block)
                |> String.concat

        Effect _ e ->
            block e.content

        Table _ (Unformatted _ rows _) ->
            rows
                |> List.map (List.map .string >> String.concat)
                |> String.concat

        Table _ (Formatted _ header _ rows _) ->
            let
                head =
                    header
                        |> List.map Inline.stringify
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
                |> block

        _ ->
            ""



--=
--| Formatted Class MultInlines (List String) (List Row) Int


block : List Markdown -> String
block =
    List.map stringify >> String.concat
