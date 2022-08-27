let GithubActions = ../../schema.dhall

let PT = GithubActions.WithParameterType

let utils = ../../utils.dhall

let Text/concatSep = https://prelude.dhall-lang.org/Text/concatSep

let Params =
      { Type =
          { toolchain : Optional Text
          , target : Optional Text
          , default : Optional Bool
          , override : Optional Bool
          , profile : Optional Text
          , components : List Text
          }
      , default =
        { toolchain = None Text
        , target = None Text
        , default = None Bool
        , override = None Bool
        , profile = None Text
        , components = [] : List Text
        }
      }

let mkComponentListParam = \(xs : List Text) -> PT.Text (Text/concatSep "," xs)

let mkParam =
      \(p : Params.Type) ->
        utils.List/concatWithEntries
          [ utils.convOpt Text "toolchain" PT.Text p.toolchain
          , utils.convOpt Text "target" PT.Text p.target
          , utils.convOpt Bool "default" PT.Boolean p.default
          , utils.convOpt Bool "override" PT.Boolean p.override
          , utils.convOpt Text "profile" PT.Text p.profile
          , utils.convOpt
              (List Text)
              "components"
              mkComponentListParam
              (utils.List/optionalize Text p.components)
          ]

let step =
      \(params : Params.Type) ->
        GithubActions.Step::{
        , name = "Install Rust Toolchain"
        , uses = Some "actions-rs/toolchain@v1"
        , `with` = Some (mkParam params)
        }

in  { Params, step }
