let GithubActions = ./schema.dhall

let PT = GithubActions.WithParameterType

let utils = ./utils.dhall

let convOpt = utils.convOpt

let Map = https://prelude.dhall-lang.org/Map/Type

let List/null = https://prelude.dhall-lang.org/List/null

let List/concat = https://prelude.dhall-lang.org/List/concat

let Map/Entry = https://prelude.dhall-lang.org/Map/Entry

let Opt/fold = https://prelude.dhall-lang.org/Optional/fold

let CheckoutParams = { Type = { ref : Optional Text }, default.ref = None Text }

let checkoutStep =
      λ(params : CheckoutParams.Type) →
        GithubActions.Step::{
        , name = "Checking out"
        , uses = Some "actions/checkout@v2"
        , `with` =
            utils.List/optionalize
              { mapKey : Text, mapValue : PT }
              (convOpt Text "ref" PT.Text params.ref)
        }

let UploadArtifactParams =
      { Type = { name : Text, path : Text }, default = {=} }

let uploadArtifactStep =
      λ(params : UploadArtifactParams.Type) →
        GithubActions.Step::{
        , name = "Uploading Artifacts"
        , uses = Some "actions/upload-artifact@v1"
        , `with` = Some
            (toMap { name = PT.Text params.name, path = PT.Text params.path })
        }

let DownloadArtifactParams =
      { Type = { name : Text, path : Optional Text }, default.path = None Text }

let makeDownloadArtifactParams =
      λ(p : DownloadArtifactParams.Type) →
        let base = toMap { name = PT.Text p.name }

        let opt_path = convOpt Text "path" PT.Text p.path

        in  utils.List/concatWithEntries [ base, opt_path ]

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
                { tag_name = PT.Text params.tag_name
                , release_name = PT.Text params.release_name
                }

        let body =
              merge
                { Text = λ(text : Text) → toMap { body = PT.Text text }
                , Path = λ(path : Text) → toMap { body_path = PT.Text path }
                }
                params.body

        in  utils.List/concatWithEntries
              [ base
              , body
              , convOpt Bool "draft" PT.Boolean params.draft
              , convOpt Bool "prerelease" PT.Boolean params.prerelease
              , convOpt Text "commitish" PT.Text params.commitish
              , convOpt Text "owner" PT.Text params.owner
              , convOpt Text "repo" PT.Text params.repo
              ]

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
    , setup-python = ./ProvidedSteps/setup-python.dhall
    }
