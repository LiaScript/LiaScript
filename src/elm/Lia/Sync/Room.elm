module Lia.Sync.Room exposing (generator)

import Array exposing (Array)
import List.Extra
import Random


{-| Generate a random String that can be used as an Room
-}
generator : Random.Generator String
generator =
    positiveWords
        |> Array.length
        |> Random.int 0
        -- since there might be doubles, a little buffer is added
        |> Random.list 10
        |> Random.map toSentence


{-| Turn a list or random ids into a positive Room id, which consists of 4
positive words.
-}
toSentence : List Int -> String
toSentence =
    -- remove doubles
    List.Extra.unique
        -- turn them into positive words
        >> List.filterMap (\id -> Array.get id positiveWords)
        -- get only the 4 first ids
        >> List.Extra.splitAt 4
        >> Tuple.first
        --
        >> String.concat


{-| These are all positive words that are related to education:
-}
positiveWords : Array String
positiveWords =
    Array.fromList
        -- A
        [ "Accommodating" -- Teachers should always be accommodating to your needs. This means they will change the way they teach you to make sure you learn to the best of your ability.
        , "Accomplished"
        , "Authentic"
        , "Awesome"
        , "Awe-Inspiring" -- An awe-inspiring education is one that makes you wonder at the amazement of the world and all the knowledge in it.

        -- B
        , "Brave"
        , "Bright"
        , "Brilliant"

        -- C
        , "Caring"
        , "Creative"

        -- D
        , "Delightful"
        , "Dreamy"

        -- E
        , "Easy" -- You might use this word if you feel as if you don’t have to make much of an effort and still get good grades.
        , "Education"
        , "Effortless" -- You would similarly use this one if you think perhaps you’re in a class that’s too easy for you and so you don’t study or try, but will still pass with flying colors.
        , "Empathy"
        , "Empowering"
        , "Engaging" -- An engaging lesson is usually one where the students can actually participate, rather than sitting and watching.
        , "Epic"
        , "Exciting" -- If you find learning to be enjoyable and you just can’t wait for the next lesson, you might call school an exciting place.
        , "Exhilarating" -- If you’re doing a science project and feel like you’re on the verge of a breakthrough, you might consider the project to be exhilarating.
        , "Eye-Opening" -- At school, we learn a lot of new things that expand our horizons and change how we look at things. In these situations, we might walk out of a lesson and say ‘that was eye opening!’

        -- F
        , "Fabulous"
        , "Fair"
        , "Fantastical" -- This is a term you might use in a library when you walk in and know you’re going to find another book that will draw you into a fantasy world.
        , "Flexible" -- A school that will make accommodations for you and your specific learning needs might be described as one that is ‘flexible’.
        , "Free"
        , "Friendly" -- We always hope when we walk into a classroom that there will be lots of friendly faces around us. As a teacher, I always strive to create a friendly environment.
        , "Fun" -- If you really enjoy all the adventures and activities you’re assigned in class, you might come home and tell your parents: ‘school was fun today!’

        -- G
        , "Genius"
        , "Great"
        , "Good"

        -- H
        , "Hands-On" -- A hands-on classroom is one that lets all the students be active participants in their learning, which will help them learn and be engaged.
        , "Happy"
        , "High-Expectations" -- A school that sets high expectations is one that wants you to do the best you possibly can, and won’t accept anything less.
        , "Hilarious"
        , "Honest"

        -- I
        , "Idyllic"
        , "Important" -- Most of us believe that learning is one of the most important things we can do so that we can succeed at life.
        , "Inclusive" -- An inclusive environment is one that ensures everyone is welcomed and a wide variety of views are encouraged.
        , "Inspiring" -- An inspiring environment is one that will always be teaching you in ways that make you lean in and take interest in the amazing things they’re teaching you.
        , "Interactive" -- Sometimes schools are not very interactive and students just have to sit and watch. But the good ones make sure everyone gets involved and can do some hands-on activities.
        , "Inviting" -- An inviting school might be one with lovely artworks of the students around the walls and kind teachers who make you feel welcome.

        -- J
        , "Joyful"

        -- K
        , "Kind" -- A kind school would have teachers who are generous, smiling and patient with you while you learn. It may also focus on teaching the values of kindness.
        , "Knowledge"

        -- L
        , "Learning"
        , "LiaScript"
        , "Life-Changing" -- A life-changing education would be one that gives you skills to go out and make the sort of life you wouldn’t have been able to otherwise.
        , "Lucky"

        -- M
        , "Magical"
        , "Marvelous"
        , "Mind-Blowing" -- You might find a lesson to be mind-blowing if you come out of it feeling as if everything you thought you knew has been totally upended by your new knowledge.
        , "Motivating" -- You would find it motivating if you really want to wake up every day and go to learn something new.

        -- N
        , "New"

        -- O
        , "Open"
        , "Optimistic"
        , "Outstanding"

        -- P
        , "Passion"
        , "Participatory" -- A participatory classroom would be one that allows students to actively be involved in learning and share their opinions.
        , "Playful"
        , "Polite"

        -- Q
        -- R
        , "Relaxing"
        , "Reliable"
        , "Respectful"

        -- S
        , "Safe" -- Safety is incredibly important in an institution and should be first and foremost. According to Maslow’s Hierarchy of Needs, people need to feel safe and comfortable in order to learn.
        , "Social" -- A social learning environment would be one were people get to talk to one another while learning. You might also consider school to be social if your favorite part about it is making new friends.
        , "Successful"

        -- T
        , "Thankful"
        , "Thoughtful"
        , "Trustworthy"

        -- U
        , "Ultimate"
        , "United"
        , "Useful"

        -- V
        , "Varied" -- A varied educational experience might occur if you get to learn about a lot of different things in a lot of different ways.

        -- W
        , "Warm"
        , "Welcoming" -- You might feel like a classroom is warm and welcoming if you walked in and were instantly greeted by a kind teacher.

        -- X
        -- Y
        , "Yummy"

        -- Z
        ]
