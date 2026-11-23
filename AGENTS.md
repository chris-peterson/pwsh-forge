# AGENTS.md

Guidance for coding agents working in this repository.

## Commands

`just` (the default recipe) runs `test lint help`.

| Command | What it does |
|---|---|
| `just test` | Pester over `./tests` |
| `just lint` | PSScriptAnalyzer over `./src` and `./build` with `PSScriptAnalyzerSettings.ps1` |
| `just help-update` | Regenerate `docs/**/*.md`, `docs/_sidebar.md`, `docs/README.md` from the module |
| `just help-export` | Compile `docs/**/*.md` into `src/ForgeCli/en-US/ForgeCli-Help.xml` (MAML) |
| `just docs` | Serve the docsify site locally |

Run one test file or one test:

```powershell
Invoke-Pester -Path ./tests/UnifiedCommands.Tests.ps1
Invoke-Pester -Path ./tests/UnifiedCommands.Tests.ps1 -FullNameFilter '*Should map Id to IssueId*'
```

Tests need `GithubCli` and `GitlabCli` installed (`Install-Module GithubCli, GitlabCli`); `Init.ps1` drops any
provider whose module is missing from the registry, so an uninstalled provider silently disappears from the test
matrix rather than failing.

CI treats PSScriptAnalyzer **warnings** as failure (exit 2), not just errors.

## Architecture

ForgeCli dispatches; it never calls a forge API. Each exported command maps its own parameters onto a
provider command's parameters and invokes it.

The dispatch table is **generated, not written**. `Private/Init.ps1` reads `FunctionsToExport` from
`ForgeCli.psd1`, splits each `<Verb>-<Noun>`, and looks the noun up in each provider's `Resource` table to
build `Verb-<Prefix><MappedNoun>`:

```
Get-Repo  →  github: Get-GithubRepository
          →  gitlab: Get-GitlabProject
```

A noun in `FunctionsToExport` with no `Resource` entry throws at import time.

ForgeCli is one module scope. `ForgeCli.psd1` lists `.ps1` scripts as its `NestedModules`: the helpers in
`Private/Functions/`, then `Private/Init.ps1`, then `Forge.ps1` (all exported commands). A script listed there runs in
the module's own scope, so the registry is `$script:ForgeProviders` and `$script:ForgeCommands`, and the helpers are
private without being declared anything special. Don't move module code to `ScriptsToProcess`: it runs in the
importer's session state, out of reach of the module's own commands when another module does the importing.
`tests/ModuleImport.Tests.ps1` covers that case. The `SupportedProvider` class lives in `Forge.ps1` because a
parameter attribute can't resolve a class defined in another of the module's scripts.

The tests dot-source the same files into the test scope rather than importing the module, so `Mock` reaches the
provider commands and a test can swap `$script:ForgeProviders` for a single provider.

Provider resolution (`Resolve-ForgeProvider`): an explicit `-Forge` wins; otherwise `Get-ForgeRemoteHost`
reads `remote.origin.url` and regex-matches the host against each provider's `HostPatterns`.
`-Forge` is validated by the `SupportedProvider` class against the *live* registry, so the valid set shrinks
when a provider module isn't installed.

## Adding or changing a command

A new command touches five places, and the tests enforce three of them:

1. `ForgeCli.psd1` → `FunctionsToExport`
2. `Private/Init.ps1` → a `Resource` entry in **every** provider, if the noun is new
3. `Forge.ps1` → the function itself
4. `tests/UnifiedCommands.Tests.ps1` → a stub for each new provider command in `BeforeAll`, plus per-provider
   mapping assertions
5. `TERMINOLOGY.md` → the Unified Command Surface table

`CommandSurface.Tests.ps1` regenerates that TERMINOLOGY.md table and diffs it; on mismatch it prints the
correct table to paste in. `PROVIDERS.md` (the per-parameter matrix) is hand-maintained and **not**
test-enforced, so it drifts. Read `Forge.ps1` for the real mapping.

### Command conventions

Every command follows the same shape:

```powershell
$Target = Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider $Forge
$Params = @{}
switch ($Target.Provider) {
    'github' { if ($Id) { $Params.IssueId = $Id } ... }
    'gitlab' { ... }
}
& $Target.Command @Params
```

- Common trailing params: `-Repo`, then `-Forge` with `[Alias('Provider')]` and `[ValidateSet([SupportedProvider])]`.
- Build `$Params` conditionally (`if ($X) { ... }`) so unset params are never forwarded; providers treat a
  passed `$null` differently from an absent key.
- Where a provider can't express a param, `Write-Warning` naming the command, param, and provider. Don't
  silently drop it and don't substitute a different behavior.
- Provider-side value differences are translated in a nested `switch` (forge `-State open` → GitLab `opened`).
- `Get-UserActivity` is the exception to pure dispatch: GitHub has no server-side date/action filters, so it
  builds a `$ClientFilters` list of closures and applies them to the results. Keep that pattern contained to
  commands where the provider genuinely lacks the filter.

## Output contract

Each noun's output is defined by a JSON Schema, written in YAML, in `src/ForgeCli/Schemas/<noun>.schema.yml`, with
snake_case fields documented down to the value. A field that comes back differently from the two providers is fixed
in that provider's module (GithubCli or GitlabCli), never translated here. `tests/Contract.Tests.ps1` runs the real
provider modules against recorded API responses and fails per field and per provider. The `TERMINOLOGY.md` section
for each noun is generated from its schema. Mechanics: `.claude/rules/output-contract.md`.

## Docs and release

The markdown under `docs/` is the source of truth for help: hand-written descriptions and examples live
there, and `Update-Help.ps1` only *generates* files for commands that have none. `Export-Help.ps1` compiles
them to MAML at publish time. The CI `docs` job runs `Update-Help.ps1 -ThrowOnChanges`, so run `just help-update`
and commit the result whenever a command's parameters change. `{{ Fill ... }}` placeholders left in a doc fail
the run.

Releases are cut by publishing a [GitHub Release](https://github.com/chris-peterson/pwsh-forge/releases); the
`v`-prefixed tag carries the version. The `release` job promotes the `## [Unreleased]` section of `CHANGELOG.md`
into a dated section, writes that same text into `ModuleVersion` and `PrivateData.PSData.ReleaseNotes` in
`ForgeCli.psd1`, publishes to the gallery, sets the release body, and commits the bump back to `main`. So a change
worth a release note adds a bullet under `## [Unreleased]`, and leaves `ModuleVersion` alone. An empty
`Unreleased` fails the release. `CONTRIBUTING.md` has the full flow; preview it with
`./build/Update-ReleaseArtifacts.ps1 -Version v0.13.0 -WhatIf`.

Commands blocked on gaps in the provider modules are tracked in `BACKLOG.md` rather than stubbed out here.
