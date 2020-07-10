module Ui.Text exposing ( h1
                        , h2
                        , h3
                        , h4
                        , h5
                        , h6

                        , p
                        , pOpener

                        , ul
                        , externalLinks
                        )

import Html exposing (Html, a, div, h1, li, text, ul, p)
import Html.Attributes exposing (class, href, target)


{-| Creates an HTML Heading 1 (`<h1>`).
-}
h1 : String -> Html msg
h1 string = Html.h1 [] [ Html.text string ]

{-| Creates an HTML Heading 2 (`<h2>`).
-}
h2 : String -> Html msg
h2 string = Html.h2 [] [ Html.text string ]

{-| Creates an HTML Heading 3 (`<h3>`).
-}
h3 : String -> Html msg
h3 string = Html.h3 [] [ Html.text string ]

{-| Creates an HTML Heading 4 (`<h4>`).
-}
h4 : String -> Html msg
h4 string = Html.h4 [] [ Html.text string ]

{-| Creates an HTML Heading 5 (`<h5>`).
-}
h5 : String -> Html msg
h5 string = Html.h5 [] [ Html.text string ]

{-| Creates an HTML Heading 6 (`<h6>`).
-}
h6 : String -> Html msg
h6 string = Html.h6 [] [ Html.text string ]




{-| Creates an HTML Paragraph (`<p>`).
-}
p : String -> Html msg
p string =
    Html.p [] [ Html.text string ]

{-| An HTML paragraph, but stylised in such a way where they are
emphasised from normal paragraphs.
-}
pOpener : String -> Html msg
pOpener string =
    Html.p [ class "opener" ] [ Html.text string ]


{-| Creates an HTML Unordered List (`<ul>`).
-}
ul : List String -> Html msg
ul strings =
    let
        listItem = (\x -> Html.li [] [ Html.text x ])
    in
        Html.ul [] ( List.map listItem strings )


{-| Creates a list of external links.
-}
externalLinks : List (String, String) -> Html msg
externalLinks strings =
    let
        listItem = (\x -> Html.li []
                        [ Html.a [ href (Tuple.first x), target "_blank" ]
                            [ Html.text ( Tuple.second x ) ]
                        ]
                    )

    in
        Html.ul [ class "ps--external-links" ] (List.map listItem strings)
