module HtmlSnapshot exposing (expect, toString)

{-| Snapshot testing for rendered `Html`.

Selectors in `Test.Html` only see what a test explicitly asks for. When a view
gets refactored, a snapshot instead guarantees that the complete markup (tags,
attributes, classes, text and the order of children, including empty text
nodes) stays exactly the same. Event handlers are not part of the snapshot;
test them with `Test.Html.Event`.

`elm-explorations/test` has no public function to print `Html`, but it prints
the queried markup into the description of a failing query, which is what
`toString` extracts.

-}

import Expect exposing (Expectation)
import Html exposing (Html)
import Test.Html.Query as Query
import Test.Html.Selector exposing (tag)
import Test.Runner


{-| Render `Html` to the pretty-printed string that `Test.Html` uses in its
failure messages (4 spaces indentation, one node per line).
-}
toString : Html msg -> String
toString html =
    Query.fromHtml html
        |> Query.has [ tag "html-snapshot-unmatchable-tag" ]
        |> Test.Runner.getFailureReason
        |> Maybe.map (.description >> extract)
        |> Maybe.withDefault "HtmlSnapshot: could not render html"


{-| Cut the markup out of a description of the form

    ▼ Query.fromHtml

        <markup>


    ▼ Query.has [ ... ]

and remove the indentation `Test.Html` adds in front of every line.

-}
extract : String -> String
extract description =
    description
        |> String.split "\n\n\n▼ Query.has"
        |> List.head
        |> Maybe.withDefault ""
        |> String.replace "▼ Query.fromHtml\n\n" ""
        |> String.lines
        |> List.map (String.dropLeft 4)
        |> String.join "\n"


{-| Expect `html` to render exactly to `snapshot`.
-}
expect : String -> Html msg -> Expectation
expect snapshot html =
    toString html
        |> Expect.equal snapshot
