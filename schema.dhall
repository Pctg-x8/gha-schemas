let Map = https://prelude.dhall-lang.org/Map/Type

let id = https://prelude.dhall-lang.org/Function/identity

let mkExpression = λ(x : Text) → "\${{ ${x} }}"

let mkRefStepOutputExpression =
      λ(step : Text) →
      λ(var : Text) →
        mkExpression "steps.${step}.outputs.${var}"

let Shell = < bash | pwsh | python | sh | cmd | powershell | Custom : Text >

let WithParameterType = < Number : Natural | Text : Text | Boolean : Bool >

let ConcurrencyGroup =
      { Type = { group : Text, cancel-in-progress : Optional Bool }
      , default.cancel-in-progress = None Bool
      }

let Step =
      { Type =
          { name : Text
          , id : Optional Text
          , if : Optional Text
          , run : Optional Text
          , working-directory : Optional Text
          , uses : Optional Text
          , env : Optional (Map Text Text)
          , with : Optional (Map Text WithParameterType)
          , shell : Optional Shell
          }
      , default =
        { id = None Text
        , if = None Text
        , run = None Text
        , working-directory = None Text
        , uses = None Text
        , env = None (Map Text Text)
        , with = None (Map Text WithParameterType)
        , shell = None Shell
        }
      }

let RunnerPlatform =
      < ubuntu-latest | windows-latest | macos-latest | Custom : Text >

let runnerPlatformAsText =
      let handler =
            { ubuntu-latest = "ubuntu-latest"
            , windows-latest = "windows-latest"
            , macos-latest = "macos-latest"
            , Custom = id Text
            }

      in  λ(p : RunnerPlatform) → merge handler p

let Strategy =
      { Type =
          { matrix : Optional (Map Text (List Text))
          , fail-fast : Optional Bool
          , max-parallel : Optional Integer
          }
      , default =
        { matrix = None (Map Text (List Text))
        , fail-fast = None Bool
        , max-parallel = None Integer
        }
      }

let DockerHubCredentials =
      { Type = { username : Text, password : Text }, default = {=} }

let Service =
      { Type =
          { image : Text
          , credentials : Optional DockerHubCredentials.Type
          , env : Optional (Map Text Text)
          , ports : Optional (List Text)
          , volumes : Optional (List Text)
          , options : Optional Text
          }
      , default =
        { credentials = None DockerHubCredentials.Type
        , env = None (Map Text Text)
        , ports = None (List Text)
        , volumes = None (List Text)
        , options = None Text
        }
      }

let Job =
      { Type =
          { name : Optional Text
          , runs-on : RunnerPlatform
          , strategy : Optional Strategy.Type
          , needs : Optional (List Text)
          , if : Optional Text
          , outputs : Optional (Map Text Text)
          , steps : List Step.Type
          , permissions : Optional (Map Text Text)
          , services : Optional (Map Text Service.Type)
          , environment : Optional Text
          , concurrency : Optional ConcurrencyGroup.Type
          }
      , default =
        { name = None Text
        , outputs = None (Map Text Text)
        , strategy = None Strategy.Type
        , needs = None (List Text)
        , if = None Text
        , permissions = None (Map Text Text)
        , services = None (Map Text Service.Type)
        , environment = None Text
        , concurrency = None ConcurrencyGroup.Type
        }
      }

let Triggers = ./Triggers.dhall

let Workflow =
      { Type =
          { name : Optional Text
          , on : Triggers.On
          , jobs : Map Text Job.Type
          , permissions : Optional (Map Text Text)
          , concurrency : Optional ConcurrencyGroup.Type
          }
      , default =
        { name = None Text
        , permissions = None (Map Text Text)
        , concurrency = None ConcurrencyGroup.Type
        }
      }

in    { Workflow
      , Job
      , RunnerPlatform
      , runnerPlatformAsText
      , Strategy
      , Step
      , Shell
      , Service
      , DockerHubCredentials
      , mkExpression
      , mkRefStepOutputExpression
      , WithParameterType
      }
    ∧ Triggers
