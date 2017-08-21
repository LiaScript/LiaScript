module Lia.Type
    exposing
        ( Block(..)
        , Inline(..)
        , Mode(..)
        , Quiz(..)
        , Reference(..)
        , Slide
        )


type Mode
    = Slides
    | Plain


type alias Slide =
    { indentation : Int
    , title : String
    , body : List Block
    , effects : Int
    }


type Block
    = HorizontalLine
    | CodeBlock String String
    | Quote (List Inline)
    | Paragraph (List Inline)
    | Table (List (List Inline)) (List String) (List (List (List Inline)))
    | Quiz Quiz Int (List (List Inline))
    | EBlock Int (List Block)


type Quiz
    = SingleChoice Int (List (List Inline))
    | MultipleChoice (List ( Bool, List Inline ))
    | TextInput String



--    | Bullet List Block


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


type Lia
    = LiaBool Bool
    | LiaInt Int
    | LiaFloat Float
    | LiaString String
    | LiaList (List Lia)
    | LiaCmd String (List Lia)
