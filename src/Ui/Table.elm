module Ui.Table exposing (view)

import Html exposing (Html, caption, div, span, table, text, thead, tbody, tr, th, td)
import Html.Attributes exposing (class, scope)


{-| A working, preliminary table.
-}
view : String -> List String -> List (List String) -> Html msg
view captionText headerContent tableContent =
    let
        spanThing = (\x -> span [] [text x])
        headerCells = (\x -> th [ scope "col" ] [ spanThing x ] )
        -- scope="col" tells screenreaders that this header is for it's column.
        tableCells = (\x -> td [] [ spanThing x ] )
        tableRow = (\x -> tr [] (List.map tableCells x) )
    in
        div [ class "ps--table-wrapper" ]
            [ table [ class "ps--table" ]
                (  [ caption [] [ text captionText ] ] -- summary of the table for screenreaders
                ++ [ thead [] (List.map headerCells headerContent) ]
                ++ [ tbody [] (List.map tableRow tableContent) ]
                )
            ]
