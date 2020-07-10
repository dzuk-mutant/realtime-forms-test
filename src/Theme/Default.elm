module Theme.Default exposing (testValues, lightTheme, darkTheme)

{-| Interim code for maintaining themes to test
with while more of the theme functionality is made.
-}



import Css exposing (Style)
import Theme exposing (Theme, ThemeType(..), ColorPalette)

-- parastat branding colors
purple100 = "#2B0043"
purple90 = "#440068"
purple80 = "#690099"
purple70 = "#8200BE"
purple60 = "#A100EC"
purple50 = "#C23EFF"
purple40 = "#CB5CFF"
purple30 = "#D478FF"
purple20 = "#E09EFF"
purple10 = "#EFC6FF"

pink100 = "#400025"
pink90 = "#68003D"
pink80 = "#990059"
pink70 = "#BE006F"
pink60 = "#E10183"
pink50 = "#FF23A3"
pink40 = "#FF5CBB"
pink30 = "#FF78C7"
pink20 = "#FF9EDF"
pink10 = "#FFC6E7"

red100 = "#440308"
red90 = "#61050B"
red80 = "#88070F"
red70 = "#B40A13"
red60 = "#E3141B"
red50 = "#fa2c33"
red40 = "#fc5661"
red30 = "#fa7881"
red20 = "#f79ca2"
red10 = "#fec7c8"

greenLight = "#56D905"
greenDark = "#4FC705"




darkColors : ColorPalette
darkColors =
    { body = "#060606"
    , body2 = "#131313"
    , floatingBG = "#32004D"

    , link = purple50
    , linkHover = purple60

    , input = "#131313"
    , inputHover = "#1a1a1a"
    , inputNested = "#222"
    , inputNestedHover = "#2a2a2a"

    , text = "#d0d0d0"
    , text2 = "#828282"
    , text3 = "#686868"

    , focus = purple60
    , focus2 = "#ffffff"

    , selectedFill = purple80

    , colorSym = purple50

    , success = greenLight

    , warning = red60
    , warningFocus = red30

    , disabled = "#777"
    , disabled2 = "#555"

    , logoAccent = "#BE006F"

    -- WIP Stuff
    , buttonContent = "#fff"
    , primary = purple70
    , primaryHover = purple80
    , primaryActive = purple90

    , secondary = "#242424"
    , secondaryHover = "#1c1c1c"
    , secondaryActive = "#151515"
    , secondaryContent = "#fff"

    , checkRadioContent = "#fff"
    , checkRadioBorder = "#373737"
    , checkRadioBorderHover = "#474747"
    , checkRadioContentFocus = "#fff"

    , tableBorder = "#262626"
    , tableHead = "#222"
    }





lightColors : ColorPalette
lightColors =
    { body = "#fff"
    , body2 = "#e8e8e8"
    , floatingBG = "#FB6274"

    , link = purple60
    , linkHover = purple70

    , input = "#e8e8e8"
    , inputHover = "#d3d3d3"
    , inputNested = "#c1c1c1"
    , inputNestedHover = "#cacaca"

    , text = "#111"
    , text2 = "#555"
    , text3 = "#888"

    , focus = purple50
    , focus2 = "#000"

    , selectedFill = purple30

    , colorSym = purple60

    , success = greenDark

    , warning = red50
    , warningFocus = red70

    , disabled = "#6d6d6d"
    , disabled2 = "#adadad"

    , logoAccent = "#FF5CBB"

    , buttonContent = "#fff"
    , primary = purple60
    , primaryHover = purple70
    , primaryActive = purple80

    , secondary = "#646464"
    , secondaryHover = "#535353"
    , secondaryActive = "#3e3e3e"
    , secondaryContent = "#fff"

    , checkRadioContent = "#fff"
    , checkRadioBorder = "#aaa"
    , checkRadioBorderHover = "#888"
    , checkRadioContentFocus = "#000"

    , tableBorder = "#bfbfbf"
    , tableHead = "#d0d0d0"
    }


darkTheme = Theme.fromPaletteAndType darkColors DarkTheme
lightTheme = Theme.fromPaletteAndType lightColors LightTheme

testValues : List Style
testValues =
    Theme.toCSSWithPrefs lightTheme darkTheme darkTheme
