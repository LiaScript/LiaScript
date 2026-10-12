module Library.SplitPane exposing
    ( State, init
    , Msg, update, subscriptions
    , Visible(..), view
    )

{-| Two panes side by side with a draggable splitter between them, a trimmed
down version of [elm-split-pane](https://github.com/doodledood/elm-split-pane):
horizontal only, the splitter position is a share of the width between 0 and 1.

@docs State, init
@docs Msg, update, subscriptions
@docs Visible, view

-}

import Browser.Events
import Html exposing (Attribute, Html, div, span)
import Html.Attributes exposing (class, style)
import Html.Events
import Json.Decode as JD



-- MODEL


{-| The splitter position as a share of the width and, while the splitter is
dragged, the width of the container and the last x-coordinate of the pointer.
-}
type State
    = State
        { position : Float
        , drag : Maybe { width : Int, x : Int }
        }


{-| Which of the two panes are shown, only `Both` shows the splitter.
-}
type Visible
    = Both
    | OnlyFirst
    | OnlySecond


{-| Both panes get half of the width.
-}
init : State
init =
    State { position = 0.5, drag = Nothing }



-- UPDATE


{-| Internal messages.
-}
type Msg
    = SplitterClick { x : Maybe Int, width : Int }
    | SplitterMove Int
    | SplitterLeftAlone


{-| Start, follow and end dragging the splitter.
-}
update : Msg -> State -> State
update msg (State state) =
    case ( state.drag, msg ) of
        ( Nothing, SplitterClick { x, width } ) ->
            State { state | drag = Just { width = width, x = Maybe.withDefault (width // 2) x } }

        ( Just _, SplitterLeftAlone ) ->
            State { state | drag = Nothing }

        ( Just { width, x }, SplitterMove newX ) ->
            State
                { position =
                    -- not `clamp`, it turns NaN (width 0) into 1 instead of 0
                    state.position
                        + toFloat (newX - x)
                        / toFloat width
                        |> max 0
                        |> min 1
                , drag = Just { width = width, x = newX }
                }

        _ ->
            State state


{-| Mouse moves and releases are tracked on the whole document while dragging.
-}
subscriptions : State -> Sub Msg
subscriptions (State state) =
    case state.drag of
        Just _ ->
            Sub.batch
                [ Browser.Events.onMouseMove (JD.map SplitterMove (pair "pageX" "pageY"))
                , Browser.Events.onMouseUp (JD.map (always SplitterLeftAlone) (pair "pageX" "pageY"))
                ]

        Nothing ->
            Sub.none



-- VIEW


{-| Render the two panes and the splitter, `toMsg` wraps the splitter events.
-}
view : Visible -> (Msg -> msg) -> Html msg -> Html msg -> State -> Html msg
view visible toMsg firstView secondView (State state) =
    div
        [ class "pane-container"
        , style "overflow" "hidden"
        , style "display" <|
            if visible == Both then
                "flex"

            else
                "block"
        , style "flexDirection" "row"
        , style "justifyContent" "center"
        , style "alignItems" "center"
        , style "width" "100%"
        , style "height" "100%"
        , style "boxSizing" "border-box"
        ]
        [ div
            (class "pane-first-view"
                :: paneStyle (visible /= OnlySecond)
                    (if visible == Both then
                        String.fromFloat state.position

                     else
                        "1 1 0%"
                    )
            )
            [ firstView ]
        , viewSplitter visible |> Html.map toMsg
        , div
            (class "pane-second-view"
                :: paneStyle (visible /= OnlyFirst)
                    (if visible == OnlySecond then
                        "1 1 0%"

                     else
                        String.fromFloat (1 - state.position)
                    )
            )
            [ secondView ]
        ]


{-| **@private:** Style of a pane with its `flex` value.
-}
paneStyle : Bool -> String -> List (Attribute msg)
paneStyle visible flex =
    [ style "display" <|
        if visible then
            "flex"

        else
            "none"
    , style "flex" flex
    , style "width" "100%"
    , style "height" "100%"
    , style "overflow" "hidden"
    , style "boxSizing" "border-box"
    , style "position" "relative"
    ]


{-| **@private:** The splitter, hidden unless both panes are shown.
-}
viewSplitter : Visible -> Html Msg
viewSplitter visible =
    span
        ([ on "mousedown" False click
         , on "touchstart" True click
         , on "touchend" True (JD.map (always SplitterLeftAlone) parentWidth)
         , on "touchmove" True (JD.map2 always (JD.map SplitterMove clientX) parentWidth)
         , on "touchcancel" True (JD.map (always SplitterLeftAlone) parentWidth)
         , style "background" "#000"
         , style "boxSizing" "border-box"
         , style "opacity" ".2"
         , style "zIndex" "1"
         , style "webkitUserSelect" "none"
         , style "mozUserSelect" "none"
         , style "userSelect" "none"
         , style "backgroundClip" "padding-box"
         , style "width" "11px"
         , style "height" "100%"
         , style "margin" "0 -5px"
         , style "borderLeft" "5px solid rgba(255, 255, 255, 0)"
         , style "borderRight" "5px solid rgba(255, 255, 255, 0)"
         ]
            ++ (if visible == Both then
                    [ style "cursor" "col-resize", style "display" "" ]

                else
                    [ style "display" "none" ]
               )
        )
        []


{-| **@private:** A handler that always prevents the default and only stops
the propagation of touch events.
-}
on : String -> Bool -> JD.Decoder Msg -> Attribute Msg
on event stop =
    JD.map (\msg -> { message = msg, preventDefault = True, stopPropagation = stop })
        >> Html.Events.custom event


{-| **@private:** Grab the splitter, the mouse position is the anchor (touch
events have no top level `clientX`, they start in the middle).
-}
click : JD.Decoder Msg
click =
    JD.map2 (\x width -> SplitterClick { x = x, width = width })
        (JD.maybe (JD.field "clientX" JD.int))
        parentWidth


{-| **@private:** The x-coordinate of the first touch, or of the mouse, each
only if x and y are integers, otherwise 0.
-}
clientX : JD.Decoder Int
clientX =
    JD.oneOf
        [ JD.at [ "touches", "0" ] (pair "clientX" "clientY")
        , pair "clientX" "clientY"
        , JD.succeed 0
        ]


{-| **@private:** The value of field `x`, if field `y` is an integer too.
-}
pair : String -> String -> JD.Decoder Int
pair x y =
    JD.map2 always (JD.field x JD.int) (JD.field y JD.int)


{-| **@private:** The width of the container, which also has to report its height.
-}
parentWidth : JD.Decoder Int
parentWidth =
    JD.at [ "currentTarget", "parentElement" ] (pair "clientWidth" "clientHeight")
