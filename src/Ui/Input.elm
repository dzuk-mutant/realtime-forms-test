module Ui.Input exposing ( OptionalLabel(..)

                         , TextInputStruct
                         , text
                         , textCounted
                         , password
                         , email
                         , search
                         , multiline
                         , multilineCounted

                         , select

                         , radioGrid
                         , RadioGridOptions(..)
                         , radioGridTextOption
                         , radioGridDescOption
                         , radioGridVisualOption

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
import Form exposing (FieldGetter, FieldSetter, Form, getField, showAnyFieldErr, updateField)
import Form.Field as Field exposing (Field)
import Form.Validatable as Validatable exposing (ErrVisibility(..), Validatable, Validity(..), ifShowErr)
import Form.Validator as Validator exposing (ValidatorSet)
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
    , formValidators : ValidatorSet b
    , fieldValidators : ValidatorSet String

    }

{-| The basis for all single-line text inputs.
-}
basicTextInput : List (Attribute msg)
        -> TextInputStruct msg b
        -> Maybe Int
        -> TextInputType
        -> Html msg
basicTextInput attrs { id, required, label, helper, placeholder, onChange, form, field, setter, formValidators, fieldValidators } counter inputType =
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
            , onInput <| Form.updateField formValidators fieldValidators realField form setter onChange
            , onBlur <| Form.showAnyFieldErr formValidators fieldValidators realField form setter onChange
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
                ++ Label.liveHelperInvalid realField
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











-- discrete option inputs -------------------------------------------------


{-| Internal data type for interfacing with discrete options in
an HTML input where the user selects one thing out of many.

- `id` : The identifier in HTML.
- `value` : The value in Elm that the HTML identifier actually correlates to.
-}
type alias DiscreteOption r a =
    { r | id : String
        , value : a
    }


{-| Internal helper function that takes a value that's a Maybe
and returns a corresponding string ID from a list of DiscreteOptions.

If nothing matching is found, it returns a blank string.
-}
maybeDataToOption : List (DiscreteOption r a) -> Maybe a -> String
maybeDataToOption optionList target =
    case target of
        Nothing -> ""
        Just t -> case List.head <| List.filter (\o -> o.value == t) optionList of
            Nothing -> ""
            Just v -> v.id

{-| Internal helper that takes a value and returns a corresponding
string ID from a list of DiscreteOptions.

If nothing matching is found, it returns a blank string.
-}
dataToOption : List (DiscreteOption r a) -> a -> String
dataToOption optionList target =
    case List.head <| List.filter (\o -> o.value == target) optionList of
            Nothing -> ""
            Just v -> v.id

{-| Takes a string ID and returns a corresponding value from a list of
DiscreteOptions.

It may not be able to return anything at all, so it's a maybe.
-}
optionToData : List (DiscreteOption r a) -> String -> Maybe a
optionToData optionList target =
    case List.head <| List.filter (\o -> o.id == target) optionList of
        Nothing -> Nothing
        Just i -> Just i.value













{-| Internal data type representing an option in a select.
Is used as a `DiscreteOption`.
-}
type alias SelectOption a =
    { id : String
    , value : a
    , label : String
    }

{-| Internal helper that creates a list of SelectOptions from a developer's input.
-}
createSelectOptions : List (a, String) -> List (SelectOption a)
createSelectOptions list =
    let
        createOpts = (\l ->
            let
                id = String.fromInt <| Tuple.first l
                stuff = Tuple.second l

                value = Tuple.first <| stuff
                label = Tuple.second <| stuff
            in
                { id = id
                , value = value
                , label = label
                })
    in

        list
        |> List.indexedMap Tuple.pair
        |> List.map createOpts




{-| A standard HTML select input.

Options are a list of tuples containing the value the option
represents and a label the user will see for that particular option.

The value associated with this input will be `Just a` when the user
has selected something (or you prefill the value), that `a` being
something that you put in this list.

```
, options = [ (AutoLoading, "Auto (Infinite scroll)")
            , (ManualLoading, "Manual")
            ]
```


The field in this one is a `Maybe a` because `Nothing`
represents an un-filled select input, like if you're
presenting a blank form to a user.

If the value is `Nothing`, then the `instruction` text will
appear in the input instead of a value.

-}
select : List (Attribute msg)
     -> { id : String
        , required : Bool
        , label : OptionalLabel
        , helper : Maybe String
        , instruction : String
        , options : List (a, String)

        , onChange : Form b -> msg
        , form : Form b
        , field : Form.FieldGetter (Maybe a) b
        , setter : Form.FieldSetter (Maybe a) b
        , formValidators : ValidatorSet b
        , fieldValidators : ValidatorSet (Maybe a)
        }
     -> Html msg
select attrs { id, required, label, helper, instruction, options, onChange, form, field, setter, formValidators, fieldValidators } =
    let
        realField = getField field form
        realOptions = createSelectOptions options

        -- When there's no pre-filled data, this is a disabled options
        -- that instructs the user on what to do.
        instructionOption =
            [ Html.option
                [ disabled True
                , selected <| realField.value == Nothing
                , value "" ]
                [ Html.text instruction ]
            ]

        actualOptions =
            ( instructionOption -- the first thing the user sees if blank. Not meant to be selectable.
            ++ selectOptionView realField.value realOptions
            )

    in
        Html.fieldset
            [ class "ps--form-block"
            ]
                -- label
            (   maybeVisibleLabel id label

                -- helper text
                ++ maybeHelperText helper

                -- wrapper
                ++ [ div [ class "ps--select-input-wrapper" ]
                        -- the input itself
                        [ Html.select
                                (   [ class "ps--select-input"
                                    , Html.Attributes.id id
                                    , onInput (optionToData realOptions >> (Form.updateField formValidators fieldValidators realField form setter onChange))
                                    , onBlur <| Form.showAnyFieldErr formValidators fieldValidators realField form setter onChange
                                    , classList [ ("invalid", Validatable.ifShowErr realField) ]
                                    , ariaRequired required
                                    ]
                                    ++ attrs
                                    ++ maybeHiddenLabel label
                                )
                                -- options
                                ( actualOptions )

                        -- sym area
                        , div [ class "ps--sym-area" ]
                            ( [Symbol.dropdown]
                            ++ maybeInvalidSym realField

                            )
                        ]
                    ]

                -- uncomment to debug
                --++ [Html.div [] [ Html.text <| maybeDataToOption realOptions realField.value ]]

                -- invalid helper
                ++ Label.liveHelperInvalid realField
            )





{-| Internal helper function that generates a
user-selectable option that appears within a select input.
-}
selectOptionView : Maybe a -> List (SelectOption a) -> List (Html msg)
selectOptionView val selectOptions =
    let
        makeOptions = (\x ->
            Html.option
                [ selected (Just x.value == val)
                , value x.id -- required for onInput.
                ]
                [ Html.text x.label ]
            )
    in
        List.map makeOptions selectOptions















{-| An encapsulation of the different types of options that can
be used in a radioGrid.

- `RadioGridText`: Radio grid buttons with a label.
    - Create options with `radioGridTextOption`.
- `RadioGridDesc`: Radio grid buttons with a label and a description.
    - Create options with `radioGridDescOption`.
- `RadioGridVisual`: Radio grid buttons with a visual presentation.
    - Create options with `radioGridVisualOption`.
-}
type RadioGridOptions a msg
    = RadioGridText (List (RadioGridTextOption a))
    | RadioGridDesc (List (RadioGridDescOption a))
    | RadioGridVisual (List (RadioGridVisualOption a msg))



{- Internal types for the different radio grid options.

These are what the user inputs.
-}

type alias RadioGridTextOption a =
    { value : a
    , label : String
    }

type alias RadioGridDescOption a =
    { value : a
    , label : String
    , desc : String
    }

type alias RadioGridVisualOption a msg =
    { value : a
    , label : String
    , visual : Html msg
    }


{- Internal types for the different radio grid options that
get used in the final HTML output.

These are used all as a `DiscreteOption`s.
-}

type alias RadioGridTextOptionActual a =
    { id : String
    , value : a
    , label : String
    }

type alias RadioGridDescOptionActual a =
    { id : String
    , value : a
    , label : String
    , desc : String
    }

type alias RadioGridVisualOptionActual a msg =
    { id : String
    , value : a
    , label : String
    , visual : Html msg
    }





{-| A function that constructs a `RadioGridTextOption` for radioGrids.
-}
radioGridTextOption : a -> String -> RadioGridTextOption a
radioGridTextOption value label =
    { value = value
    , label = label
    }

{-| Internal helper that creates a list of text radioGrid options from a developer's input.
-}
createRadioGridTextOptions : List (RadioGridTextOption a) -> List (RadioGridTextOptionActual a)
createRadioGridTextOptions list =
    let
        createOpts = (\l ->
            let
                id = String.fromInt <| Tuple.first l
                stuff = Tuple.second l
            in
                { id = id
                , value = stuff.value
                , label = stuff.label
                })

    in
        list
        |> List.indexedMap Tuple.pair
        |> List.map createOpts





{-| A function that constructs a `RadioGridDescOption` for radioGrids.
-}
radioGridDescOption : a -> String -> String -> RadioGridDescOption a
radioGridDescOption value label desc =
    { value = value
    , label = label
    , desc = desc
    }

{-| Internal helper that creates a list of Text + Desc radioGrid options from a developer's input.
-}
createRadioGridDescOptions : List (RadioGridDescOption a) -> List (RadioGridDescOptionActual a)
createRadioGridDescOptions list =
    let
        createOpts = (\l ->
            let
                id = String.fromInt <| Tuple.first l
                stuff = Tuple.second l
            in
                { id = id
                , value = stuff.value
                , label = stuff.label
                , desc = stuff.desc
                })

    in
        list
        |> List.indexedMap Tuple.pair
        |> List.map createOpts






{-| A function that constructs a `RadioGridVisualOption` for radioGrids.
-}
radioGridVisualOption : a -> String -> Html msg -> RadioGridVisualOption a msg
radioGridVisualOption value label visual =
    { value = value
    , label = label
    , visual = visual
    }


{-| Internal helper that creates a list of visual radioGrid options from a developer's input.
-}
createRadioGridVisualOptions : List (RadioGridVisualOption a msg) -> List (RadioGridVisualOptionActual a msg)
createRadioGridVisualOptions list =
    let
        createOpts = (\l ->
            let
                id = String.fromInt <| Tuple.first l
                stuff = Tuple.second l
            in
                { id = id
                , value = stuff.value
                , label = stuff.label
                , visual = stuff.visual
                })

    in
        list
        |> List.indexedMap Tuple.pair
        |> List.map createOpts







{-| A set of radio buttons, but instead of circular icons
representing whether something is active, there are contents
arranged in a grid.

```
Input.radioGrid []
    { id = "labelAndHinting"
    , required = True
    , label = VisibleLabel "Label & shape hinting preference"
    , helper = Just "Changes the appearance of certain buttons and interactable areas."
    , options = RadioGridVisual [ Input.radioGridVisualOption (PrefersIcon, LessShapeHinting) "Icons" iconLessPreview
                                , Input.radioGridVisualOption (PrefersText, LessShapeHinting) "Text" textLessPreview
                                , Input.radioGridVisualOption (PrefersIcon, MoreShapeHinting) "Icons with shape hinting" iconMorePreview
                                , Input.radioGridVisualOption (PrefersText, MoreShapeHinting) "Text with shape hinting" textMorePreview
                                ]

    , onChange = VisualFormChanged
    , form = form
    , field = .labelAndHinting
    , setter = (\v x -> { v | labelAndHinting = x })
    }
```

See `RadioGridOptions` for how to add options.

Because this is a radio, there always has to have a selected option
and it does not have validation inputs.
-}
radioGrid : List (Attribute msg)
        -> { id : String
            , required : Bool
            , label : OptionalLabel
            , helper : Maybe String
            , options : RadioGridOptions a msg

            , onChange : Form b -> msg
            , form : Form b
            , field : Form.FieldGetter a b
            , setter : Form.FieldSetter a b
            }

        -> Html msg

radioGrid attrs { id, required, label, helper, options, onChange, form, field, setter } =
    let
        realField = getField field form

        renderedOptions = case options of
            RadioGridText opts ->
                radioTextView id realField.value opts realField form setter onChange

            RadioGridDesc opts ->
                radioDescView id realField.value opts realField form setter onChange

            RadioGridVisual opts ->
                radioVisualView id realField.value opts realField form setter onChange

    in
        Html.fieldset
            [ class "ps--form-block"]

                -- label
            (   maybeVisibleLabelLegend label

                -- label (hidden variant)
                -- (you can't use ariaLabel here)
                ++ maybeHiddenLabelLegend label

                -- helper text
                ++ maybeHelperText helper

                -- wrapper
                ++ [    Html.div
                            [ class "ps--radio-grid-wrapper"
                            , classList [ ("invalid", Validatable.ifShowErr realField )
                                        ]
                            ]
                            [ Html.div [ class "container" ]
                                ( renderedOptions
                                --++ Layout.flexGridDummies 2
                                )
                            ]
                   ]
                -- debug area
                --++ [ Html.div [] [ Html.text <| "current val: " ++ (dataToOption realOptions realField.value) ] ]

                -- validation error message
                ++ Label.liveHelperInvalid realField
            )


{-| Basic structure for all radioGrid buttons.
-}
radioGridButtonBasic : a
                -> a
                -> String
                -> String
                -> Maybe String
                -> Field a
                -> Form b
                -> Form.FieldSetter a b
                -> (Form b -> msg)
                -> List (Html.Attribute msg)
                -> List (Html msg)
                -> List (Html msg)
                -> Html msg
radioGridButtonBasic val selectedVal id idNum srLabel realField form setter onChange attrs labelHtml extHtml =
    let
        maybeSRLabel = case srLabel of
            Nothing -> []
            Just a -> [ ariaLabel a ]
    in
        Html.div [ class "option-block-wrapper"]
            [ Html.input
                (   [ type_ "radio"
                    , name id
                    , Html.Attributes.id <| id ++ idNum
                    , value idNum
                    , checked (val == selectedVal)  -- whether this is the selected one.

                    , onClick <| Form.updateFieldManuallyWithoutValidation val realField form setter onChange
                    , class "radio-button"
                    ]
                    ++ maybeSRLabel
                )
                []
            ,   Html.label
                (   [ class "option-block"
                    , class <| (\v -> case selectedVal == v of
                                    True -> "checked"
                                    False -> "unchecked") val
                                    -- styles are used instead of :checked because Safari doesn't
                                    -- seem to know how to handle it and gets confused.
                    , for <| id ++ idNum
                    ]
                    ++ attrs
                )
                [ Html.div [ class "contents" ]
                    ( [ Html.div [ class "label" ] labelHtml ]
                    ++ extHtml
                    )
                ]
            ]


{-| Internal helper function that inserts an blank into a visualRadio
if the options given are an odd number.
-}
radioGridInsertEvenBlank : List (Html msg) -> List (Html msg)
radioGridInsertEvenBlank contents =
    let
        count = List.length contents
    in
        case modBy 2 count of
            0 -> contents
            _ -> (contents ++ [Html.div [ class "even-blank" ] []])



{-| Internal helper function that generates a 'text' button for a radio grid.
-}
radioTextView : String
                -> a
                -> List (RadioGridTextOption a)
                -> Field a
                -> Form b
                -> Form.FieldSetter a b
                -> (Form b -> msg)
                -> List (Html msg)
radioTextView id selectedVal options realField form setter onChange =
    let
        makeOptions = (\opt ->
            radioGridButtonBasic opt.value selectedVal id opt.id Nothing realField form setter onChange
                [ class "text" ]
                [ Html.text opt.label ]
                []
                )
    in
        options
        |> createRadioGridTextOptions
        |> List.map makeOptions
        |> radioGridInsertEvenBlank


{-| Internal helper function that generates a 'desc' button for a radio grid.
-}
radioDescView : String
                -> a
                -> List (RadioGridDescOption a)
                -> Field a
                -> Form b
                -> Form.FieldSetter a b
                -> (Form b -> msg)
                -> List (Html msg)
radioDescView id selectedVal options realField form setter onChange =
    let
        makeOptions = (\opt ->
            radioGridButtonBasic opt.value selectedVal id opt.id Nothing realField form setter onChange
                [ class "desc" ]
                [ Html.text opt.label ]
                [ Html.div [class "desc"]
                    [ Html.text opt.desc ]
                ])
    in
        options
        |> createRadioGridDescOptions
        |> List.map makeOptions
        |> radioGridInsertEvenBlank



{-| Internal helper function that generates a 'visual' button for a radio grid.
-}
radioVisualView : String
                -> a
                -> List (RadioGridVisualOption a msg)
                -> Field a
                -> Form b
                -> Form.FieldSetter a b
                -> (Form b -> msg)
                -> List (Html msg)
radioVisualView id selectedVal options realField form setter onChange =
    let
        makeOptions = (\opt ->

            radioGridButtonBasic opt.value selectedVal id opt.id (Just opt.label) realField form setter onChange
                [ class "visual"
                ]
                -- container for quarantining the positioning of inner contents.
                [ Html.div
                    [ class "container"
                    , ariaHidden True -- what happens in the preview stays in the preview
                    ]
                    [ opt.visual ]
                ]
                -- non SR friendly label
                [ Html.div [class "visual-label"]
                    [ Html.text opt.label ]

                ])
    in
        options
        |> createRadioGridVisualOptions
        |> List.map makeOptions
        |> radioGridInsertEvenBlank






















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
           , formValidators : ValidatorSet b
           , fieldValidators : ValidatorSet Bool
           }
        -> Html msg

checkbox attrs { id, required, label, helper, onChange, form, field, setter, formValidators, fieldValidators } =
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
                    , onCheck <| Form.updateField formValidators fieldValidators realField form setter onChange
                    , onBlur <| Form.showAnyFieldErr formValidators fieldValidators realField form setter onChange
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
                ++ Label.liveHelperInvalid realField

                )
            ]
