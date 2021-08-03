module Lia.Graph.Update exposing
    ( Msg(..)
    , setRootSection
    , setSectionVisibility
    , update
    )

import Json.Decode as JD
import Json.Encode as JE
import Lia.Graph.Graph as Graph
import Lia.Graph.Model exposing (Model, isRootNode, updateJson)
import Lia.Graph.Node as Node exposing (Node(..))
import Lia.Graph.Settings as Settings
import Session exposing (Session)
import Url


type Msg
    = Clicked JD.Value
    | UpdateSettings Settings.Msg


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        Clicked obj ->
            case getNode model obj of
                Just (Section sec) ->
                    ( model, Session.navToSlide session sec.id )

                Just (Link node) ->
                    ( model
                    , node.url
                        |> Url.fromString
                        |> Maybe.map Session.load
                        |> Maybe.withDefault Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        UpdateSettings subMsg ->
            ( { model
                | settings =
                    Settings.update subMsg model.settings
              }
                |> updateJson
            , Cmd.none
            )


setRootSection : Int -> Model -> Model
setRootSection i model =
    if isRootNode model (Node.section i) then
        model

    else
        updateJson { model | root = Just (Node.section i) }


getNode : Model -> JE.Value -> Maybe Node
getNode model =
    JD.decodeValue (JD.field "data" (JD.field "id" JD.string))
        >> Result.toMaybe
        >> Maybe.andThen (Graph.getNodeById model.graph)


setSectionVisibility : Model -> List Int -> Model
setSectionVisibility model ids =
    { model | graph = Graph.setSectionVisibility model.graph ids }
