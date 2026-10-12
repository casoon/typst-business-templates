---
title: Installation
description: Install the docgen CLI from a release, with the install script or from source, or add the Rust library to a project.
order: 1
---

## docgen CLI

### Install script (macOS, Linux)

```sh
curl -fsSL https://raw.githubusercontent.com/casoon/typst-business-templates/main/install.sh | bash
```

The script picks the release archive for your platform, verifies it against the published
`checksums.txt` (SHA-256) and installs `docgen` to `~/.local/bin`. Set `INSTALL_DIR` to install
elsewhere. If that directory is not on your `PATH`, the script prints the line to add.

### Release binaries

Every [GitHub release](https://github.com/casoon/typst-business-templates/releases) carries
prebuilt binaries and a `checksums.txt`:

| Platform | Archive |
| --- | --- |
| macOS, Apple Silicon | `docgen-aarch64-apple-darwin.tar.gz` |
| macOS, Intel | `docgen-x86_64-apple-darwin.tar.gz` |
| Linux, x86_64 | `docgen-x86_64-unknown-linux-gnu.tar.gz` |
| Linux, ARM64 | `docgen-aarch64-unknown-linux-gnu.tar.gz` |
| Windows, x86_64 | `docgen-x86_64-pc-windows-msvc.exe.zip` |

### From source

```sh
git clone https://github.com/casoon/typst-business-templates.git
cd typst-business-templates
cargo build --release -p docgen
# binary: target/release/docgen
```

### Requirements

- **Typst CLI.** `docgen compile` and `docgen build` call `typst compile` for JSON and `.typ`
  documents, so the [`typst` binary](https://github.com/typst/typst#installation) must be on your
  `PATH`. Diagrams are the exception: they are rendered by the Typst engine built into `docgen`.
- **qpdf**, only for `docgen compile --encrypt`.
- **Fonts.** `docgen` passes `--font-path fonts` to Typst, relative to the project folder. The
  font presets use the fonts in the repository's
  [`fonts/`](https://github.com/casoon/typst-business-templates/tree/main/fonts) folder; copy it
  into your project to use them. Without it, Typst falls back to system fonts.

The PDFs on this site were compiled with docgen 0.7.2 and typst 0.15.1.

## Rust library

```sh
cargo add typst-business-templates
```

The crate embeds templates, locales and the bundled fonts and runs Typst as a library. It needs
neither the `typst` binary nor `docgen`. See the [library reference](../../reference/library/).

Continue with the [Quickstart](../quickstart/).
