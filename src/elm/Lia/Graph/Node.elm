module Lia.Graph.Node exposing
    ( Node(..)
    , categories
    , category
    , children
    , connect
    , equal
    , id
    , isVisible
    , name
    , section
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
        , children : List String
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


category : Node -> Int
category node =
    case node of
        Course _ ->
            0

        Hashtag _ ->
            1

        Link _ ->
            2

        Section _ ->
            3


categories : List String
categories =
    [ "Course"
    , "Hashtag"
    , "Link"
    , "Section"
    ]


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


section : Int -> Node
section i =
    Section
        { id = i
        , indentation = -1
        , weight = -1
        , name = ""
        , visible = False
        , children = []
        }


connect : Node -> Node -> Node
connect child parent =
    case parent of
        Section data ->
            Section { data | children = id child :: data.children }

        _ ->
            parent


children : Node -> List String
children node =
    case node of
        Section data ->
            data.children

        _ ->
            []
