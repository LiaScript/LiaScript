module Library.Overlay exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (on, preventDefaultOn)
import Json.Decode as Decode exposing (Decoder)



-- MODEL


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
    }


init : Model
init =
    { position = Position 0 0
    , initialPosition = Position 0 0
    , size = Size 200 200
    , initialSize = Size 200 200
    , drag = Nothing
    , resize = Nothing
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

        Foreign parentMsg ->
            ( model, Cmd.none, Just parentMsg )


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


view : Model -> Html parentMsg -> Html (Msg parentMsg)
view model inside =
    div
        [ style "position" "absolute"
        , style "z-index" "100000000"
        , style "left" (px model.position.x)
        , style "top" (px model.position.y)
        , style "width" (px model.size.width)
        , style "height" (px model.size.height)
        , style "border" "1px solid #d3d3d3"
        , style "border-radius" "50%"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "justify-content" "center"
        , style "align-items" "center"
        , style "overflow" "hidden"
        , style "touch-action" "none"
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
            ]
            []
        , div
            [ style "width" "8%"
            , style "height" "8%"
            , style "background" "blue"
            , style "position" "absolute"
            , style "right" "10%"
            , style "bottom" "10%"
            , style "cursor" "se-resize"
            , style "border-radius" "30%"
            , onMouseDown ResizeStart
            , onTouchStart ResizeStart
            ]
            []
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
        (Decode.field "pageX" Decode.int)
        (Decode.field "pageY" Decode.int)


touchPositionDecoder : Decoder Position
touchPositionDecoder =
    Decode.at [ "touches", "0" ] positionDecoder


alwaysPreventDefault : msg -> ( msg, Bool )
alwaysPreventDefault msg =
    ( msg, True )
