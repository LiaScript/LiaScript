module Index.View exposing (view)

import Const
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import Index.Model as Model exposing (Model)
import Index.Update exposing (Msg(..))
import Index.View.Base as Base
import Index.View.Board as Board
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
        , Html.main_
            [ Attr.class "lia-slide__content"
            , Attr.style "width" "100%"
            , Attr.style "max-width" "100%"
            , Attr.style "height" "calc(100vh - 12rem)"
            , Attr.style "margin-bottom" "0px"
            , Attr.style "overflow" "hidden"
            ]
            [ Html.h1 [] [ Html.text "Lia: Open-courSes" ]
            , searchBar model.input
            , if List.isEmpty model.courses && Model.loaded model then
                Empty.view

              else if Model.loaded model then
                --Base.view session model.courses
                model.board
                    |> Board.view (Base.card session.share { body = False, tags = False, footer = False })
                        [ Attr.style "min-width" "360px"
                        , Attr.style "border-radius" "15px"

                        --, Attr.style "background" "rgb(var(--color-highlight))"
                        , Attr.style "margin" "2rem 2rem 0rem 0rem"
                        , Attr.style "padding" "10px 10px 2px 10px"
                        , Attr.style "border" "2.5px solid"
                        , Attr.style "border-color" "rgb(var(--color-highlight))"
                        ]
                    |> Html.map BoardUpdate

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
