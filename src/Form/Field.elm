module Form.Field exposing ( Field
                          , empty
                          , prefilled

                          , getValue
                          , replaceValue
                          )

{-| A module that encapsulates user-submitted data with Validatable metadata.

# Field
@docs Field

# Creating Fields
@docs empty, prefilled

# Manipulation
@docs getValue, replaceValue

-}

import Form.Validatable exposing ( Validity(..)
                                 , ErrVisibility(..)
                                 , ErrBehavior(..)
                                 )


{-| A data type enclosing user inputs alongside validation information
on that input.

(See `Form.Validatable.Validatable` to understand this record structure.)
-}
type alias Field a =
    { value : a
    , validity : Validity
    , errMsg : String
    , errVisibility : ErrVisibility
    , errBehavior : ErrBehavior
    }

{-| Creates a `Field` that is set up in a state which assumes
that the user hasn't filled in this particular data point yet (therefore, it is `Unchecked`).

Because there are many possible representations of what empty is,
you have to enter in what 'empty' means for the value itself.

A `Field.empty` should always be used inside a `Form.empty`.

    initModel : Model
    initModel =
        { registerForm = Form.empty { username = Field.empty ""
                                    , email = Field.empty ""
                                    , option = Field.empty Nothing
                                    , tos = Field.empty False
                                    }
        }
-}
empty : a -> Field a
empty val =
    { value = val
    , validity = Unchecked
    , errMsg = ""
    , errVisibility = HideErr
    , errBehavior = RevealedValidation
    }


{-| Creates a `Field` that is set up in a state which assumes
that the user has filled in this data point before and that it's `Valid`.

Designed for `Form`s that a user is returning to.

Because it's assumed the user is returning to it, validation errors will
show immediately.

A `Field.prefilled` should always be used inside a `Form.prefilled`.

    initModel : Model
    initModel =
        { profileForm = Form.prefilled { displayName = Field.prefilled "Dzuk"
                                       , bio = Field.prefilled "Big gay orc."
                                       , botAccount = Field.prefilled False
                                       , adultAccount = Field.prefilled False
                                       }
        }
-}
prefilled : a -> Field a
prefilled val =
    { value = val
    , validity = Valid
    , errMsg = ""
    , errVisibility = ShowErr
    , errBehavior = AlwaysValidation
    }


{-| Returns a field's value.

    fieldy = Field.prefilled "Hi"

    Field.getValue fieldy == "Hi"
-}
getValue : Field a -> a
getValue field = field.value

{-| Take a Field, and replaces it's value with the one given.

    fieldy = Field.prefilled "Hi"

    getValue fieldy == "Hi"
    getValue <| replaceValue fieldy "Bye" == "Bye"
-}
replaceValue : Field a -> a -> Field a
replaceValue field val = { field | value = val }
