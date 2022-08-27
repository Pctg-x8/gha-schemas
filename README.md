## Unofficial Dhall Schema for GitHub Actions

https://docs.github.com/ja/free-pro-team@latest/actions

## Usage

```dhall
let GitHubActions = https://raw.githubusercontent.com/Pctg-x8/gha-schemas/master/schema.dhall
```

### ProvidedSteps

```dhall
-- ex. using actions/checkout step
let ProvidedSteps/actions/checkout = https://raw.githubusercontent.com/Pctg-x8/gha-schemas/master/ProvidedSteps/actions/checkout.dhall
```

#### checkout@v2

```dhall
let checkoutStep = ProvidedSteps.checkoutStep ProvidedSteps.CheckoutParams::{
    , ref = Some "branch"
    }
```

#### upload-artifact@v1

```dhall
let uploadArtifactStep = ProvidedSteps.uploadArtifactStep ProvidedSteps.UploadArtifactParams::{
    , name = "exec"
    , path = "target/release/exec"
    }
```

## Examples

https://github.com/Pctg-x8/peridot/tree/dev/.github/workflows
