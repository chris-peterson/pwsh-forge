# Changelog

All notable changes to ForgeCli are recorded here, newest first.

## [Unreleased]

### Features
* Milestone write verbs: `New-Milestone`, `Update-Milestone`, `Remove-Milestone`. `-State closed` reaches Gitlab as `-StateEvent close`, so the forge parameter means the same thing on both providers: https://github.com/chris-peterson/pwsh-forge/pull/13
* Label commands: `Get-Label`, `New-Label`, `Update-Label`, `Remove-Label`. A `-Name` is resolved to Gitlab's numeric label id before dispatch, so labels stay addressable by the identifier you know: https://github.com/chris-peterson/pwsh-forge/pull/12

## [0.12.0] - 2026-04-21

### Breaking Changes
* `Get-ChangeRequest` parameters `-Since` / `-Until` are renamed to `-CreatedAfter` / `-CreatedBefore`. No aliases; update call sites directly.

### Features
* `Get-ChangeRequest` gains `-MergedAfter` / `-MergedBefore` for filtering by merge date independent of `-State`. Threads through to pwsh-github 0.9.0+ and pwsh-gitlab 1.171.0+.
