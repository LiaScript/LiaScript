module Lia.Markdown.Inline.View exposing
    ( audio
    , dropHere
    , onError
    , reduce
    , view
    , viewMedia
    , viewQuizDrops
    , view_inf
    , viewer
    )

import Accessibility.Aria as A11y_Aria
import Accessibility.Role as A11y_Role
import Array
import Conditional.List as CList
import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Keyed
import Html.Lazy
import I18n.Translations as Translations exposing (Lang)
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Msg exposing (Msg, Scripts)
import Lia.Markdown.Effect.Script.View as JS
import Lia.Markdown.Effect.View as Effect
import Lia.Markdown.Footnote.View as Footnote
import Lia.Markdown.HTML.Attributes exposing (Parameters, annotation, toAttribute)
import Lia.Markdown.HTML.View as HTML
import Lia.Markdown.Inline.Config as Config exposing (Config)
import Lia.Markdown.Inline.Multimedia exposing (website)
import Lia.Markdown.Inline.Stringify exposing (stringify_)
import Lia.Markdown.Inline.Types exposing (Inline(..), Inlines, Reference(..), combine)
import Lia.Markdown.Quiz.Block.Types exposing (State(..))
import Lia.Section exposing (SubSection)
import Lia.Settings.Types exposing (Mode(..))
import Lia.Utils exposing (blockKeydown, noTranslate, shuffle)
import List.Extra
import QRCode


{-| Render a list of inlines.
-}
viewer : Config sub -> Inlines -> List (Html (Msg sub))
viewer config =
    List.map (view config)


{-| Render a single inline element.
-}
view : Config sub -> Inline -> Html (Msg sub)
view config element =
    case element of
        Chars e [] ->
            Html.text e

        Chars e attr ->
            view config (Container [ Chars e [] ] attr)

        Bold e attr ->
            Html.strong (annotation "lia-bold" attr) [ view config e ]

        Italic e attr ->
            Html.em (annotation "lia-italic" attr) [ view config e ]

        Strike e attr ->
            Html.s (annotation "lia-strike" attr) [ view config e ]

        Underline e attr ->
            Html.u (annotation "lia-underline" attr) [ view config e ]

        Superscript e attr ->
            Html.sup (annotation "lia-superscript" attr) [ view config e ]

        Verbatim e attr ->
            Html.code
                (attr
                    |> annotation "lia-code lia-code--inline"
                    |> noTranslate
                )
                [ Html.text e ]

        Ref e attr ->
            reference config e attr

        Formula mode_ e [] ->
            formula
                [ config.formulas
                    |> JE.dict identity JE.string
                    |> Attr.property "macros"
                ]
                mode_
                e

        Formula mode_ e attr ->
            view config (Container [ Formula mode_ e [] ] attr)

        Symbol e [] ->
            Html.text e

        Symbol e attr ->
            view config (Container [ Symbol e [] ] attr)

        FootnoteMark e attr ->
            attr
                |> toAttribute
                |> Footnote.inline e

        Container list attr ->
            list
                |> viewer config
                |> Html.span (Attr.style "left" "initial" :: Attr.style "text-decoration" "inherit" :: toAttribute attr)

        IHTML node attr ->
            HTML.view Html.span (view config) attr node

        EInline e attr ->
            e.content
                |> viewer config
                |> Effect.inline config attr e

        Script id attr ->
            JS.view config id attr

        Quiz input attr ->
            viewQuiz config input attr


{-| **@private:** A `lia-formula` web component, `mode_` is `"true"` for
display mode.
-}
formula : List (Attribute msg) -> String -> String -> Html msg
formula attributes mode_ e =
    Html.node "lia-formula"
        (Attr.attribute "displayMode" mode_
            :: Attr.class "notranslate"
            :: Attr.attribute "translate" "no"
            :: Attr.property "formula" (JE.string e)
            :: attributes
        )
        []


{-| **@private:** Render the quiz input with `id`, depending on its state:
a text input, a dropdown selection, or a drop target.
-}
viewQuiz : Config sub -> ( String, Int ) -> Parameters -> Html (Msg sub)
viewQuiz config ( width, id ) attr =
    let
        partiallyCorrect =
            if config.input.active then
                Array.get id config.input.partiallyCorrect

            else
                Nothing

        highlight a =
            partiallyCorrect
                |> Maybe.map (highlightPartialSolution a)
                |> Maybe.withDefault a
    in
    case Array.get id config.input.state of
        Just (Text text) ->
            viewText config id width text (highlight (toAttribute attr))

        Just (Select open [ selected ]) ->
            viewSelect config id open selected (toAttribute attr) highlight

        Just (Drop _ _ [ i ]) ->
            Html.span
                (highlight (toAttribute attr)
                    ++ dropStyle ("3px dotted " ++ borderColor partiallyCorrect) "5px"
                )
                [ config.input.options
                    |> Array.get id
                    |> Maybe.andThen (List.Extra.getAt i)
                    |> Maybe.map (viewer config >> Html.span [])
                    |> Maybe.withDefault (dropHere [])
                ]

        Just (Drop highlighted _ state) ->
            viewDropTarget config id highlighted state partiallyCorrect attr

        _ ->
            Html.text "todo"


{-| **@private:** A text input.
-}
viewText : Config sub -> Int -> String -> String -> List (Attribute (Msg sub)) -> Html (Msg sub)
viewText config id width text attributes =
    Html.input
        ([ Attr.type_ "text"
         , Attr.class "lia-input lia-quiz__input"
         , Attr.style "padding" "0.2rem 0.5rem"
         , Attr.style "text-align" "center"
         , Attr.placeholder "?"
         , Attr.style "width" width
         , Attr.style "font-weight" "inherit"
         , Attr.style "text-decoration" "inherit"
         , Attr.style "font-style" "inherit"
         , Attr.style "vertical-align" "middle"
         , Attr.value text
         , if config.input.active then
            Attr.attribute "oninput" (config.input.on "input" id "this.value")

           else
            Attr.disabled True
         , blockKeydown Msg.NoOp
         , A11y_Aria.label "quiz answer"
         , Attr.class <|
            if config.input.active then
                ""

            else
                "lia-input--disabled is-disabled"
         , Attr.disabled (not config.input.active)
         ]
            ++ attributes
        )
        []


{-| **@private:** A dropdown, `selected` is the index of the selected option.
-}
viewSelect : Config sub -> Int -> Bool -> Int -> List (Attribute (Msg sub)) -> (List (Attribute (Msg sub)) -> List (Attribute (Msg sub))) -> Html (Msg sub)
viewSelect config id open selected attributes highlight =
    let
        options =
            config.input.options
                |> Array.get id
                |> Maybe.withDefault []

        action =
            if config.input.active then
                [ Attr.attribute "onClick" (config.input.on "toggle" id "true")
                , keyDownEvent (config.input.on "toggle" id "true")
                ]

            else
                [ Attr.disabled True
                , Attr.class "is-disabled"
                ]
    in
    Html.span
        (highlight
            (action
                ++ [ Attr.class "lia-dropdown"
                   , Attr.style "padding" "0 0.5rem"
                   , Attr.tabindex 0
                   , Attr.style "vertical-align"
                        (if open then
                            "text-top"

                         else
                            "middle"
                        )
                   ]
                ++ attributes
            )
        )
        [ Html.span
            [ Attr.class "lia-dropdown__selected"
            , A11y_Aria.hidden False
            , A11y_Role.button
            , A11y_Aria.expanded open
            , Attr.style "font-weight" "inherit"
            , Attr.style "text-decoration" "inherit"
            , Attr.style "font-style" "inherit"
            ]
            [ case List.Extra.getAt selected options of
                Just option ->
                    Html.span [] (viewer config option)

                Nothing ->
                    Html.span [] [ Html.text <| Translations.quizSelection config.lang ]
            , Html.i
                [ Attr.class <|
                    if open then
                        "icon icon-chevron-up"

                    else
                        "icon icon-chevron-down"
                , A11y_Role.button
                ]
                []
            ]
        , options
            |> List.indexedMap (viewOption config open id)
            |> shuffle (Maybe.andThen (Array.get id) config.input.randomize)
            |> Html.div
                [ Attr.class "lia-dropdown__options"
                , Attr.tabindex -1
                , Attr.class <|
                    if open then
                        "is-visible"

                    else
                        "is-hidden"
                ]
        ]


{-| **@private:** An option `i` of the dropdown with `id`.
-}
viewOption : Config sub -> Bool -> Int -> Int -> Inlines -> Html (Msg sub)
viewOption config open id i option =
    Html.div
        [ Attr.class "lia-dropdown__option"
        , Attr.attribute "onclick" (config.input.on "choose" id (String.fromInt i))
        , A11y_Role.listItem
        , Attr.tabindex <|
            if open then
                0

            else
                -1
        , keyDownEvent (config.input.on "choose" id (String.fromInt i))
        ]
        [ Html.div [] (viewer config option) ]


{-| **@private:** A drop target, `state` is `[ input, option ]` of the
dropped option, which can be dragged away again.
-}
viewDropTarget : Config sub -> Int -> Bool -> List Int -> Maybe Bool -> Parameters -> Html (Msg sub)
viewDropTarget config id highlighted state partiallyCorrect attr =
    let
        option =
            case state of
                [ i, j ] ->
                    config.input.options
                        |> Array.get i
                        |> Maybe.andThen (List.Extra.getAt j)

                _ ->
                    Nothing
    in
    Html.span
        (toAttribute attr
            ++ dropStyle
                ((if highlighted then
                    "5px"

                  else
                    "3px"
                 )
                    ++ " dotted "
                    ++ borderColor partiallyCorrect
                )
                "4px"
            ++ [ Attr.style "background-color" "#88888822"
               , Attr.attribute "ondragover" (config.input.on "dragenter" id "true")
               , Attr.attribute "ondragleave" ("setTimeout(()=>" ++ config.input.on "dragenter" id "false" ++ ", 100)")
               , Attr.tabindex 0
               , A11y_Role.button
               , Attr.attribute "onclick" (config.input.on "dragtarget" id "null")
               , keyDownEvent (config.input.on "dragtarget" id "null")
               ]
        )
        [ case option of
            Just inlines ->
                Html.span
                    [ Attr.draggable "true"
                    , Attr.style "cursor" "pointer"
                    , Attr.attribute "ondragend"
                        (config.input.on "dragend"
                            id
                            (case state of
                                [ i, j ] ->
                                    encodePair i j

                                _ ->
                                    ""
                            )
                        )
                    ]
                    (viewer config inlines)

            Nothing ->
                dropHere []
        ]


{-| **@private:** The common style of drop targets.
-}
dropStyle : String -> String -> List (Attribute msg)
dropStyle border radius =
    [ Attr.style "padding" "1rem"
    , Attr.style "margin" "0.25rem"
    , Attr.style "position" "relative"
    , Attr.style "border" border
    , Attr.style "border-radius" radius
    , Attr.style "display" "inline-block"
    , Attr.style "vertical-align" "middle"
    ]


{-| **@private:** Gray if unchecked, otherwise green or red.
-}
borderColor : Maybe Bool -> String
borderColor partiallyCorrect =
    case partiallyCorrect of
        Nothing ->
            "#888"

        Just True ->
            "green"

        Just False ->
            "red"


{-| **@private:** `[i,j]`
-}
encodePair : Int -> Int -> String
encodePair i j =
    [ i, j ]
        |> JE.list JE.int
        |> JE.encode 0


{-| Render all options of all drop inputs that are not dropped yet, so that
they can be dragged onto their targets.
-}
viewQuizDrops : Config sub -> List (Html (Msg sub))
viewQuizDrops config =
    let
        occupied =
            config.input.state
                |> Array.toList
                |> List.indexedMap
                    (\i state ->
                        case state of
                            -- only one id, is shown, when the quiz was resolved
                            Drop _ _ [ state_ ] ->
                                Just [ i, state_ ]

                            Drop _ _ [] ->
                                Nothing

                            Drop _ _ state_ ->
                                Just state_

                            _ ->
                                Nothing
                    )
                |> List.filterMap identity
    in
    List.map2 Tuple.pair
        (Array.toList config.input.state)
        (Array.toList config.input.options)
        |> List.indexedMap
            (\id ( state, options ) ->
                case state of
                    Drop _ active _ ->
                        List.indexedMap
                            (\i option ->
                                if List.member [ id, i ] occupied then
                                    Html.text ""

                                else
                                    viewDragOption config active id i option
                            )
                            options

                    _ ->
                        []
            )
        |> List.concat


{-| **@private:** Option `i` of the drop input `id`.
-}
viewDragOption : Config sub -> Bool -> Int -> Int -> Inlines -> Html (Msg sub)
viewDragOption config active id i option =
    let
        on msg =
            config.input.on msg id (encodePair id i)
    in
    viewer config option
        |> Html.span
            ([ Attr.style "border" "3px dotted #888"
             , Attr.style "margin" "0.25rem"
             , Attr.style "padding" "1rem"
             , Attr.style "background-color" "#88888822"
             , Attr.style "border-radius" "4px"
             , Attr.style "display" "inline-block"
             , A11y_Role.button
             , Attr.tabindex 0
             , Attr.attribute "aria-grabbed"
                (if active then
                    "true"

                 else
                    "false"
                )
             ]
                |> CList.appendIf config.input.active
                    [ Attr.style "cursor" "pointer"
                    , Attr.draggable "true"
                    , Attr.attribute "ondragend" (on "dragend")
                    , Attr.attribute "ondragstart" (on "dragstart")
                    , Attr.attribute "onclick" (on "dragsource")
                    , keyDownEvent (on "dragsource")
                    ]
            )


{-| An empty drop target.
-}
dropHere : List (Attribute msg) -> Html msg
dropHere attr =
    Html.div
        (Attr.style "display" "flex"
            :: Attr.style "justify-content" "center"
            :: Attr.style "align-items" "center"
            :: Attr.style "line-height" "1"
            :: Attr.style "color" "#888"
            :: Attr.style "min-width" "3rem"
            :: attr
        )
        [ Html.text "✛" ]


{-| **@private:** Execute `msg` on space or enter.
-}
keyDownEvent : String -> Attribute msg
keyDownEvent msg =
    Attr.attribute
        "onkeydown"
        ("if(event.key===' '||event.key==='Enter')" ++ msg)


{-| **@private:** Mark a quiz input as correct or wrong.
-}
highlightPartialSolution : List (Attribute msg) -> Bool -> List (Attribute msg)
highlightPartialSolution attr partiallyCorrect =
    if partiallyCorrect then
        Attr.class "is-success"
            :: A11y_Aria.invalid False
            :: attr

    else
        Attr.class "is-failure"
            :: A11y_Aria.invalid True
            :: attr


{-| **@private:** A reduced text representation, every sentence `". "` of
plain text becomes a paragraph.
-}
toText : Config sub -> Inline -> Html (Msg sub)
toText config element =
    case element of
        Chars e _ ->
            e
                |> String.split ". "
                |> List.map (\s -> Html.p [] [ Html.text (s ++ ".") ])
                |> Html.div []

        Verbatim e attr ->
            Html.span
                (attr
                    |> toAttribute
                    |> noTranslate
                )
                [ Html.text e ]

        Formula mode_ e _ ->
            formula [] mode_ e

        Symbol e _ ->
            Html.text e

        Container [ e ] _ ->
            toText config e

        Container list _ ->
            list
                |> List.map (toText config)
                |> Html.span []

        IHTML node attr ->
            HTML.view Html.span (toText config) attr node

        EInline e _ ->
            e.content
                |> List.map (toText config)
                |> Effect.inline config [] e

        Script id attr ->
            JS.view config id attr

        _ ->
            Html.text ""


{-| Render inlines without styles and references, see `toText`.
-}
reduce : Config sub -> List Inline -> List (Html (Msg sub))
reduce config =
    List.map reduce_
        >> combine
        >> List.map (toText config)


{-| **@private:** Remove styles and replace references by their text.
-}
reduce_ : Inline -> Inline
reduce_ element =
    case element of
        Chars e _ ->
            Chars e []

        Bold e _ ->
            reduce_ e

        Italic e _ ->
            reduce_ e

        Strike e _ ->
            reduce_ e

        Underline e _ ->
            reduce_ e

        Superscript e _ ->
            reduce_ e

        Ref e _ ->
            case e of
                Link alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Mail alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Image alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Audio alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Movie alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Embed alt_ _ _ ->
                    reduce_ (Container alt_ [])

                Preview_Lia _ ->
                    Chars "preview-lia" []

                Preview_Link _ ->
                    Chars "preview-link" []

                QR_Link _ _ ->
                    Chars "qrcode" []

        FootnoteMark e _ ->
            Chars ("[" ++ e ++ "]") []

        Container [ e ] _ ->
            reduce_ e

        Container list _ ->
            Container (List.map reduce_ list) []

        _ ->
            element


{-| Render an image as zoomable figure (used by galleries), all other
elements are rendered as usual.
-}
viewMedia : Config sub -> Inline -> Html (Msg sub)
viewMedia config inline =
    case inline of
        Ref (Image alt_ url_ title_) attr ->
            let
                width =
                    mediaWidth config url_
            in
            Html.figure [ Attr.class "lia-figure" ]
                [ Html.div
                    [ Attr.class "lia-figure__media"
                    , Attr.attribute "data-media-image" "image"
                    , width
                        |> Maybe.map Attr.width
                        |> Maybe.withDefault (Attr.class "")
                    , Attr.style "background-image" ("url('" ++ url_ ++ "')")
                    , Attr.class "lia-figure__zoom"
                    , Attr.attribute "onmousemove" "window.LIA.img.zoom(event)"
                    ]
                    [ Html.img
                        (Attr.src url_
                            :: onError "img" url_
                            :: (alt config alt_ |> Maybe.withDefault (Attr.alt ""))
                            :: toAttribute attr
                            |> CList.addIf (width == Nothing) (load url_)
                            |> CList.addWhen (title config title_)
                        )
                        []
                    ]
                , caption config title_
                ]

        _ ->
            view config inline


{-| Render an inline outside of a section (titles, the table of contents,
etc.).
-}
view_inf :
    Scripts SubSection
    -> Lang
    -> Bool
    -> Bool
    -> Maybe { old : String, new : String, name : Maybe String }
    -> Maybe (Dict String String)
    -> Maybe (Dict String ( Int, Int ))
    -> Inline
    -> Html (Msg sub)
view_inf scripts lang light tooltips translations formulas media =
    { mode = Textbook
    , visible = Nothing
    , slide = -1
    , speaking = Nothing
    , paused = Nothing
    , lang = lang
    , theme = Nothing
    , light = light
    , tooltips = tooltips
    , hideVideoComments = True
    , media = media |> Maybe.withDefault Dict.empty
    , scripts = scripts
    , translations = translations
    , sync = Nothing
    , formulas = formulas
    }
        |> Config.init
        |> view


{-| **@private:** The width of a loaded image, `Nothing` if it is not loaded
yet.
-}
mediaWidth : Config sub -> String -> Maybe Int
mediaWidth config url_ =
    config.media
        |> Dict.get url_
        |> Maybe.map Tuple.first


{-| **@private:** Turn `title` and `alt` text into attributes, empty strings
are ignored.
-}
stringFrom : Config sub -> Maybe Inlines -> Maybe String
stringFrom config el =
    case Maybe.map (stringify_ config >> String.trim) el of
        Just "" ->
            Nothing

        str ->
            str


title : Config sub -> Maybe Inlines -> Maybe (Attribute msg)
title config =
    stringFrom config >> Maybe.map Attr.title


alt : Config sub -> Inlines -> Maybe (Attribute msg)
alt config =
    Just >> stringFrom config >> Maybe.map Attr.alt


{-| **@private:** Add the optional `title` and `alt` attributes.
-}
titleAndAlt : Config sub -> Inlines -> Maybe Inlines -> List (Attribute msg) -> List (Attribute msg)
titleAndAlt config alt_ title_ =
    CList.addWhen (title config title_)
        >> CList.addWhen (alt config alt_)


{-| **@private:** An image, a click opens the zoomed image, if it has no
annotations. `width` is `Nothing` if the image is not loaded yet.
-}
img : Config sub -> Parameters -> Inlines -> String -> Maybe Inlines -> Maybe Int -> Html msg
img config attr alt_ url_ title_ width =
    Html.img
        (Attr.src url_
            :: onError "img" url_
            :: (alt config alt_ |> Maybe.withDefault (Attr.alt ""))
            :: (-- double-click event is always added to the image
                if List.length attr == 1 && config.image_zoom then
                    [ Attr.attribute "onClick" ("window.LIA.img.click(\"" ++ url_ ++ "\")") ]

                else
                    toAttribute attr
               )
            |> CList.addIf (width == Nothing) (load url_)
            |> CList.addWhen (title config title_)
            |> addLazyLoading config.visible
        )
        []


{-| **@private:** Only in textbook mode (`visible == Nothing`) media is loaded
lazily.
-}
addLazyLoading : Maybe Int -> List (Attribute msg) -> List (Attribute msg)
addLazyLoading visible =
    CList.addIf (visible == Nothing) (Attr.attribute "loading" "lazy")


{-| **@private:** Report the size of a loaded image.
-}
load : String -> Attribute msg
load url =
    Attr.attribute "onload" ("window.LIA.img.load('" ++ url ++ "',this.width,this.height)")


{-| Report a media `tag` that could not be loaded from `url`.
-}
onError : String -> String -> Attribute msg
onError tag url =
    Attr.attribute "onerror" ("window.LIA.fetchError('" ++ tag ++ "','" ++ url ++ "')")


{-| **@private:** Wrap media into a figure with an optional caption.
-}
figure : Config sub -> Maybe Inlines -> Maybe Int -> String -> Html (Msg sub) -> Html (Msg sub)
figure config title_ width dataType element =
    Html.figure
        ([ Attr.class "lia-figure" ]
            |> CList.addWhen (Maybe.map Attr.width width)
        )
        [ Html.div
            [ Attr.class "lia-figure__media"
            , Attr.attribute "data-media-type" dataType
            ]
            [ element
            ]
        , caption config title_
        ]


{-| **@private:** The title as figure caption.
-}
caption : Config sub -> Maybe Inlines -> Html (Msg sub)
caption config =
    Maybe.map (viewer config >> Html.figcaption [ Attr.class "lia-figure__caption" ])
        >> Maybe.withDefault (Html.text "")


{-| **@private:** Permissions of embedded iframes.
-}
allow : Attribute msg
allow =
    Attr.attribute "allow" "accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"


{-| **@private:** Render links and media.
-}
reference : Config sub -> Reference -> Parameters -> Html (Msg sub)
reference config ref attr =
    case ref of
        Link alt_ url_ title_ ->
            view_url { config | image_zoom = False } alt_ url_ title_ attr

        Mail alt_ url_ title_ ->
            view_url { config | image_zoom = False } alt_ url_ title_ attr

        Image alt_ url_ title_ ->
            let
                width =
                    mediaWidth config url_
            in
            img config attr alt_ url_ title_ width
                |> figure config title_ width "image"

        Audio alt_ ( tube, url_ ) title_ ->
            figure config title_ Nothing "audio" <|
                Html.div []
                    [ printLink config alt_ title_ url_
                    , if tube then
                        Html.iframe
                            (Attr.src url_
                                :: Attr.attribute "allowfullscreen" ""
                                :: allow
                                :: Attr.style "width" "100%"
                                :: annotation "lia-audio" attr
                                |> titleAndAlt config alt_ title_
                                |> addLazyLoading config.visible
                            )
                            []

                      else
                        audio
                            (toAttribute attr |> titleAndAlt config alt_ title_)
                            { url = url_
                            , controls = True
                            , preload = "none"
                            , errorHandling = True
                            }
                    ]

        Movie alt_ ( tube, url_ ) title_ ->
            if tube then
                figure config title_ Nothing "iframe" <|
                    Html.div [ Attr.class "lia-iframe-wrapper" ]
                        [ printLink config alt_ title_ url_
                        , Html.iframe
                            (Attr.src (addTranslation config url_)
                                :: Attr.attribute "allowfullscreen" ""
                                :: allow
                                :: toAttribute attr
                                |> titleAndAlt config alt_ title_
                                |> addLazyLoading config.visible
                            )
                            (viewer config alt_)
                        ]

            else
                figure config title_ Nothing "movie" <|
                    -- This fixes if multiple videos appear on different sites, but on the same
                    -- position, then only the attributes are changed, which does not affect the
                    -- video at all. By using Html.Keyed the system is forced to update the
                    -- entire video tag.
                    Html.div []
                        [ printLink config alt_ title_ url_
                        , Html.Keyed.node "div"
                            [ Attr.class "lia-video-wrapper" ]
                            [ ( url_
                              , Html.video
                                    (Attr.controls True
                                        :: Attr.attribute "preload" "none"
                                        :: toAttribute attr
                                        |> titleAndAlt config alt_ title_
                                    )
                                    [ Html.source [ Attr.src url_, onError "video" url_ ] [] ]
                              )
                            ]
                        ]

        Embed alt_ url title_ ->
            Html.figure [ Attr.class "lia-figure", Attr.style "height" "auto", Attr.style "width" "100%" ]
                [ Html.div [ Attr.class "lia-figure__media" ]
                    [ printLink config alt_ title_ url
                    , oembed config.oEmbed attr url
                    , Html.figcaption [ Attr.class "lia-figure__caption" ] <|
                        case title_ of
                            Just sub ->
                                viewer config sub

                            Nothing ->
                                [ Html.a
                                    [ Attr.class "lia-link"
                                    , Attr.href url
                                    , Attr.target "blank_"
                                    ]
                                    [ Html.text url ]
                                ]
                    ]
                ]

        Preview_Lia url ->
            Html.node "preview-lia"
                (Attr.attribute "src" url :: annotation "" attr)
                []

        Preview_Link url ->
            Html.Keyed.node "preview-link"
                (Attr.attribute "src" url :: annotation "" attr)
                []

        QR_Link url title_ ->
            [ Html.Lazy.lazy2 qrCode config.lang url ]
                |> Html.a
                    (Attr.href url
                        :: Attr.style "width" "300px"
                        :: Attr.style "display" "inline-block"
                        :: Attr.style "background-color" "white"
                        :: annotation "lia-link" attr
                        |> CList.addWhen (title config title_)
                    )
                |> figure config title_ (Just 300) "image"


{-| An audio element, keyed by its url, so that it gets replaced if the url
changes.
-}
audio :
    List (Attribute msg)
    ->
        { url : String
        , controls : Bool
        , preload : String
        , errorHandling : Bool
        }
    -> Html msg
audio attr settings =
    Html.Keyed.node "span"
        []
        [ ( settings.url
          , Html.audio
                (Attr.controls settings.controls
                    :: Attr.preload settings.preload
                    :: attr
                )
                [ Html.source
                    ([ Attr.src settings.url ]
                        |> CList.addIf settings.errorHandling (onError "audio" settings.url)
                    )
                    []
                ]
          )
        ]


{-| **@private:** Add the current language to YouTube videos.
-}
addTranslation : Config sub -> String -> String
addTranslation config url_ =
    if String.startsWith website.youtube url_ then
        url_
            ++ (if String.contains "?" url_ then
                    "&hl="

                else
                    "?hl="
               )
            ++ (config.translations
                    |> Maybe.map .new
                    |> Maybe.withDefault (Translations.baseLang config.lang)
               )

    else
        url_


{-| **@private:** A link to the media, which is only visible in print.
-}
printLink : Config sub -> Inlines -> Maybe Inlines -> String -> Html (Msg sub)
printLink config alt_ title_ url_ =
    Html.a
        ([ Attr.class "lia-link lia-print-only"
         , Attr.href url_
         ]
            |> CList.addWhen (title config title_)
        )
        (viewer config alt_)


{-| **@private:** The `lia-embed` web component, which loads oEmbed content.
-}
oembed : Maybe { maxwidth : Int, maxheight : Int, scale : Float, thumbnail : Bool } -> Parameters -> String -> Html msg
oembed option attr url =
    Html.node "lia-embed"
        [ url
            |> JE.string
            |> Attr.property "url"
        , option
            |> Maybe.map
                (\o ->
                    if o.maxwidth > 0 then
                        String.fromInt o.maxwidth ++ "px"

                    else
                        "100%"
                )
            |> Maybe.withDefault "100%"
            |> Attr.style "width"
        , option
            |> Maybe.map
                (\o ->
                    if o.maxheight > 0 then
                        String.fromInt o.maxheight ++ "px"

                    else
                        "auto"
                )
            |> Maybe.withDefault "auto"
            |> Attr.style "height"
        , Attr.style "display" "inline-block"
        , Attr.style "max-height" "100%"
        , option
            |> Maybe.map .maxwidth
            |> Maybe.withDefault 0
            |> JE.int
            |> Attr.property "maxwidth"
        , option
            |> Maybe.map .maxheight
            |> Maybe.withDefault 0
            |> JE.int
            |> Attr.property "maxheight"
        , option
            |> Maybe.map .thumbnail
            |> Maybe.withDefault False
            |> JE.bool
            |> Attr.property "thumbnail"
        , option
            |> Maybe.map (.scale >> String.fromFloat >> Attr.attribute "scale")
            |> Maybe.withDefault (Attr.class "")
        , attr
            |> List.map (Tuple.mapSecond JE.string)
            |> JE.object
            |> JE.encode 0
            |> Attr.attribute "data-attributes"
        ]
        []


{-| **@private:** Links get a preview tooltip, if tooltips are enabled and if
they do not point to a section of the course.
-}
view_url : Config sub -> Inlines -> String -> Maybe Inlines -> Parameters -> Html (Msg sub)
view_url config alt_ url_ title_ attr =
    if not config.tooltips || String.startsWith "#" url_ then
        link config alt_ url_ title_ attr

    else
        Html.Keyed.node "span"
            []
            [ ( url_
              , Html.node "preview-link"
                    [ Attr.attribute "src" url_
                    , config.light
                        |> JE.bool
                        |> Attr.property "light"
                    ]
                    [ link config alt_ url_ title_ attr ]
              )
            ]


{-| **@private:** External links are opened in a new tab.
-}
link : Config sub -> Inlines -> String -> Maybe Inlines -> Parameters -> Html (Msg sub)
link config alt_ url_ title_ attr =
    Html.a
        (Attr.href url_
            :: Attr.target
                (if String.startsWith "#" url_ then
                    ""

                 else
                    "_blank"
                )
            :: annotation "lia-link" attr
            |> CList.addWhen (title config title_)
        )
        (viewer config alt_)


{-| Lazy, because encoding the QR matrix is expensive and would otherwise run on
every frame.
-}
qrCode : Lang -> String -> Html msg
qrCode lang url =
    url
        |> QRCode.fromString
        |> Result.map (QRCode.toSvg [ A11y_Aria.label <| Translations.qrCode lang ++ ": " ++ url ])
        |> Result.withDefault (Html.text (Translations.qrErr lang))
