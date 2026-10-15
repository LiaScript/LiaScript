module Index.View.Popup exposing (..)

import Accessibility.Aria as A11y_Aria
import Accessibility.Role as A11y_Role
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as JD
import Lia.Utils exposing (btnIcon)
import Library.Group as Group


groupID : String
groupID =
    "lia-popup"


{-| The abort button, which gets the focus when the popup opens, since the
action is destructive.
-}
cancelID : String
cancelID =
    "lia-popup-cancel"


{-| A custom message type for the popup.
-}
view : { escape : msg, text : String, action : { msg : msg, text : String } } -> Html msg
view { escape, text, action } =
    Html.div
        [ -- Use ARIA attributes to define the dialog.
          A11y_Role.alertDialog
        , A11y_Aria.label action.text
        , A11y_Aria.describedBy [ groupID ++ "-text" ]
        , Attr.style "position" "absolute"
        , Attr.style "min-width" "250px"
        , Attr.style "background-color" "#fff"
        , Attr.style "border" "1px solid #ddd"
        , Attr.style "box-shadow" "0 4px 8px rgba(0,0,0,0.1)"
        , Attr.style "padding" "16px"
        , Attr.style "border-radius" "8px"
        , Attr.style "z-index" "100"
        , Attr.style "bottom" "1rem"
        , Attr.tabindex -1
        , Attr.id groupID

        -- Enter is handled by the focused button only, otherwise it would
        -- trigger the action also on abort. Escape must not close a
        -- surrounding modal as well.
        , Event.custom "keydown"
            (JD.field "key" JD.string
                |> JD.andThen
                    (\key ->
                        if key == "Escape" then
                            JD.succeed
                                { message = escape
                                , stopPropagation = True
                                , preventDefault = False
                                }

                        else
                            JD.fail "no escape"
                    )
            )
        , Group.id groupID
        , Group.blur (always escape)
        ]
        [ Html.p
            [ Attr.id (groupID ++ "-text")
            , Group.id groupID
            , Group.blur (always escape)
            , Attr.style "margin-block-end" "16px"
            , Attr.style "font-size" "16px"
            , Attr.style "color" "#333"
            ]
            [ Html.text text ]
        , Html.button
            [ Event.onClick action.msg
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
            [ Attr.id cancelID
            , Group.id groupID
            , Attr.class "lia-btn--transparent px-0 py-0"
            , Attr.style "position" "absolute"
            , Attr.style "right" "2px"
            , Attr.style "top" "-3px"
            , Group.blur (always escape)
            ]
        ]
