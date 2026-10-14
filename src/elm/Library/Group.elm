module Library.Group exposing (id, blur)

{-| Elements that belong together (like a dropdown and its button) share a
group id, `blur` only fires when the focus leaves the whole group.

@docs id, blur

-}

import Html exposing (Attribute)
import Html.Attributes as Attr
import Html.Events as Event
import Json.Decode as JD


{-| Put an element into the group `groupId`.
-}
id : String -> Attribute msg
id groupId =
    Attr.attribute "data-group-id" groupId


{-| Send the group id of the blurred element, unless the focus moves to an
element of the same group.
-}
blur : (String -> msg) -> Attribute msg
blur msg =
    JD.map2 Tuple.pair
        (JD.at [ "target", "dataset", "groupId" ] JD.string)
        (JD.field "relatedTarget" closestGroupId)
        |> JD.andThen
            (\( group, next ) ->
                if Just group == next then
                    JD.fail "no change"

                else
                    JD.succeed (msg group)
            )
        |> Event.on "blur"


{-| Walks up from a node (e.g. `relatedTarget`) to find the nearest
`data-group-id`, mimicking `Element.closest`. Elements injected into a
group's container by third-party scripts (e.g. the Google Translate
widget's `<select>`) don't carry that attribute themselves, but their
ancestor container does, so they still count as "inside" the group.
-}
closestGroupId : JD.Decoder (Maybe String)
closestGroupId =
    JD.oneOf
        [ JD.at [ "dataset", "groupId" ] JD.string |> JD.map Just
        , JD.field "parentElement" (JD.lazy (\_ -> closestGroupId))
        , JD.succeed Nothing
        ]
