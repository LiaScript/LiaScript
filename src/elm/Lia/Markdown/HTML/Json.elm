module Lia.Markdown.HTML.Json exposing
    ( encParameters
    , encode
    , maybeEncParameters
    )

import Json.Encode as JE
import Lia.Markdown.HTML.Attributes exposing (Parameters)
import Lia.Markdown.HTML.Types exposing (Node(..))


encode : (x -> JE.Value) -> Node x -> ( String, JE.Value )
encode encoder node =
    case node of
        Node tag a content ->
            ( "Node"
            , JE.object
                [ ( "tag", JE.string tag )
                , encParameters a
                , ( "content", JE.list encoder content )
                ]
            )

        InnerHtml code ->
            ( "InnerHtml", JE.string code )

        OuterHtml tag a content ->
            ( "OuterHtml"
            , JE.object
                [ ( "tag", JE.string tag )
                , encParameters a
                , ( "content", JE.string content )
                ]
            )

        SvgNode a code foreignObjects ->
            ( "SvgNode"
            , JE.object
                [ ( "body", JE.string code )
                , encParameters a
                , ( "foreignObjects"
                  , JE.list
                        (\( attr, content ) ->
                            JE.object
                                [ encParameters attr
                                , ( "content", JE.list encoder content )
                                ]
                        )
                        foreignObjects
                  )
                ]
            )


encParameters : Parameters -> ( String, JE.Value )
encParameters annotation =
    ( "a"
    , case annotation of
        [] ->
            JE.null

        _ ->
            annotation
                |> JE.list (\( key, value ) -> JE.list JE.string [ key, value ])
    )


maybeEncParameters : Parameters -> List ( String, JE.Value ) -> List ( String, JE.Value )
maybeEncParameters a =
    if List.isEmpty a then
        identity

    else
        (::) (encParameters a)
