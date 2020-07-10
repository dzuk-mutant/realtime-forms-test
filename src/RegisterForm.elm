module RegisterForm exposing (view)

-----------

import Html exposing (Html, div, form)
import Html.Attributes exposing (class, spellcheck)
import Http
import I18Next exposing (Translations, tf)
import Form exposing (Form)
import Form.Validatable as Validatable exposing (isValid, validateAndShowErr)
import Form.Validator as Validator exposing ( ValidatorSet(..) )
import Ui.Button as Button
import Ui.Form
import Ui.Layout as Layout
import Ui.Input as Input exposing ( OptionalLabel(..) )
import Ui.Text as Text
import Msg exposing (Msg(..))
import Model exposing (RegisterFields)
import Json.Encode as Encode

-------------------------------------------------------




usernameValidators : List Translations -> ValidatorSet String
usernameValidators translations =
    DoValidation
        [ Validator.isNotEmpty (tf translations "input-fail-req")
        , Validator.hasMaxLength 20 (tf translations "username-fail-req")
        , Validator.hasOnlyAlphanumericOrUnderscores (tf translations "username-fail-req")
        ]

emailValidators : List Translations -> ValidatorSet String
emailValidators translations =
    DoValidation
        [ Validator.isNotEmpty (tf translations "input-fail-req")
        , Validator.isValidEmail (tf translations "email-fail-invalid")
        ]

tosValidators : List Translations -> ValidatorSet Bool
tosValidators translations =
    DoValidation
        [ Validator.isTrue (tf translations "tos-fail-decline") ]


{-| A validatorSet for the form. Basically just checking that every field is Valid.
-}
formValidators : List Translations -> ValidatorSet RegisterFields
formValidators translations =
    DoValidation
        [ ( (\r -> isValid r.username
                  && isValid r.email
                  && isValid r.tos )
            , (tf translations "form-fail")
            )
        ]

{-| Every field validation as a list of functions that
applies the validations directly to the form.

For what happens when the user clicks the Submit/Save button.
-}
allFieldValidations : List Translations -> RegisterFields -> RegisterFields
allFieldValidations translations r =
    r
    |> (\v -> { v | username = Validatable.validateAndShowErr (usernameValidators translations) v.username } )
    |> (\v -> { v | email = Validatable.validateAndShowErr (emailValidators translations) v.email } )
    |> (\v -> { v | tos = Validatable.validateAndShowErr (tosValidators translations) v.tos } )







{-| Encodes this form into JSON for sending to the server.
-}
encoder : Form RegisterFields -> Encode.Value
encoder form =
    Encode.object
        [ ( "username", Encode.string <| Form.getFieldVal .username form )
        , ( "email", Encode.string <| Form.getFieldVal .email form )
        ]


{- For future development when there's a server to test with...
-}
-- send : Register -> Cmd msg
-- send form =
--     Http.request
--         { method = "POST"
--         , headers = []
--         , url = ""
--         , body = Http.jsonBody <| encoder form
--         , expect = Http.expectWhatever FormSubmit
--         , timeout = Just (30 * 1000)
--         , tracker = Nothing
--         }




view : List Translations -> Form RegisterFields -> Html Msg
view translations registerForm =
    Ui.Form.view []
        [ Text.h1 (tf translations "form-title")
        , Text.p (tf translations "form-desc")

        , Layout.divider

        , Input.textCounted 20 [ spellcheck False ]
            { id = "username"
            , required = True
            , label = VisibleLabel (tf translations "username")
            , helper = Just (tf translations "username-helper")
            , placeholder = Nothing

            , onChange = RegisterFormChanged
            , form = registerForm
            , field = .username
            , setter = (\v x -> { v | username = x })
            , formValidators = formValidators translations
            , fieldValidators = usernameValidators translations
            }

        , Input.email []
            { id = "email"
            , required = True
            , label = VisibleLabel (tf translations "email")
            , helper = Just (tf translations "email-helper")
            , placeholder = Just (tf translations "email-placeholder")

            , onChange = RegisterFormChanged
            , form = registerForm
            , field = .email
            , setter = (\v x -> { v | email = x })
            , formValidators = formValidators translations
            , fieldValidators = emailValidators translations
            }

        , Layout.divider

        , Text.p (tf translations "tos-lead-in")

        , Text.externalLinks
            [ ("", (tf translations "tos-link"))
            , ("https://parast.at/coc", (tf translations "rules-link"))
            ]

        , Input.checkbox []
            { id = "checkbox2"
            , required = True
            , label = (tf translations "tos")
            , helper = Nothing

            , onChange = RegisterFormChanged
            , form = registerForm
            , field = .tos
            , setter = (\v x -> { v | tos = x })
            , formValidators = formValidators translations
            , fieldValidators = tosValidators translations
            }


        , Button.submit [ class "primary" ]
            { label = (tf translations "sign-up-button")

            , onChange = RegisterFormChanged
            , form = registerForm
            , fieldValidations = allFieldValidations translations
            , formValidation = formValidators translations
            }
        ]
