module Ui.Label exposing (label
                        , labelLegend
                        , labelLegendHidden
                        , labelDiv
                        , desc
                        , liveHelperInvalid
                        , liveHelperDisabled
                        )
{-|

# Labels
@docs label, labelLegend, labelLegendHidden, labelDiv

# Descriptions
@docs desc

# Helpers
@docs liveHelperInvalid, liveHelperDisabled

-}
import Html exposing (Html, Attribute, div, span, label, text)
import Html.Attributes exposing (class, classList, for)
import Html.Attributes.Aria exposing (ariaLive, ariaHidden)

import Form.Validatable as Validatable exposing (Validatable, Validity(..), ErrVisibility(..), ErrBehavior(..))




{-| A basic text label block.
-}
label : String -> String -> Html msg
label id labelString =
    Html.label [ for id, class "ps--label" ] [ Html.text labelString ]


{-| A basic text label block, but as a legend for certain inputs.

Legends don't need IDs.
-}
labelLegend : String -> Html msg
labelLegend labelString =
    Html.legend [ class "ps--label" ] [ Html.text labelString ]

{-| A hidden legend block.
Legends don't need IDs.
-}
labelLegendHidden : String -> Html msg
labelLegendHidden labelString =
    Html.legend [ class "ps--label-hidden" ] [ Html.text labelString ]


{-| label, but as a div. For inputs that need their `<label>`s to be elsewhere (like checkboxes.)
-}
labelDiv : String -> Html msg
labelDiv labelString =
    Html.div [ class "ps--label" ] [ Html.text labelString ]



{-| Text block that provides additional information to guide the user
through a form.
-}
desc : String -> Html msg
desc string =
    Html.div [ class "ps--form-helper" ] [ Html.text string ]







{-| The basics of a live text box that appears beneath controls
and inputs, telling the user why something is either not valid
or not usable.
-}
liveHelperText : List (Attribute msg) -> Validatable a r -> Html msg
liveHelperText attrs obj =
        let
            showContent = Validatable.ifShowErr obj
        in
                    -- this attr order is important for styling.
            div (   [ class "ps--live-helper" ]
                    ++ attrs
                    ++ [ classList [("empty", not showContent)]
                        , ariaLive "polite" ]
                )
                -- ariaHidden is done so SR users don't see error messages if
                -- there's no error because error content doesn't become blank
                -- if errors disappear so they can transition out.
                [ Html.span [ ariaHidden <| not showContent ]
                    [ Html.text obj.errMsg ]
                ]

{-| Helper text that shows if an input is invalid because the data structure
underlying it (of `Validatable` type), is `Invalid`.
-}
liveHelperInvalid : Validatable a r -> List (Html msg)
liveHelperInvalid o =
    [ liveHelperText [ class "invalid" ] o ]


{-| Helper text that shows if a control is disabled because the data structure
underlying it (of `Validatable` type), is `Invalid`.
-}
liveHelperDisabled : Validatable a r -> List (Html msg)
liveHelperDisabled o =
    [ liveHelperText [ class "disabled" ] o ]



{-| Development debug of liveHelperText. TODO: Remove when live helper stuff has been streamlined enough.
-}
liveHelperTextDebug : List (Attribute msg) -> Validatable a r -> Html msg
liveHelperTextDebug attrs obj =
        let
            showContent = Validatable.ifShowErr obj

            debug = case obj.errVisibility of
                    ShowErr -> "ShowErr"
                    HideErr -> "HideErr"

            debugValid = case obj.validity of
                    Valid -> "Valid"
                    Invalid -> "Invalid"
                    Unchecked -> "Unchecked"

            debugBehavior = case obj.errBehavior of
                    AlwaysValidation -> "[AV]"
                    RevealedValidation -> "[RV]"
                    TriggeredValidation -> "[TV]"
        in
            div []
                [         -- this attr order is important for styling.
                div (   [ class "ps--live-helper" ]
                        ++ attrs
                        ++ [ classList [("empty", not showContent)]
                            , ariaLive "polite" ]
                    )
                    -- ariaHidden is done so SR users don't see error messages if
                    -- there's no error because error content doesn't become blank
                    -- if errors disappear so they can transition out.
                    [ Html.span [ ariaHidden <| not showContent ]
                        [ Html.text obj.errMsg ]
                    ]

                , span [] [ Html.text (debugBehavior ++ " " ++ debug ++ " " ++ debugValid) ]

                ]
