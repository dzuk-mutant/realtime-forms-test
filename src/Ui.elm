module Ui exposing    ( Ui
                      , LabelPreference(..)
                      , ShapeHinting(..)
                      , ScrollbarThickness(..)

                      , view
                      )

{-| Represents the base interface and a user's options to control
the way things are presented.

# Data types
@docs Presentation
, ViewOptions
, ViewOptionsLabel
, ViewOptionsScrollbar
, ViewOptionsShapes

# View
@docs view

# Convenience functions
@docs viewOptions
-}

import Css.Global
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (class, classList, dir, id)
import Html.Styled
import Html.Styled.Attributes exposing (css)
import I18Next exposing (Translations)
import Language exposing (LanguageList)
import Theme exposing (Theme, ThemeType(..))
import Theme.Default



{-| For interfacing with the core parts of the model relevant
to the UI stuff.
-}
type alias Ui r =
    { r | languages : LanguageList
        , translationLoads : Int
        , translationAttempts : Int
        , translations : List Translations

        , labelPreference : LabelPreference
        , shapeHinting : ShapeHinting
        , scrollbarThickness : ScrollbarThickness

        , theme : Theme
        , osFonts : Bool
        }


{-| The user's label preferences.

This isn't an absolute; some interface areas will always
have icons and some will always have text, but for the parts
that can change, this preference will change.
-}
type LabelPreference
    = PrefersIcon
    | PrefersText

{-| The user's shape hinting preferences.

This doesn't apply to absolutely everything, but it will
increase/decrease the hinting of most areas of the interface.
-}
type ShapeHinting
    = LessShapeHinting
    | MoreShapeHinting


{-| The user's scrollbar preferences.

This doesn't always apply; some browsers and devices ignore
this or don't show scrollbars at all.
-}
type ScrollbarThickness
    = ThinScrollbars
    | ThickScrollbars




{-| Converts a `Ui` (a model containing `viewOptions` (`ViewOptions`) and `languages` `(LanguageList)`) into a
working basic structure that all Parastat UIs should be wrapped within.

This also contains the base styles that affect many of the layout elements
of Parastat's UI (like script direction).

If Parastat UI components are not wrapped in this, they will not display
correctly and functionality may break.
-}
view : Ui r -> Html msg -> Html msg -> Html msg -> Html msg
view ui loadingContent failedContent loadedContent =
    -- the code is weird because it's the one
    -- small pocket of styled CSS using elm-css.
    -- (We need it to implement themes.)
    Html.Styled.toUnstyled (
        Html.Styled.div
            [ Html.Styled.Attributes.id "base"
            , Html.Styled.Attributes.dir <| Language.firstScriptDir ui.languages
            ]
            -- Create a CSS snippet in the HTML that applies
            -- the theme color vars to the <body> of the UI.
            [ Css.Global.global
                [ Css.Global.body (Theme.toCSS ui.theme)
                ]
            , Html.Styled.div
                [ Html.Styled.Attributes.id "ui"
                , viewOptionsToClasses ui
                ]
                [ case checkInit ui of
                    Loading ->
                        (Html.Styled.fromUnstyled loadingContent)

                    Loaded ->
                        (Html.Styled.fromUnstyled loadedContent)

                    Failed startupErr ->
                        (Html.Styled.fromUnstyled failedContent)


                ]
            ]
        )


{-| Determines important CSS classes for the
user interface that will change various features
based on user preferences.
-}
viewOptionsToClasses : Ui r -> Html.Styled.Attribute msg
viewOptionsToClasses ui =
    let
        theme = ui.theme

        label =
            case ui.labelPreference of
                PrefersIcon -> ( "pref-label-icon", True )
                PrefersText -> ( "pref-label-text", True )

        shapeHinting =
            case ui.shapeHinting of
                LessShapeHinting -> ( "pref-shapes-less", True )
                MoreShapeHinting -> ( "pref-shapes-more", True )

        scrollbarThickness =
            case ui.scrollbarThickness of
                ThinScrollbars -> ( "pref-scrollbars-thin", True )
                ThickScrollbars -> ( "pref-scrollbars-thick", True )

        themeType =
            case theme.themeType of
                LightTheme -> ( "light-theme", True )
                DarkTheme -> ( "dark-theme", True)

        fonts =
            case ui.osFonts of
                True -> ( "fonts-os", True )
                False -> ( "fonts-default", True )

        scriptcat = (Language.firstScriptCatClass ui.languages, True)

    in
        -- weird elm-css Html because it's being used in view, which is also weird.
        Html.Styled.Attributes.classList
                  [ label
                  , shapeHinting
                  , scrollbarThickness
                  , themeType
                  , fonts
                  , scriptcat
                  ]




{-| Determines the core state of the interface at startup.

  - If everything loads fine, then this will return `Loaded`, along with the translations data that succeeded.
  - If the app hasn't tried loading everything yet, then it will return 'Loading'.
  - If something screws up, then this will return 'Failed'.

-}
type StartupState
    = Loading
    | Loaded
    | Failed StartupErr

type StartupErr
    = NoTranslations


{-| Checks to see if the critical areas of the interface are loaded.
Returns StartupState depending on what's going on.
-}
checkInit : Ui r -> StartupState
checkInit ui =
    let
        userLanguagesCount = List.length ui.languages

        everythingAttempted =
            (ui.translationAttempts == userLanguagesCount)
    in
        if not everythingAttempted then
            Loading
        else
            if not (ui.translationLoads == userLanguagesCount) then
                Failed NoTranslations
            else
                Loaded
