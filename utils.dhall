let GithubActions = ./schema.dhall

let List/null = https://prelude.dhall-lang.org/List/null

let List/concat = https://prelude.dhall-lang.org/List/concat

let Map/Entry = https://prelude.dhall-lang.org/Map/Entry

let Opt/fold = https://prelude.dhall-lang.org/Optional/fold

let List/optionalize =
      λ(a : Type) →
      λ(list : List a) →
        if List/null a list then None (List a) else Some list

let List/concatWithEntries =
      List/concat (Map/Entry Text GithubActions.WithParameterType)

let emptyEntry = [] : List (Map/Entry Text GithubActions.WithParameterType)

let convOpt =
      λ(a : Type) →
      λ(name : Text) →
      λ(f : a → GithubActions.WithParameterType) →
      λ(v : Optional a) →
        merge
          { Some = λ(x : a) → [ { mapKey = name, mapValue = f x } ]
          , None = emptyEntry
          }
          v

let defOutput =
      λ(name : Text) →
      λ(stepId : Text) →
        GithubActions.mkRefStepOutputExpression stepId name

in  { List/optionalize, List/concatWithEntries, emptyEntry, convOpt, defOutput }
