module Lia.Index.View exposing
    ( bottom
    , content
    , search
    )

import Accessibility.Aria as A11y_Aria
import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Array exposing (Array)
import Conditional.List as CList
import Conditional.String as CString
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (on, onClick, onInput, preventDefaultOn, stopPropagationOn)
import Html.Lazy
import I18n.Translations as Translations exposing (Lang, baseSearch)
import Json.Decode as JD
import Lia.Index.Model exposing (Model)
import Lia.Index.Update exposing (Msg(..), Node(..), entries, nest)
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Inline.View exposing (view_inf)
import Lia.Section exposing (Section, Sections)
import Lia.Utils exposing (btn, icon)
import Set exposing (Set)


{-| The search field, a button to clear it and, for screen readers, the number
of matching sections.
-}
search : Lang -> Bool -> Array { x | visible : Bool } -> String -> List (Html Msg)
search lang active results model =
    [ Html.input
        [ Attr.type_ "search"
        , Attr.value model
        , Attr.class "lia-input"
        , Attr.placeholder (baseSearch lang)
        , A11y_Aria.label (baseSearch lang)
        , onInput ScanIndex
        , onKeyDown
        , Attr.id "lia-input-search"
        , A11y_Key.tabbable active
        , A11y_Aria.hidden (not active)
        ]
        []
    , Html.span
        [ Attr.class "icon icon-search"
        ]
        []
    , if String.isEmpty model then
        Html.text ""

      else
        Html.button
            [ Attr.class "lia-toc__clear-index"
            , onClick DeleteSearch
            , A11y_Key.tabbable active
            , lang
                |> Translations.baseDelete
                |> Attr.title
            ]
            [ Html.i
                [ Attr.class "lia-btn__icon icon icon-close" ]
                []
            ]
    -- the status region exists also without a search, otherwise the first
    -- result is not announced
    , Html.span [ A11y_Role.status, Attr.class "hidden-visually" ]
        [ Html.text <|
            if String.isEmpty model then
                ""

            else
                case results |> Array.filter .visible |> Array.length of
                    0 ->
                        Translations.baseNoResult lang

                    1 ->
                        Translations.baseOneResult lang

                    counts ->
                        String.fromInt counts ++ " " ++ Translations.baseResults lang
        ]
    ]


{-| No key within the search field may reach the global slide navigation
(arrow keys move the cursor), Enter clears the search.
-}
onKeyDown : Html.Attribute Msg
onKeyDown =
    JD.map2
        (\keyCode shiftKey ->
            ( if keyCode == 13 && not shiftKey then
                ScanIndex ""

              else
                NoOp
            , True
            )
        )
        (JD.field "keyCode" JD.int)
        (JD.field "shiftKey" JD.bool)
        |> stopPropagationOn "keydown"


{-| The links to all sections as a navigation tree (APG treeview) with a
single tab stop, the current section or the entry that got the focus last.
Sections that do not match the search are hidden. The subsections of a
section can be collapsed, while searching all of them are shown.
-}
content : Lang -> Bool -> Int -> (( Int, Script.Msg sub ) -> msg) -> (Msg -> msg) -> Model -> Sections -> List (Html msg)
content lang active sectionId msg index model sections =
    let
        visible =
            entries model sections

        isVisible id =
            List.any (.id >> (==) id) visible

        -- the entry that got the focus last, as long as the section did not
        -- change, otherwise the current section or the first visible entry
        tabbable =
            case model.focus of
                Just ( current, id ) ->
                    if current == sectionId && isVisible id then
                        id

                    else
                        fallback

                Nothing ->
                    fallback

        fallback =
            if isVisible sectionId then
                sectionId

            else
                visible |> List.head |> Maybe.map .id |> Maybe.withDefault sectionId
    in
    sections
        |> Array.toList
        |> nest
        |> viewNodes
            { lang = lang
            , active = active
            , sectionId = sectionId
            , tabbable = tabbable
            , msg = msg
            , index = index
            , open =
                if String.isEmpty model.search then
                    \id -> not (Set.member id model.collapsed)

                else
                    always True
            , searching = not (String.isEmpty model.search)
            }
            [ A11y_Role.tree
            , A11y_Aria.label (Translations.baseToc lang)
            , keys sectionId |> JD.map (\key -> ( index (Key key), True )) |> preventDefaultOn "keydown"
            , dataID |> JD.map (Focus sectionId >> index) |> on "focusin"
            ]
        |> List.singleton


{-| The keys of the tree, the id of an entry is its `data-toc` attribute.
-}
keys : Int -> JD.Decoder { current : Int, key : String, rtl : Bool, id : Int }
keys current =
    JD.map3 (\key dir id -> { current = current, key = key, rtl = dir == "rtl", id = id })
        (JD.field "key" JD.string
            |> JD.andThen
                (\key ->
                    if List.member key [ "ArrowDown", "ArrowUp", "ArrowLeft", "ArrowRight", "Home", "End" ] then
                        JD.succeed key

                    else
                        JD.fail "no tree key"
                )
        )
        (JD.at [ "target", "ownerDocument", "documentElement", "dir" ] JD.string)
        dataID


dataID : JD.Decoder Int
dataID =
    JD.at [ "target", "dataset", "toc" ] JD.string
        |> JD.andThen (String.toInt >> Maybe.map JD.succeed >> Maybe.withDefault (JD.fail "no entry"))


type alias NodeConfig sub msg =
    { lang : Lang
    , active : Bool
    , sectionId : Int
    , tabbable : Int
    , msg : ( Int, Script.Msg sub ) -> msg
    , index : Msg -> msg
    , open : Int -> Bool
    , searching : Bool
    }


viewNodes : NodeConfig sub msg -> List (Html.Attribute msg) -> List Node -> Html msg
viewNodes config attr =
    List.map (viewNode config)
        >> Html.ul (Attr.class "lia-toc__list" :: attr)


{-| An entry, links are rendered lazily, see `item`. A section with subsections
gets a button for the mouse to collapse them, which is hidden while searching,
the keyboard uses the arrow keys of the tree.
-}
viewNode : NodeConfig sub msg -> Node -> Html msg
viewNode config (Node section children) =
    let
        open =
            config.open section.id

        link expanded =
            Html.Lazy.lazy7 item
                config.lang
                config.active
                (config.sectionId == section.id)
                (config.tabbable == section.id)
                expanded
                config.msg
                section
    in
    if List.isEmpty children then
        Html.li [ A11y_Role.presentation ] [ link Nothing ]

    else
        Html.li [ A11y_Role.presentation, Attr.class "lia-toc__parent" ]
            [ link (Just open)
            , if config.searching then
                Html.text ""

              else
                Html.button
                    [ Attr.class "lia-toc__toggle"
                    , onClick (config.index (Toggle section.id))
                    , Attr.tabindex -1
                    , A11y_Aria.hidden True
                    ]
                    [ icon
                        (if open then
                            "icon-chevron-up"

                         else
                            "icon-chevron-down"
                        )
                        []
                    ]
            , viewNodes config [ A11y_Role.group, Attr.hidden (not open) ] children
            ]


{-| The home button at the bottom of the table of contents.
-}
bottom : Lang -> Bool -> msg -> Html msg
bottom lang active msg =
    btn
        { title = ""
        , msg = Just msg
        , tabbable = active
        }
        [ Attr.class "lia-btn--transparent"
        , Attr.id "lia-btn-home"
        ]
        [ icon "icon-grid" []
        , Html.span [ Attr.class "lia-btn__text" ] [ Html.text (Translations.home lang) ]
        ]


{-| Rendered lazily by `content`, thus only sections that changed are rendered
again, all arguments have to be stable references (`msg` a constructor).
`expanded` is `Nothing` for a section without subsections.
-}
item : Lang -> Bool -> Bool -> Bool -> Maybe Bool -> (( Int, Script.Msg sub ) -> msg) -> Section -> Html msg
item lang active isCurrent isTabbable expanded msg section =
    section.title
        |> List.map (view_inf Array.empty lang False False Nothing Nothing Nothing)
        |> itemLink active isCurrent isTabbable expanded section
        |> Html.map (Tuple.pair section.id >> msg)


itemLink : Bool -> Bool -> Bool -> Maybe Bool -> Section -> List (Html msg) -> Html msg
itemLink active isCurrent isTabbable expanded section =
    [ A11y_Role.treeItem
    , A11y_Key.tabbable (active && isTabbable)
    , A11y_Aria.hidden (not active)
    , Attr.attribute "data-toc" (String.fromInt section.id)

    -- like Enter, as for every tree item, instead of scrolling the list
    , Attr.attribute "onkeydown" "if(event.key===' '){event.preventDefault();this.click()}"
    , Attr.id
        (if isCurrent then
            "focusedToc"

         else
            "lia-toc-" ++ String.fromInt section.id
        )
    , section.indentation
        |> String.fromInt
        |> (++) "lia-toc__link lia-toc__link--is-lvl-"
        |> CString.attachIf (not section.visible) " hide"
        |> Attr.class
    , section.id
        + 1
        |> String.fromInt
        |> (++) "#"
        |> Attr.href
    ]
        |> CList.addWhen (Maybe.map A11y_Aria.expanded expanded)
        |> CList.appendIf isCurrent [ Attr.class "lia-active", Attr.attribute "aria-current" "page" ]
        |> Html.a
