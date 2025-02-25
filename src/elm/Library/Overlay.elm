module Library.Overlay exposing
    ( Model
    , Msg(..)
    , init
    , update
    , view
    )

import Html
    exposing
        ( Attribute
        , Html
        , div
        , text
        )
import Html.Attributes
    exposing
        ( attribute
        , style
        , tabindex
        , title
        )
import Html.Events
    exposing
        ( on
        , onBlur
        , preventDefaultOn
        )
import Json.Decode as Decode exposing (Decoder)



-- MODEL


type Mode
    = Move
    | Resize
    | FollowMouse Position -- Added new mode with the initial click position


type alias Position =
    { x : Int
    , y : Int
    }


type alias Size =
    { width : Int
    , height : Int
    }


type alias Drag =
    { start : Position
    , current : Position
    }


type alias Model =
    { position : Position
    , initialPosition : Position
    , size : Size
    , initialSize : Size
    , drag : Maybe Drag
    , resize : Maybe Drag
    , mode : Mode
    , followOffset : Maybe Position -- Added to store the offset from click to overlay position
    }


init : Model
init =
    { position = Position 20 100
    , initialPosition = Position 20 100
    , size = Size 200 200
    , initialSize = Size 200 200
    , drag = Nothing
    , resize = Nothing
    , mode = Move
    , followOffset = Nothing
    }



-- UPDATE


type Msg parentMsg
    = DragStart Position
    | DragAt Position
    | DragEnd
    | ResizeStart Position
    | ResizeAt Position
    | ResizeEnd
    | Foreign parentMsg
    | ArrowMove Direction
    | ArrowResize Direction
    | ToggleMode
    | Ignore
    | DoubleClick Position -- Added for double-click activation
    | MouseMoveFollow Position -- Added for mouse following
    | ExitFollowMode -- Added for exiting follow mode
    | LostFocus -- Added for when overlay loses focus


type Direction
    = Up
    | Down
    | Left
    | Right


update : Msg parentMsg -> Model -> ( Model, Cmd (Msg parentMsg), Maybe parentMsg )
update msg model =
    case msg of
        DragStart pos ->
            ( { model
                | drag = Just { start = pos, current = pos }
                , initialPosition = model.position
              }
            , Cmd.none
            , Nothing
            )

        DragAt pos ->
            ( { model
                | position = draggedPosition model pos
                , drag = Maybe.map (\{ start } -> { start = start, current = pos }) model.drag
              }
            , Cmd.none
            , Nothing
            )

        DragEnd ->
            ( { model | drag = Nothing }
            , Cmd.none
            , Nothing
            )

        ResizeStart pos ->
            ( { model
                | resize = Just { start = pos, current = pos }
                , initialSize = model.size
              }
            , Cmd.none
            , Nothing
            )

        ResizeAt pos ->
            ( { model
                | size = resizedSize model pos
                , resize = Maybe.map (\{ start } -> { start = start, current = pos }) model.resize
              }
            , Cmd.none
            , Nothing
            )

        ResizeEnd ->
            ( { model | resize = Nothing }
            , Cmd.none
            , Nothing
            )

        ArrowMove direction ->
            let
                newPosition =
                    movePosition model.position direction
            in
            ( { model | position = newPosition }, Cmd.none, Nothing )

        ArrowResize direction ->
            let
                newSize =
                    resizeWithArrows model.size direction
            in
            ( { model | size = newSize }, Cmd.none, Nothing )

        ToggleMode ->
            ( { model | mode = toggleMode model.mode }, Cmd.none, Nothing )

        DoubleClick pos ->
            ( case model.mode of
                FollowMouse _ ->
                    { model
                        | mode = Move
                        , followOffset = Nothing
                    }

                _ ->
                    { model
                        | mode = FollowMouse pos
                        , followOffset =
                            Just
                                -- Calculate the offset between click position and overlay position
                                (Position
                                    (pos.x + model.position.x)
                                    (pos.y - model.position.y)
                                )
                    }
            , Cmd.none
            , Nothing
            )

        MouseMoveFollow pos ->
            case model.mode of
                FollowMouse _ ->
                    -- Apply the offset to keep the initial click point under the cursor
                    let
                        newPosition =
                            case model.followOffset of
                                Just offset ->
                                    Position
                                        (offset.x - pos.x)
                                        -- Changed from subtraction to addition
                                        (pos.y - offset.y)

                                Nothing ->
                                    model.position
                    in
                    ( { model | position = newPosition }, Cmd.none, Nothing )

                _ ->
                    ( model, Cmd.none, Nothing )

        ExitFollowMode ->
            ( { model | mode = Move, followOffset = Nothing }, Cmd.none, Nothing )

        LostFocus ->
            -- When focus is lost, exit follow mode if active
            case model.mode of
                FollowMouse _ ->
                    ( { model | mode = Move, followOffset = Nothing }, Cmd.none, Nothing )

                _ ->
                    ( model, Cmd.none, Nothing )

        Foreign parentMsg ->
            ( model, Cmd.none, Just parentMsg )

        Ignore ->
            ( model, Cmd.none, Nothing )


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


toggleMode : Mode -> Mode
toggleMode mode =
    case mode of
        Move ->
            Resize

        Resize ->
            Move

        FollowMouse _ ->
            Move


draggedPosition : Model -> Position -> Position
draggedPosition model pos =
    case model.drag of
        Just { start } ->
            Position
                (model.initialPosition.x + (start.x - pos.x))
                (model.initialPosition.y + (pos.y - start.y))

        Nothing ->
            model.position


resizedSize : Model -> Position -> Size
resizedSize model pos =
    case model.resize of
        Just { start } ->
            Size
                (Basics.max 100 (model.initialSize.width + pos.x - start.x))
                (Basics.max 100 (model.initialSize.height + pos.y - start.y))

        Nothing ->
            model.size



-- VIEW
-- This background div covers the entire screen and is rendered only when dragging or resizing.


backgroundDiv : Model -> Html (Msg parentMsg)
backgroundDiv model =
    if model.drag /= Nothing || model.resize /= Nothing || isFollowMode model.mode then
        div
            [ style "position" "fixed"
            , style "top" "0"
            , style "left" "0"
            , style "width" "100vw"
            , style "height" "100vh"
            , style "z-index" "40"
            , style "background" "transparent"
            , tabindex 0
            , onMouseMove
                (\pos ->
                    if model.drag /= Nothing then
                        DragAt pos

                    else if model.resize /= Nothing then
                        ResizeAt pos

                    else if isFollowMode model.mode then
                        MouseMoveFollow pos

                    else
                        DragAt pos
                )
            , onMouseUp
                (if model.drag /= Nothing then
                    DragEnd

                 else if model.resize /= Nothing then
                    ResizeEnd

                 else
                    DragEnd
                )
            , onTouchMove
                (\pos ->
                    if model.drag /= Nothing then
                        DragAt pos

                    else if model.resize /= Nothing then
                        ResizeAt pos

                    else if isFollowMode model.mode then
                        MouseMoveFollow pos

                    else
                        DragAt pos
                )
            , onTouchEnd
                (if model.drag /= Nothing then
                    DragEnd

                 else if model.resize /= Nothing then
                    ResizeEnd

                 else
                    DragEnd
                )

            --, onDoubleClick (always ExitFollowMode)
            ]
            []

    else
        text ""


isFollowMode : Mode -> Bool
isFollowMode mode =
    case mode of
        FollowMouse _ ->
            True

        _ ->
            False


getBorderColor : Mode -> String
getBorderColor mode =
    case mode of
        FollowMouse _ ->
            "#ff5722"

        -- Orange border for follow mode
        _ ->
            "#d3d3d3"



-- Default gray border
-- The main overlay div


overlayDiv : List (Attribute (Msg parentMsg)) -> Model -> Html parentMsg -> Html (Msg parentMsg)
overlayDiv attr model inside =
    div
        (List.append
            [ style "position" "absolute"
            , style "z-index" "50"
            , style "background" "#000"
            , onKeyDownPreventDefault model.mode
            , attribute "tabindex" "0"
            , attribute "aria-label" ("Video playback controls - Current mode: " ++ modeToString model.mode)
            , style "right" (px model.position.x)
            , style "top" (px model.position.y)
            , style "width" (px model.size.width)
            , style "height" (px model.size.height)
            , style "border" ("5px solid " ++ getBorderColor model.mode)
            , style "border-radius" "50%"
            , style "display" "flex"
            , style "flex-direction" "column"
            , style "justify-content" "center"
            , style "align-items" "center"
            , style "overflow" "hidden"
            , style "touch-action" "none"
            , attribute "role" "region"
            , attribute "aria-label" "Video playback controls"
            , attribute "aria-live" "polite"
            , onMouseMove
                (\pos ->
                    if model.drag /= Nothing then
                        DragAt pos

                    else if model.resize /= Nothing then
                        ResizeAt pos

                    else if isFollowMode model.mode then
                        MouseMoveFollow pos

                    else
                        Ignore
                )
            , onMouseUp
                (if model.drag /= Nothing then
                    DragEnd

                 else if model.resize /= Nothing then
                    ResizeEnd

                 else
                    Ignore
                )
            , onTouchMove
                (\pos ->
                    if model.drag /= Nothing then
                        DragAt pos

                    else if model.resize /= Nothing then
                        ResizeAt pos

                    else if isFollowMode model.mode then
                        MouseMoveFollow pos

                    else
                        Ignore
                )
            , onTouchEnd
                (if model.drag /= Nothing then
                    DragEnd

                 else if model.resize /= Nothing then
                    ResizeEnd

                 else
                    Ignore
                )
            , onBlur LostFocus
            ]
            attr
        )
        [ Html.map Foreign inside
        , div
            [ style "position" "absolute"
            , style "width" "100%"
            , style "padding" "10px"
            , style "height" "100%"
            , style "cursor"
                (if isFollowMode model.mode then
                    "grabbing"

                 else
                    "move"
                )
            , style "color" "#fff"
            , style "text-align" "center"
            , style "top" "0px"
            , style "right" "0px"
            , onMouseDown DragStart
            , onTouchStart DragStart
            , onDoubleClick (\pos -> DoubleClick pos)
            , attribute "aria-label" "Drag to move video overlay. Double-click to make it follow mouse."
            , attribute "tabindex" "0"
            , title
                (if isFollowMode model.mode then
                    "double-click to release"

                 else
                    "drag or double-click video comment"
                )
            ]
            []
        , div
            [ style "width" "8%"
            , style "height" "8%"
            , style "background" "#d3d3d3"
            , style "position" "absolute"
            , style "right" "10%"
            , style "bottom" "10%"
            , style "cursor" "se-resize"
            , style "border-radius" "50%"
            , onMouseDown ResizeStart
            , onTouchStart ResizeStart
            , attribute "aria-label" "Resize video overlay"
            , attribute "tabindex" "0"
            , title "resize video comment"
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
            [ text
                ("Current mode: "
                    ++ modeToString model.mode
                    ++ ". "
                    ++ (if isFollowMode model.mode then
                            "Overlay is following mouse. Double-click or press ESC to release. "

                        else
                            "Use arrow keys to "
                                ++ (if model.mode == Move then
                                        "move"

                                    else
                                        "resize"
                                   )
                                ++ " the video overlay. Press Enter to switch modes. Double-click to make overlay follow mouse. "
                       )
                    ++ "Current position: "
                    ++ positionToString model.position
                    ++ ". Current size: "
                    ++ sizeToString model.size
                )
            ]
        ]


view : List (Attribute (Msg parentMsg)) -> Model -> Html parentMsg -> Html (Msg parentMsg)
view attr model inside =
    div []
        [ backgroundDiv model
        , overlayDiv attr model inside
        ]


px : Int -> String
px n =
    String.fromInt n ++ "px"


onMouseDown : (Position -> msg) -> Attribute msg
onMouseDown toMsg =
    on "mousedown" (Decode.map toMsg positionDecoder)


onMouseMove : (Position -> msg) -> Attribute msg
onMouseMove toMsg =
    on "mousemove" (Decode.map toMsg positionDecoder)


onMouseUp : msg -> Attribute msg
onMouseUp msg =
    on "mouseup" (Decode.succeed msg)


onTouchStart : (Position -> msg) -> Attribute msg
onTouchStart toMsg =
    preventDefaultOn "touchstart" (Decode.map alwaysPreventDefault (Decode.map toMsg touchPositionDecoder))


onTouchMove : (Position -> msg) -> Attribute msg
onTouchMove toMsg =
    preventDefaultOn "touchmove" (Decode.map alwaysPreventDefault (Decode.map toMsg touchPositionDecoder))


onTouchEnd : msg -> Attribute msg
onTouchEnd msg =
    on "touchend" (Decode.succeed msg)


onDoubleClick : (Position -> msg) -> Attribute msg
onDoubleClick toMsg =
    on "dblclick" (Decode.map toMsg positionDecoder)


positionDecoder : Decoder Position
positionDecoder =
    Decode.map2 Position
        (Decode.field "pageX" Decode.float |> Decode.map Basics.round)
        (Decode.field "pageY" Decode.float |> Decode.map Basics.round)


touchPositionDecoder : Decoder Position
touchPositionDecoder =
    Decode.at [ "touches", "0" ] positionDecoder


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )


onKeyDownPreventDefault : Mode -> Attribute (Msg parentMsg)
onKeyDownPreventDefault mode =
    Html.Events.custom "keydown" (keyDecoder mode)


keyDecoder : Mode -> Decode.Decoder { message : Msg parentMsg, preventDefault : Bool, stopPropagation : Bool }
keyDecoder mode =
    Decode.map
        (\keyCode ->
            case keyCode of
                13 ->
                    { message = ToggleMode, preventDefault = True, stopPropagation = True }

                27 ->
                    -- ESC key to exit follow mode
                    { message = ExitFollowMode, preventDefault = True, stopPropagation = True }

                37 ->
                    { message = arrowMsg mode Right, preventDefault = True, stopPropagation = True }

                38 ->
                    { message = arrowMsg mode Up, preventDefault = True, stopPropagation = True }

                39 ->
                    { message = arrowMsg mode Left, preventDefault = True, stopPropagation = True }

                40 ->
                    { message = arrowMsg mode Down, preventDefault = True, stopPropagation = True }

                _ ->
                    { message = Ignore, preventDefault = False, stopPropagation = False }
        )
        Html.Events.keyCode


arrowMsg : Mode -> Direction -> Msg parentMsg
arrowMsg mode direction =
    case mode of
        Move ->
            ArrowMove direction

        Resize ->
            ArrowResize direction

        FollowMouse _ ->
            Ignore


modeToString : Mode -> String
modeToString mode =
    case mode of
        Move ->
            "Move"

        Resize ->
            "Resize"

        FollowMouse _ ->
            "Follow Mouse"


positionToString : Position -> String
positionToString pos =
    "x: " ++ String.fromInt pos.x ++ ", y: " ++ String.fromInt pos.y


sizeToString : Size -> String
sizeToString size =
    "width: " ++ String.fromInt size.width ++ ", height: " ++ String.fromInt size.height
