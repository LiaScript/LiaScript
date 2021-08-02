module Lia.Graph.Update exposing
    ( Msg(..)
    , setRootSection
    , setSectionVisibility
    , update
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Graph.Graph as Graph
import Lia.Graph.Model exposing (Model)
import Lia.Graph.Node as Node exposing (Node(..))
import Session exposing (Session)
import Url


type Msg
    = Clicked JD.Value


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
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


setRootSection : Int -> Model -> Model
setRootSection i model =
    { model | root = Just (Node.section i) }


getNode : Model -> JE.Value -> Maybe Node
getNode model =
    JD.decodeValue (JD.field "data" (JD.field "id" JD.string))
        >> Result.toMaybe
        >> Maybe.andThen (Graph.getNodeById model.graph)


setSectionVisibility : Model -> List Int -> Model
setSectionVisibility model ids =
    { model | graph = Graph.setSectionVisibility model.graph ids }
