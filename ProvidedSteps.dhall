let GithubActions = ./schema.dhall

let Map = https://prelude.dhall-lang.org/Map/Type

let List/null = https://prelude.dhall-lang.org/List/null

let List/concat = https://prelude.dhall-lang.org/List/concat

let Map/Entry = https://prelude.dhall-lang.org/Map/Entry

let Opt/fold = https://prelude.dhall-lang.org/Optional/fold

let List/optionalize =
      λ(a : Type) →
      λ(list : List a) →
        if List/null a list then None (List a) else Some list

let CheckoutParams = { Type = { ref : Optional Text }, default.ref = None Text }

let checkoutStep =
      λ(params : CheckoutParams.Type) →
        GithubActions.Step::{
        , name = "Checking out"
        , uses = Some "actions/checkout@v2"
        , `with` =
            List/optionalize
              { mapKey : Text, mapValue : GithubActions.WithParameterType }
              ( merge
                  { Some =
                      λ(x : Text) →
                        [ { mapKey = "ref"
                          , mapValue = GithubActions.WithParameterType.Text x
                          }
                        ]
                  , None = [] : Map Text GithubActions.WithParameterType
                  }
                  params.ref
              )
        }

let UploadArtifactParams =
      { Type = { name : Text, path : Text }, default = {=} }

let uploadArtifactStep =
      λ(params : UploadArtifactParams.Type) →
        GithubActions.Step::{
        , name = "Uploading Artifacts"
        , uses = Some "actions/upload-artifact@v1"
        , `with` = Some
            ( toMap
                { name = GithubActions.WithParameterType.Text params.name
                , path = GithubActions.WithParameterType.Text params.path
                }
            )
        }

let DownloadArtifactParams =
      { Type = { name : Text, path : Optional Text }, default.path = None Text }

let makeDownloadArtifactParams =
      λ(p : DownloadArtifactParams.Type) →
        let base = toMap { name = GithubActions.WithParameterType.Text p.name }

        let opt_path =
              Opt/fold
                Text
                p.path
                (List (Map/Entry Text GithubActions.WithParameterType))
                (λ(p : Text) → [ { mapKey = "path", mapValue = GithubActions.WithParameterType.Text p } ])
                ([] : List (Map/Entry Text GithubActions.WithParameterType))

        in  List/concat (Map/Entry Text GithubActions.WithParameterType) [ base, opt_path ]

let downloadArtifactStep =
      λ(params : DownloadArtifactParams.Type) →
        GithubActions.Step::{
        , name = "Downloading Artifacts"
        , uses = Some "actions/download-artifact@v1"
        , `with` = Some (makeDownloadArtifactParams params)
        }

in  { CheckoutParams
    , checkoutStep
    , UploadArtifactParams
    , uploadArtifactStep
    , DownloadArtifactParams
    , downloadArtifactStep
    }
