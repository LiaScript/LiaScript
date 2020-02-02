module Lia.Markdown.HTML.Types exposing (Node(..))


type Node content
    = Node String (List ( String, String )) (List content)
