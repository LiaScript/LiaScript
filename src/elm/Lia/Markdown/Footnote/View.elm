module Lia.Markdown.Footnote.View exposing
    ( block
    , byKey
    , inline
    )

import Accessibility.Aria as A11y_Aria
import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import I18n.Translations as Trans exposing (Lang)
import Json.Encode as JE
import Lia.Markdown.Footnote.Model exposing (Model)
import Lia.Markdown.Types as Markdown


{-| The footnote mark `[key]`. The inline view cannot send section messages,
therefore a click opens the footnote via `window.LIA.showFootnote` and the
`footnote` port.
-}
inline : Lang -> String -> List (Html.Attribute msg) -> Html msg
inline lang key attr =
    Html.sup []
        [ Html.button
            (attr
                ++ [ Attr.style "padding" "2px"
                   , Attr.class "lia-btn lia-btn--transparent text-highlight"
                   , Attr.attribute "onclick" ("window.LIA.showFootnote(" ++ JE.encode 0 (JE.string key) ++ ");")
                   , Attr.id (byKey key)

                   -- the text of the footnote, if the list is shown
                   , A11y_Aria.describedBy [ by key ]
                   ]
            )
            [ Html.span [ Attr.class "hidden-visually" ] [ Html.text (Trans.baseFootnote lang ++ " ") ]
            , braces key
            ]
        ]


{-| All footnotes of a section as a definition list at its end, nothing if
there are none (styles in `_components.footnote.scss`).
-}
block : Lang -> (Markdown.Block -> Html msg) -> Model -> Html msg
block lang fn model =
    if Dict.isEmpty model then
        Html.text ""

    else
        Html.section [ A11y_Aria.label (Trans.baseFootnotes lang) ]
            [ model
                |> Dict.toList
                |> List.map (definition fn)
                |> Html.dl [ Attr.class "lia-footnotes" ]
            ]


definition : (Markdown.Block -> Html msg) -> ( String, Markdown.Blocks ) -> Html msg
definition fn ( key, body ) =
    Html.div []
        [ Html.dt [] [ braces key ]
        , Html.dd [ Attr.id (by key) ] (List.map fn body)
        ]


braces : String -> Html msg
braces key =
    Html.text ("[" ++ key ++ "]")


{-| Id of the text of a footnote in the list, which describes its mark.
-}
by : String -> String
by =
    (++) "footnote-"


{-| Id of the footnote mark, the focus returns here when the modal is closed.
-}
byKey : String -> String
byKey =
    (++) "footnote-key-"
