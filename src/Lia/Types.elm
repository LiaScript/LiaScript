module Lia.Types exposing (Block(..), Mode(..), Paragraph, Slide)

import Lia.Inline.Types exposing (..)
import Lia.Quiz.Types exposing (QuizBlock)


type Mode
    = Slides
    | Plain


type alias Slide =
    { indentation : Int
    , title : String
    , body : List Block
    , effects : Int
    }


type alias Paragraph =
    List Inline


type Block
    = HLine
    | CodeBlock String String
    | Quote Paragraph
    | Paragraph Paragraph
    | Table (List Paragraph) (List String) (List (List Paragraph))
    | Quiz QuizBlock
    | EBlock Int (List Block)
    | EComment Int Paragraph
    | MList (List Block)



--    | Bullet List Block


type Lia
    = LiaBool Bool
    | LiaInt Int
    | LiaFloat Float
    | LiaString String
    | LiaList (List Lia)
    | LiaCmd String (List Lia)
