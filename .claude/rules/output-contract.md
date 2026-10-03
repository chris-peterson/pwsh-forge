---
paths:
  - src/ForgeCli/Schemas/**
  - src/ForgeCli/Private/Functions/RecordHelpers.ps1
  - tests/Contract.Tests.ps1
  - tests/fixtures/**
  - tests/Support/**
---

# Output contract mechanics

- **Field names.** A provider object's PascalCase property maps to a snake_case field by a fixed rule
  (`MergedAt` → `merged_at`), applied by `ConvertTo-ForgeRecord`. A property the provider lacks is left out, so
  schema validation names the missing field instead of reporting a `null`.
- **Schema shape.** Every field has a `description`. Enumerated values use `oneOf` + `const`, so each value carries
  its own description, and its own `x-github` / `x-gitlab` when the mapping differs per value. `x-github` /
  `x-gitlab` name the API field each provider reads. These keys feed the generated "Detailed Property Mappings"
  section of `TERMINOLOGY.md`, so after editing a schema, paste the section the contract test prints.
- **Shared definitions** (`forge`, `host`, `project_path`, `timestamp`, `date`, `username`) live in
  `common.schema.yml`. `Get-ForgeSchema` merges them into each noun's `$defs`; a field references one with `$ref` and
  overrides its `description` or `x-*` keys where the noun needs to.
- **Which nouns have a schema.** Every noun except `ForgeApi` and `ForgeConfiguration`, which return the provider's
  response by design, and `Forge` (search), whose results take the shape of the scope searched.
- **Mocks go on the provider's nested module** that makes the call (`PullRequests`, `MergeRequests`). A mock on the
  root module (`GithubCli`) doesn't intercept the call, so the request reaches the live API and the test still
  passes against public repos. The `reads the fixture rather than the live API` test catches that.
- **Fixtures** are raw API responses from public repos, pretty-printed with `jq`. Record them with `gh api <path>`
  or with `curl` against a public GitLab project. Don't record from a private instance: the repo is public.
- **One field per check.** `Test-Json` also reports the unmatched branches of a `oneOf` that passed, so a
  whole-record failure buries the real error. The test validates each field against its own sub-schema, then checks
  the cross-field rules (`allOf`, `additionalProperties`) separately.
