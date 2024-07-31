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
        , title
        )
import Html.Events
    exposing
        ( on
        , preventDefaultOn
        )
import Json.Decode as Decode exposing (Decoder)



-- MODEL


type Mode
    = Move
    | Resize


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
    }


init : Model
init =
    { position = Position 0 0
    , initialPosition = Position 0 0
    , size = Size 200 200
    , initialSize = Size 200 200
    , drag = Nothing
    , resize = Nothing
    , mode = Move
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


draggedPosition : Model -> Position -> Position
draggedPosition model pos =
    case model.drag of
        Just { start } ->
            Position
                (model.initialPosition.x + (pos.x - start.x))
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


view : List (Attribute (Msg parentMsg)) -> Model -> Html parentMsg -> Html (Msg parentMsg)
view attr model inside =
    div
        (List.append
            [ style "position" "absolute"
            , style "z-index" "50"
            , style "background" "#000"
            , onKeyDownPreventDefault model.mode
            , attribute "tabindex" "0"
            , attribute "aria-label" ("Video playback controls - Current mode: " ++ modeToString model.mode)
            , style "left" (px model.position.x)
            , style "top" (px model.position.y)
            , style "width" (px model.size.width)
            , style "height" (px model.size.height)
            , style "border" "5px solid #d3d3d3"
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

                    else
                        DragAt pos
                 -- This will be ignored in the update function
                )
            , onMouseUp
                (if model.drag /= Nothing then
                    DragEnd

                 else if model.resize /= Nothing then
                    ResizeEnd

                 else
                    DragEnd
                 -- This will be ignored in the update function
                )
            , onTouchMove
                (\pos ->
                    if model.drag /= Nothing then
                        DragAt pos

                    else if model.resize /= Nothing then
                        ResizeAt pos

                    else
                        DragAt pos
                 -- This will be ignored in the update function
                )
            , onTouchEnd
                (if model.drag /= Nothing then
                    DragEnd

                 else if model.resize /= Nothing then
                    ResizeEnd

                 else
                    DragEnd
                 -- This will be ignored in the update function
                )
            ]
            attr
        )
        [ Html.map Foreign inside
        , div
            [ style "position" "absolute"
            , style "width" "100%"
            , style "padding" "10px"
            , style "height" "100%"
            , style "cursor" "move"
            , style "color" "#fff"
            , style "text-align" "center"
            , onMouseDown DragStart
            , onTouchStart DragStart
            , attribute "aria-label" "Drag to move video overlay"
            , attribute "tabindex" "0"
            , title "drag video comment"
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
                    ++ ". Use arrow keys to "
                    ++ (if model.mode == Move then
                            "move"

                        else
                            "resize"
                       )
                    ++ " the video overlay. Press Enter to switch modes. Current position: "
                    ++ positionToString model.position
                    ++ ". Current size: "
                    ++ sizeToString model.size
                )
            ]
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

                -- Enter key
                37 ->
                    { message = arrowMsg mode Left, preventDefault = True, stopPropagation = True }

                38 ->
                    { message = arrowMsg mode Up, preventDefault = True, stopPropagation = True }

                39 ->
                    { message = arrowMsg mode Right, preventDefault = True, stopPropagation = True }

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


modeToString : Mode -> String
modeToString mode =
    case mode of
        Move ->
            "Move"

        Resize ->
            "Resize"


positionToString : Position -> String
positionToString pos =
    "x: " ++ String.fromInt pos.x ++ ", y: " ++ String.fromInt pos.y


sizeToString : Size -> String
sizeToString size =
    "width: " ++ String.fromInt size.width ++ ", height: " ++ String.fromInt size.height
