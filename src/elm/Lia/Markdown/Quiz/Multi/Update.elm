module Lia.Markdown.Quiz.Multi.Update exposing
    ( Msg(..)
    , handle
    , toString
    , update
    )

import Array
import I18n.Translations exposing (Lang(..))
import Json.Decode as JD
import Json.Encode as JE
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Quiz.Block.Types as Block
import Lia.Markdown.Quiz.Block.Update as Block
import Lia.Markdown.Quiz.Multi.Types exposing (State)
import Return exposing (Return)


{-| The inputs of a gap-text are rendered as inline elements, their events are
sent via JavaScript (`window.LIA.send`, see `Multi.View`) as `Handle`.
-}
type Msg sub
    = Script (Script.Msg sub)
    | Handle ( String, JE.Value )


{-| -}
handle : ( String, JE.Value ) -> Msg sub
handle =
    Handle


{-| All commands carry the `id` of the input and a `value`, `dragend` and
`dragsource` carry the position `[ input, option ]`:

  - `input`: text input
  - `choose` and `toggle`: select an option and open/close a dropdown
  - `dragstart`, `dragenter`, `dragend`: drag and drop, the highlighted drop
    zone takes the dragged option, which is removed from the zone it was in
  - `dragtarget` and `dragsource`: click and drop, first select a drop zone,
    then the option to put into it

-}
update : Msg sub -> State -> Return State msg sub
update msg state =
    case msg of
        Handle ( cmd, param ) ->
            case ( cmd, decodeId param ) of
                ( "input", Ok id ) ->
                    case ( Array.get id state, decodeValue JD.string param ) of
                        ( Just (Block.Text _), Ok text ) ->
                            state
                                |> Array.set id (Block.Text text)
                                |> Return.val

                        _ ->
                            state
                                |> Return.val

                ( "choose", Ok id ) ->
                    case ( Array.get id state, decodeValue JD.int param ) of
                        ( Just (Block.Select open _), Ok option ) ->
                            state
                                |> Array.set id (Block.Select open [ option ])
                                |> Return.val

                        _ ->
                            state
                                |> Return.val

                ( "toggle", Ok id ) ->
                    case Array.get id state of
                        Just (Block.Select open option) ->
                            state
                                |> Array.set id (Block.Select (not open) option)
                                |> Return.val

                        _ ->
                            state
                                |> Return.val

                ( "dragstart", Ok id ) ->
                    case Array.get id state of
                        Just (Block.Drop highlight _ option) ->
                            state
                                |> Array.set id
                                    (Block.Drop
                                        highlight
                                        True
                                        option
                                    )
                                |> Return.val

                        _ ->
                            state
                                |> Return.val

                ( "dragenter", Ok id ) ->
                    case Array.get id state of
                        Just (Block.Drop _ _ option) ->
                            state
                                |> Array.set id
                                    (Block.Drop
                                        (param
                                            |> decodeValue JD.bool
                                            |> Result.withDefault False
                                        )
                                        False
                                        option
                                    )
                                |> Return.val

                        _ ->
                            state
                                |> Return.val

                ( "dragend", _ ) ->
                    let
                        pos =
                            decodeList param
                    in
                    state
                        |> Array.map
                            (\block ->
                                case block of
                                    Block.Drop False _ pp ->
                                        Block.Drop False
                                            False
                                            (if pos == pp then
                                                []

                                             else
                                                pp
                                            )

                                    Block.Drop True _ _ ->
                                        Block.Drop False False pos

                                    _ ->
                                        block
                            )
                        |> Return.val

                ( "dragtarget", Ok id ) ->
                    state
                        |> Array.indexedMap
                            (\i block ->
                                case block of
                                    Block.Drop _ _ pp ->
                                        Block.Drop False (i == id) pp

                                    _ ->
                                        block
                            )
                        |> Return.val

                ( "dragsource", _ ) ->
                    let
                        pos =
                            decodeList param
                    in
                    state
                        |> Array.map
                            (\block ->
                                case block of
                                    Block.Drop _ True _ ->
                                        Block.Drop False False pos

                                    _ ->
                                        block
                            )
                        |> Return.val

                _ ->
                    state
                        |> Return.val

        Script sub ->
            state
                |> Return.val
                |> Return.script sub


decodeList : JD.Value -> List Int
decodeList =
    decodeValue (JD.list JD.int)
        >> Result.toMaybe
        >> Maybe.withDefault []


{-| The input as passed to a checking script, a list with one entry per input,
texts are quoted. A dropped option counts only for the input it was dropped
onto.
-}
toString : State -> String
toString state =
    state
        |> Array.toIndexedList
        |> List.map
            (\( id, block ) ->
                case block of
                    -- inline drops store [ input, option ], options of other inputs are wrong
                    Block.Drop _ _ [ input, option ] ->
                        if input == id then
                            String.fromInt option

                        else
                            "-1"

                    _ ->
                        Block.toString True block
            )
        |> String.join ","
        |> (\str -> "[" ++ str ++ "]")


decodeValue : JD.Decoder a -> JD.Value -> Result JD.Error a
decodeValue type_ =
    JD.decodeValue (JD.field "value" type_)


decodeId : JD.Value -> Result JD.Error Int
decodeId =
    JD.decodeValue (JD.field "id" JD.int)
