module Lia.Graph.Update exposing (..)

import Dict
import Json.Decode as JD
import Json.Encode as JE
import Lia.Graph.Model exposing (Graph, Node(..), section)
import Session exposing (Session)
import Url


type Msg
    = Clicked JD.Value


update : Session -> Msg -> Graph -> ( Graph, Cmd Msg )
update session msg graph =
    case msg of
        Clicked obj ->
            case getNode graph obj of
                Just (Section sec) ->
                    ( graph, Session.navToSlide session sec.id )

                Just (Link node) ->
                    ( graph
                    , node.url
                        |> Url.fromString
                        |> Maybe.map Session.load
                        |> Maybe.withDefault Cmd.none
                    )

                _ ->
                    ( graph, Cmd.none )


rootSection : Int -> Graph -> Graph
rootSection i graph =
    { graph | root = Just (section i) }


getNode : Graph -> JE.Value -> Maybe Node
getNode graph obj =
    case JD.decodeValue (JD.field "data" (JD.field "id" JD.string)) obj of
        Ok id ->
            Dict.get id graph.node

        _ ->
            Nothing
