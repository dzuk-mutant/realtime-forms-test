module Ui.Button exposing ( miniIcon
                          , miniText
                          , miniFlex
                          , medium
                          , large
                          , largeEndAligned

                          , submit
                          , save
                          )

{-| A module that covers buttons.

## Mini (24px)
Small buttons designed for specific high-density areas like Action Toolbars.
They can only have text or icons, not both.

@docs miniIcon, miniText, miniFlex

## Medium (32px)
@docs medium

## Large (48px)
@docs large, largeEndAligned

## Save/Submit buttons
Buttons specifically for saving and submitting user information within forms.

Because of Parastat's validation system, these buttons have a much
more complex input structure than typical buttons.

@docs save, submit

-}

import Html exposing (Attribute, Html, button, div, node, span, text)
import Html.Attributes exposing (class, classList, type_)
import Html.Attributes.Aria exposing (ariaLabel)
import Html.Events exposing (onClick, onSubmit)
import Svg exposing (Svg)

--------------------

import Form exposing (Form, validate)
import Form.Validatable as Validatable exposing (Validatable, isValid)
import Form.Validator as Validator exposing (ValidatorSet)

import Ui.Label exposing (liveHelperDisabled)
import Ui.Symbol as Symbol exposing (ok)



{-| The foundation for all buttons in Parastat.
Buttons in Parastat can have either icons, text, or both.

This function should not be used by itself, it's descendants should be used instead.

There should always be a string of some kind inputted,
whether it is normal text or screenreader text (MaybeSrText)
-}
basic : List (Html.Attribute msg)
     -> Maybe (Svg msg)
     -> Maybe (String)
     -> Maybe (String)
     -> Html msg


basic attributes maybeIcon maybeText maybeSrText =
    let
        icon = case maybeIcon of
            Just i -> [ i ]
            Nothing -> []

        textString = case maybeText of
            Just t -> [ text t ]
            Nothing -> []

        srText = case maybeSrText of
            Just s -> [ ariaLabel s ]
            Nothing -> []

    in
        button ( attributes ++ srText )
            ( icon ++ textString )







--------------------- NORMAL BUTTONS ---------------------


{-| A mini button that only contains an icon.
-}
miniIcon : List (Html.Attribute msg) -> Svg msg -> String -> Html msg
miniIcon attributes icon srText =
    basic
        ( [ class "ps--btn-mini-icon" ] ++ attributes )
        ( Just icon )
        Nothing
        ( Just srText )


{-| A mini button that only contains text.
-}
miniText : List (Html.Attribute msg) -> String -> Html msg
miniText attributes label =
    basic ( [ class "ps--btn-mini-text" ] ++ attributes )
        Nothing
        ( Just label )
        Nothing


{-| A mini button that is either text or icon
depending on the user's preferences.
-}
miniFlex : List (Html.Attribute msg) -> Svg msg -> String -> Html msg
miniFlex attributes icon label =
    basic
        ( [ class "ps--btn-mini-flex" ] ++ attributes )
        ( Just icon )
        ( Just label )
        ( Just label )


{-| A medium button. Only for text.
-}
medium : List (Html.Attribute msg) -> String -> Html msg
medium attributes label =
    basic
        ( [ class "ps--btn-med-combo" ] ++ attributes )
        Nothing
        ( Just label )
        Nothing

{-| A large button. Only for text.
-}
large : List (Html.Attribute msg) -> String -> Html msg
large attributes label =
    basic
        ( [ class "ps--btn-lrg-combo" ] ++ attributes )
        Nothing
        ( Just label )
        Nothing

{-| A large button that's aligned towards the end.
-}
largeEndAligned : List (Html.Attribute msg) -> String -> Html msg
largeEndAligned attributes label =
    basic
        ( [ class "ps--btn-lrg-combo", class "end-aligned" ] ++ attributes )
        Nothing
        ( Just label )
        Nothing









--------------------- SUBMIT/SAVE BUTTONS ---------------------


{-| Internal helper type for distinguishing Submit and Save buttons.
-}
type SaveSubmitType
    = SubmitButton
    | SaveButton


{-| The main data structure for Submit/Save buttons.
-}
type alias SubmitSaveStruct msg a =
    { label : String

    , onChange : Form a -> msg
    , form : Form a
    , fieldValidations : (a -> a)
    , formValidation : ValidatorSet a
    }

{-| The fundamental structure for submit/save buttons.
-}
submitSaveHelper : List (Html.Attribute msg)
    -> SubmitSaveStruct msg a
    -> SaveSubmitType
    -> Html msg
submitSaveHelper attributes { label, onChange, form, fieldValidations, formValidation } btnType =
        Html.div [ classList [ ("ps--btn-submit", btnType == SubmitButton)
                             , ("ps--btn-save", btnType == SaveButton)
                             ]
                ]
            (   [ Html.div [ ] -- horizontal area
                    [ basic
                            (   [ class "ps--btn-lrg-combo"
                                , classList [ ("end-aligned", btnType == SaveButton)
                                            , ("disabled", not <| Validatable.isValid form)
                                            ]

                                -- stops the button from causing a page refresh when in a <form>
                                , type_ "button"
                                , onClick (onChange <| Form.validate fieldValidations formValidation form)
                                ]
                                ++ attributes
                            )
                            Nothing
                            ( Just label )
                            Nothing
                    -- sym area for successes
                    -- TBA
                    -- , div [ class "sym-area" ] [ Symbol.ok ]
                    ]
                ]
            ++ Ui.Label.liveHelperDisabled form
            )

{-| The button used at the end of blank forms that the user submits.
-}
submit : List (Html.Attribute msg)
    -> SubmitSaveStruct msg a
    -> Html msg
submit attrs struct = submitSaveHelper attrs struct SubmitButton

{-| The button used at the beginning of settings pages that the user
saves their information with.
-}
save : List (Html.Attribute msg)
    -> SubmitSaveStruct msg a
    -> Html msg
save attrs struct = submitSaveHelper attrs struct SaveButton
