let GithubActions = ../../schema.dhall

let PT = GithubActions.WithParameterType

let utils = ../../utils.dhall

let Body = < Text : Text | Path : Text >

let Params =
      { Type =
          { tag_name : Text
          , release_name : Text
          , body : Body
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

let mkParam =
      λ(params : Params.Type) →
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
              , utils.convOpt Bool "draft" PT.Boolean params.draft
              , utils.convOpt Bool "prerelease" PT.Boolean params.prerelease
              , utils.convOpt Text "commitish" PT.Text params.commitish
              , utils.convOpt Text "owner" PT.Text params.owner
              , utils.convOpt Text "repo" PT.Text params.repo
              ]

let step =
      λ(params : Params.Type) →
        GithubActions.Step::{
        , name = "Create a Release"
        , uses = Some "actions/create-release@v1"
        , `with` = Some (mkParam params)
        , env = Some (toMap { GITHUB_TOKEN = params.token })
        }

in  { Body, Params, step }
