module Ui.Icon exposing ( icon, symbol )


import Html.Attributes.Aria exposing (ariaHidden)

import Svg exposing (Svg, g, path)
import Svg.Attributes exposing (class, d, height, width, style, version, viewBox)



{-| The basis for all icons.
-}
icon : String -> List (Svg.Attribute msg) -> List ( Svg msg ) -> Svg msg
icon viewBoxSize attrs iconGeometry =
    iconHelper viewBoxSize ([class "icon"] ++ attrs) iconGeometry


{-| The basis for all symbols.
-}
symbol : String -> List (Svg.Attribute msg) -> List ( Svg msg ) -> Svg msg
symbol viewBoxSize attrs iconGeometry =
    iconHelper viewBoxSize ([class "symbol"] ++ attrs) iconGeometry

{-| The basis for all icons and symbols.
Wraps SVG icon geometry in repeatable stuff.
-}
iconHelper : String -> List (Svg.Attribute msg) -> List ( Svg msg ) -> Svg msg
iconHelper viewBoxSize attrs iconGeometry =
        Svg.svg (   [ viewBox viewBoxSize
                    , version "1.1"
                    , style "fill-rule:evenodd;" -- prevents punched holes from disappearing.
                    , ariaHidden True
                    ]
                    ++ attrs
                )
                [ g []
                    iconGeometry
                ]
