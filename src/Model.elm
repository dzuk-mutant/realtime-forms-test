module Model exposing ( Model
                      )

import I18Next exposing (Translations)
import Theme exposing (Theme)
import Ui exposing (LabelPreference(..), ScrollbarThickness(..), ShapeHinting(..))
import Language exposing (Language, LanguageList)
import RegisterForm exposing (RegisterForm)





type alias Model =
    { -- Language (represented by LanguageRecords)
      languages: List Language
    , translationAttempts: Int
    , translationLoads: Int
    , translations: List Translations

    , labelPreference : LabelPreference
    , shapeHinting : ShapeHinting
    , scrollbarThickness : ScrollbarThickness
    , theme : Theme
    , osFonts : Bool

    , registerForm : RegisterForm
    }
