# Invoice language demos

The PDFs are committed and can be opened directly. Each folder contains the editable
`invoice-config.json` and `invoice.json`; all eight use the same `invoice.typ` wrapper.
The shared fictional [Example Studio logo](logo.svg) is selected through `company.logo`.
Descriptions, greetings and notes are supplied in the selected language. Companies,
registrations, accounts and tax rates are fictional; these are presentation examples,
not national tax presets.

| Demo | PDF | Configuration | Input |
| --- | --- | --- | --- |
| German | [Rechnung](de/invoice.pdf) | [Config](de/invoice-config.json) | [Input](de/invoice.json) |
| English | [Invoice](en/invoice.pdf) | [Config](en/invoice-config.json) | [Input](en/invoice.json) |
| French | [Facture](fr/invoice.pdf) | [Config](fr/invoice-config.json) | [Input](fr/invoice.json) |
| Spanish | [Factura](es/invoice.pdf) | [Config](es/invoice-config.json) | [Input](es/invoice.json) |
| Italian | [Fattura](it/invoice.pdf) | [Config](it/invoice-config.json) | [Input](it/invoice.json) |
| Dutch | [Factuur](nl/invoice.pdf) | [Config](nl/invoice-config.json) | [Input](nl/invoice.json) |
| Portuguese | [Fatura](pt/invoice.pdf) | [Config](pt/invoice-config.json) | [Input](pt/invoice.json) |
| English (US) | [US invoice](en-US/invoice.pdf) | [Config](en-US/invoice-config.json) | [Input](en-US/invoice.json) |

The seven EUR examples use A4 and the same illustrative 20% rate to make presentation
differences easy to compare. The US example uses Letter, `en-US`, USD dollar symbols,
city/state/ZIP addresses and separate illustrative state/local tax components. It contains
US routing/account fields rather than IBAN/BIC fields.

## Rebuild

From the repository root, with typstgen 0.6.0 on PATH:

```sh
python3 examples/invoice-languages/build.py
```

`--typstgen /path/to/typstgen` selects another binary. After `scripts/test.sh` has installed
the pinned tool, the builder prefers that project-local binary; otherwise it uses `typstgen` on PATH.
Use `--output-dir output/invoice-demos` to keep the committed PDFs unchanged.

To prepare a single variant manually, from this directory:

```sh
typstgen prepare-invoice --config en-US/invoice-config.json en-US/invoice.json > en-US/resolved.json
typstgen compile invoice.typ --input resolved=en-US/resolved.json -o en-US/invoice.pdf
```

VAT configurations can use the existing CII/Factur-X path. Sales-tax configurations produce
PDFs and canonical component data; CII export rejects them rather than interpreting the
components as VAT. See [invoice configuration](../../docs/guides/invoice-configuration.md).
