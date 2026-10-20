module Lia.Index.Update exposing
    ( Entry
    , Msg(..)
    , Node(..)
    , entries
    , linkID
    , nest
    , reveal
    , update
    )

{-| Searching the sections of a course, the search pattern is a list of words,
separated by spaces. A section is visible, if its code or title contain all of
them (ignoring the case). Words with 4 or more characters may also match the
start of a word with one typo.
-}

import Array
import Lia.Index.Model exposing (Model)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Section exposing (Section, Sections)
import Lia.Utils exposing (focus)
import List.Extra
import Set


{-| -}
type Msg
    = ScanIndex String
    | DeleteSearch
    | Toggle Int
    | Focus Int Int
    | Key { current : Int, key : String, rtl : Bool, id : Int }
    | NoOp


{-| Store the pattern and mark the matching sections as `visible`. Deleting
the search moves the focus back into the search field.
-}
update : Msg -> Model -> Sections -> ( Model, Sections, Cmd Msg )
update msg model sections =
    case msg of
        ScanIndex pattern ->
            ( { model | search = pattern }, scan pattern sections, Cmd.none )

        DeleteSearch ->
            ( { model | search = "" }, scan "" sections, focus NoOp "lia-input-search" )

        Toggle id ->
            ( { model
                | collapsed =
                    if Set.member id model.collapsed then
                        Set.remove id model.collapsed

                    else
                        Set.insert id model.collapsed
              }
            , sections
            , Cmd.none
            )

        Focus current id ->
            ( { model | focus = Just ( current, id ) }, sections, Cmd.none )

        Key key ->
            navigate key model sections

        NoOp ->
            ( model, sections, Cmd.none )


{-| Keyboard navigation of the tree (APG navigation treeview): Up and Down
move between the visible entries, Home and End to the first and last one.
Right opens a section or moves to its first subsection, Left closes it or
moves to its parent section, both mirrored for `rtl`.
-}
navigate : { current : Int, key : String, rtl : Bool, id : Int } -> Model -> Sections -> ( Model, Sections, Cmd Msg )
navigate { current, key, rtl, id } model sections =
    let
        list =
            entries model sections

        index =
            List.Extra.findIndex (.id >> (==) id) list

        at i =
            List.Extra.getAt i list

        moveTo target =
            case target of
                Just entry ->
                    ( { model | focus = Just ( current, entry.id ) }, sections, focus NoOp (linkID current entry.id) )

                Nothing ->
                    ( model, sections, Cmd.none )

        setCollapsed fn =
            ( { model | collapsed = fn id model.collapsed }, sections, Cmd.none )

        searching =
            model.search /= ""

        ( forward, backward ) =
            if rtl then
                ( "ArrowLeft", "ArrowRight" )

            else
                ( "ArrowRight", "ArrowLeft" )
    in
    case ( index, Maybe.andThen at index ) of
        ( Just i, Just entry ) ->
            if key == "ArrowDown" then
                moveTo (at (i + 1))

            else if key == "ArrowUp" then
                moveTo (at (i - 1))

            else if key == "Home" then
                moveTo (List.head list)

            else if key == "End" then
                moveTo (List.Extra.last list)

            else if key == forward && entry.children then
                if entry.open then
                    -- the first subsection, unless the search hides it
                    moveTo
                        (case at (i + 1) of
                            Just next ->
                                if next.parent == Just id then
                                    Just next

                                else
                                    Nothing

                            _ ->
                                Nothing
                        )

                else
                    setCollapsed Set.remove

            else if key == backward then
                if entry.children && entry.open && not searching then
                    setCollapsed Set.insert

                else
                    moveTo (entry.parent |> Maybe.andThen (\p -> List.Extra.find (.id >> (==) p) list))

            else
                ( model, sections, Cmd.none )

        _ ->
            ( model, sections, Cmd.none )


{-| Called whenever the current section changes: The first time, when all
sections are known, the sections below the two upper levels of the course
get collapsed. Every time the branch of the current section gets opened.
-}
reveal : Int -> Sections -> Model -> Model
reveal current sections model =
    let
        list =
            Array.toList sections

        top =
            list |> List.map .indentation |> List.minimum |> Maybe.withDefault 1

        collapsible nodes =
            List.concatMap
                (\(Node section children) ->
                    if List.isEmpty children then
                        []

                    else if section.indentation > top then
                        section.id :: collapsible children

                    else
                        collapsible children
                )
                nodes

        collapsed =
            if model.defaults then
                model.collapsed

            else
                list |> nest |> collapsible |> Set.fromList

        -- the preceding sections with a smaller indentation each
        ancestors =
            case Array.get current sections of
                Just section ->
                    List.take current list
                        |> List.foldr
                            (\s ( level, ids ) ->
                                if s.indentation < level then
                                    ( s.indentation, s.id :: ids )

                                else
                                    ( level, ids )
                            )
                            ( section.indentation, [] )
                        |> Tuple.second

                Nothing ->
                    []
    in
    { model
        | defaults = True
        , collapsed = List.foldl Set.remove collapsed ancestors
    }


{-| The link of the current section has the id `focusedToc` (scrolled into
view and focused by Alt+Shift+C).
-}
linkID : Int -> Int -> String
linkID current id =
    if id == current then
        "focusedToc"

    else
        "lia-toc-" ++ String.fromInt id


{-| A section and its subsections.
-}
type Node
    = Node Section (List Node)


{-| Build the tree from the flat list of sections, all following sections with
a larger indentation are subsections.
-}
nest : List Section -> List Node
nest sections =
    case sections of
        [] ->
            []

        section :: rest ->
            let
                ( children, siblings ) =
                    List.Extra.span (\s -> s.indentation > section.indentation) rest
            in
            Node section (nest children) :: nest siblings


type alias Entry =
    { id : Int, parent : Maybe Int, children : Bool, open : Bool }


{-| The visible entries in their order: sections that match the search and are
not within a collapsed section. While searching all sections are open.
-}
entries : Model -> Sections -> List Entry
entries model =
    let
        isOpen id =
            model.search /= "" || not (Set.member id model.collapsed)

        visible parent =
            List.concatMap
                (\(Node section children) ->
                    (if section.visible then
                        [ { id = section.id, parent = parent, children = children /= [], open = isOpen section.id } ]

                     else
                        []
                    )
                        ++ (if isOpen section.id then
                                visible (Just section.id) children

                            else
                                []
                           )
                )
    in
    Array.toList >> nest >> visible Nothing


scan : String -> Sections -> Sections
scan pattern =
    case
        pattern
            |> String.toLower
            |> String.split " "
            |> List.filter ((/=) "")
    of
        [] ->
            Array.map (\section -> { section | visible = True })

        words ->
            Array.map
                (\section ->
                    let
                        text =
                            String.toLower (section.code ++ stringify section.title)
                    in
                    { section
                        | visible =
                            case List.filter (\word -> not (String.contains word text)) words of
                                [] ->
                                    True

                                missing ->
                                    let
                                        tokens =
                                            text
                                                |> String.map
                                                    (\c ->
                                                        if Char.isAlphaNum c || Char.toCode c > 127 then
                                                            c

                                                        else
                                                            ' '
                                                    )
                                                |> String.words
                                                |> List.map String.toList
                                    in
                                    List.all
                                        (\word ->
                                            String.length word >= 4 && List.any (near (String.toList word)) tokens
                                        )
                                        missing
                    }
                )


{-| Typo tolerance: `word` differs from the start of `token` by at most one
wrong, missing, extra or swapped character.

ponytail: tokenizes the whole section on every miss, precompute tokens if large courses lag

-}
near : List Char -> List Char -> Bool
near word token =
    case ( word, token ) of
        ( [], _ ) ->
            True

        ( _, [] ) ->
            List.length word <= 1

        ( x :: xs, y :: ys ) ->
            if x == y then
                near xs ys

            else
                startsWith xs ys
                    || startsWith xs token
                    || startsWith word ys
                    || (case ( xs, ys ) of
                            ( x2 :: xs2, y2 :: ys2 ) ->
                                x2 == y && y2 == x && startsWith xs2 ys2

                            _ ->
                                False
                       )


startsWith : List Char -> List Char -> Bool
startsWith prefix list =
    prefix == List.take (List.length prefix) list
