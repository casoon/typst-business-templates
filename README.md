# Typst Business Templates

[![Crates.io](https://img.shields.io/crates/v/typst-business-templates.svg)](https://crates.io/crates/typst-business-templates)
[![Documentation](https://docs.rs/typst-business-templates/badge.svg)](https://docs.rs/typst-business-templates)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**Professional document generation for small businesses — as a Rust library or standalone CLI.**

Generate invoices, offers, contracts and more as PDF without a running Typst installation.
Templates, fonts and localization are embedded directly in the binary.

Created by [casoon.de](https://www.casoon.de).

---

## Rust Library

Add to your `Cargo.toml`:

```toml
[dependencies]
typst-business-templates = "0.1"
```

### Quick Start

```rust
use typst_business_templates::{
    DocgenCompiler, CompanyData, CompanyAddress, CompanyContact,
    InvoiceData, InvoiceMetadata, InvoiceRecipient, InvoiceItem,
};

fn main() -> anyhow::Result<()> {
    let company = CompanyData {
        name: "Mustermann IT-Services".into(),
        language: "de".into(),
        address: CompanyAddress {
            street: "Musterstraße".into(),
            house_number: "1".into(),
            postal_code: "12345".into(),
            city: "Berlin".into(),
            country: Some("Deutschland".into()),
        },
        contact: CompanyContact {
            email: Some("info@example.com".into()),
            ..Default::default()
        },
        ..Default::default()
    };

    let invoice = InvoiceData {
        metadata: InvoiceMetadata {
            invoice_number: "RE-2024-001".into(),
            invoice_date: "01.01.2024".into(),
            due_date: "15.01.2024".into(),
            ..Default::default()
        },
        recipient: InvoiceRecipient {
            name: "Kunde GmbH".into(),
            company: Some("Kunde GmbH".into()),
            address: typst_business_templates::types::RecipientAddress {
                street: "Kundenstraße".into(),
                house_number: "42".into(),
                postal_code: "10115".into(),
                city: "Berlin".into(),
                country: None,
            },
        },
        items: vec![InvoiceItem {
            position: 1,
            description: "Webentwicklung".into(),
            quantity: 8.0,
            unit: "h".into(),
            vat_rate: typst_business_templates::types::VatRate { percentage: 19 },
            unit_price: typst_business_templates::types::MoneyAmount { amount: 90.0, currency: None },
            total: typst_business_templates::types::MoneyAmount { amount: 720.0, currency: None },
            sub_items: vec![],
        }],
        totals: typst_business_templates::types::InvoiceTotals {
            subtotal: typst_business_templates::types::MoneyAmount { amount: 720.0, currency: None },
            vat_breakdown: vec![typst_business_templates::types::VatBreakdownItem {
                rate: 19,
                base: typst_business_templates::types::MoneyAmount { amount: 720.0, currency: None },
                amount: typst_business_templates::types::MoneyAmount { amount: 136.80, currency: None },
            }],
            total: typst_business_templates::types::MoneyAmount { amount: 856.80, currency: None },
        },
        payment: typst_business_templates::types::InvoicePayment {
            due_date: "15.01.2024".into(),
            bank_transfer_note: None,
        },
        salutation: None,
        closing: None,
    };

    let pdf = DocgenCompiler::new().compile_invoice(&invoice, &company)?;
    std::fs::write("rechnung.pdf", pdf)?;
    println!("PDF generated: rechnung.pdf");
    Ok(())
}
```

### Supported Templates

| Template name | Document type |
|---|---|
| `invoice` | Rechnung / Invoice |
| `offer` | Angebot / Offer |
| `contract` | Vertrag / Contract |
| `credentials` | Zugangsdaten / Credentials |
| `concept` | Konzept / Concept |
| `documentation` | Dokumentation / Documentation |
| `letter` | Brief / Letter |
| `delivery-note` | Lieferschein / Delivery Note |
| `credit-note` | Gutschrift / Credit Note |
| `reminder` | Mahnung / Reminder |

For templates other than `invoice`, use the generic `compile()` method:

```rust
let pdf = DocgenCompiler::new().compile(
    "offer",
    serde_json::to_vec(&offer_data)?,
    &company,
    "de",
)?;
```

### Custom Fonts

By default, system fonts are used. To load additional fonts:

```rust
let compiler = DocgenCompiler::new()
    .with_fonts_dir("/path/to/fonts");
```

---

## CLI (`docgen`)

**Professional document generation for small businesses without expensive software.**

Stop paying for bloated invoice and document software. This open-source solution combines:
- **[Typst](https://typst.app/)** - Modern markup language for beautiful PDFs
- **JSON Data Format** - Simple, human-readable data for your documents
- **AI-Powered Creation** - Use Claude or other LLMs to generate content
- **Interactive CLI** - Manage clients, projects, and documents from your terminal

Perfect for freelancers, agencies, and small businesses who want full control over their documents.

## Why This Approach?

| Traditional Software | This Solution |
|---------------------|---------------|
| Monthly subscriptions | Free & open source |
| Vendor lock-in | Your data in plain JSON |
| Limited customization | Full template control |
| Cloud dependency | Works offline |
| Complex interfaces | Simple CLI + AI |

### docgen vs. raw Typst

While templates are built with [Typst](https://typst.app/), the `docgen` CLI simplifies everything:

```bash
# With docgen - just point to your JSON
docgen compile invoice.json

# With raw typst - you handle all the paths
typst compile --root . --font-path fonts templates/invoice/default.typ output/invoice.pdf \
  --input data=/path/to/invoice.json --input company=/path/to/company.json
```

`docgen` auto-detects document type, finds templates, loads fonts, and places output correctly.

### The AI Workflow

Instead of clicking through forms, describe what you need:

```
"Create an invoice for client Acme Corp for 40 hours of web development 
at 85 EUR/hour, project was the new landing page, payment due in 14 days"
```

An AI assistant (we recommend [Claude](https://claude.ai)) generates the JSON, you review it, and compile to PDF. Fast, flexible, and you stay in control.

## Features

- **Invoice Template** - Professional German invoices with VAT calculation
- **Offer Template** - Quotes and proposals with item breakdowns
- **Credentials Template** - Secure access documentation for clients
- **Concept Template** - Project concepts and proposals
- **Documentation Template** - Technical documentation, API docs, project docs
- **Simple CLI** - Manage clients, projects, and create documents
- **JSON Data Storage** - Human-readable data files with automatic numbering
- **Direct .typ File Support** - Write documents directly in Typst without JSON
- **Project-Local Templates** - Standard templates auto-update, fork for customization
- **Watch Mode** - Auto-rebuild on file changes
- **10 Font Presets** - Bundled Google Fonts (Inter, Roboto, Montserrat, etc.)
- **Customizable Branding** - Colors, fonts, logo via company.json

## Quick Start

### Prerequisites

Install [Typst](https://github.com/typst/typst#installation) (required for PDF generation)

### Installation

#### Option 1: Homebrew (macOS/Linux)

```bash
# Add the tap
brew tap casoon/tap

# Install docgen
brew install docgen
```

#### Option 2: Install Script (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/casoon/typst-business-templates/main/install.sh | bash
```

#### Option 3: Download Binary

Download the latest release for your platform from [GitHub Releases](https://github.com/casoon/typst-business-templates/releases).

| Platform | Download |
|----------|----------|
| macOS (Apple Silicon) | `docgen-aarch64-apple-darwin.tar.gz` |
| macOS (Intel) | `docgen-x86_64-apple-darwin.tar.gz` |
| Linux (x64) | `docgen-x86_64-unknown-linux-gnu.tar.gz` |
| Linux (ARM64) | `docgen-aarch64-unknown-linux-gnu.tar.gz` |
| Windows (x64) | `docgen-x86_64-pc-windows-msvc.zip` |

#### Option 4: Build from Source

```bash
# Clone repository
git clone https://github.com/casoon/typst-business-templates.git
cd typst-business-templates

# Build CLI
cd cli
cargo build --release

# Add to PATH (optional)
export PATH="$PATH:$(pwd)/target/release"
```

### First Steps

```bash
# Initialize new project
docgen init my-business
cd my-business

# Edit your company data
nano data/company.json

# Add a client
docgen client add --name "Acme Corp"

# See all commands
docgen --help
```

## Direct .typ File Support & Templates

### Template System (v0.5.0+)

Templates live in your project directory for maximum portability:

```
project/
├── .docgen/templates/    # Standard templates (auto-updated)
│   ├── concept/
│   ├── invoice/
│   └── ...
├── templates/            # Your custom templates (stable)
│   └── my-custom-concept/
├── data/
│   ├── company.json
│   └── logo.png
└── documents/
```

**Initialize templates:**
```bash
docgen template init
```

**Standard Templates** (`.docgen/templates/`)
- Auto-updated on every `docgen compile` or `docgen build`
- Always match your docgen version
- Never committed to Git (in `.gitignore`)
- Perfect for standard business documents

**Custom Templates** (`templates/`)
- Fork from standard templates when you need customization
- Stable - never auto-updated
- Committed to Git - part of your project
- Full control over layout and structure

### Using Templates in .typ Files

```typ
// Standard template (auto-updated)
#import "/.docgen/templates/concept/default.typ": concept

// Custom template (stable)
#import "/templates/my-custom-concept/default.typ": my_custom_concept

// Load company and locale data
#let company = json("/data/company.json")
#let locale = json("/locale/de.json")

#show: concept.with(
  title: "Cloud Migration Strategy",
  document_number: "DOC-2025-001",
  client_name: "Example Corp",
  project_name: "Cloud Transformation",
  version: "1.0",
  status: "final",
  company: company,
  locale: locale,
)

= Current Situation

The client currently uses an outdated email infrastructure...

= Proposed Solution

Migration will be performed in multiple phases:

1. Inventory of existing email addresses
2. Setup of new mail server infrastructure
3. Mailbox migration
4. DNS switchover
```

Compile with:
```bash
docgen compile documents/concepts/2025/email-migration.typ
```

### Template Commands

```bash
# Initialize project templates
docgen template init

# List available templates
docgen template list

# Fork a standard template to customize it
docgen template fork concept --name my-custom-concept

# Update standard templates (normally automatic)
docgen template update
```

**Workflow: Customizing a Template**

1. Fork the template:
   ```bash
   docgen template fork invoice --name branded-invoice
   ```

2. Edit `templates/branded-invoice/default.typ`:
   ```typ
   // Add your custom styling
   #let primary-color = rgb("#FF6B35")
   // ... customize as needed
   ```

3. Commit to Git:
   ```bash
   git add templates/branded-invoice/
   git commit -m "Add custom branded invoice template"
   ```

4. Use in your documents:
   ```typ
   #import "/templates/branded-invoice/default.typ": invoice
   ```

**Benefits:**
- ✅ Everything in your project - works on any machine
- ✅ No system-wide package installation
- ✅ Commit custom templates to Git
- ✅ Standard templates always current
- ✅ Break-change protection - custom templates stay stable

## Workflow Options

### Option 1: Direct CLI Commands

Simple, direct commands for managing your business data:

```bash
# Manage clients
docgen client list
docgen client add --name "Acme Corp" --company "Acme Corporation GmbH"
docgen client show K-001

# Manage projects
docgen project list K-001
docgen project add K-001 "Website Redesign"

# Compile documents
docgen compile documents/invoices/RE-2025-001.json
docgen build documents/invoices/2025/
docgen watch documents/
```

All data stored in human-readable JSON files:
- `data/clients.json` - Your clients
- `data/projects.json` - Your projects
- `data/counters.json` - Auto-incrementing numbers

### Option 2: AI-Assisted Creation

1. **Describe your document** to an AI assistant:
   ```
   Create a JSON invoice for:
   - Client: K-001 (Acme Corp)
   - 3 items: 
     - 40h Development @ 85 EUR
     - 8h Code Review @ 85 EUR  
     - 500 EUR fixed for deployment
   - Due in 14 days
   ```

2. **AI generates the JSON** following the schema in `cli/templates/invoice.json`

3. **Save and compile**:
   ```bash
   docgen compile documents/invoices/RE-2025-001.json
   ```

4. **PDF ready** in `output/RE-2025-001.pdf`

### Option 3: Direct JSON Editing

For power users - copy a template, edit the JSON directly:

```bash
cp cli/templates/invoice.json documents/invoices/RE-2025-001.json
nano documents/invoices/RE-2025-001.json
docgen compile documents/invoices/RE-2025-001.json
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `docgen` | Show help |
| `docgen init <name>` | Create new project |
| `docgen compile <file>` | Compile JSON or .typ file to PDF (add `--encrypt` for password protection) |
| `docgen build [path]` | Build all documents (.json and .typ files) in directory |
| `docgen watch [path]` | Watch and auto-rebuild on changes |
| `docgen client list` | List all clients |
| `docgen client add --name "Name"` | Add new client (requires --name parameter) |
| `docgen client show <id>` | Show client details |
| `docgen project list <client>` | List projects |
| `docgen project add <client> <name>` | Add project |
| `docgen template init` | Initialize project templates |
| `docgen template list` | List standard and custom templates |
| `docgen template fork <name> --name <custom>` | Fork and customize a template |
| `docgen template update` | Update standard templates to current version |


### PDF Encryption

Protect sensitive documents (like credentials) with password encryption:

```bash
# Compile with encryption
docgen compile documents/credentials/2026/client-access.json --encrypt
# Enter password (will be visible): [type password]
```

**Default permissions:**
- Allow printing: yes
- Allow copying text/images: no
- Allow modifications: no
- Allow document modification? (default: no)

**Requirements:**
- Requires `qpdf` to be installed
- Installation:
  - macOS: `brew install qpdf`
  - Linux: `apt-get install qpdf` (Debian/Ubuntu) or `yum install qpdf` (RHEL/CentOS)
  - Windows: `choco install qpdf`
  - Or download from: https://github.com/qpdf/qpdf/releases

**Features:**
- AES-256 encryption (industry standard)
- Password protection
- Configurable permissions (print, copy, modify)
- Compatible with all PDF readers


## Project Structure

```
my-business/
├── data/
│   ├── clients.json       # Your clients (human-readable)
│   ├── projects.json      # Your projects (human-readable)
│   ├── counters.json      # Auto-incrementing numbers
│   └── company.json       # Your company data & settings
├── documents/
│   ├── invoices/
│   │   ├── 2025/          # Organized by year
│   │   └── 2026/
│   ├── offers/
│   │   └── 2026/
│   ├── credentials/
│   │   └── 2026/
│   ├── concepts/
│   │   └── 2026/
│   └── documentation/
│       └── 2026/
├── .docgen/templates/     # Standard templates (auto-updated)
├── templates/             # Your custom templates
└── output/
    └── 2026/              # PDFs organized by year
```

## Document Numbering

Automatic, consistent numbering managed by `data/counters.json`:

| Type | Format | Example |
|------|--------|---------|
| Client | K-XXX | K-001 |
| Project | P-KKK-NN | P-001-01 |
| Invoice | RE-YYYY-NNN | RE-2025-001 |
| Offer | AN-YYYY-NNN | AN-2025-001 |
| Credentials | ZD-YYYY-NNN | ZD-2025-001 |
| Concept | KO-YYYY-NNN | KO-2025-001 |

## Examples

The `examples/` directory contains complete, ready-to-use example projects for different types of businesses. Each project is self-contained with its own company data, documents, templates, and locales - just like a real project created with `docgen init`.

See [examples/README.md](examples/README.md) for detailed information about each project.

### Example Projects

#### 1. Digitalagentur (Web Agency)
**Pixelwerk Digitalagentur** - Full-service web agency from Cologne

Complete project with 5 documents (Invoice, Offer, Credentials, Concept, Documentation) demonstrating both JSON and .typ workflows.

[View Project →](examples/digitalagentur/)

#### 2. Freelance Designer
**Lisa Chen Design** - Freelance graphic designer from Hamburg

Demonstrates **Kleinunternehmer** setup (§19 UStG - no VAT). Includes invoices, offers, and credentials.

[View Project →](examples/freelance-designer/)

#### 3. IT Consultant
**TechVision Consulting** - IT consulting firm from Berlin

Demonstrates regular business with **19% VAT**. Includes security audits, penetration testing, and consulting services.

[View Project →](examples/it-consultant/)

### Try It Yourself

```bash
# Compile any document from an example project
cd examples/digitalagentur
docgen build

# Or compile a specific document
docgen compile documents/invoices/2025/invoice.json
```

## Template Customization

Templates are written in [Typst](https://typst.app/docs), a modern alternative to LaTeX.

**To customize a template:**

1. Fork it: `docgen template fork invoice --name my-invoice`
2. Edit: `templates/my-invoice/default.typ`
3. Commit: `git add templates/my-invoice/`
4. Use: `#import "/templates/my-invoice/default.typ": invoice`

**Standard templates** (`.docgen/templates/`) are auto-updated and should not be edited.
**Custom templates** (`templates/`) are yours to modify and version control.

### Company Configuration

The `company.json` file contains all business settings:

```json
{
  "name": "Your Company",
  "language": "de",
  "branding": {
    "accent_color": "#E94B3C",
    "primary_color": "#2c3e50",
    "font_preset": "inter"
  },
  "numbering": {
    "year_format": "short",
    "prefixes": {
      "invoice": "RE",
      "offer": "AN",
      "credentials": "ZD",
      "concept": "KO"
    }
  },
  "structure": {
    "organize_by_year": true
  },
  "default_terms": {
    "hourly_rate": "95.00",
    "currency": "EUR",
    "payment_days": 14,
    "vat_rate": 19,
    "standard_terms": [
      "All prices are net plus VAT.",
      "Payment due within 14 days."
    ]
  }
}
```

| Section | Purpose |
|---------|---------|
| `branding` | Colors, fonts, logo |
| `numbering` | Document number prefixes (RE, AN, ZD, KO) |
| `structure` | Organize documents by year |
| `default_terms` | Rates, payment terms, standard conditions |

### Multi-Language Support

Both the CLI and document templates support 7 languages:

| Code | Language |
|------|----------|
| `de` | Deutsch (German) |
| `en` | English |
| `fr` | Français (French) |
| `es` | Español (Spanish) |
| `it` | Italiano (Italian) |
| `nl` | Nederlands (Dutch) |
| `pt` | Português (Portuguese) |

Set the `language` field in `company.json` to change all labels, headings, and CLI output.

### Font Presets

10 professional Google Font combinations are available:

| Preset | Body/Heading | Mono | Style |
|--------|--------------|------|-------|
| `inter` | Inter | JetBrains Mono | Modern, clean |
| `roboto` | Roboto | Roboto Mono | Google's signature |
| `open-sans` | Open Sans | Source Code Pro | Friendly |
| `lato` | Lato | Fira Code | Elegant |
| `montserrat` | Montserrat | Fira Code | Geometric |
| `source-sans` | Source Sans 3 | Source Code Pro | Professional |
| `poppins` | Poppins | JetBrains Mono | Playful |
| `raleway` | Raleway | Fira Code | Sophisticated |
| `nunito` | Nunito | JetBrains Mono | Rounded |
| `work-sans` | Work Sans | Fira Code | Neutral |
| `default` | Helvetica | Courier New | System fallback |

All fonts are included in the `fonts/` directory. Use `--font-path fonts` when compiling:

```bash
typst compile --root . --font-path fonts templates/invoice/default.typ output/invoice.pdf \
  --input data=/path/to/invoice.json
```

## AI Integration Tips

When using Claude or other AI assistants:

1. **Share the JSON schema** from `cli/templates/` so the AI knows the structure
2. **Provide client context** - the AI can look up client data from your database exports
3. **Review before compiling** - always check the generated JSON for accuracy
4. **Use watch mode** during iteration: `docgen watch documents/`

Example prompt for Claude:
```
I'm using typst-business-templates. Here's my invoice schema: [paste schema]
Create an invoice JSON for client "Acme Corp" (K-001) for the following work:
- 40 hours frontend development at 95 EUR/hour
- Project: Website Redesign (P-001-02)
- Invoice date: today
- Payment terms: 14 days
```

## Documentation

- [Project Overview](docs/PROJECT.md) - Current state and ideas
- [Simplification Plan](docs/SIMPLIFICATION-PLAN.md) - Unix philosophy approach
- [Roadmap](docs/ROADMAP.md) - Detailed plan for upcoming improvements

## Requirements

- [Typst](https://typst.app/) >= 0.11
- [Rust](https://rustup.rs/) >= 1.70 (for building CLI)

## Philosophy

This tool follows Unix philosophy:
- **Do one thing well**: Generate professional business documents
- **Plain text**: All data in human-readable JSON
- **Composable**: Integrate with scripts, AI tools, version control
- **Simple**: Direct CLI commands, no complex UI

Future improvements focus on simplicity, not feature bloat:
- [ ] Edit/delete clients and projects
- [ ] Document templates in more languages
- [ ] E-invoice support (ZUGFeRD/XRechnung)
- [ ] Better AI integration examples

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome! Areas where help is needed:
- Additional document templates (delivery notes, credit notes, reminders)
- Internationalization (currently German-focused)
- Test coverage
- Binary releases for different platforms

Please feel free to submit a Pull Request.
