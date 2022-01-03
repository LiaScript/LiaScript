module Port.Service.Slide exposing
    ( initialize
    , scrollIntoView
    , scrollUp
    )

import Json.Encode as JE
import Port.Event as Event exposing (Event)


{-| This event shall be called on every slide load and will move the slide back
to the top and also check if the associated title is visible in the table of
contents, if not, this will be moved into the viewPort either.
-}
initialize : Int -> Event
initialize slide =
    [ ( "slide", JE.int slide ) ]
        |> JE.object
        |> event "init"


{-| Scroll the HTML `main` element to the top.
-}
scrollUp : Event
scrollUp =
    event "scrollUp" JE.null


{-| Pass the id of an element that should be scrolled into the visible area as
well as a delay in milliseconds. This is useful, for highlighting effects and
animations, that might take a while before they are calculated.
-}
scrollIntoView : String -> Int -> Event
scrollIntoView elementID delay =
    [ ( "id", JE.string elementID )
    , ( "delay", JE.int delay )
    ]
        |> JE.object
        |> event "scrollIntoView"


{-| **private:** Helper function to generate event - stubs that will be handled
by the service module `Slide.ts`.
-}
event : String -> JE.Value -> Event
event cmd message =
    { cmd = cmd, param = message }
        |> Event.initX "slide"
        |> Event.withNoReply
