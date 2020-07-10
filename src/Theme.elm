module Theme exposing ( Theme
                      , ThemeType(..)
                      , ColorPalette
                      , fromValues
                      , fromPaletteAndType
                      , toCSS
                      , toCSSWithPrefs
                      )


{-| Create and use Parastat themes.

# Types
@docs Theme, ThemeAccessibility, Contrast, ColorblindAccessibility, ColorPalette

# Make themes
#docs fromValues, fromPalette

# Use themes
@docs toCSS, toCSSWithPrefs
-}


import Css exposing (Style, color, hex, property)
import Css.Media exposing (withMediaQuery)
import Html.Styled exposing (var)


{-| A type encapsulating a Parastat theme.
-}
type alias Theme =
    { colors : ColorPalette
    , themeType : ThemeType
    , contrast : Contrast
    , colorAccessibility : ColorblindAccessibility
    }


{-| What kind of theme it is:

- LightTheme : dark-on-light
- DarkTheme : light-on-dark
-}
type ThemeType
    = LightTheme
    | DarkTheme

{-| How compliant a theme is with WCAG guidelines at minimum:

This isn't a value judgment (low contrast
themes are good for some people!), just a
matter of fact statement.

- LowContrast : No compliance with WCAG.
- BasicContrast : Compliance with WCAG.
- EnhancedContrast : Compliamce with WCAG Enhanced.
-}
type Contrast
    = LowContrast
    | BasicContrast
    | EnhancedContrast


{-| Whether a theme is expected to be usable
by people with certain kinds of colorblindness.

`True` means yes, `False` means no.

Colorblindness isn't a clear thing to guess,
so this can only be an approximate expectation.

- anomalousRed (Protanomaly)
- noRed (Protanopia)
- anomalousGreen (Deuteranomaly)
- noGreen (Deureranopia)
- anomalousBlue (Tritanomaly)
- noBlue (Tritanopia)
- mono (Achromatopsia)
-}
type alias ColorblindAccessibility =
    { anomalousRed : Bool
    , noRed : Bool
    , anomalousGreen : Bool
    , noGreen : Bool
    , anomalousBlue : Bool
    , noBlue : Bool
    , mono : Bool
    }


{-| The color palette for a theme that dictates
the interface's colors.
-}
type alias ColorPalette =
    { body : String
    , body2 : String
    , floatingBG : String

    , link : String
    , linkHover : String

    , input : String
    , inputHover : String
    , inputNested : String
    , inputNestedHover : String

    , text : String
    , text2 : String
    , text3 : String

    , focus : String
    , focus2 : String

    , selectedFill : String

    , colorSym : String

    , success : String

    , warning : String
    , warningFocus : String

    , disabled : String
    , disabled2 : String

    , logoAccent : String

    -- WIP Stuff
    , buttonContent : String
    , primary : String
    , primaryHover : String
    , primaryActive : String

    , secondary : String
    , secondaryHover : String
    , secondaryActive : String
    , secondaryContent : String

    , checkRadioContent : String
    , checkRadioBorder : String
    , checkRadioBorderHover : String
    , checkRadioContentFocus : String

    , tableBorder : String
    , tableHead : String
    }


{-| Creates a Theme from values.
-}
fromValues : ColorPalette -> ThemeType -> Contrast -> ColorblindAccessibility -> Theme
fromValues palette themeType contrast colorAccess =
    { colors = palette
    , themeType = themeType
    , contrast = contrast
    , colorAccessibility = colorAccess
    }


{-|  Creates a Theme from a Palette and ThemeType.

TEMP: Should not be used in actual production.
-}
fromPaletteAndType : ColorPalette -> ThemeType -> Theme
fromPaletteAndType palette themeType =
    let
        colorAccess =
            { anomalousRed = True
            , noRed = True
            , anomalousGreen = True
            , noGreen = True
            , anomalousBlue = True
            , noBlue = True
            , mono = True
            }

    in
        { colors = palette
        , themeType = themeType
        , contrast = BasicContrast
        , colorAccessibility = colorAccess
        }


{-| Converts a theme to CSS variables usable in Styles.
-}
toCSS : Theme -> List Style
toCSS theme =
    let
        colors = theme.colors
    in
        [ property "--body" colors.body
        , property "--body-2" colors.body2
        , property "--floating-bg" colors.floatingBG

        , property "--link" colors.link
        , property "--link-hover" colors.linkHover

        , property "--input" colors.input
        , property "--input-hover" colors.inputHover
        , property "--input-nested" colors.inputNested
        , property "--input-nested-hover" colors.inputNestedHover

        , color (hex colors.text) -- text1 is also default color.
        , property "--text-1" colors.text
        , property "--text-2" colors.text2
        , property "--text-3" colors.text3

        , property "--focus" colors.focus
        , property "--focus-2" colors.focus2

        , property "--selected-fill" colors.selectedFill

        , property "--color-sym" colors.colorSym

        , property "--success" colors.success

        , property "--warning" colors.warning
        , property "--warning-focus" colors.warningFocus

        , property "--disabled" colors.disabled
        , property "--disabled-2" colors.disabled2

        , property "--logo-accent" colors.logoAccent

        -- WIP ones

        , property "--button-content" colors.buttonContent
        , property "--primary" colors.primary
        , property "--primary-hover" theme.colors.primaryHover
        , property "--primary-active" theme.colors.primaryActive

        , property "--secondary" colors.secondary
        , property "--secondary-hover" colors.secondaryHover
        , property "--secondary-active" colors.secondaryActive
        , property "--secondary-content" colors.secondaryContent

        , property "--check-radio-content" colors.checkRadioContent
        , property "--check-radio-border" colors.checkRadioBorder
        , property "--check-radio-border-hover" colors.checkRadioBorderHover
        , property "--check-radio-content-focus" colors.checkRadioContentFocus

        , property "--table-border" colors.tableBorder
        , property "--table-head" colors.tableHead
        ]





{-| Takes three sets of themes (each representing the light,
dark and default theme), converts them to CSS and wraps them in
prefers-media-scheme queries for use.
-}
toCSSWithPrefs : Theme -> Theme -> Theme-> List Style
toCSSWithPrefs lightTheme darkTheme defaultTheme =
    [ withMediaQuery [ "(prefers-color-scheme: light)" ]
        (toCSS lightTheme)
    , withMediaQuery [ "(prefers-color-scheme: dark)" ]
        (toCSS darkTheme)
    , withMediaQuery [ "(prefers-color-scheme: no-preference)" ]
        (toCSS defaultTheme)
    ]


{-| Internal helper that retrieves a Theme's ColorPalette.
-}
getColorPalette : Theme -> ColorPalette
getColorPalette theme = theme.colors
