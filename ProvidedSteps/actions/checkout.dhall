let GithubActions = ../../schema.dhall

let PT = GithubActions.WithParameterType

let utils = ../../utils.dhall

let Params = { Type = { ref : Optional Text }, default.ref = None Text }

let step =
      λ(params : Params.Type) →
        GithubActions.Step::{
        , name = "Checking out"
        , uses = Some "actions/checkout@v2"
        , `with` =
            utils.List/optionalize
              { mapKey : Text, mapValue : PT }
              (utils.convOpt Text "ref" PT.Text params.ref)
        }

let stepv3 =
      λ(params : Params.Type) →
        GithubActions.Step::{
        , name = "Checking out"
        , uses = Some "actions/checkout@v3"
        , `with` =
            utils.List/optionalize
              { mapKey : Text, mapValue : PT }
              (utils.convOpt Text "ref" PT.Text params.ref)
        }

in  { Params, step, stepv3 }
