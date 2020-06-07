module Lia.Markdown.Inline.Types exposing
    ( Config
    , Inline(..)
    , Inlines
    , MultInlines
    , Reference(..)
    , config
    , htmlBlock
    , isHTML
    )

import Lia.Markdown.Effect.Types exposing (Effect)
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.HTML.Types exposing (Node(..))
import Lia.Settings.Model exposing (Mode(..))
import Translations exposing (Lang)


type alias Config =
    { mode : Mode
    , visible : Int
    , speaking : Maybe Int
    , lang : Lang
    }


config : Mode -> Int -> Maybe Int -> Lang -> Config
config mode visible speaking lang =
    Config mode
        (if mode == Textbook then
            99999

         else
            visible
        )
        speaking
        lang


type alias Inlines =
    List Inline


type alias MultInlines =
    List Inlines


type Inline
    = Chars String Parameters
    | Symbol String Parameters
    | Bold Inline Parameters
    | Italic Inline Parameters
    | Strike Inline Parameters
    | Underline Inline Parameters
    | Superscript Inline Parameters
    | Verbatim String Parameters
    | Formula String String Parameters
    | Ref Reference Parameters
    | FootnoteMark String Parameters
    | EInline (Effect Inline) Parameters
    | IHTML (Node Inline) Parameters
    | Container Inlines Parameters
    | Goto Inline Int


type Reference
    = Link Inlines String String
    | Mail Inlines String String
    | Image Inlines String String
    | Audio Inlines ( Bool, String ) String
    | Movie Inlines ( Bool, String ) String
    | Embed Inlines String String


isHTML : Inline -> Bool
isHTML inline =
    case inline of
        IHTML _ _ ->
            True

        _ ->
            False


htmlBlock : Inline -> Maybe ( String, List ( String, String ), List Inline )
htmlBlock inline =
    case inline of
        IHTML (Node name attributes content) attr ->
            Just ( name, attributes, [ Container content attr ] )

        _ ->
            Nothing
