# AGENTS.md

Guidance for coding agents working in this repository.

## Commands

`just` (the default recipe) runs `test lint help`.

| Command | What it does |
|---|---|
| `just test` | Pester over `./tests` |
| `just lint` | PSScriptAnalyzer over `./src` with `PSScriptAnalyzerSettings.ps1` |
| `just help-update` | Regenerate `docs/**/*.md`, `docs/_sidebar.md`, `docs/README.md` from the module |
| `just help-export` | Compile `docs/**/*.md` into `src/ForgeCli/en-US/ForgeCli-Help.xml` (MAML) |
| `just docs` | Serve the docsify site locally |

Run one test file or one test:

```powershell
Invoke-Pester -Path ./tests/UnifiedCommands.Tests.ps1
Invoke-Pester -Path ./tests/UnifiedCommands.Tests.ps1 -FullNameFilter '*Should map Id to IssueId*'
```

Tests need `GithubCli` and `GitlabCli` installed (`Install-Module GithubCli, GitlabCli`); `Init.psm1` drops any
provider whose module is missing from the registry, so an uninstalled provider silently disappears from the test
matrix rather than failing.

CI treats PSScriptAnalyzer **warnings** as failure (exit 2), not just errors.

## Architecture

ForgeCli dispatches; it never calls a forge API. Each exported command maps its own parameters onto a
provider command's parameters and invokes it.

The dispatch table is **generated, not written**. `Private/Init.psm1` reads `FunctionsToExport` from
`ForgeCli.psd1`, splits each `<Verb>-<Noun>`, and looks the noun up in each provider's `Resource` table to
build `Verb-<Prefix><MappedNoun>`:

```
Get-Repo  →  github: Get-GithubRepository
          →  gitlab: Get-GitlabProject
```

A noun in `FunctionsToExport` with no `Resource` entry throws at import time. State lives in two globals
(`$global:ForgeCommands`, `$global:ForgeProviders`) because `$script:` scope doesn't cross module files;
`PSAvoidGlobalVars` is excluded for this reason.

Load order from the manifest: `ScriptsToProcess` (`Validations.ps1`, `GitHelpers.ps1`, `ProviderHelpers.ps1`)
→ `RootModule` (`Private/Init.psm1`) → `NestedModules` (`Forge.psm1`, all 29 exported commands).

Provider resolution (`Resolve-ForgeProvider`): an explicit `-Forge` wins; otherwise `Get-ForgeRemoteHost`
reads `remote.origin.url` and regex-matches the host against each provider's `HostPatterns`.
`-Forge` is validated by the `SupportedProvider` class against the *live* registry, so the valid set shrinks
when a provider module isn't installed.

## Adding or changing a command

A new command touches five places, and the tests enforce three of them:

1. `ForgeCli.psd1` → `FunctionsToExport`
2. `Private/Init.psm1` → a `Resource` entry in **every** provider, if the noun is new
3. `Forge.psm1` → the function itself
4. `tests/UnifiedCommands.Tests.ps1` → a stub for each new provider command in `BeforeAll`, plus per-provider
   mapping assertions
5. `TERMINOLOGY.md` → the Unified Command Surface table

`CommandSurface.Tests.ps1` regenerates that TERMINOLOGY.md table and diffs it; on mismatch it prints the
correct table to paste in. `PROVIDERS.md` (the per-parameter matrix) is hand-maintained and **not**
test-enforced, so it drifts. Read `Forge.psm1` for the real mapping.

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

## Docs and release

The markdown under `docs/` is the source of truth for help: hand-written descriptions and examples live
there, and `Update-Help.ps1` only *generates* files for commands that have none. `Export-Help.ps1` compiles
them to MAML at publish time. The CI `docs` job runs `Update-Help.ps1 -ThrowOnChanges`, so run `just help-update`
and commit the result whenever a command's parameters change. `{{ Fill ... }}` placeholders left in a doc fail
the run.

`publish-module` fires on any `src/**` change landing on `main`, so bump `ModuleVersion` in `ForgeCli.psd1` and
rewrite `PrivateData.PSData.ReleaseNotes` in the same change; a stale version fails the gallery push.

Commands blocked on gaps in the provider modules are tracked in `BACKLOG.md` rather than stubbed out here.
