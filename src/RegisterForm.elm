module RegisterForm exposing (view, usernameValidators, emailValidators, tosValidators, formValidators)

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




usernameValidators : ValidatorSet String
usernameValidators =
    DoValidation
        [ Validator.isNotEmpty "input-fail-req"
        , Validator.hasMaxLength 20 "username-fail-len"
        , Validator.hasOnlyAlphanumericOrUnderscores "username-fail-chars"
        ]

emailValidators : ValidatorSet String
emailValidators =
    DoValidation
        [ Validator.isNotEmpty "input-fail-req"
        , Validator.isValidEmail "email-fail-invalid"
        ]

tosValidators : ValidatorSet Bool
tosValidators =
    DoValidation
        [ Validator.isTrue "tos-fail-decline" ]


{-| A validatorSet for the form. Basically just checking that every field is Valid.
-}
formValidators : ValidatorSet RegisterFields
formValidators =
    DoValidation
        [ ( (\r -> isValid r.username
                  && isValid r.email
                  && isValid r.tos )
            , "form-fail"
            )
        ]

{-| Every field validation as a list of functions that
applies the validations directly to the form.

For what happens when the user clicks the Submit/Save button.
-}
allFieldValidations : RegisterFields -> RegisterFields
allFieldValidations r =
    r
    |> (\v -> { v | username = validateAndShowErr v.username } )
    |> (\v -> { v | email = validateAndShowErr v.email } )
    |> (\v -> { v | tos = validateAndShowErr v.tos } )


{-| Encodes this form into JSON for sending to the server.
-}
encoder : Form RegisterFields -> Encode.Value
encoder form =
    Encode.object
        [ ( "username", Encode.string <| Form.getFieldVal .username form )
        , ( "email", Encode.string <| Form.getFieldVal .email form )
        , ( "email", Encode.bool <| Form.getFieldVal .tos form )
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
view trans registerForm =
    Ui.Form.view []
        [ Text.h1 (tf trans "form-title")
        , Text.p (tf trans "form-desc")

        , Layout.divider

        , Input.textCounted 20 [ spellcheck False ]
            { id = "username"
            , required = True
            , label = VisibleLabel (tf trans "username")
            , helper = Just (tf trans "username-helper")
            , placeholder = Nothing

            , onChange = RegisterFormChanged
            , form = registerForm
            , field = .username
            , setter = (\v x -> { v | username = x })
            , translations = trans
            }

        , Input.email []
            { id = "email"
            , required = True
            , label = VisibleLabel (tf trans "email")
            , helper = Just (tf trans "email-helper")
            , placeholder = Just (tf trans "email-placeholder")

            , onChange = RegisterFormChanged
            , form = registerForm
            , field = .email
            , setter = (\v x -> { v | email = x })
            , translations = trans
            }

        , Layout.divider

        , Text.p (tf trans "tos-lead-in")

        , Text.externalLinks
            [ ("", (tf trans "tos-link"))
            , ("https://parast.at/coc", (tf trans "rules-link"))
            ]

        , Input.checkbox []
            { id = "checkbox2"
            , required = True
            , label = (tf trans "tos")
            , helper = Nothing

            , onChange = RegisterFormChanged
            , form = registerForm
            , field = .tos
            , setter = (\v x -> { v | tos = x })
            , translations = trans
            }


        , Button.submit [ class "primary" ]
            { label = (tf trans "sign-up-button")

            , onChange = RegisterFormChanged
            , form = registerForm
            , fieldValidations = allFieldValidations
            , translations = trans
            }
        ]
