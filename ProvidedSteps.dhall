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

let CheckoutParams = { Type = { ref : Optional Text }, default.ref = None Text }

let checkoutStep =
      λ(params : CheckoutParams.Type) →
        GithubActions.Step::{
        , name = "Checking out"
        , uses = Some "actions/checkout@v2"
        , `with` =
            List/optionalize
              { mapKey : Text, mapValue : GithubActions.WithParameterType }
              ( convOpt
                  Text
                  "ref"
                  GithubActions.WithParameterType.Text
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
              convOpt Text "path" GithubActions.WithParameterType.Text p.path

        in  List/concatWithEntries [ base, opt_path ]

let downloadArtifactStep =
      λ(params : DownloadArtifactParams.Type) →
        GithubActions.Step::{
        , name = "Downloading Artifacts"
        , uses = Some "actions/download-artifact@v1"
        , `with` = Some (makeDownloadArtifactParams params)
        }

let CreateReleaseBody = < Text : Text | Path : Text >

let CreateReleaseParams =
      { Type =
          { tag_name : Text
          , release_name : Text
          , body : CreateReleaseBody
          , draft : Optional Bool
          , prerelease : Optional Bool
          , commitish : Optional Text
          , owner : Optional Text
          , repo : Optional Text
          , token : Text
          }
      , default =
        { draft = None Bool
        , prerelease = None Bool
        , commitish = None Text
        , owner = None Text
        , repo = None Text
        , token = GithubActions.mkExpression "github.token"
        }
      }

let mkCreateReleaseParamMap =
      λ(params : CreateReleaseParams.Type) →
        let base =
              toMap
                { tag_name =
                    GithubActions.WithParameterType.Text params.tag_name
                , release_name =
                    GithubActions.WithParameterType.Text params.release_name
                }

        let body =
              merge
                { Text =
                    λ(text : Text) →
                      toMap { body = GithubActions.WithParameterType.Text text }
                , Path =
                    λ(path : Text) →
                      toMap
                        { body_path = GithubActions.WithParameterType.Text path
                        }
                }
                params.body

        let draft =
              convOpt
                Bool
                "draft"
                GithubActions.WithParameterType.Boolean
                params.draft

        let prerelease =
              convOpt
                Bool
                "prerelease"
                GithubActions.WithParameterType.Boolean
                params.prerelease

        let commitish =
              convOpt
                Text
                "commitish"
                GithubActions.WithParameterType.Text
                params.commitish

        let owner =
              convOpt
                Text
                "owner"
                GithubActions.WithParameterType.Text
                params.owner

        let repo =
              convOpt
                Text
                "repo"
                GithubActions.WithParameterType.Text
                params.repo

        in  List/concatWithEntries
              [ base, body, draft, prerelease, commitish, owner, repo ]

let createReleaseStep =
      λ(params : CreateReleaseParams.Type) →
        GithubActions.Step::{
        , name = "Create a Release"
        , uses = Some "actions/create-release@v1"
        , `with` = Some (mkCreateReleaseParamMap params)
        , env = Some (toMap { GITHUB_TOKEN = params.token })
        }

in  { CheckoutParams
    , checkoutStep
    , UploadArtifactParams
    , uploadArtifactStep
    , DownloadArtifactParams
    , downloadArtifactStep
    , CreateReleaseParams
    , CreateReleaseBody
    , createReleaseStep
    }
