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

{-| The animation state of a section and its narrator comments.
-}

import Array exposing (Array)
import Dict exposing (Dict)
import Helper.Array as Array
import Lia.Markdown.Effect.Script.Types exposing (Scripts)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.Inline.Stringify exposing (stringify)
import Lia.Markdown.Inline.Types exposing (Inlines)


{-| `visible` is the current animation step out of `effects`, `comments` are
the narrator comments per step, `speaking` and `paused` the id of the effect
whose playback is currently running or paused.
-}
type alias Model a =
    { visible : Int
    , effects : Int
    , comments : Dict Int Element
    , javascript : Scripts a
    , speaking : Maybe Int
    , paused : Maybe Int
    }


{-| All comments of one animation step, read out with the same narrator.
-}
type alias Element =
    { narrator : String
    , content : Array Content
    }


{-| A single comment paragraph. Hidden comments (`<!-- --{{1}}-- -->`) are
not `visible` in textbook mode. `audio` and `video` hold recordings that
replace the text-to-speech output.
-}
type alias Content =
    { visible : Bool
    , attr : Parameters
    , content : Inlines
    , audio : Array String
    , video : Array String
    }


{-| Are there comments to be spoken at the current animation step?
-}
hasComments : Model a -> Bool
hasComments model =
    Dict.member model.visible model.comments


{-| Audio recordings of the comments at the current animation step.
-}
getAudioRecordings : Model a -> List String
getAudioRecordings =
    getRecordings .audio


{-| Video recordings of the comments at the current animation step.
-}
getVideoRecordings : Model a -> List String
getVideoRecordings =
    getRecordings .video


getRecordings : (Content -> Array String) -> Model a -> List String
getRecordings fn model =
    case Dict.get model.visible model.comments of
        Just element ->
            Array.foldr (\c list -> Array.toList (fn c) ++ list) [] element.content

        Nothing ->
            []


{-| Append attributes to paragraph `id2` of the comments at step `id1`.
-}
set_annotation : Int -> Int -> Dict Int Element -> Parameters -> Dict Int Element
set_annotation id1 id2 m attr =
    Dict.update id1
        (Maybe.map
            (\e -> { e | content = Array.update id2 (\par -> { par | attr = par.attr ++ attr }) e.content })
        )
        m


{-| Paragraph `id2` of the comments at step `id1` together with its narrator.
With `attachHidden` the hidden comments that directly follow are appended to
its content.
-}
get_paragraph : Bool -> Int -> Int -> Model a -> Maybe ( String, Content )
get_paragraph attachHidden id1 id2 model =
    Dict.get id1 model.comments
        |> Maybe.andThen
            (\element ->
                Array.get id2 element.content
                    |> Maybe.map
                        (\content ->
                            ( element.narrator
                            , if attachHidden then
                                attachHiddenFrom (id2 + 1) element.content content

                              else
                                content
                            )
                        )
            )


{-| Append the content of all hidden comments from position `id` on, up to the
next visible one.
-}
attachHiddenFrom : Int -> Array Content -> Content -> Content
attachHiddenFrom id from result =
    case Array.get id from of
        Just next ->
            if next.visible then
                result

            else
                attachHiddenFrom (id + 1) from { result | content = result.content ++ next.content }

        Nothing ->
            result


{-| For every animation step from 0 to `effects`: is it the current one, its
number and its narrator and comments, if there are any.
-}
current_paragraphs : Model a -> List ( Bool, Int, Maybe ( String, List Content ) )
current_paragraphs model =
    List.range 0 model.effects
        |> List.map
            (\key ->
                ( key == model.visible
                , key
                , Dict.get key model.comments
                    |> Maybe.map (\element -> ( element.narrator, Array.toList element.content ))
                )
            )


{-| The current animation step, if it has comments.
-}
current_comment : Model a -> Maybe Int
current_comment model =
    if hasComments model then
        Just model.visible

    else
        Nothing


{-| All comments that start with a hidden comment, as `(step, narrator, text)`.
Hidden comments that follow a visible one are not returned, they get attached
to it instead (cf. `get_paragraph`), which preserves the order.

    --{{1}}--
    The next comment wont be added, because I exist

    <!-- --{{1}}--
    Do not show this in Textbook-mode ...
    -->

    <!-- --{{0}}--
    I will get returned ...
    -->

-}
getHiddenComments : Dict Int Element -> List ( Int, String, String )
getHiddenComments =
    Dict.foldr
        (\key element list ->
            case Array.get 0 element.content of
                Just first ->
                    if first.visible then
                        list

                    else
                        ( key
                        , element.narrator
                        , attachHiddenFrom 1 element.content first |> .content |> stringify
                        )
                            :: list

                Nothing ->
                    list
        )
        []


{-| -}
init : Model a
init =
    { visible = 0
    , effects = 0
    , comments = Dict.empty
    , javascript = Array.empty
    , speaking = Nothing
    , paused = Nothing
    }
