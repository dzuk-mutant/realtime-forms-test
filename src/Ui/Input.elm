module Ui.Input exposing ( OptionalLabel(..)

                         , TextInputStruct
                         , text
                         , textCounted
                         , password
                         , email
                         , search
                         , multiline
                         , multilineCounted

                         , checkbox
                         )

{-| A module governing all of the form elements.

# Common input arguments
All of the inputs' arguments consists of a list for inserting Html Attributes
and a structure containing key aspects of the data, function and presentation
of the input.

Here are arguments that commonly appear on inputs:

## HTML-related
- `id` : The actual HTML `id` attribute of the input. You need to make sure
these are differentiated so user focusing and keyboard control works properly.

## User guidance
- `required`: For telling screenreaders whether it is a required input.
This is only for screenreaders - it does not tell sighted users if it's required, nor does it affect validation.

- `label`: The label that appears above the input. It can be different types depending on whether hiding a label is permitted or not.
- `name`: Sort of like a label, for inputs that don't use labels (like checkboxes.)
- `helper`: Explanation text to guide the user through what to do with this input or how it works.
- `placeholder`: Placeholder content for the input (for text or select).
- `instruction`: Like a placeholder, but for telling the user *what* to do instead of *how* to do it.

## Data
- `form`: The form model that this input is a part of.
- `field`: The record access operator that points to the Field this input represents. (ie. `.username`)
- `options`: A list of options for inputs that inputs that are based on discrete options.
- `validators`: A list of validator functions and error messages.
- `setter`: A function to set this input's data in the form's model.

## Msg
- `onChange`: The Msg that gets activated when the form changes.
Use this to keep your form's model in sync with your inputs as they are being edited.


-----------

# Data Types
@docs OptionalLabel

# Text
@docs TextInputStruct

## Single line text inputs
@docs text, textCounted, password, email, search

## Multiline text inputs
@docs multiline, multilineCounted

# Discrete option pickers
In Parastat, normal radio buttons should not be used
in regular circumstances, you should use either a select
or radioGridVisual instead.

## Select
@docs select

## Radio Grids
@docs radioGrid, RadioGridOptions, radioGridTextOption, radioGridDescOption, radioGridVisualOption

# Other inputs
@docs checkbox, upload
-}

import Dict
import I18Next exposing (Translations)
import Form exposing (FieldGetter, FieldSetter, Form, getField, showAnyFieldErr, updateField)
import Form.Field as Field exposing (Field)
import Form.Validatable as Validatable exposing (ErrVisibility(..), Validatable, Validity(..), ifShowErr)
import Html exposing (Attribute, Html, a, b, div, fieldset, input, label, legend, optgroup, option, select, span, text, textarea)
import Html.Attributes exposing (checked, class, classList, disabled, for, id, maxlength, name, placeholder, selected, tabindex, type_, value)
import Html.Attributes.Aria exposing (ariaChecked, ariaHidden, ariaLabel, ariaLive, ariaRequired, role)
import Html.Events exposing (onBlur, onCheck, onClick, onInput)
import Svg exposing (Svg)
import Ui.Label as Label exposing (desc, label, labelDiv, liveHelperDisabled, liveHelperInvalid)
import Ui.Layout as Layout
import Ui.Symbol as Symbol exposing (checkboxChecked, checkboxIntermediate, dropdown, warning)


-----------------------





-- little input components -------------------------------------------------

{- These are chunks of HTML or HTML Attributes that are used
repeatedly across multiple inputs.
-}

{-| For when labels are optional:
    - VisibleLabel (ones that appear above the entry)
    - HiddenLabel (ones that aren't visible to sighted users because
      the role of the asssociated input exists in context)
-}
type OptionalLabel
    = VisibleLabel String
    | HiddenLabel String

maybeVisibleLabel : String -> OptionalLabel -> List (Html msg)
maybeVisibleLabel id label = case label of
    VisibleLabel s -> [ Label.label id s ]
    _ -> []

maybeVisibleLabelLegend : OptionalLabel -> List (Html msg)
maybeVisibleLabelLegend label = case label of
    VisibleLabel s -> [ Label.labelLegend s ]
    _ -> []

maybeHiddenLabel : OptionalLabel -> List (Attribute msg)
maybeHiddenLabel label = case label of
    HiddenLabel s -> [ ariaLabel s ]
    _ -> []

maybeHiddenLabelLegend : OptionalLabel -> List (Html msg)
maybeHiddenLabelLegend label = case label of
    HiddenLabel s -> [ Label.labelLegendHidden s ]
    _ -> []


maybeHelperText : Maybe String -> List (Html msg)
maybeHelperText helper = case helper of
    Nothing -> []
    Just s -> [ Label.desc s ]

maybeInvalidSym : Field a -> List (Svg msg)
maybeInvalidSym field = case Validatable.ifShowErr field of
    True -> [ Symbol.warning ]
    False -> []









-- text inputs -------------------------------------------------

{-| Internal type used to determine what kind
of text input is being created.
-}
type TextInputType
    = SingleLineText String
    | MultiLineText

{-| A common set of parameters for all Text inputs.
-}
type alias TextInputStruct msg b =
    { id : String
    , required : Bool
    , onChange : Form b -> msg
    , label : OptionalLabel
    , helper : Maybe String
    , placeholder : Maybe String

    , form : Form b
    , field : Form.FieldGetter String b
    , setter : Form.FieldSetter String b
    , translations : List Translations
    }

{-| The basis for all single-line text inputs.
-}
basicTextInput : List (Attribute msg)
        -> TextInputStruct msg b
        -> Maybe Int
        -> TextInputType
        -> Html msg
basicTextInput attrs { id, required, label, helper, placeholder, onChange, form, field, setter, translations } counter inputType =
    let
        realField = getField field form

        maybePlaceholder = case placeholder of
            Just p -> [ Html.Attributes.placeholder p ]
            Nothing -> []

        maybeCounter = case counter of
            Nothing -> []
            Just c ->
                [ div [ class "ps--text-counter"
                      , ariaHidden True -- should be hidden from screenreaders
                      ]
                    [ div [ class "text" ]
                        [ Html.text <| (String.fromInt <| String.length realField.value) ++ " / " ++ (String.fromInt c)
                        ]
                    ]
                ]

        commonInputAttrs =
            [ value realField.value
            , onInput <| Form.updateField realField form setter onChange
            , onBlur <| Form.showAnyFieldErr realField form setter onChange
            , Html.Attributes.id id
            , ariaRequired required
            , classList [ ( "invalid", Validatable.ifShowErr realField )
                        ]
            ]
            ++ attrs
            ++ maybePlaceholder
            ++ maybeHiddenLabel label


    in
        Html.fieldset
            [ class "ps--form-block"
            ]
                -- label
            (   maybeVisibleLabel id label
                -- helper text
                ++ maybeHelperText helper
                -- the input itself
                ++  [ div [ class "ps--text-input-wrapper"
                          , classList [ ( "singleline", inputType /= MultiLineText )
                                      , ( "multiline", inputType == MultiLineText )
                                      , ( "uncounted", counter == Nothing )
                                      , ( "counted", counter /= Nothing )
                                      ]
                          ]
                        ([ case inputType of
                                SingleLineText singleLineType ->
                                    Html.input
                                        (   [ class "ps--text-input"
                                            , type_ singleLineType
                                            ]
                                            ++ commonInputAttrs
                                        )
                                        [ Html.text realField.value ]


                                MultiLineText ->
                                    Html.textarea
                                        (   [ class "ps--text-multiline" ]
                                            ++ commonInputAttrs
                                        )
                                        [ Html.text realField.value ]

                        , div [ class "ps--sym-area" ] ( maybeInvalidSym realField )
                        ]
                        ++ maybeCounter
                        )
                    ]
                -- validation error message
                ++ Label.liveHelperInvalid translations realField
            )






{-| Single-line text input that has no particular
semantic orientation.
-}
text : List (Attribute msg)
        -> TextInputStruct msg b
        -> Html msg
text attrs struct =
    basicTextInput attrs struct Nothing (SingleLineText "text")

{-| Single-line text input with a counter (that has no particular
semantic orientation).
-}
textCounted : Int
            -> List (Attribute msg)
            -> TextInputStruct msg b
            -> Html msg
textCounted counter attrs struct =
    basicTextInput attrs struct (Just counter) (SingleLineText "text")


{-| Single-line text input that's semantically oriented
for password input.
-}
password : List (Attribute msg)
        -> TextInputStruct msg b
        -> Html msg
password attrs struct =
    basicTextInput attrs struct Nothing (SingleLineText "password")


{-| Single-line text input that's semantically oriented
for email input.
-}
email : List (Attribute msg)
        -> TextInputStruct msg b
        -> Html msg
email attrs struct =
    basicTextInput attrs struct Nothing (SingleLineText "email")


{-| Single-line text input that's semantically oriented
for search input.
-}
search : List (Attribute msg)
        -> TextInputStruct msg b
        -> Html msg
search attrs struct =
    basicTextInput attrs struct Nothing (SingleLineText "search")



{-| A multi-line text input.
-}
multiline : List (Attribute msg)
        -> TextInputStruct msg b
        -> Html msg
multiline attrs struct =
    basicTextInput attrs struct Nothing (MultiLineText)


{-| A multi-line text input with a counter.
-}
multilineCounted : Int
                -> List (Attribute msg)
                -> TextInputStruct msg b
                -> Html msg
multilineCounted counter attrs struct =
    basicTextInput attrs struct (Just counter) (MultiLineText)


















{-| The standard checkbox for Parastat.

Visible labels are mandatory so labels are a `String` type
instead of an `OptionalLabel` type.
-}
checkbox : List (Attribute msg)
        -> { id : String
           , required : Bool
           , label : String
           , helper : Maybe String

           , onChange : Form b -> msg
           , form : Form b
           , field : Form.FieldGetter Bool b
           , setter : Form.FieldSetter Bool b
           , translations : List Translations
           }
        -> Html msg

checkbox attrs { id, required, label, helper, onChange, form, field, setter, translations } =
    let
        realField = getField field form
    in
        Html.fieldset [ class "ps--form-block"]
            [ Html.div
                [ class "ps--checkbox-wrapper"
                , classList [ ("invalid", Validatable.ifShowErr realField )
                            ]
                ]

                -- the 'real', invisible checkbox

                -- the label for this input is contained in ARIA label.
                -- The visible label is hidden to SRs.
                ( [Html.input
                    [ type_ "checkbox"
                    , class "ps--checkbox"
                    , Html.Attributes.id id
                    , onCheck <| Form.updateField realField form setter onChange
                    , onBlur <| Form.showAnyFieldErr realField form setter onChange
                    , checked realField.value
                    , ariaRequired required
                    , ariaLabel label
                    ]
                    []]

                -- the 'label' that contains the checkbox graphic and the label.

                -- the label text is hidden to SRs because it repeats over when the user
                -- comes down from the input to the text stuff.
                ++ [Html.label [ class "label", for id ]
                    [ span [ class "text", ariaHidden True ]
                        ( [Label.labelDiv label]
                        )
                    , Html.div [ class "ps--sym-area-free" ]
                        [ Symbol.warning ]
                    , Html.div [ class "ps--checkbox-graphic" ]
                        [ Symbol.checkboxChecked
                        , Symbol.checkboxIntermediate
                        ]
                    ]]
                -- helper
                ++ maybeHelperText helper
                -- invalid helper
                ++ Label.liveHelperInvalid translations realField

                )
            ]
