module Index.View.Modal exposing
    ( btn_directory_import
    , btn_files_import
    , directory
    , files
    )

import Html exposing (Attribute, Html)
import Html.Attributes as Attr
import I18n.Translations exposing (Lang(..))
import Index.Model exposing (Modal(..))
import Index.Update exposing (Msg(..))
import Lia.Markdown.Code.Log exposing (Level(..))
import Lia.Utils exposing (btn, modal)


files : Maybe String -> Html Msg
files error =
    modal (Modal Nothing)
        Nothing
        [ Html.div
            [ Attr.style "max-width" "800px"
            , Attr.style "margin" "auto"
            , Attr.style "padding" "1rem"
            ]
            [ Html.h1 [ Attr.tabindex -1, Attr.id "lia-modal-focus" ] [ Html.text "Import File(s)" ]
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


btn_directory_import : Html Msg
btn_directory_import =
    btn
        { tabbable = True
        , title = "Import files and subfolders from a directory"
        , msg = Just Directory |> Modal |> Just
        }
        []
        [ Html.text "Import Directory" ]


btn_files_import : Html Msg
btn_files_import =
    btn
        { tabbable = True
        , title = "Import multiple file or a ZIP-archive"
        , msg = Just Files |> Modal |> Just
        }
        [ Attr.class "mr-1 mb-1" ]
        [ Html.text "Import File(s) / Zip" ]


directory : Maybe String -> Html Msg
directory error =
    modal (Modal Nothing)
        Nothing
        [ Html.div
            [ Attr.style "max-width" "800px"
            , Attr.style "margin" "auto"
            , Attr.style "padding" "1rem"
            ]
            [ Html.h1 [ Attr.tabindex -1, Attr.id "lia-modal-focus" ] [ Html.text "Import Directory" ]
            , Html.p []
                [ Html.text "Select a folder (which might contain sub-folders as well) by clicking on the button below or drag and drop it onto the field below. "
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
