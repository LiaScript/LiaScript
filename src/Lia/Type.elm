module Lia.Type
    exposing
        ( Block(..)
        , Mode(..)
        , Slide
        )

import Lia.Inline.Type exposing (..)
import Lia.Quiz.Type exposing (QuizBlock)


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
    | Quiz QuizBlock
    | EBlock Int (List Block)



--    | Bullet List Block


type Lia
    = LiaBool Bool
    | LiaInt Int
    | LiaFloat Float
    | LiaString String
    | LiaList (List Lia)
    | LiaCmd String (List Lia)
