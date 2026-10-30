---
title: Installation
description: Install typstgen (and chartlet for diagrams), make the business-templates package available to Typst, and add the fonts.
order: 1
---

## In three steps

```sh
# 1. The compiler (typstgen embeds Typst; no separate typst binary needed)
cargo install typstgen --version 0.6.0 --locked

# 2. The package, from the tagged source release
git clone --branch templates-v0.2.0 https://github.com/casoon/typst-business-templates.git
cd typst-business-templates && ./scripts/install-package.sh

# 3. A check: rebuild the invoice demos
python3 examples/invoice-languages/build.py --output-dir /tmp/invoice-demos
```

After step 2, any project can `#import "@local/business-templates:0.2.0": invoice`; step 3 is
optional. You need [Rust and Cargo](https://rustup.rs/) for step 1; other install options are in
the [typstgen documentation](https://casoon.github.io/typstgen/). The version pair that this
package is checked with is recorded in `tool-versions.json`: **typstgen 0.6.0**, which provides
invoice configuration (`prepare-invoice`), profile checks, ZUGFeRD/Factur-X and the XRechnung/Peppol
writer (`e-invoice`). Plain-template documents also compile with typstgen 0.5.0.

See [Invoice configuration](../../guides/invoice-configuration/) and the
[eight PDF demos](../../../showcase/) for the practical path.

## chartlet (optional)

Only needed if you draw [diagrams](../../guides/diagrams/):

```sh
cargo install chartlet
```

## The package

The package is the `templates/` folder of the repository (`templates/typst.toml`, entry point
`templates/lib.typ`). It is not on Typst Universe. `scripts/install-package.sh` (step 2 above)
copies it into the Typst package directory of your system as `local/business-templates/0.2.0`;
pass a directory to install somewhere else, for example `./scripts/install-package.sh ~/packages`
together with `package_path = "/home/you/packages"` in `typstgen.toml`.

To do it by hand instead, copy or symlink `templates/` into your Typst package directory:

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
