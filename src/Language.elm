module Language exposing    ( Language
                            , LanguageList
                            , ScriptDir(..)

                            , fromParts

                            , getTranslations
                            , scriptDirToString
                            , firstScriptCode
                            , firstScriptDir
                            , firstScriptCatClass

                            , LanguageRecords
                            , addTranslations
                            )

{-| Storing and handling the presentation of a user's language choices.

# Basic Data Types
@docs LanguageList, Language

# Handling script direction
@docs ScriptDir, scriptDirToString

# Functions
@docs getTranslations, scriptCategoryClasses, getFirstScriptDir

# Wrapping the data types in model
@docs LanguageRecords

# Setting translations in the model
@docs addTranslations


-}


import Http exposing (Error)
import I18Next exposing (Translations)


{-| An encapsulation of `List Language`, since that is the base data structure for
use in the model for language storage and access.
-}
type alias LanguageList = List Language


{-| The representation of a single language in Pineapple.

- `code`: the ISO code for identification.
- `scriptCategory`: Determines certain presentation features of the UI.
- `scriptDir`: Horizontal directionality of the languages' script(s).
`LTR` or `RTL`.
-}
type alias Language =
    { code : String
    , scriptCategory : String
    , scriptDir : ScriptDir
    }

{-| A type for noting the reading direction of layouts and content.
-}
type ScriptDir
    = LTR
    | RTL


{-| Creates a Language type from a language code strings,
scriptcat string and a ScriptDir.
-}
fromParts : String -> String -> ScriptDir -> Language
fromParts code scriptCat scriptDir =
    { code = code
    , scriptCategory = scriptCat
    , scriptDir = scriptDir
    }


{-| Creates the correct file path for fetching strings JSON files.

Parastat structures strings starting with a directory containing the language
code, then the specific file containing the strings relevant to the particular
web app like so:

```
strings
|- en
|   |- client.json
|   |- register.json
|   |- app_auth.json
|   | (..)
|- ja
|   | (..)

... etc.

So this function enables you to insert both the language and
the type of JSON file that you're looking for.
```
-}
makeTranslationsPath : Language -> String
makeTranslationsPath language =
    "../strings/" ++ language.code ++ ".json"


{-| Fetches the user's chosen language(s)
from the strings directory.
(It does this by creating a Cmd for each
language the user has chosen.)
-}
getTranslations : (Result Http.Error Translations -> msg) -> LanguageList -> Cmd msg
getTranslations msg languages =
    let
        getTranslation language =
            fetchTranslations msg <| makeTranslationsPath language

    in
        Cmd.batch <| List.map getTranslation languages




{-| Loads translation files by sending a HTTP request for the appropriate file.

It returns a result with the decoded translations, or an error if the
request or decoding failed.
-}
fetchTranslations : (Result Http.Error Translations -> msg) -> String -> Cmd msg
fetchTranslations msg url =
    Http.request
        { method = "GET"
        , headers = []
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson msg I18Next.translationsDecoder
        , timeout = Just (15 * 1000) -- 15 secs
        , tracker = Nothing
        }





{-| Designed to take the user's first language choice and apply a class
to `#ui` that will change the size or styling of certain text
areas based on the script.

Will return an empty string if there are no languages because it's
expected that there should be a language there.
-}
firstScriptCatClass : LanguageList -> String
firstScriptCatClass languages =
    case List.head languages of
        Just language -> "scriptcat-" ++ language.scriptCategory
        Nothing -> ""

{-| Takes the user's first language choice and gets it's
code.
-}
firstScriptCode : LanguageList -> String
firstScriptCode languages =
    case List.head languages of
        Just language -> language.code
        Nothing -> ""

{-| Takes the user's first language choice and get it's
script direction.
-}
firstScriptDir : LanguageList -> String
firstScriptDir languages =
    case List.head languages of
        Just language ->
            scriptDirToString language.scriptDir

        Nothing ->
            "ltr"

{-| Converts a `ScriptDir` to a string that works with
HTML's `dir` attribute.
-}
scriptDirToString : ScriptDir -> String
scriptDirToString dir =
    case dir of
        LTR -> "ltr"
        RTL -> "rtl"




{-| The chunk of language data that resides in the model.
-}
type alias LanguageRecords r =
    { r | languages : LanguageList
        , translationLoads : Int
        , translationAttempts : Int
        , translations : List Translations
    }


{-| Performs a sequence of model modifications that happen
every time a set of translations gets successfully loaded on app startup.
-}
addTranslations : Translations -> LanguageRecords r -> LanguageRecords r
addTranslations translations model =
    let
        loads = model.translationLoads
    in
        model
        |> (\m -> { m | translations = (List.append model.translations [translations]) })
        |> (\m -> { m | translationLoads = (loads + 1) })
        |> (\m -> { m | translationAttempts = (loads + 1) })
