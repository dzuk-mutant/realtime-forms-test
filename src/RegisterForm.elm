module RegisterForm exposing ( RegisterForm
                             , view
                             , init
                             )

import Html exposing (Html, div, form)
import Html.Attributes exposing (class, spellcheck)
import Http
import I18Next exposing (Translations, tf)
import Form exposing (Form, empty, validateFieldInFormVal)
import Form.Field as Field exposing (Field, empty)
import Form.Validatable as Validatable exposing (isValid)
import Form.Validator as Validator exposing ( ValidatorSet(..) )
import Ui.Button as Button
import Ui.Form
import Ui.Layout as Layout
import Ui.Input as Input exposing ( OptionalLabel(..) )
import Ui.Text as Text
import Json.Encode as Encode






type alias RegisterForm = Form RegisterFields

type alias RegisterFields =
        { username : Field String
         , email : Field String
         , tos : Field Bool
         }


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



{-| A validatorSet for the form.

Basically just checking that every field is Valid.
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

Part of what happens when the user clicks the Submit/Save button.
-}
allFieldValidations : RegisterFields -> RegisterFields
allFieldValidations r =
    r
    |> validateFieldInFormVal .username (\v x -> { v | username = x })
    |> validateFieldInFormVal .email (\v x -> { v | email = x })
    |> validateFieldInFormVal .tos (\v x -> { v | tos = x })



{-| Initialises an empty RegisterForm model for filling in.
-}
init = Form.empty formValidators allFieldValidations
                    { username = Field.empty usernameValidators ""
                    , email = Field.empty emailValidators ""
                    , tos = Field.empty tosValidators False
                    }





{-| Encodes this form into JSON for sending to the server.
-}
encoder : RegisterForm -> Encode.Value
encoder form =
    Encode.object
        [ ( "username", Encode.string <| Form.getFieldVal .username form )
        , ( "email", Encode.string <| Form.getFieldVal .email form )
        , ( "tos", Encode.bool <| Form.getFieldVal .tos form )
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




view : List Translations -> (RegisterForm -> msg) -> RegisterForm -> Html msg
view trans changeMsg form =
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

            , onChange = changeMsg
            , form = form
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

            , onChange = changeMsg
            , form = form
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
            { id = "checkbox"
            , required = True
            , label = (tf trans "tos")
            , helper = Nothing

            , onChange = changeMsg
            , form = form
            , field = .tos
            , setter = (\v x -> { v | tos = x })
            , translations = trans
            }


        , Button.submit [ class "primary" ]
            { label = (tf trans "sign-up-button")
            , onChange = changeMsg
            , form = form
            , translations = trans
            }
        ]
