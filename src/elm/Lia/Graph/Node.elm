module Lia.Graph.Node exposing
    ( Node(..)
    , equal
    , id
    , isVisible
    , name
    , weight
    )


type Node
    = Hashtag
        { name : String
        , visible : Bool
        }
    | Section
        { id : Int
        , indentation : Int
        , weight : Int
        , name : String
        , visible : Bool
        }
    | Link
        { name : String
        , url : String
        , visible : Bool
        }
    | Course
        { name : String
        , url : String
        , visible : Bool
        }


isVisible : Node -> Bool
isVisible node =
    case node of
        Section sec ->
            sec.visible

        _ ->
            True


name : Node -> String
name node =
    case node of
        Section sec ->
            sec.name

        Link link ->
            link.name

        Hashtag tag ->
            tag.name

        Course lia ->
            lia.name


id : Node -> String
id node =
    case node of
        Section sec ->
            "sec: " ++ String.fromInt sec.id

        Link link ->
            "url: " ++ link.url

        Course lia ->
            "lia: " ++ lia.url

        Hashtag tag ->
            "tag: " ++ String.toLower tag.name


weight : Node -> Float
weight node =
    case node of
        Section sec ->
            toFloat sec.weight / 60

        Course _ ->
            50

        _ ->
            10


equal : Node -> Node -> Bool
equal node1 node2 =
    case ( node1, node2 ) of
        ( Section sec1, Section sec2 ) ->
            sec1.id == sec2.id

        ( Hashtag str1, Hashtag str2 ) ->
            str1 == str2

        ( Link link1, Link link2 ) ->
            link1.url == link2.url

        ( Course lia1, Course lia2 ) ->
            lia1.url == lia2.url

        _ ->
            False
