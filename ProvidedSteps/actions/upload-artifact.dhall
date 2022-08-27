let GithubActions = ../../schema.dhall

let PT = GithubActions.WithParameterType

let utils = ../../utils.dhall

let Params = { Type = { name : Text, path : Text }, default = {=} }

let step =
      λ(params : Params.Type) →
        GithubActions.Step::{
        , name = "Uploading Artifacts"
        , uses = Some "actions/upload-artifact@v1"
        , `with` = Some
            (toMap { name = PT.Text params.name, path = PT.Text params.path })
        }

in  { Params, step }
