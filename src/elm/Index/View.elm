module Index.View exposing (view)

import Const
import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import Html.Events exposing (onInput)
import I18n.Translations exposing (Lang(..))
import Index.Model exposing (Course, Modal(..), Model)
import Index.Update exposing (Msg(..))
import Index.View.Base as Base
import Index.View.Card exposing (card)
import Lia.Markdown.Code.Log exposing (Level(..))
import Lia.Parser.PatReplace exposing (link)
import Lia.Settings.Types exposing (Settings)
import Lia.Settings.View as Settings
import Lia.Utils exposing (blockKeydown, btn, modal)
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
                            { toView = itemView
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
                modal_files model.error

            Just Directory ->
                modal_directory model.error
        ]


itemView : Masonry.Id -> Course -> Html Msg
itemView _ course =
    card course


modal_files : Maybe String -> Html Msg
modal_files error =
    modal (Modal Nothing)
        Nothing
        [ Html.div
            [ Attr.style "max-width" "800px"
            , Attr.style "margin" "auto"
            , Attr.style "padding" "1rem"
            ]
            [ Html.h1 [] [ Html.text "Import File(s)" ]
            , Html.p []
                [ Html.text "You can import a course either from a single ZIP file or from multiple uncompressed files that contain all the necessary content. "
                , Html.text "To do this, you can either click on the button below to load the files or simply drag and drop them onto the field below. "
                ]
            , input [ Attr.multiple True ]
            , Html.h3 [] [ Html.text "... from a ZIP" ]
            , Html.p []
                [ Html.text "Your ZIP file should contain at least one \"README.md\" file, which will be used as the main entry point for your course. "
                , Html.text "All other files (including images, audio, or video) will be extracted and stored in your browser's local database, "
                , Html.a [ Attr.href "https://en.wikipedia.org/wiki/Indexed_Database_API" ] [ Html.text "IndexedDB" ]
                , Html.text ". "
                , Html.text "Depending on the size of the ZIP file, the initial loading might take some time."
                ]
            , Html.h3 [] [ Html.text "... from Multiple Files" ]
            , Html.p []
                [ Html.text "You can load multiple uncompressed files from a single directory. "
                , Html.text "Similar to the ZIP file, the \"README.md\" file will be used as the main entry point for your course. "
                , Html.text "HTML5 allows loading only files that are in the same folder; loading nested subfolders is not possible. "
                , Html.text "If you want to load an entire folder with subfolders, please use the directory import option."
                ]
            , btn_directory_import
            , note
            , showError error
            ]
        ]


modal_directory : Maybe String -> Html Msg
modal_directory error =
    modal (Modal Nothing)
        Nothing
        [ Html.div
            [ Attr.style "max-width" "800px"
            , Attr.style "margin" "auto"
            , Attr.style "padding" "1rem"
            ]
            [ Html.h1 [] [ Html.text "Import Directory" ]
            , Html.p []
                [ Html.text "Select a folder (which might contain subfolders as well) by clicking on the button below or drag and drop it onto the field below. "
                , Html.text "The folder should contain at least one \"README.md\" file, which will be used as the main entry point for your course."
                ]
            , input
                [ Attr.attribute "webkitdirectory" ""
                , Attr.attribute "directory" ""
                ]
            , note
            , showError error
            ]
        ]


showError : Maybe String -> Html Msg
showError error =
    case error of
        Just msg ->
            Html.section
                [ Attr.class "lia-error"
                , Attr.style "border" "1px solid white"
                , Attr.style "border-radius" "0.5rem"
                , Attr.style "padding" "1.5rem"
                ]
                [ Html.h3 [] [ Html.text "Ups an Error occurred" ]
                , Html.p [] [ Html.text msg ]
                ]

        Nothing ->
            Html.text ""


note : Html msg
note =
    Html.div []
        [ Html.h3 [ Attr.style "padding-top" "2rem" ] [ Html.text "Note" ]
        , Html.p []
            [ Html.text "Your project will be stored under the reference \"local://...\", followed by the hash value of the \"README.md\" file. "
            , Html.text "Therefore, loading the same course from different files will result in the same reference. "
            , Html.text "Any changes you make to the course will be stored under a new URL."
            ]
        ]


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
        , btn
            { tabbable = True
            , title = "Import multiple file or a ZIP-archive"
            , msg = Just Files |> Modal |> Just
            }
            [ Attr.class "mr-1 mb-1" ]
            [ Html.text "Import File(s) / Zip" ]
        , btn_directory_import
        , Html.hr [ Attr.class "border-grey-light max-w-50 mr-1 mb-1" ] []
        ]


btn_directory_import : Html Msg
btn_directory_import =
    btn
        { tabbable = True
        , title = "Import files and subfolders from a directory"
        , msg = Just Directory |> Modal |> Just
        }
        []
        [ Html.text "Import Directory" ]


input : List (Attribute msg) -> Html msg
input attributes =
    Html.input
        (List.append attributes
            [ Attr.type_ "file"
            , Attr.class "lia-input border-grey-light max-w-100 mb-1"
            , Attr.attribute "onchange" "LIA.fileUpload(event)"

            --, Attr.attribute "ondragover" "event.preventDefault()"
            , Attr.attribute "ondrop" "LIA.fileUpload(event)"
            ]
        )
        []
