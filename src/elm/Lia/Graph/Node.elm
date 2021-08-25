module Lia.Graph.Node exposing
    ( Node
    , Type(..)
    , addLink
    , addParent
    , categories
    , category
    , connections
    , equal
    , identifier
    , links
    , parent
    , section
    , weight
    )

import Conditional.Set as CSet
import Set exposing (Set)


type Type
    = Hashtag
    | Reference String
    | Course String
    | Section
        { id : Int
        , indentation : Int
        , weight : Int
        , parent : Maybe String
        }


type alias Node =
    { name : String
    , visible : Bool
    , links : Set String
    , data : Type
    }


identifier : Node -> String
identifier node =
    case node.data of
        Section sec ->
            "sec: " ++ String.fromInt sec.id

        Reference url ->
            "ref: " ++ url

        Course url ->
            "lia: " ++ url

        Hashtag ->
            "tag: " ++ String.toLower node.name


weight : Node -> Float
weight node =
    case node.data of
        Section sec ->
            toFloat sec.weight / 60

        Course _ ->
            50

        _ ->
            10


category : Node -> Int
category node =
    case node.data of
        Course _ ->
            0

        Hashtag ->
            1

        Reference _ ->
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
    case ( node1.data, node2.data ) of
        ( Section sec1, Section sec2 ) ->
            sec1.id == sec2.id

        ( Reference url1, Reference url2 ) ->
            url1 == url2

        ( Hashtag, Hashtag ) ->
            node1.name == node2.name

        ( Course lia1, Course lia2 ) ->
            lia1 == lia2

        _ ->
            False


section : Int -> Node
section i =
    { name = ""
    , visible = False
    , links = Set.empty
    , data =
        Section
            { id = i
            , indentation = -1
            , weight = -1
            , parent = Nothing
            }
    }


addLink : Node -> Node -> Node
addLink target source =
    { source | links = Set.insert (identifier target) source.links }


addParent : Node -> Node -> Node
addParent child p =
    case child.data of
        Section sec ->
            { child | data = Section { sec | parent = Just (identifier p) } }

        _ ->
            child


parent : Node -> Maybe String
parent node =
    case node.data of
        Section data ->
            data.parent

        _ ->
            Nothing


links : Node -> List String
links =
    .links >> Set.toList


connections : Node -> List String
connections node =
    node.links
        |> CSet.insertWhen (parent node)
        |> Set.toList
