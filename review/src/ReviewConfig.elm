module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Documentation.ReadmeLinksPointToCurrentVersion
import NoBooleanCase
import NoExposingEverything
import NoImportingEverything
import NoInvalidRGBValues
import NoLongImportLines
import NoMissingSubscriptionsCall
import NoMissingTypeAnnotation
import NoMissingTypeAnnotationInLetIn
import NoMissingTypeExpose
import NoRecursiveUpdate
import NoRedundantConcat
import NoRedundantCons
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Modules
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import NoUselessSubscriptions
import Review.Rule exposing (Rule)
import Simplify
import UseCamelCase


config : List Rule
config =
    [ Simplify.rule Simplify.defaults
    , NoRedundantConcat.rule
    , NoRedundantCons.rule
    --, NoExposingEverything.rule
    , NoImportingEverything.rule []
    , NoMissingTypeAnnotation.rule
    --, NoMissingTypeAnnotationInLetIn.rule
    --, Documentation.ReadmeLinksPointToCurrentVersion.rule
    --, NoMissingTypeExpose.rule
    --, NoInvalidRGBValues.rule
    --, NoMissingSubscriptionsCall.rule
    --, NoRecursiveUpdate.rule
    --, NoUselessSubscriptions.rule
    --, NoUnused.CustomTypeConstructors.rule []
    --, NoUnused.CustomTypeConstructorArgs.rule
    --, NoUnused.Dependencies.rule
    --, NoUnused.Exports.rule
    --, NoUnused.Modules.rule
    --, NoUnused.Parameters.rule
    --, NoUnused.Patterns.rule
    --, NoUnused.Variables.rule
    --, NoLongImportLines.rule
    --, UseCamelCase.rule UseCamelCase.default
    --, NoBooleanCase.rule
    --, NoRedundantCons.rule
    ]
