module Lia.Markdown.Footnote.View exposing
    ( block
    , byKey
    , inline
    )

import Accessibility.Aria as A11y_Aria
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Encode as JE
import Lia.Markdown.Footnote.Model exposing (Model)
import Lia.Markdown.Types as Markdown


{-| The footnote mark `[key]`. The inline view cannot send section messages,
therefore a click opens the footnote via `window.LIA.showFootnote` and the
`footnote` port.
-}
inline : String -> List (Html.Attribute msg) -> Html msg
inline key attr =
    Html.sup []
        [ Html.button
            (attr
                ++ [ Attr.style "padding" "2px"
                   , Attr.class "lia-btn lia-btn--transparent text-highlight"
                   , Attr.attribute "onclick" ("window.LIA.showFootnote(" ++ JE.encode 0 (JE.string key) ++ ");")
                   , Attr.id (byKey key)
                   , A11y_Aria.describedBy [ by key ]
                   ]
            )
            [ braces key ]
        ]


{-| All footnotes of a section as a definition list at its end, nothing if
there are none (styles in `_components.footnote.scss`).
-}
block : (Markdown.Block -> Html msg) -> Model -> Html msg
block fn model =
    if Dict.isEmpty model then
        Html.text ""

    else
        Html.footer [ Attr.attribute "role" "doc-endnotes" ]
            [ model
                |> Dict.toList
                |> List.map (definition fn)
                |> Html.dl [ Attr.class "lia-footnotes" ]
            ]


definition : (Markdown.Block -> Html msg) -> ( String, Markdown.Blocks ) -> Html msg
definition fn ( key, body ) =
    Html.div []
        [ Html.dt [ Attr.id (by key) ] [ braces key ]
        , Html.dd [] (List.map fn body)
        ]


braces : String -> Html msg
braces key =
    Html.text ("[" ++ key ++ "]")


{-| Id of the footnote definition in the table.
-}
by : String -> String
by =
    (++) "footnote-"


{-| Id of the footnote mark, the focus returns here when the modal is closed.
-}
byKey : String -> String
byKey =
    (++) "footnote-key-"
