module Index.View exposing (view)

import Const
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import Index.Model exposing (Model)
import Index.Update exposing (Msg(..))
import Index.View.Base as Base
import Index.View.Empty as Empty
import Lia.Parser.PatReplace exposing (link)
import Lia.Settings.Types exposing (Settings)
import Lia.Settings.View as Settings
import Lia.Utils exposing (blockKeydown, btn)
import Session exposing (Session)
import Translations exposing (Lang(..))


view : Session -> Settings -> Model -> Html Msg
view session settings model =
    Html.div [ Attr.class "p-2" ]
        [ [ ( Settings.menuSettings, "settings" )
          ]
            |> Settings.header En session.screen settings Const.icon
            |> Html.map UpdateSettings
        , Html.main_ [ Attr.class "lia-slide__content" ]
            [ Html.h1 [] [ Html.text "Lia: Open-courSes" ]
            , searchBar model.input
            , if List.isEmpty model.courses && model.initialized then
                Empty.view

              else if model.initialized then
                Base.view session model.courses

              else
                Html.text ""
            ]
        ]


searchBar : String -> Html Msg
searchBar url =
    Html.div []
        [ Html.input
            [ Attr.type_ "url"
            , onInput Input
            , Attr.value url
            , Attr.placeholder "course-url"
            , Attr.class "lia-input border-grey-light max-w-50 mr-1"
            , blockKeydown NoOp
            ]
            []
        , if url == "" then
            btn
                { tabbable = False
                , title = "load"
                , msg = Nothing
                }
                []
                [ Html.text "load course"
                ]

          else
            btn
                { tabbable = True
                , title = "load"
                , msg =
                    url
                        |> link
                        |> (++) "./?"
                        |> LoadCourse
                        |> Just
                }
                []
                [ Html.text "load course"
                ]
        ]
