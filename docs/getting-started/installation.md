---
title: Installation
description: Install typstgen (and chartlet for diagrams), make the business-templates package available to Typst, and add the fonts.
order: 1
---

## typstgen

There are two supported build workflows. Use the coordinated source build for invoice
configuration and profile commands; use the published compiler for the existing plain-template
examples and VAT export. The template package is distributed as a versioned source release.

### Configured invoices and profile tools

From the cloned `typst-business-templates` repository, install the exact revision declared by
the package into a project-local tool directory:

```sh
revision="$(python3 -c 'import json; print(json.load(open("tool-versions.json"))["typstgen_profiles_revision"])')"
cargo install typstgen --git https://github.com/casoon/typstgen \
  --rev "$revision" --locked --debug \
  --root ".cache/test-tools/typstgen-$revision"
export PATH="$PWD/.cache/test-tools/typstgen-$revision/bin:$PATH"
python3 examples/invoice-languages/build.py
```

This does not replace a globally installed compiler. The binary still reports package version
0.5.0; the Git revision identifies the development features. `scripts/test.sh` also installs
this pinned build and runs the complete acceptance workflow, including external validators.

See [Invoice configuration](../../guides/invoice-configuration/) and the
[eight PDF demos](../../../showcase/) for the practical path.

### Existing plain-template examples

```sh
cargo install typstgen --version 0.5.0 --locked
```

typstgen embeds the Typst compiler, so no separate `typst` binary is needed. Other install options
are in the [typstgen documentation](https://casoon.github.io/typstgen/).
The published 0.5.0 crate does not contain `prepare-invoice` or the profile commands.

## chartlet (optional)

Only needed if you draw [diagrams](../../guides/diagrams/):

```sh
cargo install chartlet
```

## The package

The package is the `templates/` folder of the repository (`templates/typst.toml`, entry point
`templates/lib.typ`). It is not on Typst Universe; install it as a local package under the name
`business-templates`, version `0.2.0`:

```sh
git clone --branch templates-v0.2.0 https://github.com/casoon/typst-business-templates.git
```

Then either copy or symlink `templates/` into your Typst package directory:

```sh
# macOS
mkdir -p ~/Library/Application\ Support/typst/packages/local/business-templates
ln -s "$PWD/typst-business-templates/templates" \
  ~/Library/Application\ Support/typst/packages/local/business-templates/0.2.0

# Linux: ~/.local/share/typst/packages/local/business-templates/0.2.0
# Windows: %APPDATA%\typst\packages\local\business-templates\0.2.0
```

or point typstgen at any folder that contains `local/business-templates/0.2.0` with
`package_path` in your project's `typstgen.toml`:

```toml
package_path = "/path/to/packages"
```

The repository does the latter for its examples: `packages/local/business-templates/0.2.0` is a
link to `templates/`, and the example projects set `package_path = "../../packages"`.

Documents then import from the package:

```typst
#import "@local/business-templates:0.2.0": invoice
```

The package needs Typst 0.15 or later (`compiler = "0.15.0"` in `typst.toml`).

## Fonts

The running-text documents and the credentials sheet use the font preset from `company.json`
(Inter, Roboto, Source Sans 3 …, see [Branding](../../guides/branding/#font-presets)). The font
files are in the repository's
[`fonts/`](https://github.com/casoon/typst-business-templates/tree/main/fonts) folder. Copy the
families you use into your project and list the folder in `typstgen.toml`:

```toml
font_paths = ["fonts"]
```

The accounting documents use Helvetica. Without it, Typst falls back to an installed sans-serif
font and prints a warning.

Continue with the [Quickstart](../quickstart/).

Use the `templates-v0.2.0` source release for reproducibility; historical
`v0.7.x` releases contain docgen. See [Versions](../../reference/releases/) and
[Migration](../../guides/migration/).
