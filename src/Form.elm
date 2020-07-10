module Form exposing ( Form
                     , empty
                     , prefilled

                     , replaceValues

                     , validate

                     , FieldSetter
                     , FieldGetter
                     , getField
                     , getFieldVal

                     , updateField
                     , updateFieldWithoutValidation
                     , updateFieldManually
                     , updateFieldManuallyWithoutValidation
                     , showAnyFieldErr
                     )

{-| Setting up, manipulating and handling forms.


# Form
@docs Form



# Creating Forms
@docs empty, prefilled



# Manipulation
@docs replaceValues



# Validation
@docs validate



# Field access
Types and functions for accessing and handling `Field` values within a `Form`.

Basically lenses. I'm so sorry.
@docs FieldSetter, FieldGetter, getField, getFieldVal



# Event handlers for inputs
Functions for storing user input changes and validating them as they are being inputted.

## Designed for event handlers like onInput
@docs updateField, updateFieldWithoutValidation

## Designed for event handlers like onClick
@docs updateFieldManually, updateFieldManuallyWithoutValidation

## Functions that don't change values, only metadata
@docs showAnyFieldErr


-}



import Form.Field as Field exposing (Field)
import Form.Validator exposing (ValidatorSet(..))
import Form.Validatable as Validatable exposing ( Validity(..)
                                                , ErrVisibility(..)
                                                , ErrBehavior(..)
                                                , validate
                                                )


{-| A type that represents your whole form, including it's validation state.

(See `Form.Validatable.Validatable` to understand this record structure.)
-}
type alias Form b =
    { value : b
    , validators : ValidatorSet b

    , validity : Validity
    , errMsg : String
    , errVisibility : ErrVisibility
    , errBehavior : ErrBehavior
    }



{-| Creates a `Form` that is set up in a state which assumes
that the user hasn't filled in this particular form yet (therefore, it is `Unchecked`).

Because there are many possible representations for empty `Field`s out there,
you have to enter in what 'empty' means for the value itself.

A `Form.empty` should always be used with `Field.empty`.

    initModel : Model
    initModel =
        { registerForm = Form.empty registerValidators { username = Field.empty usernameValidators ""
                                                        , email = Field.empty emailValidators  ""
                                                        , tos = Field.empty tosValidators False
                                                        }
        }

-}
empty : ValidatorSet b -> b -> Form b
empty valis val =
    { value = val
    , validators  = valis

    , validity = Unchecked
    , errMsg = ""
    , errVisibility = HideErr
    , errBehavior = TriggeredValidation
    }

{-| Creates a `Form` that is set up in a state which assumes
that the user has filled in this data point before, and therefore assumes it's already`Valid`.

Designed for forms that a user is returning to.

In addition to being `Valid`, the validation behavior is set so that validation errors are set to
show immediately.

    initModel : Model
    initModel =
        { profileForm = Form.prefilled profileValidators { displayName = Field.prefilled displayNameValidators "Dzuk"
                                                           , bio = Field.prefilled bioValidators "Big gay orc."
                                                           , botAccount = Field.prefilled PassValidation False
                                                           , adultAccount = Field.prefilled PassValidation False
                                                           }
        }
-}
prefilled : ValidatorSet b -> b -> Form b
prefilled valis val =
    { value = val
    , validators  = valis

    , validity = Valid
    , errMsg = ""
    , errVisibility = HideErr
    , errBehavior = AlwaysValidation -- prefilled forms should keep the user more clued in to errors.
    }


{-| Take a `Form`, and replaces it's values with the one given. This does not validate the result.

    initialForm = Form.prefilled { displayName = Field.prefilled "Dzuk"
                                   , bio = Field.prefilled "Big gay orc."
                                   , botAccount = Field.prefilled False
                                   , adultAccount = Field.prefilled False
                                   }

    newFormValue = { displayName = Field.prefilled "Someone else"
               , bio = Field.prefilled "Not as cool as Dzuk."
               , botAccount = Field.prefilled False
               , adultAccount = Field.prefilled False
               }

    replaceValues initialForm newFormValue
-}
replaceValues : Form b -> b -> Form b
replaceValues form val = { form | value = val }






{-| Validates every `Field` of a `Form`, then validates the whole `Form` itself.

### Validating the Fields
In order to validate every Field of the form, you have to create a function (`a -> a`) that
takes in the `Form`'s enclosed type, checks all the values, and returns a validated version.

Because a Field can enclose any type, this has to be done manually and by hooking up
`ValidatorSet`s you would have used when validating Fields individually, like below:

```
allFieldValidations : a -> a
allFieldValidations f =
    f
    |> (\v -> { v | displayName = validateAndShowErr displayNameValidation v.displayName } )
    |> (\v -> { v | bio = validateAndShowErr bioValidation v.bio } )
```

### Validating the Form itself
To validate the form itself, you need to create a ValidatorSet for the form
that checks it's contents to make sure all Fields that are validated are correct.

(Once again, because of Elm's strict type system, each check has to be manually put in.)

```
formValidators : ValidatorSet ProfileForm
formValidators =
    DoValidation
        [ ( (\r -> isValid r.displayName
              && isValid r.bio)
            , "Some of your settings are incorrect."
            )
        ]
```
-}
validate : (b -> b)
            -> Form b
            -> Form b
validate fieldValidation model =
    let
        -- validate each field individually first
        newVals = fieldValidation model.value
        newModel = { model | value = newVals }
    in
        -- validate the whole field structure
        Validatable.validateAndToggleErr newModel





















-- moving data around -------------------------------------------------



{-| A function that sets a Field to a `Form`'s `.value`.
-}
type alias FieldSetter a b = b -> Field a -> b

{-| A function that gets a Field from a `Form`'s `.value`.
-}
type alias FieldGetter a b = b -> Field a

{-| Gets a `Field` from a `Form` via a `FieldGetter` (ie. `.username`).
-}
getField : FieldGetter a b -> Form b -> Field a
getField accessor form = accessor form.value

{-| Gets a `Field`'s value from a `Form` via a `FieldGetter` (ie. `.username`).
-}
getFieldVal : FieldGetter a b -> Form b -> a
getFieldVal accessor form =
    let
        field = accessor form.value
    in
        field.value







-- event handlers -------------------------------------------------


{-| Takes an `(a -> msg)`, updates the `Field` value to that `a` and performs
validation on both the field and the form.

(This is intended to be used in event handlers that return values, like `onInput`.)

- `a` is the `Field` data type.
- `b` is the `Form` data type.

```
    Html.input
        (   [ class "ps--text-input"
            , type_ "text"
            , onInput <| Form.updateField formValidators fieldValidators field form setter onChange
        )
        [ Html.text field.value ]
```

-}
updateField : Field a
            -> Form b
            -> FieldSetter a b
            -> (Form b -> msg)
            -> (a -> msg)
updateField field form setter onChange =
    -- Field
    Field.replaceValue field >>
    Validatable.validate >>
    -- Form values
    setter form.value >>
    -- Form
    replaceValues form >>
    Validatable.validateAndHideErr >>
    onChange



{-| Takes an `(a -> msg)`, updates the `Field` value to
that `a`. This **does not** perform validation.

This is intended to be used in event handlers that return values, like
`onInput`.

The reason this doesn't validate is because some
inputs (like radio buttons) should not need to be validated,
therefore validation does not need to be performed when these certain types of
inputs change.

- `a` is the `Field` data type.
- `b` is the `Form` data type.



-}
updateFieldWithoutValidation : Field a
                            -> Form b
                            -> FieldSetter a b
                            -> (Form b -> msg)
                            -> (a -> msg)
updateFieldWithoutValidation field form setter onChange =
    -- Field
    Field.replaceValue field >>
    -- Form values
    setter form.value >>
    -- Form
    replaceValues form >>
    onChange




{-| Takes a `(msg)`, updates the `Field` value with a specific value given to it
and performs validation on both the field and the form.

(This is intended to be used in event handlers that don't return values but
need something passed to identify what has changed, like `onClick` in radio inputs.)

- `a` is the `Field` data type.
- `b` is the `Form` data type.

```
    Html.input
        (   [ class "ps--text-input"
            , type_ "text"
            , onInput <| Form.updateField formValidators fieldValidators field form setter onChange
        )
        [ Html.text field.value ]
```

-}
updateFieldManually : a
                    -> Field a
                    -> Form b
                    -> FieldSetter a b
                    -> (Form b -> msg)
                    -> msg
updateFieldManually newValue field form setter onChange =
    newValue
    -- Field
    |> Field.replaceValue field
    |> Validatable.validate

    -- Form values
    |> setter form.value

    -- Form
    |> replaceValues form
    |> Validatable.validateAndHideErr

    |> onChange




{-| updateFieldWithValue but does not perform validation.

This is intended to be used in event handlers that don't return values but
need something passed to identify what has changed, like `onClick` in radio inputs.

The reason this doesn't validate is because some
inputs (like radio buttons) should not need to be validated,
therefore validation does not need to be performed when these certain types of
inputs change.
-}
updateFieldManuallyWithoutValidation : a
                                    -> Field a
                                    -> Form b
                                    -> FieldSetter a b
                                    -> (Form b -> msg)
                                    -> msg
updateFieldManuallyWithoutValidation newValue field form setter onChange =
    newValue
    -- Field
    |> Field.replaceValue field

    -- Form values
    |> setter form.value

    -- Form
    |> replaceValues form

    |> onChange

{-| The series of basic data transformations that to be done to a `Form`
the time the user performs an action that is meant to validate the form
and trigger any potential validation errors to show.

(This should be used in event handlers that don't give a value,
like `onBlur`)

- `a` is the `Field` data type.
- `b` is the `Form` data type.

```
    Html.input
        (   [ class "ps--text-input"
            , type_ "text"
            , onInput <| Form.updateField formValidators fieldValidators field form setter onChange
            , onBlur <| Form.showAnyFieldErr formValidators fieldValidators field form setter onChange
            ]
        )
        [ Html.text field.value ]
```
-}
showAnyFieldErr : Field a
                -> Form b
                -> FieldSetter a b
                -> (Form b -> msg)
                -> msg
showAnyFieldErr field form setter onChange =
    onChange
    -- Form
    <| Validatable.validateAndHideErr
    <| replaceValues form
    -- Form value
    <| setter form.value
    -- Field
    <| Validatable.possiblyShowErr
    <| Validatable.validate field
