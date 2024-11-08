module Index.View exposing (view)

import Const
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import I18n.Translations exposing (Lang(..))
import Index.Model exposing (Course, Modal(..), Model)
import Index.Update exposing (Msg(..))
import Index.View.Base as Base
import Index.View.Card exposing (card)
import Index.View.Modal as Modal
import Lia.Markdown.Code.Log exposing (Level(..))
import Lia.Parser.PatReplace exposing (link)
import Lia.Settings.Types exposing (Settings)
import Lia.Settings.View as Settings
import Lia.Utils exposing (blockKeydown, btn)
import Library.Masonry as Masonry
import Session exposing (Session)


view : Session -> Settings -> Model -> Html Msg
view session settings model =
    Html.div []
        [ [ ( \_ _ _ -> [], "ignore" )
          , ( Settings.menuSettings session.screen.width, "settings" )
          ]
            |> Settings.header False En session.screen settings Const.icon
            |> Html.map UpdateSettings
        , Html.div [ Attr.class "lia-slide__container" ]
            [ Html.main_
                [ Attr.class "lia-slide__content"
                , if session.screen.width < 240 then
                    Attr.style "padding" "0 1rem"

                  else
                    Attr.style "min-width" "100%"
                ]
                [ Html.h1 [] [ Html.text "LiaScript: Open-courSe" ]
                , Html.p []
                    [ Html.text "( ... search a list of free LiaScript courses and related material on "
                    , Html.a
                        [ Attr.href "https://github.com/topics/liascript", Attr.target "_blank" ]
                        [ Html.text "GitHub" ]
                    , Html.text " )"
                    ]
                , searchBar model.input
                , if List.isEmpty model.courses && model.initialized then
                    Base.view

                  else if model.initialized then
                    let
                        config =
                            { toView = itemView session.share
                            , columns = (session.screen.width // 600) + 1
                            , attributes = [ Attr.style "gap" "2rem", Attr.style "overflow" "hidden" ]
                            }
                    in
                    Html.div []
                        [ Html.p [ Attr.style "padding-top" "1rem" ]
                            [ Html.text "These courses are stored locally in your browser and are only visible to you. You can access them offline and safely remove or reset any of them at any time."
                            ]
                        , Masonry.view config model.masonry
                        ]

                  else
                    Html.text ""
                ]
            ]
        , case model.modal of
            Nothing ->
                Html.text ""

            Just Files ->
                Modal.files model.error

            Just Directory ->
                Modal.directory model.error
        ]


itemView : Bool -> Masonry.Id -> Course -> Html Msg
itemView hasShareAPI _ course =
    card hasShareAPI course


searchBar : String -> Html Msg
searchBar url =
    Html.div
        [ Attr.style "position" "relative"
        ]
        [ Html.input
            [ Attr.type_ "url"
            , onInput Input
            , Attr.value url
            , Attr.placeholder "course-url"
            , Attr.class "lia-input border-grey-light max-w-50 mr-1 mb-1"
            , blockKeydown NoOp
            ]
            []
        , let
            deactivated =
                url == ""
          in
          btn
            { tabbable = not deactivated
            , title = "load"
            , msg =
                if deactivated then
                    Nothing

                else
                    url
                        |> link
                        |> (++) "./?"
                        |> LoadCourse
                        |> Just
            }
            []
            [ Html.text "Load from URL"
            ]
        , Html.p [] [ Html.text "As an alternative you can upload courses from your device to the browser, either from separate files or from a directory." ]
        , Modal.btn_files_import
        , Modal.btn_directory_import
        , Html.hr [ Attr.class "border-grey-light max-w-50 mr-1 mb-1" ] []
        ]
