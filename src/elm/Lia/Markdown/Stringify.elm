module Lia.Markdown.Stringify exposing (stringify)

import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.Effect.Types exposing (isIn)
import Lia.Markdown.HTML.Types as HTML
import Lia.Markdown.Inline.Stringify as Inline
import Lia.Markdown.Types exposing (Markdown(..))
import Tuple


{-| Stringify a LiaScript Markdown element based on dynamic results originated
from JavaScript evaluation and the current visualization mode, the parameters
are:

1.  `scripts`: the current configuration of all `Effect.Scripts`, which might
    also change over time...
2.  `id`: the current effect ID, which means, if there is an effect element,
    such as an animation/fragment, it will only turned into a string, if its
    fragment `id` maps this `id`, if the effect id is of type `Nothing`, all
    effects will be stringified (used in textbook mode)
3.  `markdown`: the element to strigify...

-}
stringify : Scripts a -> Maybe Int -> Markdown -> String
stringify scripts id markdown =
    case markdown of
        Paragraph _ inlines ->
            Inline.stringify_ scripts id inlines

        Quote _ mds ->
            block scripts id mds

        BulletList _ mds ->
            mds
                |> List.map (block scripts id)
                |> String.concat

        OrderedList _ mds ->
            mds
                |> List.map (Tuple.second >> block scripts id)
                |> String.concat

        Effect _ e ->
            if isIn id e then
                block scripts id e.content

            else
                "\n"

        Table _ table ->
            let
                head =
                    table.head
                        |> List.map (Tuple.second >> Inline.stringify_ scripts id)
                        |> String.concat

                body =
                    table.body
                        |> List.map (List.map (Tuple.second >> Inline.stringify_ scripts id) >> String.concat)
                        |> String.concat
            in
            head ++ " " ++ body

        HTML _ node ->
            node
                |> HTML.getContent
                |> block scripts id

        Header _ ( title, _ ) ->
            Inline.stringify_ scripts id title

        Citation _ inlines ->
            Inline.stringify_ scripts id inlines

        Problem inlines ->
            Inline.stringify_ scripts id inlines

        _ ->
            ""


{-| **@private:** stringify a list of Markdown into a string, separated by "\\n"
-}
block : Scripts a -> Maybe Int -> List Markdown -> String
block scripts id =
    List.map (stringify scripts id)
        >> List.intersperse "\n"
        >> String.concat
