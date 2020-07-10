module Ui.Form exposing ( view )

import Html exposing (Html, Attribute, form)
import Html.Attributes exposing (class)

{-| Semantic wrapper for Form UI stuff. It's just a wrapper
for HTML `<form>` right now.
-}
view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view attrs content =
    Html.form ([ class "ps--form" ] ++ attrs )
        content
