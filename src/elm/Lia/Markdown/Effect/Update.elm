module Lia.Markdown.Effect.Update exposing
    ( Msg(..)
    , handle
    , has_next
    , has_previous
    , init
    , next
    , previous
    , soundEvent
    , update
    )

import Browser.Dom as Dom
import Json.Decode as JD
import Json.Encode as JE
import Lia.Event as Event exposing (Event)
import Lia.Markdown.Effect.Model exposing (Map, Model, current_comment, get_all_javascript, get_javascript)
import Lia.Utils
import Task


type Msg
    = Init Bool
    | Next
    | Previous
    | Send (List Event)
    | Handle Event
    | Rendered Bool Dom.Viewport


handle : Event -> Msg
handle =
    Handle


update : Bool -> Msg -> Model -> ( Model, Cmd Msg, List Event )
update sound msg model =
    case msg of
        Init run_all_javascript ->
            ( model, Task.perform (Rendered run_all_javascript) Dom.getViewport, [] )

        Next ->
            if has_next model then
                { model | visible = model.visible + 1 }
                    |> execute sound False 0

            else
                ( model, Cmd.none, [] )

        Previous ->
            if has_previous model then
                { model | visible = model.visible - 1 }
                    |> execute sound False 0

            else
                ( model, Cmd.none, [] )

        Send event ->
            let
                events =
                    ("focused"
                        |> JE.string
                        |> Event "scrollTo" -1
                    )
                        :: event
            in
            case ( sound, current_comment model ) of
                ( True, Just ( comment, narrator ) ) ->
                    ( { model | speaking = True }
                    , Cmd.none
                    , (Event "speak" -1 <| JE.list JE.string [ narrator, comment ]) :: events
                    )

                ( True, Nothing ) ->
                    speak_stop events model

                ( False, Just ( comment, narrator ) ) ->
                    if model.speaking then
                        { model | speaking = False }
                            |> speak_stop events

                    else
                        speak_stop events model

                _ ->
                    speak_stop events model

        Rendered run_all_javascript _ ->
            execute sound run_all_javascript 0 model

        Handle event ->
            case ( event.topic, JD.decodeValue JD.string event.message |> Result.withDefault "" ) of
                ( "speak_end", "" ) ->
                    ( { model | speaking = False }, Cmd.none, [] )

                ( "speak_end", error ) ->
                    ( { model | speaking = False }, Cmd.none, [] )

                ( "speak", "repeat" ) ->
                    update True (Send []) model

                _ ->
                    ( model, Cmd.none, [] )


speak_stop : List Event -> Model -> ( Model, Cmd Msg, List Event )
speak_stop events model =
    ( model
    , Cmd.none
    , (Event "speak" -1 <| JE.string "cancel") :: events
    )


executeEvent : Int -> String -> Event
executeEvent delay code =
    Event "execute" -1 <|
        JE.object
            [ ( "delay", JE.int delay )
            , ( "code", JE.string code )
            ]


execute : Bool -> Bool -> Int -> Model -> ( Model, Cmd Msg, List Event )
execute sound run_all delay model =
    let
        javascript =
            if run_all then
                get_all_javascript model

            else
                get_javascript model
    in
    update sound
        (javascript
            |> List.map (executeEvent delay)
            |> Send
        )
        model


has_next : Model -> Bool
has_next model =
    model.visible < model.effects


has_previous : Model -> Bool
has_previous model =
    model.visible > 0


init : Bool -> Msg
init run_all_javascript =
    Init run_all_javascript


next : Msg
next =
    Next


previous : Msg
previous =
    Previous


soundEvent : Bool -> Event
soundEvent on =
    (if on then
        "repeat"

     else
        "cancel"
    )
        |> JE.string
        |> Event "speak" -1
        |> Event.toJson
        |> Event "effect" -1
