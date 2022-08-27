let GithubActions = ../../schema.dhall

let utils = ../../utils.dhall

let convOpt = utils.convOpt

let PT = GithubActions.WithParameterType

let CacheType = < pip | pipenv | poetry >

let cacheTypeToParameterType =
      \(t : CacheType) ->
        merge
          { pip = PT.Text "pip"
          , pipenv = PT.Text "pipenv"
          , poetry = PT.Text "poetry"
          }
          t

let Params =
      { Type =
          { python-version : Optional Text
          , python-version-file : Optional Text
          , cache : Optional CacheType
          , architecture : Optional Text
          , check-latest : Optional Bool
          , token : Optional Text
          , cache-dependency-path : Optional Text
          , update-environment : Optional Bool
          }
      , default =
        { python-version = None Text
        , python-version-file = None Text
        , cache = None CacheType
        , architecture = None Text
        , check-latest = None Bool
        , token = None Text
        , cache-dependency-path = None Text
        , update-environment = None Bool
        }
      }

let mkParam =
      \(p : Params.Type) ->
        utils.List/concatWithEntries
          [ convOpt Text "python-version" PT.Text p.python-version
          , convOpt Text "python-version-file" PT.Text p.python-version-file
          , convOpt CacheType "cache" cacheTypeToParameterType p.cache
          , convOpt Text "architecture" PT.Text p.architecture
          , convOpt Bool "check-latest" PT.Boolean p.check-latest
          , convOpt Text "token" PT.Text p.token
          , convOpt Text "cache-dependency-path" PT.Text p.cache-dependency-path
          , convOpt Bool "update-environment" PT.Boolean p.update-environment
          ]

let step =
      \(params : Params.Type) ->
        GithubActions.Step::{
        , name = "Setup Python"
        , uses = Some "actions/setup-python@v4"
        , `with` = Some (mkParam params)
        }

in  { CacheType, Params, step }
