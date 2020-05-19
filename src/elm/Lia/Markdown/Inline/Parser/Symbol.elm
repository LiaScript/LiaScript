module Lia.Markdown.Inline.Parser.Symbol exposing (arrows, smileys)

import Combine exposing (Parser, choice, map, onsuccess, string)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Types exposing (Inline(..))


arrows : Parser s (Parameters -> Inline)
arrows =
    choice
        [ string "<-->" |> onsuccess "⟷"
        , string "<--" |> onsuccess "⟵"
        , string "-->" |> onsuccess "⟶"
        , string "<<-" |> onsuccess "↞"
        , string "->>" |> onsuccess "↠"
        , string "<->" |> onsuccess "↔"
        , string ">->" |> onsuccess "↣"
        , string "<-<" |> onsuccess "↢"
        , string "->" |> onsuccess "→"
        , string "<-" |> onsuccess "←"
        , string "<~" |> onsuccess "↜"
        , string "~>" |> onsuccess "↝"
        , string "<==>" |> onsuccess "⟺"
        , string "==>" |> onsuccess "⟹"
        , string "<==" |> onsuccess "⟸"
        , string "<=>" |> onsuccess "⇔"
        , string "=>" |> onsuccess "⇒"
        , string "<=" |> onsuccess "⇐"
        ]
        |> map Symbol


smileys : Parser s (Parameters -> Inline)
smileys =
    choice
        [ string ":-)" |> onsuccess "🙂"
        , string ";-)" |> onsuccess "😉"
        , string ":-D" |> onsuccess "😀"
        , string ":-O" |> onsuccess "😮"
        , string ":-(" |> onsuccess "🙁"
        , string ":-|" |> onsuccess "😐"
        , string ":-/" |> onsuccess "😕"
        , string ":-\\" |> onsuccess "😕"
        , string ":-P" |> onsuccess "😛"
        , string ":-p" |> onsuccess "😛"
        , string ";-P" |> onsuccess "😜"
        , string ";-p" |> onsuccess "😜"
        , string ":-*" |> onsuccess "😗"
        , string ";-*" |> onsuccess "😘"
        , string ":')" |> onsuccess "😂"
        , string ":'(" |> onsuccess "😢"
        , string ":'[" |> onsuccess "😭"
        , string ":-[" |> onsuccess "😠"
        , string ":-#" |> onsuccess "😷"
        , string ":-X" |> onsuccess "😷"
        , string ":-§" |> onsuccess "😖"
        ]
        |> map Symbol
