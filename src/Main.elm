module Main exposing (main)


import Browser exposing (Document)
import Form
import Form.Field as Field
import Language exposing (ScriptDir(..))
import Model exposing (Model)
import Msg exposing (Msg(..))
import RegisterForm exposing (init)
import Theme.Default exposing (darkTheme)
import Ui exposing (LabelPreference(..), ScrollbarThickness(..), ShapeHinting(..))
import View


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
    { title = "Granular Forms Demo"
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
    , theme = darkTheme

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
