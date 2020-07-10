module View exposing (view)

import Html exposing (Html)
import Html.Attributes
import Model exposing (Model)
import Msg exposing (Msg(..))
import RegisterForm
import Ui
import Ui.Page as Page



view : Model -> Html Msg
view model =
    Ui.view model
        startupLoading
        startupFailed
        (Page.floating [RegisterForm.view model.translations model.registerForm])




startupLoading : Html msg
startupLoading =
    Html.div [] []

{-| The ultimate failure state. This will show in place of the
UI when something critical to the functioning of the UI cannot
be loaded at startup.

It will provide the user with brief instructions that (as
accurately as possible) describe why it couldn't start.

(TODO) Currently, there is only one possible critical error.
-}
startupFailed : Html msg
startupFailed =
    Html.div [ Html.Attributes.id "critical-error" ]
        [ Html.p []
            [ Html.text "Critical error. Translation strings could not be loaded." ]
        ]
