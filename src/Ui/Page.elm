
module Ui.Page exposing ( settings
                        , settingsSegment
                        , floating
                        )


import Html exposing (Attribute, Html, div, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Msg exposing (Msg)



{-| A narrow page that stands against a background.
For small, isolated user actions, like registration and
authorising a third-party app.
-}
floating : List (Html msg) -> Html msg
floating content =
    div [ class "ps--layout-floating-form" ]
        [ Html.div [ class "container" ]
            content
        ]







type alias SettingsSegment a msg =
    { id : a
    , label : String
    , form : (Html msg)
    }

settingsSegment : a -> String -> (Html msg) -> SettingsSegment a msg
settingsSegment id label form =
    { id = id
    , label = label
    , form = form
    }



settingsSidebarNav : a -> (a -> msg) -> SettingsSegment a msg -> Html msg
settingsSidebarNav currentPage onChange segment =
    Html.li []
        [ Html.a [ class "item"
                 , classList [ ("selected", segment.id == currentPage)
                             ]
                 , onClick <| onChange segment.id
                 ]
            [ Html.div [ class "text-area" ]
                [ Html.div [ class "label" ] [ Html.text segment.label ]
                , Html.div [ class "underline" ]
                    [ Html.div [ class "block" ] [] ]
                ]
            ]
        ]

{-| The page used for settings.
-}
settings : a -> (a -> msg) -> List (SettingsSegment a msg) -> Html msg
settings currentPage onChange content =
        Html.div [ class "ps--settings-form" ]
            [ Html.div [ class "sidebar" ]
                [ Html.ul [ class "pages" ]
                    (List.map (settingsSidebarNav currentPage onChange) content)
                ]
            , Html.div [ class "content" ]
                [ Html.div [ class "container" ]
                    ( case List.head <| List.filter (\l -> l.id == currentPage) content of
                        Nothing -> []
                        Just p -> [ p.form ]
                    )

                ]

            ]
