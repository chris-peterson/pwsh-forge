# Contributing to pwsh-forge

Thanks for your interest in contributing! This document outlines how to set up your development environment and the tools we use.

## Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| [PowerShell](https://github.com/PowerShell/PowerShell) | 7.1+ | `brew install powershell` (macOS) |
| [just](https://just.systems) | latest | `brew install just` (macOS) |

The tests dispatch against the provider modules, so install those too:

```powershell
Install-Module GithubCli, GitlabCli
```

## Development Workflow

We use [just](https://just.systems) as a task runner. The default task runs everything:

```sh
just
```

| Command | What it does |
|---|---|
| `just test` | Pester over `./tests` |
| `just lint` | PSScriptAnalyzer over `./src` and `./build` |
| `just help-update` | Regenerate the markdown help under `docs/` from the module |
| `just help-export` | Compile `docs/**/*.md` into MAML |
| `just docs` | Serve the docsify site locally |

Run `just help-update` after adding or renaming parameters — it syncs structural metadata (types, parameter sets, aliases) while preserving hand-written descriptions. CI enforces that docs are in sync.

## Releasing

`CHANGELOG.md` keeps an `## [Unreleased]` section at the top, and that section is where release notes come from. Appending to it as you work is welcome but not required; whoever cuts the release reviews it and backfills whatever is missing.

Releases are driven by [GitHub Releases](https://github.com/chris-peterson/pwsh-forge/releases). Publishing a release is the trigger; the tag carries the version:

- The **tag** is the version, `v`-prefixed (e.g. `v0.13.0`). CI strips the `v` for `ModuleVersion`.
- The **notes** are whatever `Unreleased` holds at that moment. The release body you type is replaced with them, so leaving it blank is fine.

On publish, the `release` job:

1. Promotes `Unreleased` into a dated `## [<version>]` section, leaves a fresh empty `Unreleased` behind, and writes that same text into `ForgeCli.psd1` `ModuleVersion` and `ReleaseNotes`.
2. Publishes the module to the PowerShell Gallery.
3. Sets the GitHub Release body to the promoted notes, so the releases page reads the same as the changelog.
4. Commits the manifest and changelog back to `main`.

Dispatching a release with an empty `Unreleased` fails the job, so record what changed before publishing.

The commit-back runs last so that a failed publish leaves `main` without a commit claiming a release that never shipped.

To preview the manifest and changelog edits a release will make, run the script locally with `-WhatIf`:

```powershell
./build/Update-ReleaseArtifacts.ps1 -Version v0.13.0 -WhatIf
```

Cut releases from a tag at `main`'s HEAD. The test, security, and docs gates run against the tag, but the `release` job checks out `main` (it has to, to commit the version bump back), so a tag behind `main` publishes `main`'s code rather than the code the gates checked.

The commit-back uses the built-in `GITHUB_TOKEN`. If `main` becomes a protected branch, that token needs permission to push to it.

## Making Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes — a new command touches the five places listed in [AGENTS.md](AGENTS.md#adding-or-changing-a-command)
4. Run `just` to verify tests, lint, and help are all in order
5. Add a line under `## [Unreleased]` in `CHANGELOG.md` if the change is worth a release note
6. Commit your changes
7. Open a Pull Request

## Code Style

- Follow [PowerShell Best Practices](https://poshcode.gitbook.io/powershell-practice-and-style/)
- Use approved verbs for cmdlet names (`Get-Verb` to see the list)
- Add tests for new functionality
- Avoid inline commenting (except when necessary); instead, prefer
  intention-revealing code.  Often a well-named function removes
  the need for a comment.
