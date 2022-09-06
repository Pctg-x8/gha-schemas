let GithubActions = ../../schema.dhall

let Map/unpackOptionals =
      https://prelude.dhall-lang.org/Map/unpackOptionals.dhall

let Optional/map = https://prelude.dhall-lang.org/Optional/map

let PT = GithubActions.WithParameterType

let utils = ../../utils.dhall

let Params =
      { Type =
          { projectID : Optional Text
          , workloadIdentityProvider : Optional Text
          , serviceAccount : Optional Text
          , audience : Optional Text
          , credentialsJson : Optional Text
          , createCredentialsFile : Optional Bool
          , exportEnvironmentVariables : Optional Bool
          , tokenFormat : Optional Text
          , delegates : Optional Text
          , cleanupCredentials : Optional Bool
          , accessTokenLifetime : Optional Natural
          , accessTokenScopes : Optional Text
          , accessTokenSubject : Optional Text
          , retries : Optional Natural
          , backoff : Optional Natural
          , backoffLimit : Optional Natural
          , idTokenAudience : Optional Text
          , idTokenIncludeEmail : Optional Bool
          }
      , default =
        { projectID = None Text
        , workloadIdentityProvider = None Text
        , serviceAccount = None Text
        , audience = None Text
        , credentialsJson = None Text
        , createCredentialsFile = None Bool
        , exportEnvironmentVariables = None Bool
        , tokenFormat = None Text
        , delegates = None Text
        , cleanupCredentials = None Bool
        , accessTokenLifetime = None Natural
        , accessTokenScopes = None Text
        , accessTokenSubject = None Text
        , retries = None Natural
        , backoff = None Natural
        , backoffLimit = None Natural
        , idTokenAudience = None Text
        , idTokenIncludeEmail = None Bool
        }
      }

let defOutput =
      λ(name : Text) →
      λ(stepId : Text) →
        GithubActions.mkRefStepOutputExpression stepId name

let outputs =
      { projectID = defOutput "project_id"
      , credentialsFilePath = defOutput "credentials_file_path"
      , accessToken = defOutput "access_token"
      , accessTokenExpiration = defOutput "access_token_expiration"
      , idToken = defOutput "id_token"
      }

let step =
      λ(params : Params.Type) →
        GithubActions.Step::{
        , name = "Authenticate to Google Cloud"
        , uses = Some "google-github-actions/auth@v0"
        , `with` = Some
            ( Map/unpackOptionals
                Text
                PT
                ( toMap
                    { project_id = Optional/map Text PT PT.Text params.projectID
                    , workload_identity_provider =
                        Optional/map
                          Text
                          PT
                          PT.Text
                          params.workloadIdentityProvider
                    , service_account =
                        Optional/map Text PT PT.Text params.serviceAccount
                    , audience = Optional/map Text PT PT.Text params.audience
                    , credentials_json =
                        Optional/map Text PT PT.Text params.credentialsJson
                    , create_credentials_file =
                        Optional/map
                          Bool
                          PT
                          PT.Boolean
                          params.createCredentialsFile
                    , export_environment_variables =
                        Optional/map
                          Bool
                          PT
                          PT.Boolean
                          params.exportEnvironmentVariables
                    , token_format =
                        Optional/map Text PT PT.Text params.tokenFormat
                    , delegates = Optional/map Text PT PT.Text params.delegates
                    , cleanup_credentials =
                        Optional/map
                          Bool
                          PT
                          PT.Boolean
                          params.cleanupCredentials
                    , access_token_lifetime =
                        Optional/map
                          Natural
                          PT
                          (λ(x : Natural) → PT.Text "${Natural/show x}s")
                          params.accessTokenLifetime
                    , access_token_scopes =
                        Optional/map Text PT PT.Text params.accessTokenScopes
                    , access_token_subject =
                        Optional/map Text PT PT.Text params.accessTokenSubject
                    , retries = Optional/map Natural PT PT.Number params.retries
                    , backoff = Optional/map Natural PT PT.Number params.backoff
                    , backoff_limit =
                        Optional/map Natural PT PT.Number params.backoffLimit
                    , id_token_audience =
                        Optional/map Text PT PT.Text params.idTokenAudience
                    , id_token_include_email =
                        Optional/map
                          Bool
                          PT
                          PT.Boolean
                          params.idTokenIncludeEmail
                    }
                )
            )
        }

in  { Params, step, outputs }
