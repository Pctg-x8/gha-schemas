let GithubActions = ../../schema.dhall

let Map/unpackOptionals =
      https://prelude.dhall-lang.org/Map/unpackOptionals.dhall

let Optional/map = https://prelude.dhall-lang.org/Optional/map

let PT = GithubActions.WithParameterType

let utils = ../../utils.dhall

let defOutput = utils.defOutput

let Params =
      { Type =
          { audience : Optional Text
          , awsAccessKeyID : Optional Text
          , awsSecretAccessKey : Optional Text
          , awsSessionToken : Optional Text
          , awsRegion : Text
          , maskAWSAccountID : Optional Bool
          , roleToAssume : Optional Text
          , webIdentityTokenFile : Optional Text
          , roleDurationSeconds : Optional Natural
          , roleSessionName : Optional Text
          , roleExternalID : Optional Text
          , roleSkipSessionTagging : Optional Bool
          }
      , default =
        { audience = None Text
        , awsAccessKeyID = None Text
        , awsSecretAccessKey = None Text
        , awsSessionToken = None Text
        , maskAWSAccountID = None Bool
        , roleToAssume = None Text
        , webIdentityTokenFile = None Text
        , roleDurationSeconds = None Natural
        , roleSessionName = None Text
        , roleExternalID = None Text
        , roleSkipSessionTagging = None Bool
        }
      }

let outputs = { awsAccountID = defOutput "aws-account-id" }

let step =
      λ(params : Params.Type) →
        GithubActions.Step::{
        , name = "Configure AWS Credentials"
        , uses = Some "aws-actions/configure-aws-credentials@v1"
        , `with` = Some
            ( Map/unpackOptionals
                Text
                PT
                ( toMap
                    { audience = Optional/map Text PT PT.Text params.audience
                    , aws-access-key-id =
                        Optional/map Text PT PT.Text params.awsAccessKeyID
                    , aws-secret-access-key =
                        Optional/map Text PT PT.Text params.awsSecretAccessKey
                    , aws-session-token =
                        Optional/map Text PT PT.Text params.awsSessionToken
                    , aws-region = Some (PT.Text params.awsRegion)
                    , mask-aws-account-id =
                        Optional/map Bool PT PT.Boolean params.maskAWSAccountID
                    , role-to-assume =
                        Optional/map Text PT PT.Text params.roleToAssume
                    , web-identity-token-file =
                        Optional/map Text PT PT.Text params.webIdentityTokenFile
                    , role-duration-seconds =
                        Optional/map
                          Natural
                          PT
                          PT.Number
                          params.roleDurationSeconds
                    , role-session-name =
                        Optional/map Text PT PT.Text params.roleSessionName
                    , role-external-id =
                        Optional/map Text PT PT.Text params.roleExternalID
                    , role-skip-session-tagging =
                        Optional/map
                          Bool
                          PT
                          PT.Boolean
                          params.roleSkipSessionTagging
                    }
                )
            )
        }

in  { Params, step, outputs }
