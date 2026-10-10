module Lia.Markdown.Config exposing
    ( Config
    , init
    , setID
    , setMain
    , setSubViewer
    )

import Const
import Dict exposing (Dict)
import Html exposing (Html)
import I18n.Translations exposing (Lang)
import Lia.Markdown.Effect.Script.Types as Script
import Lia.Markdown.Inline.Config as Inline
import Lia.Markdown.Inline.Types exposing (Inlines)
import Lia.Markdown.Inline.View exposing (viewer)
import Lia.Markdown.Update exposing (Msg(..))
import Lia.Section exposing (Section, SubSection)
import Lia.Settings.Types exposing (Mode(..), Settings)
import Lia.Sync.Types as Sync
import Session exposing (Screen)


{-| Everything required to render the blocks of a section:

  - `view`: renders inlines with the `main` inline config
  - `screen`: the width without the table of contents, if it is open
  - `ace_theme` and `light`: the editor theme and light or dark mode

-}
type alias Config sub =
    { mode : Mode
    , view : Inlines -> List (Html Msg)
    , section : Section
    , ace_theme : String
    , light : Bool
    , screen : Screen
    , main : Inline.Config sub
    }


{-| Build the config for one section, the formulas of the section definition
are merged into the global ones, global ones win.
-}
init :
    Lang
    -> { old : String, new : String, name : Maybe String }
    -> Settings
    -> Sync.Settings
    -> Screen
    -> Int
    -> Maybe (Dict String String)
    -> Dict String ( Int, Int )
    -> Section
    -> Config sub
init lang translations settings sync screen id formulas media section =
    let
        effect =
            section.effect_model

        main =
            Inline.init
                { mode = settings.mode
                , visible = Just effect.visible
                , slide = id
                , speaking = effect.speaking
                , paused = effect.paused
                , lang = lang
                , theme = Just settings.editor
                , light = settings.light
                , tooltips = settings.tooltips && (screen.width >= Const.tooltipBreakpoint)
                , hideVideoComments = settings.hideVideoComments
                , media = media
                , scripts = effect.javascript
                , translations = Just translations
                , sync = Just sync
                , formulas = mergeFormulas formulas (Maybe.map .formulas section.definition)
                }
    in
    { mode = settings.mode
    , view = toView main
    , section = section
    , ace_theme = settings.editor
    , light = settings.light
    , screen =
        if settings.table_of_contents then
            { screen | width = screen.width - 260 }

        else
            screen
    , main = main
    }


toView : Inline.Config Msg -> Inlines -> List (Html Msg)
toView main =
    viewer main >> List.map (Html.map Script)


{-| Replace the inline config (used by quizzes, which add their input state),
the input path of the new config is appended to the current one.
-}
setMain : Inline.Config Msg -> Config Msg -> Config Msg
setMain main config =
    let
        input =
            main.input

        main_ =
            { main | input = { input | path = config.main.input.path ++ input.path } }
    in
    { config | main = main_, view = toView main_ }


{-| Render a section as if it were slide `id` in textbook mode (used by the
chat).
-}
setID : Int -> Config sub -> Config sub
setID id config =
    let
        section =
            config.section

        main =
            config.main
    in
    { config
        | section = { section | id = id }
        , main = { main | slide = id }
        , mode = Textbook
    }


mergeFormulas : Maybe (Dict String String) -> Maybe (Dict String String) -> Maybe (Dict String String)
mergeFormulas main sec =
    case ( main, sec ) of
        ( Just m, Just s ) ->
            Just (Dict.union m s)

        ( Nothing, _ ) ->
            sec

        _ ->
            main


{-| Inlines get a viewer for the LiaScript results of scripts (sub-sections),
their input path is extended by `effect` and `sub`.
-}
setSubViewer : (Int -> Int -> SubSection -> List (Html (Script.Msg Msg))) -> Config Msg -> Config Msg
setSubViewer function config =
    let
        main =
            config.main

        input =
            main.input
    in
    { config
        | view =
            toView (Inline.setViewer function { main | input = { input | path = ( "effect", 0 ) :: ( "sub", 1 ) :: input.path } })
    }
