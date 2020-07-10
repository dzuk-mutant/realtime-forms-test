module Model exposing ( Model
                      , RegisterFields
                      )

import I18Next exposing (Translations)
import Form exposing (Form)
import Form.Field as Field exposing (Field)
import Theme exposing (Theme)
import Ui exposing (LabelPreference(..), ScrollbarThickness(..), ShapeHinting(..))
import Language exposing (Language, LanguageList)






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

    , registerForm : Form RegisterFields
    }



type alias RegisterFields =
        { username : Field String
         , email : Field String
         , tos : Field Bool
         }
