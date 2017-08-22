module Lia.Inline.Types exposing (Inline(..), Reference(..))


type Inline
    = Chars String
    | Symbol String
    | Bold Inline
    | Italic Inline
    | Underline Inline
    | Superscript Inline
    | Code String
    | Formula Bool String
    | Ref Reference
    | HTML String
    | EInline Int (List Inline)


type Reference
    = Link String String
    | Image String String
    | Movie String String
