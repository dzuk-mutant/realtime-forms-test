module Ui.Symbol exposing ( dropdown
                          , checkboxChecked
                          , checkboxIntermediate
                          , warning
                          , ok

                          , favorite
                          , boost
                          )


import Svg exposing (Svg, g, path)
import Svg.Attributes exposing (class, d, height, width, version, viewBox)

import Ui.Icon as Icon exposing (symbol)




{-| Indicator used in all dropdown (<option>) menus.
-}
dropdown : Svg msg
dropdown =
    Icon.symbol
        "0 0 16 16"
        [ class "sym-dropdown "]
        [ path [d "M8,9.189l3.97,-3.969l1.06,1.06c0,0 -3.207,3.208 -4.5,4.5c-0.14,0.141 -0.331,0.22 -0.53,0.22c-0.199,0 -0.39,-0.079 -0.53,-0.22c-1.293,-1.292 -4.5,-4.5 -4.5,-4.5l1.06,-1.06l3.97,3.969Z"][]]

{-| The tick that appears in checkboxes
-}
checkboxChecked : Svg msg
checkboxChecked =
    Icon.symbol
        "0 0 16 16"
        [ class "sym-checkbox-check" ] -- required for proper functioning
        [ path [d "M6,10.939l7.47,-7.469l1.06,1.06l-8,8c-0.293,0.293 -0.767,0.293 -1.06,0l-4,-4l1.06,-1.06l3.47,3.469Z"][]]

{-| An intermediate symbol for checkboxes
-}
checkboxIntermediate : Svg msg
checkboxIntermediate =
    Icon.symbol
        "0 0 16 16"
        [ class "sym-checkbox-indeterminate" ] -- required for proper functioning
        [ path [d "M14,7.25l0,1.5l-12,0l0,-1.5l12,0Z"][]]

{-| A warning symbol for input that has failed validation.
-}
warning : Svg msg
warning =
    Icon.symbol
        "0 0 16 16"
        [ class "sym-warning "]
        [ path [d "M8,0c4.415,0 8,3.585 8,8c0,4.415 -3.585,8 -8,8c-4.415,0 -8,-3.585 -8,-8c0,-4.415 3.585,-8 8,-8Zm0,11c0.69,0 1.25,0.56 1.25,1.25c0,0.69 -0.56,1.25 -1.25,1.25c-0.69,0 -1.25,-0.56 -1.25,-1.25c0,-0.69 0.56,-1.25 1.25,-1.25Zm-0.75,-8l0,6.5l1.5,0l0,-6.5l-1.5,0Z"][]]


{-| A warning symbol for input that has failed validation.
-}
ok : Svg msg
ok =
    Icon.symbol
        "0 0 16 16"
        [ class "sym-ok "]
        [ path [d "M8,0c4.415,0 8,3.585 8,8c0,4.415 -3.585,8 -8,8c-4.415,0 -8,-3.585 -8,-8c0,-4.415 3.585,-8 8,-8Zm-1.5,9.939l5.47,-5.469l1.06,1.06l-6,6c-0.293,0.293 -0.767,0.293 -1.06,0l-3,-3l1.06,-1.06l2.47,2.469Z"][]]





{-| Indicator for posts that have been boosted by someone else.
-}
boost : Svg msg
boost =
    Icon.symbol
        "0 0 16 16"
        []
        [ path [ d "M3.1,9l-2.1,0c-0.548,0 -0.999,-0.451 -0.999,-1c0,-0.265 0.105,-0.519 0.292,-0.707l3,-3c0.18,-0.18 0.423,-0.285 0.678,-0.293c0.01,0 0.019,0 0.029,0c0.549,0 1,0.451 1,1l0,3c0,0.01 0,0.019 0,0.029c0.015,1.643 1.354,2.971 3,2.971c0.453,0 0.883,-0.1 1.268,-0.28l0.845,1.812c-0.642,0.3 -1.358,0.468 -2.113,0.468c-2.417,0 -4.436,-1.719 -4.9,-4Zm11.9,-2c0.548,0 0.999,0.451 0.999,1c0,0.265 -0.105,0.519 -0.292,0.707l-3,3c-0.18,0.18 -0.423,0.285 -0.678,0.293c-0.01,0 -0.019,0 -0.029,0c-0.549,0 -1,-0.451 -1,-1c0,0 0,0 0,0l0,-3c0,-0.01 0,-0.019 0,-0.029c-0.015,-1.643 -1.354,-2.971 -3,-2.971c-0.453,0 -0.883,0.1 -1.268,0.28l-0.845,-1.812c0.642,-0.3 1.358,-0.468 2.113,-0.468c2.417,0 4.436,1.719 4.9,4l2.1,0Z"] [] ]


{-| Indicator for posts that have been favourited by someone else.
-}
favorite : Svg msg
favorite =
    Icon.symbol
        "0 0 16 16"
        []
        [ path [d "M4.5,2.528c-0.92,0 -1.806,0.364 -2.457,1.015l-0.002,0.002c-0.651,0.652 -1.016,1.537 -1.016,2.457c0,0.92 0.365,1.806 1.016,2.457l5.252,5.25c0.388,0.388 1.026,0.388 1.414,0l5.252,-5.25c0.651,-0.651 1.016,-1.537 1.016,-2.457c0,-0.92 -0.365,-1.805 -1.016,-2.457l-0.002,-0.002c-0.651,-0.651 -1.537,-1.015 -2.457,-1.015c-0.92,0 -1.806,0.364 -2.457,1.015l-1.043,1.045l-1.043,-1.045c-0.651,-0.651 -1.537,-1.015 -2.457,-1.015Zm0,2c0.392,0 0.764,0.155 1.041,0.431l1.752,1.75c0.388,0.388 1.026,0.388 1.414,0l1.752,-1.75c0.277,-0.276 0.649,-0.431 1.041,-0.431c0.392,0 0.764,0.155 1.041,0.431l0.002,0.002c0.277,0.277 0.432,0.649 0.432,1.041c0,0.392 -0.155,0.765 -0.432,1.041l-4.543,4.545l-4.543,-4.545c-0.277,-0.276 -0.432,-0.649 -0.432,-1.041c0,-0.392 0.155,-0.764 0.432,-1.041l0.002,-0.002c0.277,-0.276 0.649,-0.431 1.041,-0.431Z"][]]
