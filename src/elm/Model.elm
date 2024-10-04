module Model exposing
    ( Model
    , State(..)
    )

{-| The global Model and the global State the application can be in.

In general the app can only be in three/four different states, that are defined
by the `State` type:

1.  `Running`: Means a LiaScript course has been loaded, parsed and is now
    rendered.
2.  `Idle`: Nothing has to be done. In most cases this means, that an index of
    all previously stored courses is displayed.
3.  `Loading` | `Parsing`: The course document gets loaded and parsed.
4.  `Error`: This happens only, if the course URL could not be loaded or
    something very unusual happened during parsing.

-}

import Dict exposing (Dict)
import Index.Model as Index
import Lia.Script
import Session exposing (Session)


{-| The global LiaScript Model:

  - `size`: refers to the byte-size of the loaded document (this info is later
    used to animate the preprocessing with a percentage value)

  - `hasIndex`: this parameter is defined by the so called connectors, depending
    on the applied "backend" it is possible to switch to other courses or is
    only course provided. This parameter thus defines, if there is a home-button
    or not.

  - `code`: contains the entire string of a Markdown file

  - `index`: the model for the global index, if the backend has one (`hasIndex`)

  - `preload`: if some content is reloaded from the "backend", it is stored in
    here. This might be the case, if the Version of a course has not changed or
    if the user is offline. In both cases, a subsequent pre-parsing is not
    necessary.

  - `session`: session data on local navigation and the screen size

  - `state`: the current state of the app

  - `lia`: **all data about the course**

-}
type alias Model =
    { parse_steps : Int
    , size : Float
    , hasIndex : Bool
    , code : Maybe ( String, Int )
    , index : Index.Model
    , preload : Maybe Index.Course
    , session : Session
    , state : State
    , lia : Lia.Script.Model
    , lia_ : Lia.Script.Model
    , templates : Dict String String
    }


{-| Defines the entire state of the application

  - `Idle`: Wait for user Input, commonly the Index-page is displayed in this
    state

  - `Loading`: Start to download the course if course url is defined

  - `Loading_Zip`: Start to download the course if course url is defined, but
    the course is a zip-file

  - `Parsing Bool Int`: Running the PreParser and loading the imports.
      - While the boolean value is true, the document has not been parsed
        entirely.
      - The Int defines the number (a counter) of LiaScript imports that have to
        be loaded and parsed additionally. This number is counted down after
        every successful download
      - **Note:** Only `Parsing False 0` means that the process of pre-parsing is
        finished.

  - `Running`: Pass all action to Lia

  - `Error`: What has happened?

-}
type State
    = Idle
    | Loading
    | Loading_Zip
    | Parsing Bool Int
    | Running
    | Error (List String)
