module Index.View.Popup exposing (..)

import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Lia.Utils exposing (btnIcon)
import Library.Group as Group


groupID : String
groupID =
    "lia-popup"


{-| A custom message type for the popup.
-}
view : { escape : msg, text : String, action : { msg : msg, text : String } } -> Html msg
view { escape, text, action } =
    Html.div
        [ -- Use ARIA attributes to define the dialog.
          A11y_Role.dialog
        , Attr.style "position" "absolute"
        , Attr.style "min-width" "250px"
        , Attr.style "background-color" "#fff"
        , Attr.style "border" "1px solid #ddd"
        , Attr.style "box-shadow" "0 4px 8px rgba(0,0,0,0.1)"
        , Attr.style "padding" "16px"
        , Attr.style "border-radius" "8px"
        , Attr.style "z-index" "100"
        , Attr.style "bottom" "1rem"
        , Attr.tabindex 0
        , Attr.id groupID
        , A11y_Key.onKeyDown
            [ A11y_Key.escape escape
            , A11y_Key.enter action.msg
            ]
        , Group.id groupID
        , Group.blur (always escape)
        ]
        [ Html.p
            [ Group.id groupID
            , Group.blur (always escape)
            , Attr.style "margin-bottom" "16px"
            , Attr.style "font-size" "16px"
            , Attr.style "color" "#333"
            ]
            [ Html.text text ]
        , Html.button
            [ Event.onClick action.msg
            , Attr.tabindex 0
            , Group.id groupID
            , Group.blur (always escape)
            , Attr.style "padding" "10px 20px"
            , Attr.style "background-color" "#d9534f"
            , Attr.style "color" "#fff"
            , Attr.style "border" "none"
            , Attr.style "border-radius" "4px"
            , Attr.style "cursor" "pointer"
            ]
            [ Html.text action.text ]
        , btnIcon
            { title = "abort"
            , tabbable = True
            , msg = Just escape
            , icon = "icon-close"
            }
            [ Group.id groupID
            , Attr.class "lia-btn--transparent px-0 py-0"
            , Attr.style "position" "absolute"
            , Attr.style "right" "2px"
            , Attr.style "top" "-3px"
            , Group.blur (always escape)
            ]
        ]
