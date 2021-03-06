module RegisterForm exposing ( RegisterForm
                             , view
                             , init
                             , submit
                             , handleError
                             )

import Html exposing (Html, div, form)
import Html.Attributes exposing (class, spellcheck)
import Http
import I18Next exposing (Translations, tf)
import Form exposing (Form, empty, validateField)
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
TODO: Try to make validating every field that requires it automatic???
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


{-|  Part of what happens when the user clicks the Submit/Save button.

A sequence of validating every field that requires validation.
TODO: Try to make this automatic instead of manual???
-}
allFieldValidations : RegisterFields -> RegisterFields
allFieldValidations r =
    r
    |> Form.validateField .username (\v x -> { v | username = x })
    |> Form.validateField .email (\v x -> { v | email = x })
    |> Form.validateField .tos (\v x -> { v | tos = x })



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
        ]


{- For future development when there's a server to test with...
-}
submit : (Result Http.Error () -> msg) -> RegisterForm -> Cmd msg
submit sendMsg form =
    Http.request
        { method = "POST"
        , headers = []
        , url = "http://localhost:3000/signup"
        , body = Http.jsonBody <| encoder form
        , expect = Http.expectWhatever sendMsg
        , timeout = Just 30000
        , tracker = Nothing
        }


{-| Error messages!
-}
handleError : Http.Error -> RegisterForm -> RegisterForm
handleError err form =
    let
        errMsg = case err of
            Http.Timeout -> "The server timed out."
            Http.NetworkError -> "Parastat can't connect right now. Check your internet connection then try again."
            Http.BadUrl url -> "Critical network error. Contact the admin about this issue."
            Http.BadStatus code -> "Critical network error. Contact the admin about this issue."
            Http.BadBody string -> "Critical network error. Contact the admin about this issue."
    in
        form
        |> Form.changeState Form.Unsaved
        |> Form.addHttpErr errMsg





view : List Translations
        -> (RegisterForm -> msg)
        -> (RegisterForm -> msg)
        -> RegisterForm
        -> Html msg
view trans changeMsg submitMsg form =
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

            , changeMsg = changeMsg
            , form = form
            , fieldGetter = .username
            , fieldSetter = (\v x -> { v | username = x })
            , translations = trans
            }

        , Input.email []
            { id = "email"
            , required = True
            , label = VisibleLabel (tf trans "email")
            , helper = Just (tf trans "email-helper")
            , placeholder = Just (tf trans "email-placeholder")

            , changeMsg = changeMsg
            , form = form
            , fieldGetter = .email
            , fieldSetter = (\v x -> { v | email = x })
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

            , changeMsg = changeMsg
            , form = form
            , fieldGetter = .tos
            , fieldSetter = (\v x -> { v | tos = x })
            , translations = trans
            }

        , Button.submit [ class "primary" ]
            { label = (tf trans "sign-up-button")
            , changeMsg = changeMsg
            , submitMsg = submitMsg
            , form = form
            , translations = trans
            }
        ]
