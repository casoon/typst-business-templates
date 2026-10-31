---
title: Versions and release preparation
description: Map Typst package versions, historical docgen tags and supported compiler versions.
order: 3
---

## Version namespaces

| Artifact | Version/tag | Meaning |
| --- | --- | --- |
| Current Typst package | `business-templates` 0.2.0 | Source release `templates-v0.2.0`; local import `@local/business-templates:0.2.0` |
| Typst package release tags | `templates-vX.Y.Z` | Tag version equals the manifest version; the first release is `templates-v0.2.0` |
| Historical repository releases | `v0.7.x` and older | docgen CLI/Rust crate; historical tags retain their original contents and meaning |
| Minimum compiler | Typst 0.15.0 | `compiler` in the package manifest |
| Verified tooling | typstgen 0.6.2, chartlet 0.21.0 | `tool-versions.json`; chartlet is optional outside diagram checks |
| Configured invoices/profile tooling | typstgen 0.6.0 or later | Earlier versions lack `prepare-invoice`, the profile commands and `e-invoice` |

The Typst package follows Semantic Versioning independently of the discontinued crate. During
0.x, a breaking public contract increments the minor version, compatible fixes/additions may
increment the patch; 1.0 establishes the stable API. Package tags use `templates-v` to avoid
colliding with historical `v0.x` tags. Do not relabel or retag historical artifacts.
Install the tagged source release, or archive an exact commit when testing newer development source.
Installation paths, imports and the manifest must use the same package version.

## Release checklist

- Keep user-facing entries under `[Unreleased]` in Keep a Changelog format until release.
- Select the package version, update `templates/typst.toml`, local package directory/symlink,
  example imports and current installation/reference documentation together.
- Move the package's unreleased entries to the version/date and start an empty `[Unreleased]`.
  The [historical changelog](../docgen-changelog/) preserves docgen history separately.
- Run the `keep-a-changelog` skill's `scripts/check_changelog.py CHANGELOG.md --release X.Y.Z`.
- Run `scripts/check.sh` with the pinned tools and Python `jsonschema`, `referencing`, `pypdf`.
  Review PDFs visually, including long content, metadata, optional branding and page breaks.
  A successful compilation does not replace external invoice or accessibility validation.
- Build the documentation site with `pnpm --dir site build`.
- Inspect a clean release diff, the manifest/compiler requirements and the intended tag.
  For this public repository, PR CI must pass before merging.
- Only after an explicit release decision create the `templates-vX.Y.Z` tag and publish artifacts.
  No tag, crate publication, yank or Universe upload is performed by this documentation change.

## Discontinued crate

Do not publish a final deprecation crate automatically. The repository already documents the
replacement, and publishing more executable legacy code creates another maintenance artifact.
If existing crate consumers need a registry-visible notice, prepare a separate maintenance-only
release from the last crate source with a README pointing to typstgen. Verify its dependencies,
installation behavior and ownership before deciding to publish. Do not reuse the Typst package
version or yank older crates as part of that task. Old CLI functionality is historical and is
not part of the supported package API.

## Typst Universe

Local package distribution is the supported installation path. Universe publication remains an
optional distribution decision. It requires package review, an available package name/version,
license/assets checks, the requested compiler version, a distributable archive and successful
examples against the archive. Until accepted, imports must remain `@local/…`; do not advertise
`@preview/…` installation or imply a published package exists.
