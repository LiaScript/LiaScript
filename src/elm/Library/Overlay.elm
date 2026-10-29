module Library.Overlay exposing
    ( Model, init
    , Msg, update
    , view
    )

{-| A round overlay (used for video comments) that can be moved and resized
with mouse, touch or arrow keys. A double-click on the center or on the resize
handle makes it follow the mouse until the next double-click or ESC.

Positions are measured from the right edge, so `x` grows to the left.

@docs Model, init
@docs Msg, update
@docs view

-}

import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (attribute, style, title)
import Html.Events exposing (on, onBlur, preventDefaultOn)
import Json.Decode as Decode exposing (Decoder)



-- MODEL


type Mode
    = Move
    | Resize
    | FollowMouse Position -- offset between pointer and position
    | FollowResize Position -- offset between pointer and size


type alias Position =
    { x : Int
    , y : Int
    }


type alias Size =
    { width : Int
    , height : Int
    }


{-| Where a drag or resize started, `from` is the position or size at that time.
-}
type alias Drag a =
    { start : Position
    , from : a
    }


{-| -}
type alias Model =
    { position : Position
    , size : Size
    , drag : Maybe (Drag Position)
    , resize : Maybe (Drag Size)
    , mode : Mode
    }


{-| 200x200 pixels, 20 pixels from the right and 100 from the top.
-}
init : Model
init =
    { position = Position 20 100
    , size = Size 200 200
    , drag = Nothing
    , resize = Nothing
    , mode = Move
    }



-- UPDATE


{-| -}
type Msg
    = DragStart Position
    | DragAt Position
    | DragEnd
    | ResizeStart Position
    | ResizeAt Position
    | ResizeEnd
    | ArrowMove Direction
    | ArrowResize Direction
    | ToggleMode
    | Ignore
    | DoubleClick Position
    | DoubleClickResize Position
    | MouseMoveFollow Position
    | MouseResizeFollow Position
    | ExitFollowMode
    | LostFocus


type Direction
    = Up
    | Down
    | Left
    | Right


{-| -}
update : Msg -> Model -> Model
update msg model =
    case msg of
        DragStart pos ->
            { model | drag = Just (Drag pos model.position), mode = Move }

        DragAt pos ->
            case model.drag of
                Just { start, from } ->
                    { model | position = Position (from.x + start.x - pos.x) (from.y + pos.y - start.y) }

                Nothing ->
                    model

        DragEnd ->
            { model | drag = Nothing }

        ResizeStart pos ->
            { model | resize = Just (Drag pos model.size), mode = Resize }

        ResizeAt pos ->
            case model.resize of
                Just { start, from } ->
                    { model | size = Size (max 100 (from.width + pos.x - start.x)) (max 100 (from.height + pos.y - start.y)) }

                Nothing ->
                    model

        ResizeEnd ->
            { model | resize = Nothing }

        ArrowMove direction ->
            { model | position = movePosition model.position direction }

        ArrowResize direction ->
            { model | size = resizeWithArrows model.size direction }

        ToggleMode ->
            { model | mode = toggleMode model.mode }

        DoubleClick pos ->
            case model.mode of
                FollowMouse _ ->
                    { model | mode = Move }

                _ ->
                    { model | mode = FollowMouse (Position (pos.x + model.position.x) (pos.y - model.position.y)) }

        DoubleClickResize pos ->
            case model.mode of
                FollowResize _ ->
                    { model | mode = Resize }

                _ ->
                    { model | mode = FollowResize (Position (pos.x - model.size.width) (pos.y - model.size.height)) }

        MouseMoveFollow pos ->
            case model.mode of
                FollowMouse offset ->
                    { model | position = Position (offset.x - pos.x) (pos.y - offset.y) }

                _ ->
                    model

        MouseResizeFollow pos ->
            case model.mode of
                FollowResize offset ->
                    { model | size = Size (max 100 (pos.x - offset.x)) (max 100 (pos.y - offset.y)) }

                _ ->
                    model

        ExitFollowMode ->
            release model

        LostFocus ->
            release model

        Ignore ->
            model


{-| **@private:** Leave a follow mode.
-}
release : Model -> Model
release model =
    case model.mode of
        FollowMouse _ ->
            { model | mode = Move }

        FollowResize _ ->
            { model | mode = Resize }

        _ ->
            model


{-| **@private:** Arrow keys move by 10 pixels (left increases `x`).
-}
movePosition : Position -> Direction -> Position
movePosition pos direction =
    case direction of
        Up ->
            { pos | y = pos.y - 10 }

        Down ->
            { pos | y = pos.y + 10 }

        Left ->
            { pos | x = pos.x - 10 }

        Right ->
            { pos | x = pos.x + 10 }


{-| **@private:** Arrow keys resize by 10 pixels, but not below 100.
-}
resizeWithArrows : Size -> Direction -> Size
resizeWithArrows size direction =
    case direction of
        Up ->
            { size | height = max 100 (size.height - 10) }

        Down ->
            { size | height = size.height + 10 }

        Left ->
            { size | width = max 100 (size.width - 10) }

        Right ->
            { size | width = size.width + 10 }


{-| **@private:** Switch between moving and resizing, a follow mode falls back
to the mode it follows.
-}
toggleMode : Mode -> Mode
toggleMode mode =
    case mode of
        Move ->
            Resize

        Resize ->
            Move

        FollowMouse _ ->
            Move

        FollowResize _ ->
            Resize



-- VIEW


{-| Render the overlay with `inside` as its content (its events are ignored),
`attr` are added to the overlay itself. With `nativeClicks` the center of the
overlay is not draggable, such that clicks reach the content (e.g. the play
button of an embedded video), it can still be dragged at its ring.
-}
view : Bool -> List (Attribute Msg) -> Model -> Html a -> Html Msg
view nativeClicks attr model inside =
    let
        following =
            model.mode /= Move && model.mode /= Resize
    in
    div []
        [ if model.drag /= Nothing || model.resize /= Nothing || following then
            -- catches the pointer outside of the overlay while dragging
            div
                (style "position" "fixed"
                    :: style "top" "0"
                    :: style "left" "0"
                    :: style "width" "100vw"
                    :: style "height" "100vh"
                    :: style "z-index" "40"
                    :: style "background" "transparent"
                    :: pointer model
                )
                []

          else
            text ""
        , div
            (List.append
                (style "position" "absolute"
                    :: style "z-index" "150"
                    :: style "background" "#000"
                    :: onKeyDown model.mode
                    :: attribute "tabindex" "0"
                    :: style "right" (px model.position.x)
                    :: style "top" (px model.position.y)
                    :: style "width" (px model.size.width)
                    :: style "height" (px model.size.height)
                    :: style "border"
                        ("5px solid "
                            ++ (case model.mode of
                                    FollowMouse _ ->
                                        "#ff5722"

                                    FollowResize _ ->
                                        "#4CAF50"

                                    _ ->
                                        "#d3d3d3"
                               )
                        )
                    :: style "border-radius" "50%"
                    :: style "display" "flex"
                    :: style "flex-direction" "column"
                    :: style "justify-content" "center"
                    :: style "align-items" "center"
                    :: style "overflow" "hidden"
                    :: style "touch-action" "none"
                    :: attribute "role" "region"
                    :: attribute "aria-label" ("Video playback controls - Current mode: " ++ modeName model.mode)
                    :: attribute "aria-live" "polite"
                    :: pointer model
                    ++ [ onBlur LostFocus ]
                )
                attr
            )
            [ Html.map (always Ignore) inside
            , div
                ((if nativeClicks then
                    -- a hole in the center, only the ring stays draggable
                    [ style "clip-path" "polygon(0% 0%, 0% 100%, 15% 100%, 15% 15%, 85% 15%, 85% 85%, 15% 85%, 15% 100%, 100% 100%, 100% 0%)" ]

                  else
                    []
                 )
                    ++ [ style "position" "absolute"
                       , style "width" "100%"
                       , style "padding" "10px"
                       , style "height" "100%"
                       , style "cursor" (iif (isFollowMove model.mode) "grabbing" "move")
                       , style "color" "#fff"
                       , style "text-align" "center"
                       , style "top" "0px"
                       , style "right" "0px"
                       , onPointer "mousedown" DragStart
                       , onTouch "touchstart" DragStart
                       , onPointer "dblclick" DoubleClick
                       , -- mouse only, the keyboard controls the overlay itself
                         attribute "aria-hidden" "true"
                       , title (iif (isFollowMove model.mode) "double-click to release" "drag or double-click video comment")
                       ]
                )
                []
            , div
                [ style "width" "8%"
                , style "height" "8%"
                , style "background" (iif (isFollowResize model.mode) "#4CAF50" "#d3d3d3")
                , style "position" "absolute"
                , style "right" "10%"
                , style "bottom" "10%"
                , style "cursor" (iif (isFollowResize model.mode) "grabbing" "se-resize")
                , style "border-radius" "50%"
                , onPointer "mousedown" ResizeStart
                , onTouch "touchstart" ResizeStart
                , onPointer "dblclick" DoubleClickResize
                , attribute "aria-hidden" "true"
                , title (iif (isFollowResize model.mode) "double-click to stop resize following" "resize or double-click to follow resize")
                ]
                []
            , div
                [ style "position" "absolute"
                , style "left" "-9999px"
                , style "top" "auto"
                , style "width" "1px"
                , style "height" "1px"
                , style "overflow" "hidden"
                ]
                [ text (description model) ]
            ]
        ]


{-| **@private:** Moving and releasing the pointer drags, resizes or follows,
depending on what is going on.
-}
pointer : Model -> List (Attribute Msg)
pointer model =
    let
        moveMsg pos =
            if model.drag /= Nothing then
                DragAt pos

            else if model.resize /= Nothing then
                ResizeAt pos

            else
                case model.mode of
                    FollowMouse _ ->
                        MouseMoveFollow pos

                    FollowResize _ ->
                        MouseResizeFollow pos

                    _ ->
                        Ignore

        endMsg =
            if model.drag /= Nothing then
                DragEnd

            else if model.resize /= Nothing then
                ResizeEnd

            else
                Ignore
    in
    [ onPointer "mousemove" moveMsg
    , on "mouseup" (Decode.succeed endMsg)
    , onTouch "touchmove" moveMsg
    , on "touchend" (Decode.succeed endMsg)
    ]


{-| **@private:** The screen reader text.
-}
description : Model -> String
description model =
    let
        keys action =
            ". Use arrow keys to "
                ++ action
                ++ " the video overlay. Press Enter to switch modes. Double-click on center to make overlay follow mouse movement. Double-click on resize handle to make overlay resize with mouse. "
    in
    "Current mode: "
        ++ modeName model.mode
        ++ (case model.mode of
                Move ->
                    keys "move"

                Resize ->
                    keys "resize"

                FollowMouse _ ->
                    ". Overlay is following mouse movement. Double-click or press ESC to release. "

                FollowResize _ ->
                    ". Overlay is following mouse for resizing. Double-click or press ESC to release. "
           )
        ++ "Current position: x: "
        ++ String.fromInt model.position.x
        ++ ", y: "
        ++ String.fromInt model.position.y
        ++ ". Current size: width: "
        ++ String.fromInt model.size.width
        ++ ", height: "
        ++ String.fromInt model.size.height


modeName : Mode -> String
modeName mode =
    case mode of
        Move ->
            "Move"

        Resize ->
            "Resize"

        FollowMouse _ ->
            "Follow Mouse Movement"

        FollowResize _ ->
            "Follow Mouse Resize"


isFollowMove : Mode -> Bool
isFollowMove mode =
    case mode of
        FollowMouse _ ->
            True

        _ ->
            False


isFollowResize : Mode -> Bool
isFollowResize mode =
    case mode of
        FollowResize _ ->
            True

        _ ->
            False


iif : Bool -> a -> a -> a
iif condition a b =
    if condition then
        a

    else
        b


px : Int -> String
px n =
    String.fromInt n ++ "px"


{-| **@private:** A mouse event with its rounded page coordinates.
-}
onPointer : String -> (Position -> Msg) -> Attribute Msg
onPointer event toMsg =
    on event (Decode.map toMsg position)


{-| **@private:** A touch event with the page coordinates of the first touch,
the default (scrolling) is prevented.
-}
onTouch : String -> (Position -> Msg) -> Attribute Msg
onTouch event toMsg =
    preventDefaultOn event (Decode.map (\pos -> ( toMsg pos, True )) (Decode.at [ "touches", "0" ] position))


position : Decoder Position
position =
    Decode.map2 Position
        (Decode.field "pageX" Decode.float |> Decode.map round)
        (Decode.field "pageY" Decode.float |> Decode.map round)


{-| **@private:** Enter toggles move/resize, ESC leaves a follow mode, arrow
keys move or resize (left/right swapped, since `x` is measured from the right).
-}
onKeyDown : Mode -> Attribute Msg
onKeyDown mode =
    let
        handled msg =
            { message = msg, preventDefault = True, stopPropagation = True }

        arrow direction =
            handled <|
                case mode of
                    Move ->
                        ArrowMove direction

                    Resize ->
                        ArrowResize direction

                    _ ->
                        Ignore
    in
    Html.Events.custom "keydown" <|
        Decode.map
            (\keyCode ->
                case keyCode of
                    13 ->
                        handled ToggleMode

                    27 ->
                        handled ExitFollowMode

                    37 ->
                        arrow Right

                    38 ->
                        arrow Up

                    39 ->
                        arrow Left

                    40 ->
                        arrow Down

                    _ ->
                        { message = Ignore, preventDefault = False, stopPropagation = False }
            )
            Html.Events.keyCode
