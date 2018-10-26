port module Lia.Effect.Update exposing (Msg(..), has_next, has_previous, init, next, previous, subscriptions, update)

import Date exposing (Date)
import Json.Encode as JE
import Lia.Effect.Model exposing (Map, Model, current_comment, get_all_javascript, get_javascript)
import Lia.Utils
import Task


port speech2js : List String -> Cmd msg


port speech2elm : (( String, String ) -> msg) -> Sub msg


type Msg
    = Init Bool
    | Next
    | Previous
    | Speak (Maybe JE.Value)
    | SpeakRslt ( String, String )
    | Rendered Bool (Maybe Date)


update : Bool -> Msg -> Model -> ( Model, Cmd Msg, Maybe JE.Value )
update sound msg model =
    let
        x =
            Debug.log "sound" ( sound, msg )
    in
    case msg of
        Init run_all_javascript ->
            ( model, Task.perform (Just >> Rendered run_all_javascript) Date.now, Nothing )

        Next ->
            if has_next model then
                { model | visible = model.visible + 1 }
                    |> execute sound False 0

            else
                ( model, Cmd.none, Nothing )

        Previous ->
            if has_previous model then
                { model | visible = model.visible - 1 }
                    |> execute sound False 0

            else
                ( model, Cmd.none, Nothing )

        Speak log ->
            case ( sound, current_comment model ) of
                ( True, Just ( comment, narrator ) ) ->
                    ( { model | speaking = True }, speech2js [ "speak", narrator, comment ], log )

                ( True, Nothing ) ->
                    ( model, speech2js [ "cancel" ], log )

                ( False, Just ( comment, narrator ) ) ->
                    if model.speaking then
                        ( { model | speaking = False }, speech2js [ "cancel" ], log )

                    else
                        ( model, speech2js [ "cancel" ], log )

                _ ->
                    ( model, speech2js [ "cancel" ], log )

        SpeakRslt ( "end", msg ) ->
            ( { model | speaking = False }, Cmd.none, Nothing )

        SpeakRslt ( "error", msg ) ->
            let
                error =
                    Debug.log "TTS error: " msg
            in
            ( { model | speaking = False }, Cmd.none, Nothing )

        Rendered run_all_javascript _ ->
            let
                d =
                    Lia.Utils.scrollIntoView "focused"
            in
            execute sound run_all_javascript 0 model

        _ ->
            ( model, Cmd.none, Nothing )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ speech2elm SpeakRslt ]


log : Int -> String -> JE.Value
log delay code =
    JE.list [ JE.string "execute", JE.int delay, JE.string code ]


execute : Bool -> Bool -> Int -> Model -> ( Model, Cmd Msg, Maybe JE.Value )
execute sound run_all delay model =
    let
        javascript =
            if run_all then
                get_all_javascript model

            else
                get_javascript model
    in
    update sound
        (Speak <|
            if List.length javascript == 0 then
                Nothing

            else
                javascript
                    |> List.map (log delay)
                    |> JE.list
                    |> Just
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
