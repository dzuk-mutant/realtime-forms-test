module Msg exposing (Msg(..))

import I18Next exposing (Translations)
import RegisterForm exposing (RegisterForm)
import Http exposing (Error)

type Msg
    = RegisterFormChanged (RegisterForm)
    | RegisterFormSubmitting (RegisterForm)
    | RegisterFormSubmitted (Result Http.Error ())
    | TranslationsLoaded (Result Http.Error Translations)
