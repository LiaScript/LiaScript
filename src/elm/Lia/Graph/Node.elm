module Lia.Graph.Node exposing
    ( Node(..)
    , addLink
    , addParent
    , categories
    , category
    , connections
    , equal
    , identifier
    , isVisible
    , links
    , name
    , parent
    , section
    , weight
    )

import Conditional.Set as CSet
import Set exposing (Set)


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
        , parent : Maybe String
        , links : Set String
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


identifier : Node -> String
identifier node =
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
        , parent = Nothing
        , links = Set.empty
        }


addLink : Node -> Node -> Node
addLink target source =
    case source of
        Section data ->
            Section { data | links = Set.insert (identifier target) data.links }

        _ ->
            source


addParent : Node -> Node -> Node
addParent child p =
    case child of
        Section data ->
            Section { data | parent = Just (identifier p) }

        _ ->
            child


parent : Node -> Maybe String
parent node =
    case node of
        Section data ->
            data.parent

        _ ->
            Nothing


links : Node -> List String
links node =
    case node of
        Section data ->
            Set.toList data.links

        _ ->
            []


connections : Node -> List String
connections node =
    case node of
        Section data ->
            data.links
                |> CSet.insertWhen data.parent
                |> Set.toList

        _ ->
            []
