module Ui.Layout exposing ( formDoubleArea
                          , actionToolbar
                          , saveHeader

                          , divider
                          , dividerSpace
                          , flexGridDummies
                          )


import Html exposing (Attribute, Html, div, form)
import Html.Attributes exposing (class)
import Html.Attributes.Aria exposing (ariaHidden)


{-| A full-width linear divider.
-}
divider : Html msg
divider =
    div [ class "ps--divider" ] []


{-| A full-width linear divider.
-}
dividerSpace : Html msg
dividerSpace =
    div [ class "ps--divider-space" ] []




{-| A wrapper for form content that creates a multi-column area.
 (That collapses to single-column in smaller sizes)
-}
formDoubleArea : List (Html msg) -> Html msg
formDoubleArea  content =
    Html.form [ class "ps--form-double" ]
        ( (List.map (\x -> Html.div [] [x] ) content) -- wrap in containers
        ++ flexGridDummies 1
        )


{-| An action toolbar is a quick set of actions related to
some sort of content or task.

They are meant to only contain mini buttons.
-}
actionToolbar : List (Html.Attribute msg) -> List (Html msg) -> List (Html msg) -> Html msg
actionToolbar attrs contentStart contentEnd =
    div ( [ class "ps--atb" ] ++ attrs )
        [ div [ class "ps--atb-section" ]
            (List.map (\x -> Html.div [] [x] ) contentStart) -- wrap in containers
        , div [ class "ps--atb-section" ] contentEnd
        ]

{-| The sticky header that appears at the top of settings pages.
-}
saveHeader : List (Html msg) -> Html msg
saveHeader content =
    div [ class "ps--save-header" ]
        content





{-| Creates a bunch of dummy divs for flex grids.
Creates X number of dummies based on the given number.
-}
flexGridDummies : Int -> List (Html msg)
flexGridDummies num =
    List.repeat num <| Html.div [ class "dummy", ariaHidden True ] []
