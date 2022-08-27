let GithubActions = ../../schema.dhall

let PT = GithubActions.WithParameterType

let utils = ../../utils.dhall

let Params =
      { Type = { name : Text, path : Optional Text }, default.path = None Text }

let mkParam =
      λ(p : Params.Type) →
        let base = toMap { name = PT.Text p.name }

        in  utils.List/concatWithEntries
              [ base, utils.convOpt Text "path" PT.Text p.path ]

let step =
      λ(params : Params.Type) →
        GithubActions.Step::{
        , name = "Downloading Artifacts"
        , uses = Some "actions/download-artifact@v1"
        , `with` = Some (mkParam params)
        }

in  { Params, step }
