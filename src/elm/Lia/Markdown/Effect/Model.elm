module Lia.Markdown.Effect.Model exposing
    ( Content
    , Element
    , Model
    , current_comment
    , current_paragraphs
    , getAudioRecordings
    , getHiddenComments
    , getVideoRecordings
    , get_paragraph
    , hasComments
    , init
    , set_annotation
    )

import Array exposing (Array)
import Browser.Events exposing (Visibility(..))
import Dict exposing (Dict)
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)
import Translations exposing (Lang(..))


type alias Model a =
    { visible : Int
    , effects : Int
    , comments : Dict Int Element
    , javascript : Scripts a
    , speaking : Maybe Int
    }


type alias Element =
    { narrator : String
    , content : Array Content
    }


type alias Content =
    { visible : Bool
    , attr : Parameters
    , content : Inlines
    , audio : Array String
    , video : Array String
    }


{-| Checks if the current effect model contains any comments that should
be spoken out loud.
-}
hasComments : Model a -> Bool
hasComments model =
    model.comments
        |> Dict.get model.visible
        |> (/=) Nothing


getAudioRecordings : Model a -> List String
getAudioRecordings =
    getRecordings .audio


getVideoRecordings : Model a -> List String
getVideoRecordings =
    getRecordings .video


getRecordings : (Content -> Array String) -> Model a -> List String
getRecordings fn model =
    model.comments
        |> Dict.get model.visible
        |> Maybe.map
            (.content
                >> Array.map (fn >> Array.toList)
                >> Array.toList
                >> List.concat
            )
        |> Maybe.withDefault []


set_annotation : Int -> Int -> Dict Int Element -> Parameters -> Dict Int Element
set_annotation id1 id2 m attr =
    case Dict.get id1 m of
        Just e ->
            case Array.get id2 e.content of
                Just par ->
                    Dict.insert id1
                        { e
                            | content =
                                e.content
                                    |> Array.set id2 { par | attr = attr }
                        }
                        m

                Nothing ->
                    m

        Nothing ->
            m


get_paragraph : Bool -> Int -> Int -> Model a -> Maybe ( String, Content )
get_paragraph attachHidden id1 id2 model =
    case Dict.get id1 model.comments of
        Just element ->
            case Array.get id2 element.content of
                Just content ->
                    Just <|
                        ( element.narrator
                        , if attachHidden then
                            getComment_Helper
                                element.content
                                (id2 + 1)
                                content

                          else
                            content
                        )

                _ ->
                    Nothing

        _ ->
            Nothing


getComment_Helper : Array Content -> Int -> Content -> Content
getComment_Helper from id result =
    case Array.get id from of
        Nothing ->
            result

        Just next ->
            if next.visible then
                result

            else
                getComment_Helper
                    from
                    (id + 1)
                    { result
                        | content = List.append result.content next.content
                    }


current_paragraphs : Model a -> List ( Bool, Int, Maybe ( String, List Content ) )
current_paragraphs model =
    model.effects
        |> List.range 0
        |> List.map
            (\key ->
                ( key == model.visible
                , key
                , model.comments
                    |> Dict.get key
                    |> Maybe.map (\element -> ( element.narrator, Array.toList element.content ))
                )
            )


current_comment : Model a -> Maybe Int
current_comment model =
    case Dict.get model.visible model.comments of
        Just _ ->
            Just model.visible

        _ ->
            Nothing


{-| This Function returns a list all hidden comments, that do not have a normal
comment above them. This might look a bit complicated, but it is required at
the moment to preserve the order. Hidden comments that do not start ... will be
automatically attached to the printed comments (cf. `get_paragraph`).

    --{{1}}--
    The next comment wont b added, because I exist

    <!-- --{{1}}--
    Do not show this in Textbook-mode ...
    -->

    <!-- --{{0}}--
    I will get returned ...
    -->

-}
getHiddenComments : Dict Int Element -> List ( Int, String, String )
getHiddenComments =
    Dict.toList
        >> List.filterMap
            (\( key, value ) ->
                case Array.get 0 value.content of
                    Just first ->
                        if not first.visible then
                            first
                                |> getComment_Helper value.content 1
                                |> .content
                                |> stringify
                                |> (\text -> ( key, value.narrator, text ))
                                |> Just

                        else
                            Nothing

                    _ ->
                        Nothing
            )


init : Model a
init =
    Model
        0
        0
        Dict.empty
        Array.empty
        Nothing
