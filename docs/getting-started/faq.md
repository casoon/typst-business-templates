---
title: Common questions
description: Local data, AI assistants, operating systems and the choice of compiler.
order: 3
---

## Do I need a separate Typst installation?

typstgen embeds the Typst compiler. You install typstgen and make the template package and
fonts available using the [setup guide](../installation/).

The standalone Typst CLI can render the base templates too, with the appropriate project root,
package and font paths. Configured invoice preparation, typstgen's Factur-X embedding,
build manifests and MCP tools belong to typstgen; they are separate from template rendering.
See the [package reference](../../reference/package/) and
[typstgen documentation](https://casoon.github.io/typstgen/).

## Are the invoice and tax cases reviewed by a tax adviser?

No. The profiles are templates built from the statutes and standards named in their sources.
Nobody has certified them for your situation. Only two cases are released (domestic standard and
reduced rates, and the small business exemption of § 19 UStG), and even those are bounded previews;
the other cases are drafts that you select explicitly, and you confirm their prerequisites. Have a
tax adviser or accountant check the profile, wording and amounts before you issue real invoices.
See [invoice profiles](../../guides/invoice-profiles/).

## Where are my data stored?

Company details, document data, templates and output PDFs are files in your project directory.
PDF compilation runs locally and requires no document-generation account or cloud service.
External Typst packages can be downloaded when an import needs them. For offline builds,
provide the dependencies locally and disable package downloads in typstgen's configuration.

When you connect an AI assistant through MCP, the assistant can receive document inputs,
diagnostics and page previews. Its model may run locally or through an external provider.
Check your client's data handling and the project access you grant it before using confidential
content. The [MCP guide](../../guides/ai-agents/) explains the editor/server boundary.

## Can I use Windows?

The templates are Typst source files. The repository's automated checks run on Linux, and local
checks have been run on macOS; Windows is not covered by this verification. The installation
guide lists the Windows package directory, but its shell commands use Unix syntax. On Windows,
adapt those commands for your shell, including executable paths and environment variables.

This is currently a package and compiler workflow, rather than a desktop application with
an installer and forms. See [Installation](../installation/) for the actual prerequisites.

## Are all documents available in seven languages?

Invoices have translated labels in German, English, French, Spanish, Italian, Dutch and
Portuguese. Other templates have their own language support; several accounting templates
retain German labels and DIN-specific formats. Body text comes from your input and is not
automatically translated. See [Branding and languages](../../guides/branding/).

## Does a successful build mean an e-invoice is ready to send?

A build checks the supported input and compiler constraints. Review the resulting PDF and run
the appropriate external invoice validator separately. National profiles and export formats
have explicit boundaries; see [Capabilities and limits](../../reference/project-status/)
and [Invoice profiles](../../guides/invoice-profiles/).

## What changes for former docgen users?

typstgen replaces the compiler portion. It does not carry over client/project management,
automatic numbering, watch mode or `--encrypt`. Keep those workflows in the calling project.
The [migration guide](../../guides/migration/) explains template imports, JSON compatibility
and the independent package version.
