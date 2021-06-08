module Lia.Utils exposing
    ( array_getLast
    , array_setLast
    , blockKeydown
    , btn
    , btnIcon
    , focus
    , get
    , icon
    , modal
    , noTranslate
    , onEnter
    , onKeyDown
    , toEscapeString
    , toJSstring
    )

import Accessibility.Key as A11y_Key
import Accessibility.Role as A11y_Role
import Accessibility.Widget as A11y_Widget
import Array exposing (Array)
import Browser.Dom as Dom
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as JD
import Task


{-| Convert JavaScript string escapes for backspace to elm escaped strings:

    toJSstring "javascript \\ escape" == "javascript \\\\ escape"

-}
toJSstring : String -> String
toJSstring =
    String.split "\\" >> String.join "\\\\"


{-| Convert common JavaScript string escapes elm escapes:

    toEscapeString "javascript \" \n" == "javascript \\\" \\n"

-}
toEscapeString : String -> String
toEscapeString str =
    str
        |> String.replace "\"" "\\\""
        |> String.replace "'" "\\'"
        |> String.replace "`" "\\`"
        |> String.replace "\n" "\\n"


onKeyDown : (Int -> msg) -> Html.Attribute msg
onKeyDown tagger =
    Event.stopPropagationOn "keydown"
        (JD.map (\x -> ( x, True )) (JD.map tagger Event.keyCode))


{-| Avoid event bubbling. Especially key-press left or right should be handled
by some elements itself and not result in a section-switch. Thus, on global
scale the left and right arrow keys should be used in slide-navigation, but
locally it must be surpressed in text inputs, search fields, etc.
-}
blockKeydown : msg -> Html.Attribute msg
blockKeydown =
    stopPropagationOn "keydown"


stopPropagationOn : String -> msg -> Html.Attribute msg
stopPropagationOn name msg =
    Event.stopPropagationOn name (JD.succeed ( msg, True ))


{-| Get the ith element of a list:

    get 2 [ 1, 2, 3, 4, 5 ] == Just 3

-}
get : Int -> List x -> Maybe x
get i list =
    case list of
        [] ->
            Nothing

        r :: rs ->
            if i <= 0 then
                Just r

            else
                get (i - 1) rs


isEnter : msg -> Int -> JD.Decoder msg
isEnter msg code =
    if code == 13 then
        JD.succeed msg

    else
        JD.fail "not ENTER"


{-| Release a message if the user hits enter.
-}
onEnter : msg -> Html.Attribute msg
onEnter msg =
    JD.andThen (isEnter msg) Event.keyCode
        |> Event.on "keyup"


{-| Render a transparent button with an icon that complies with a11y standards.
-}
btnIcon :
    { title : String
    , tabbable : Bool
    , msg : Maybe msg
    , icon : String
    }
    -> List (Html.Attribute msg)
    -> Html msg
btnIcon config attr =
    btn config
        attr
        [ icon config.icon
            [ Attr.class "lia-btn__icon" ]
        ]


{-| Render a button that must at least have a title, an onClick event and be tabbable.
If there is no message defined, then the key is disabled.
-}
btn :
    { config
        | title : String
        , tabbable : Bool
        , msg : Maybe msg
    }
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
btn { title, tabbable, msg } =
    List.append
        [ Attr.class "lia-btn"
        , msg
            |> Maybe.map Event.onClick
            |> Maybe.withDefault (Attr.disabled True)
        , A11y_Key.tabbable tabbable
        , A11y_Widget.hidden (not tabbable)
        , Attr.title title
        ]
        >> Html.button


{-| To be used for button icons ...
-}
icon : String -> List (Attribute msg) -> Html msg
icon class attributes =
    Html.i
        (List.append
            [ A11y_Widget.hidden True
            , Attr.class "icon"
            , Attr.class class
            ]
            attributes
        )
        []


focus : msg -> String -> Cmd msg
focus msg =
    Dom.focus >> Task.attempt (always msg)


{-| Create custom modals, which overlay the entire view.
-}
modal : msg -> Maybe (List (Html msg)) -> List (Html msg) -> Html msg
modal msgClose controls content =
    Html.div
        [ Attr.class "lia-modal"
        , A11y_Widget.modal True
        , A11y_Role.dialog
        ]
        [ Html.div [ Attr.class "lia-modal__inner" ]
            [ Html.div [ Attr.class "lia-modal__close" ]
                [ btnIcon
                    { icon = "icon-close"
                    , msg = Just msgClose
                    , tabbable = True
                    , title = "close modal"
                    }
                    [ Attr.class "lia-btn--transparent"
                    , Attr.id "lia-modal__close"
                    , A11y_Key.onKeyDown [ A11y_Key.escape msgClose ]
                    ]
                ]
            , content
                |> Html.div [ Attr.class "lia-modal__content" ]
            , controls
                |> Maybe.map (Html.div [ Attr.class "lia-modal__controls" ])
                |> Maybe.withDefault (Html.text "")
            ]
        , Html.div
            [ Attr.class "lia-modal__outer"
            , Event.onClick msgClose
            ]
            []
        ]


array_getLast : Array a -> Maybe a
array_getLast array =
    Array.get (Array.length array - 1) array


array_setLast : a -> Array a -> Array a
array_setLast a array =
    Array.set (Array.length array - 1) a array


{-| Add indications for google-translate and others to not translate this element.
-}
noTranslate : List (Attribute msg) -> List (Attribute msg)
noTranslate =
    List.append [ Attr.attribute "class" "notranslate", Attr.attribute "translate" "no" ]
