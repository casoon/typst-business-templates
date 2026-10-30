---
title: AI assistants with MCP
description: Connect an assistant to typstgen to check, preview and compile these templates using an existing letter example.
order: 5
---

The MCP server belongs to [typstgen](https://casoon.github.io/typstgen/), the separate PDF
builder. This template package supplies the layouts and schemas. An MCP-compatible assistant
can call the builder while its own editor tools update your JSON data or Typst source files.

## Connect an example project

Complete the [installation guide](../../getting-started/installation/) first, including the
template package and fonts. The repository's `examples/it-consultant` project already has a
`typstgen.toml` with package and font paths. Use that directory as the server root.

Configure a local stdio server in your MCP client's server settings. The settings-file location
depends on your client; this is the common `mcpServers` shape:

```json
{
  "mcpServers": {
    "typstgen": {
      "command": "/absolute/path/to/typstgen",
      "args": ["mcp", "--root", "/absolute/path/to/typst-business-templates/examples/it-consultant"]
    }
  }
}
```

Replace both paths. For configured invoices, use the pinned binary installed by the setup
guide under `.cache/test-tools/typstgen-<revision>/bin/typstgen`. An absolute executable path
avoids a desktop client's different `PATH` selecting an older global installation.
Restart or reconnect the server as required by your client.

The root selects the working directory and its `typstgen.toml`. Tool input and output paths
are relative to it. Configured package and font paths resolve from the project configuration.
Give the assistant's editor tools access to the same project so it can make requested edits.

## Try the included letter

Ask your assistant:

> Check `documents/letters/2025/letter-001.typ`, show me page 1 and report any compiler
> warnings. After I review the preview, compile it to
> `documents/letters/2025/letter-001-mcp.pdf`. Use `creation_timestamp: 1792972800`
> for the check, preview and compile calls.

The calls use the same document path and fixed timestamp:

| Tool | Arguments for this example | Result |
| --- | --- | --- |
| `check` | `path`, `creation_timestamp` | Compiler diagnostics and page count; writes no PDF |
| `preview` | `path`, `creation_timestamp`, `page: 1` | A PNG of the requested page |
| `compile` | `path`, `creation_timestamp`, `output` | PDF written to the requested project path |

`list_templates` lists `.typ` files in the configured template directories. It is a source-file
discovery tool; the [package reference](../../reference/package/) describes the exported
template functions. MCP does not translate document content or edit files itself.

## Keep the build reproducible

The model's proposed edits can vary. Once you accept the source and JSON, the same complete
input set goes through the same compiler as a CLI build. Keep data, templates, assets, fonts,
compiler/package versions and timestamp fixed. See [Deterministic builds](../json-documents/#deterministic-builds).

A successful `check` reports compiler results. Inspect the preview for layout and review the
document's content separately. External invoice validation remains a separate step.

## Configured invoices

typstgen 0.6.0 also exposes `prepare_invoice`, `list_document_profiles`,
`resolve_document_profile`, `validate_document` and `e_invoice`. Use [invoice configuration](../invoice-configuration/)
for user-owned tax and presentation settings, or [invoice profiles](../invoice-profiles/)
for explicitly bounded profile checks. Older typstgen versions do not include those tools.

For the full tool parameters and a video with actual tool results, see
[typstgen's MCP guide](https://casoon.github.io/typstgen/docs/guides/ai-agents/).
