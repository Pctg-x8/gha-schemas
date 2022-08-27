let GithubActions = ../../schema.dhall

let PT = GithubActions.WithParameterType

let utils = ../../utils.dhall

let Text/concatSep = https://prelude.dhall-lang.org/Text/concatSep

let Params =
      { Type =
          { command : Text
          , toolchain : Optional Text
          , args : Optional Text
          , use-cross : Optional Bool
          }
      , default =
        { toolchain = None Text, args = None Text, use-cross = None Bool }
      }

let mkParam =
      \(p : Params.Type) ->
        utils.List/concatWithEntries
          [ toMap { command = PT.Text p.command }
          , utils.convOpt Text "toolchain" PT.Text p.toolchain
          , utils.convOpt Text "args" PT.Text p.args
          , utils.convOpt Bool "use-cross" PT.Boolean p.use-cross
          ]

let step =
      \(params : Params.Type) ->
        GithubActions.Step::{
        , name = "Run Cargo"
        , uses = Some "actions-rs/cargo@v1"
        , `with` = Some (mkParam params)
        }

in  { Params, step }
