module Msg exposing (Msg(..))

import Form exposing (Form)
import I18Next exposing (Translations)
import Model exposing (RegisterFields)
import Http exposing (Error)

type Msg
    = RegisterFormChanged (Form RegisterFields)
    | TranslationsLoaded (Result Http.Error Translations)
