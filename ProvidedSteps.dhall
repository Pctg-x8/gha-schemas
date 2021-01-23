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
              { mapKey : Text, mapValue : Text }
              ( merge
                  { Some = λ(x : Text) → [ { mapKey = "ref", mapValue = x } ]
                  , None = [] : Map Text Text
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
        , `with` = Some (toMap params)
        }

let DownloadArtifactParams =
      { Type = { name : Text, path : Optional Text }, default.path = None Text }

let makeDownloadArtifactParams =
      λ(p : DownloadArtifactParams.Type) →
        let base = toMap { name = p.name }

        let opt_path =
              Opt/fold
                Text
                p.path
                (List (Map/Entry Text Text))
                (λ(p : Text) → [ { mapKey = "path", mapValue = p } ])
                ([] : List (Map/Entry Text Text))

        in  List/concat (Map/Entry Text Text) [ base, opt_path ]

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
