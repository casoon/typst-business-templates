---
title: Rust library
description: Compile the templates to PDF bytes from Rust with typst-business-templates, without the typst binary.
order: 3
---

```sh
cargo add typst-business-templates
```

The crate embeds all templates, the seven locales and the bundled fonts, and compiles with Typst
0.13 as a library. The result is the PDF as `Vec<u8>`. Item-level documentation is on
[docs.rs](https://docs.rs/typst-business-templates).

## `DocgenCompiler`

| Method | Does |
| --- | --- |
| `DocgenCompiler::new()` | Compiler with embedded fonts plus system fonts |
| `.with_fonts_dir(path)` | Add a font directory |
| `.without_system_fonts()` | Use only embedded and added fonts, for reproducible output |
| `.compile_invoice(&InvoiceData, &CompanyData)` | Invoice from typed data, in the company's `language` |
| `.compile(template, json_bytes, &CompanyData, language)` | Any template by name, with the document as JSON bytes |

`template` is a folder name from [Document types](../document-types/). For `"diagram"` the
JSON is laid out first, as described in [Diagrams](../../guides/diagrams/).

## Compile a document

`CompanyData` deserializes from a `company.json` as described in
[Branding and languages](../../guides/branding/). The document itself goes in as JSON bytes,
in the same shape as the files `docgen` compiles:

```rust
use typst_business_templates::{CompanyData, DocgenCompiler};

fn main() -> anyhow::Result<()> {
    let company: CompanyData = serde_json::from_slice(&std::fs::read("data/company.json")?)?;
    let invoice = std::fs::read("documents/invoices/2025/invoice.json")?;

    let pdf = DocgenCompiler::new().compile("invoice", invoice, &company, &company.language)?;
    std::fs::write("invoice.pdf", pdf)?;
    Ok(())
}
```

With the IT consultancy example project this produces the same invoice as `docgen compile`
(the [showcase invoice](../../../showcase/invoice/)). Diagrams work the same way:

```rust
let data = std::fs::read("examples/diagram-flow/diagram.json")?;
let pdf = DocgenCompiler::new().compile("diagram", data, &company, "de")?;
```

## Typed invoice data

`compile_invoice` takes an `InvoiceData` value instead of JSON bytes. `InvoiceData`,
`InvoiceItem`, `InvoiceMetadata`, `InvoiceRecipient` and `CompanyData` are re-exported at the
crate root, the other types are in `typst_business_templates::types`; their fields are listed on
[docs.rs](https://docs.rs/typst-business-templates). Dates in `InvoiceData` are plain strings,
so the example JSON files, which use date objects, do not deserialize into it — use `compile`
for those.

## Versions

The library and the CLI are versioned separately. The crate on crates.io is
`typst-business-templates` 0.1.5; `docgen` releases (currently 0.7.2) are published as binaries
on [GitHub](https://github.com/casoon/typst-business-templates/releases).
