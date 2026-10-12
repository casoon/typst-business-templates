---
title: CLI commands
description: Every docgen command and option, as of docgen 0.7.2.
order: 1
---

`docgen` without a command prints the help. Run it from the project root.

## Documents

| Command | Does |
| --- | --- |
| `docgen init <name>` | Create a project folder with `data/company.json`, `documents/`, `output/`, `templates/` and `.docgen/templates/` |
| `docgen compile <file>` | Compile one `.json` or `.typ` file to PDF |
| `docgen build [path]` | Compile every `.json` and `.typ` file below `path` (default `documents`) |
| `docgen watch [path]` | Recompile on changes below `path` (default `documents`), Ctrl+C to stop |
| `docgen ai-guide` | Print a guide with data formats and workflows for AI assistants |

### `compile` options

| Option | Meaning |
| --- | --- |
| `-o`, `--output <file>` | PDF path. Default: next to the input, with `.pdf` |
| `-t`, `--template <name>` | Template to use when the path does not name it, see [how the template is chosen](../../guides/json-documents/#how-the-template-is-chosen) |
| `-e`, `--encrypt` | Password-protect the PDF with `qpdf` (AES-256) |

### `build` options

| Option | Meaning |
| --- | --- |
| `-o`, `--output <dir>` | Output folder. Default: `output` |

## Templates

| Command | Does |
| --- | --- |
| `docgen template init` | Extract the standard templates into `.docgen/templates/` |
| `docgen template list` | List standard and custom templates |
| `docgen template fork <template> --name <custom>` | Copy a standard template to `templates/<custom>/` |
| `docgen template update` | Update the standard templates now (normally automatic) |

See [Documents in Typst](../../guides/typst-documents/) for the difference between standard and
custom templates.

## Clients and projects

Clients, projects and number counters are plain JSON files in `data/` (`clients.json`,
`projects.json`, `counters.json`).

| Command | Does |
| --- | --- |
| `docgen client list` | List all clients |
| `docgen client add --name "<name>"` | Add a client; numbers are assigned as `K-001`, `K-002` … |
| `docgen client show <id>` | Show a client, by number (`1`) or `K-001` |
| `docgen client delete <id>` | Delete a client |
| `docgen project list <client>` | List a client's projects |
| `docgen project add <client> "<name>"` | Add a project |
| `docgen project delete <id>` | Delete a project, by number (`P-001-01`) |

`docgen <command> --help` prints the details of each command.
