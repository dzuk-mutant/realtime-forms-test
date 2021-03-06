module Main exposing (main)


import Browser exposing (Document)
import Form
import Form.Field as Field
import Http
import Language exposing (ScriptDir(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import RegisterForm
import Theme.Default
import Ui exposing (LabelPreference(..), ScrollbarThickness(..), ShapeHinting(..))
import View

import Debug exposing (log)

main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none


view : Model -> Document Msg
view model =
    { title = "Realtime Forms Demo"
    , body = [View.view model]
    }




initModel : Model
initModel =
    { languages = [ Language.fromParts "en" "alphabet" LTR ]
    , translationLoads = 0
    , translationAttempts = 0
    , translations = []

    , labelPreference = PrefersIcon
    , shapeHinting = LessShapeHinting
    , scrollbarThickness = ThinScrollbars
    , osFonts = False
    , theme = Theme.Default.darkTheme

    , registerForm = RegisterForm.init
    }



{-| What to do at the very start of the program.
-}
init : () -> ( Model, Cmd Msg )
init _ =
    ( initModel
    , Cmd.batch
        [ Language.getTranslations TranslationsLoaded initModel.languages
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TranslationsLoaded (Ok translations) ->
            ( Language.addTranslations translations model
            , Cmd.none )

        TranslationsLoaded (Err err) ->
            ( { model | translationAttempts = (model.translationAttempts + 1) }
            , Cmd.none
            )

        RegisterFormChanged f -> ( { model | registerForm = f } , Cmd.none )

        RegisterFormSubmitting f ->
            ( { model | registerForm = Form.setSaving model.registerForm }
            , Cmd.batch [ RegisterForm.submit RegisterFormSubmitted f ]
            )

        RegisterFormSubmitted (Ok ()) ->
            ( { model | registerForm = Form.setDone model.registerForm }
            , Cmd.none
            )

        RegisterFormSubmitted (Err err) ->
            ( { model | registerForm = RegisterForm.handleError err model.registerForm }
            , Cmd.none
            )
