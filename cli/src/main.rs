mod commands;
mod data;
mod embedded;
mod encrypt;
mod local_templates;
mod locale;

use anyhow::{Context, Result};
use clap::{Parser, Subcommand};
use colored::Colorize;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use typst_business_templates::{CompanyData, DocgenCompiler};
use walkdir::WalkDir;

// Import new JSON-based stores
use locale::{t, tf};

#[derive(Parser)]
#[command(name = "docgen")]
#[command(author = "Typst Business Templates")]
#[command(version)]
#[command(about = "Generate professional business documents with Typst")]
#[command(long_about = "Generate professional business documents with Typst

docgen is a CLI tool for creating invoices, offers, credentials, concepts, and
documentation from JSON data or direct .typ files. It uses Typst for beautiful
PDF generation with full control over templates and branding.

Features:
  • Professional business documents (invoices, offers, credentials)
  • Multi-language support: de, en, es, fr, it, nl, pt
  • Concept and documentation templates with package system
  • Custom branding (colors, fonts, logo)
  • SQLite database for client/project management
  • Watch mode for auto-rebuild
  • PDF encryption for sensitive documents

Quick Start:
  docgen init my-business    # Create new project
  docgen compile invoice.json # Compile document
  docgen build               # Build all documents
  docgen ai-guide            # Show guide for AI assistants

Examples: https://github.com/casoon/typst-business-templates/tree/main/examples
")]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Initialize a new document project
    ///
    /// Creates a new project with the following structure:
    ///   - data/company.json (company info & branding)
    ///   - documents/ (organized by type and year)
    ///   - templates/ (Typst templates)
    ///   - locale/ (7 languages: de, en, es, fr, it, nl, pt)
    ///   - output/ (generated PDFs)
    ///
    /// Example: docgen init my-business
    Init {
        /// Project directory name
        name: String,
    },
    /// Compile a single document from JSON or .typ to PDF
    ///
    /// Supports two workflows:
    ///   1. JSON → PDF: docgen compile invoice.json
    ///   2. .typ → PDF: docgen compile concept.typ
    ///
    /// Auto-detects document type from filename or use --template.
    /// Use --encrypt to password-protect sensitive documents.
    ///
    /// Examples:
    ///   docgen compile documents/invoices/2025/RE-2025-001.json
    ///   docgen compile invoice.json -o output/custom.pdf
    ///   docgen compile credentials.json --encrypt
    Compile {
        /// Path to JSON or .typ file
        input: PathBuf,
        /// Output PDF path (optional, auto-generated if not specified)
        #[arg(short, long)]
        output: Option<PathBuf>,
        /// Template type (invoice, offer, credentials, concept, documentation)
        /// Only needed if auto-detection fails
        #[arg(short, long)]
        template: Option<String>,
        /// Encrypt the PDF with password protection (requires qpdf)
        #[arg(short, long)]
        encrypt: bool,
    },
    /// Build all documents in a directory
    ///
    /// Recursively finds all .json and .typ files and compiles them to PDF.
    /// Maintains directory structure in output folder.
    ///
    /// Examples:
    ///   docgen build                    # Build all in documents/
    ///   docgen build documents/invoices # Build only invoices
    ///   docgen build -o pdfs            # Custom output directory
    Build {
        /// Directory containing JSON and .typ files
        #[arg(default_value = "documents")]
        path: PathBuf,
        /// Output directory for PDFs
        #[arg(short, long, default_value = "output")]
        output: PathBuf,
    },
    /// Watch for changes and rebuild automatically
    ///
    /// Monitors directory for file changes and automatically recompiles
    /// documents when .json or .typ files are modified.
    ///
    /// Press Ctrl+C to stop watching.
    ///
    /// Example: docgen watch documents/
    Watch {
        /// Directory to watch for changes
        #[arg(default_value = "documents")]
        path: PathBuf,
    },
    /// Client management (SQLite database)
    ///
    /// Manage clients in the local database:
    ///   - list: Show all clients
    ///   - add: Add new client
    ///   - show: Display client details
    ///
    /// Example: docgen client list
    Client {
        #[command(subcommand)]
        action: ClientAction,
    },
    /// Project management (SQLite database)
    ///
    /// Manage projects linked to clients:
    ///   - list: Show projects for a client
    ///   - add: Create new project
    ///
    /// Example: docgen project list K-001
    Project {
        #[command(subcommand)]
        action: ProjectAction,
    },
    /// Template management
    ///
    /// Manage project-local templates for document generation:
    ///   - init: Initialize templates in .docgen/templates/
    ///   - list: Show available templates
    ///   - fork: Copy a standard template to templates/ for customization
    ///   - update: Update standard templates (normally automatic)
    ///
    /// Standard templates are stored in .docgen/templates/ and auto-update.
    /// Custom templates go in templates/ and remain stable.
    ///
    /// Examples:
    ///   docgen template init
    ///   docgen template list
    ///   docgen template fork concept --name branded-concept
    ///   docgen template update
    Template {
        #[command(subcommand)]
        action: TemplateAction,
    },
    /// Show AI assistant guide (detailed documentation for LLMs)
    ///
    /// Displays comprehensive documentation designed for AI assistants like
    /// Claude, ChatGPT, etc. Includes complete JSON schemas, workflows,
    /// and best practices.
    ///
    /// Copy the output and share with your AI assistant to help them
    /// understand docgen and generate documents for you.
    ///
    /// Example: docgen ai-guide > guide.txt
    AiGuide,
}

#[derive(Subcommand)]
enum ClientAction {
    /// List all clients from database
    ///
    /// Displays a table with client number, name, city, and email.
    ///
    /// Example: docgen client list
    List,
    /// Add a new client to database
    ///
    /// Interactively prompts for client information if --name not provided.
    /// Automatically assigns next client number (K-001, K-002, etc.).
    ///
    /// Examples:
    ///   docgen client add
    ///   docgen client add --name "Acme Corp"
    Add {
        /// Client name (optional, will prompt if not provided)
        #[arg(short, long)]
        name: Option<String>,
    },
    /// Show detailed client information
    ///
    /// Display full client details including address, contact, and projects.
    ///
    /// Examples:
    ///   docgen client show K-001
    ///   docgen client show 1
    Show {
        /// Client number (e.g., 1) or K-number (e.g., K-001)
        id: String,
    },
    /// Delete a client
    ///
    /// Removes a client from the database. Warning: This cannot be undone.
    ///
    /// Examples:
    ///   docgen client delete K-001
    ///   docgen client delete 1
    Delete {
        /// Client number (e.g., 1) or K-number (e.g., K-001)
        id: String,
    },
}

#[derive(Subcommand)]
enum ProjectAction {
    /// List all projects for a client
    ///
    /// Shows project number, name, and status for the specified client.
    ///
    /// Examples:
    ///   docgen project list K-001
    ///   docgen project list 1
    List {
        /// Client ID (K-001) or client number (1)
        client: String,
    },
    /// Add a new project for a client
    ///
    /// Creates a new project linked to the specified client.
    /// Automatically assigns project number (P-001-01, P-001-02, etc.).
    ///
    /// Example: docgen project add K-001 "Website Redesign"
    Add {
        /// Client ID (K-001) or client number (1)
        client: String,
        /// Project name
        name: String,
    },
    /// Delete a project
    ///
    /// Removes a project from the database. Warning: This cannot be undone.
    ///
    /// Examples:
    ///   docgen project delete P-001-01
    Delete {
        /// Project number (e.g., P-001-01)
        id: String,
    },
}

#[derive(Subcommand)]
enum TemplateAction {
    /// Initialize project templates
    ///
    /// Creates .docgen/templates/ with standard templates.
    /// Standard templates are auto-updated on every compile.
    ///
    /// Example: docgen template init
    Init,

    /// Fork a standard template to custom template
    ///
    /// Copies a template from .docgen/templates/ to templates/custom-name/
    /// Custom templates are stable and never auto-updated.
    ///
    /// Examples:
    ///   docgen template fork concept --name my-concept
    ///   docgen template fork invoice --name custom-invoice
    Fork {
        /// Template name to fork (concept, invoice, offer, etc.)
        template: String,

        /// Custom name for the forked template
        #[arg(short, long)]
        name: String,
    },

    /// List available templates
    ///
    /// Shows standard templates (.docgen/templates/) and custom templates (templates/)
    ///
    /// Example: docgen template list
    List,

    /// Update standard templates to current version
    ///
    /// Manually trigger update of .docgen/templates/ (normally auto-updated)
    ///
    /// Example: docgen template update
    Update,
}

fn main() -> Result<()> {
    // Initialize locale system
    locale::init();

    let cli = Cli::parse();

    match cli.command {
        // No command = show help (interactive mode removed for simplification)
        None => {
            println!("docgen - Document generation tool\n");
            println!("Usage: docgen <command>\n");
            println!("Commands:");
            println!("  compile <file>     Compile document to PDF");
            println!("  build <dir>        Build all documents in directory");
            println!("  watch <dir>        Watch and auto-rebuild");
            println!("  client list        List all clients");
            println!("  client add         Add new client");
            println!("  project list       List projects for client");
            println!("  template init      Initialize project templates");
            println!("\nFor more help: docgen --help");
            Ok(())
        }
        Some(Commands::Init { name }) => init_project(&name),
        Some(Commands::Compile {
            input,
            output,
            template,
            encrypt,
        }) => compile_document(&input, output, template, encrypt),
        Some(Commands::Build { path, output }) => build_all(&path, &output),
        Some(Commands::Watch { path }) => watch_directory(&path),
        Some(Commands::Client { action }) => commands::client::handle(action),
        Some(Commands::Project { action }) => commands::project::handle(action),
        Some(Commands::Template { action }) => commands::template::handle(action),
        Some(Commands::AiGuide) => show_ai_guide(),
    }
}

fn init_project(name: &str) -> Result<()> {
    println!(
        "{} {}: {}",
        "→".blue(),
        t("init", "initializing"),
        name.green()
    );

    let base = Path::new(name);

    // Get current year for initial directory structure
    let current_year = chrono::Local::now().format("%Y").to_string();

    let dirs = [
        "data",
        // Accounting-Layout Templates
        &format!("documents/invoices/{}", current_year),
        &format!("documents/offers/{}", current_year),
        &format!("documents/letters/{}", current_year),
        &format!("documents/credit-notes/{}", current_year),
        &format!("documents/reminders/{}", current_year),
        &format!("documents/delivery-notes/{}", current_year),
        &format!("documents/order-confirmations/{}", current_year),
        &format!("documents/time-sheets/{}", current_year),
        &format!("documents/quotation-requests/{}", current_year),
        // Document-Layout Templates
        &format!("documents/credentials/{}", current_year),
        &format!("documents/concepts/{}", current_year),
        &format!("documents/documentation/{}", current_year),
        &format!("documents/contracts/{}", current_year),
        &format!("documents/protocols/{}", current_year),
        &format!("documents/specifications/{}", current_year),
        &format!("documents/proposals/{}", current_year),
        &format!("documents/slas/{}", current_year),
        &format!("output/{}", current_year),
        "templates",
    ];

    for dir in dirs {
        std::fs::create_dir_all(base.join(dir))?;
    }

    // Create company.json with language field
    let company = r##"{
  "name": "Your Company",
  "language": "en",
  "address": {
    "street": "Street",
    "house_number": "1",
    "postal_code": "12345",
    "city": "City",
    "country": "Country"
  },
  "contact": {
    "phone": "+1 234 567890",
    "email": "info@example.com",
    "website": "www.example.com"
  },
  "tax_id": "123/456/78901",
  "vat_id": "XX123456789",
  "business_owner": "Your Name",
  "bank_account": {
    "bank_name": "Bank",
    "account_holder": "Your Company",
    "iban": "XX00 0000 0000 0000 0000 00",
    "bic": "BANKXXXX"
  },
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
      "concept": "KO",
      "documentation": "DOC"
    }
  },
  "structure": {
    "organize_by_year": true
  },
  "default_terms": {
    "hourly_rate": "95.00",
    "currency": "EUR",
    "payment_days": 14,
    "warranty_months": 12,
    "vat_rate": 19,
    "standard_terms": [
      "All prices are net plus statutory VAT.",
      "Payment due within 14 days without deduction.",
      "Copyright remains with the contractor until full payment."
    ]
  }
}"##;
    std::fs::write(base.join("data/company.json"), company)?;

    // Initialize templates using the new v0.5.0 system
    std::env::set_current_dir(&base)?;
    local_templates::init_project()?;

    // Write embedded locales
    let locale_dir = base.join("locale");
    std::fs::create_dir_all(&locale_dir)?;
    for locale in embedded::get_locales() {
        std::fs::write(locale_dir.join(locale.path), locale.content)?;
    }

    // Create .gitignore
    std::fs::write(base.join(".gitignore"), "output/*.pdf\ndata/docgen.db\n")?;

    println!("{} {}", "✓".green(), t("init", "created"));

    println!();
    println!("{}:", t("init", "next_steps"));
    println!("  cd {}", name);
    println!("  # {}", t("init", "edit_company"));
    println!("  nano data/company.json");
    println!("  # {}", t("init", "start_interactive"));
    println!("  docgen");

    Ok(())
}

fn compile_document(
    input: &Path,
    output: Option<PathBuf>,
    template: Option<String>,
    encrypt: bool,
) -> Result<()> {
    if !input.exists() {
        anyhow::bail!("{}: {}", t("compile", "file_not_found"), input.display());
    }

    // Auto-update local templates to current version
    local_templates::ensure_local_templates_updated()?;

    let output_path = output.unwrap_or_else(|| input.with_extension("pdf"));

    println!(
        "{} {}",
        "→".blue(),
        tf(
            "compile",
            "compiling",
            &[
                &input.display().to_string(),
                &output_path.display().to_string()
            ]
        )
    );

    // Determine company.json and locale paths
    let company_path = "/data/company.json";
    let company_json_path = Path::new("data/company.json");

    // Read language from company.json to determine locale
    let locale_path = if company_json_path.exists() {
        let company_content = std::fs::read_to_string(company_json_path).unwrap_or_default();
        let lang = serde_json::from_str::<serde_json::Value>(&company_content)
            .ok()
            .and_then(|v| v.get("language").and_then(|l| l.as_str().map(String::from)))
            .unwrap_or_else(|| "de".to_string());
        format!("/locale/{}.json", lang)
    } else {
        "/locale/de.json".to_string()
    };

    // Check if input is a .typ file (direct compilation mode)
    let status = if input.extension().map_or(false, |ext| ext == "typ") {
        // Direct .typ file compilation
        Command::new("typst")
            .args([
                "compile",
                "--root",
                ".",
                &input.to_string_lossy(),
                "--input",
                &format!("company={}", company_path),
                "--input",
                &format!("locale={}", locale_path),
                &output_path.to_string_lossy(),
            ])
            .status()
            .context(t("compile", "typst_not_found"))?
    } else {
        // JSON-based compilation with template
        let doc_type = template
            .unwrap_or_else(|| detect_document_type(input).unwrap_or("invoice".to_string()));

        if doc_type == "diagram" {
            let company = load_company_data(company_json_path)?;
            let data = fs::read(input).context("Failed to read diagram JSON")?;
            let pdf =
                DocgenCompiler::new().compile("diagram", data, &company, &company.language)?;
            fs::write(&output_path, pdf).context("Failed to write diagram PDF")?;

            if encrypt {
                encrypt::check_qpdf_available()?;

                println!("{} {}", "→".blue(), "Encrypting PDF...");
                let encryption_opts = encrypt::prompt_encryption_options()?;
                let temp_path = output_path.with_extension("pdf.tmp");
                std::fs::rename(&output_path, &temp_path)?;
                encrypt::encrypt_pdf(&temp_path, &output_path, encryption_opts)?;
                std::fs::remove_file(&temp_path)?;
                println!("{} {}", "✓".green(), "PDF encrypted successfully");
            }

            println!("{} {}", "✓".green(), t("compile", "success"));
            return Ok(());
        }

        let template_path = format!(".docgen/templates/{}/default.typ", doc_type);
        let data_path = format!("/{}", input.display());

        Command::new("typst")
            .args([
                "compile",
                "--root",
                ".",
                &template_path,
                "--input",
                &format!("data={}", data_path),
                "--input",
                &format!("company={}", company_path),
                "--input",
                &format!("locale={}", locale_path),
                &output_path.to_string_lossy(),
            ])
            .status()
            .context(t("compile", "typst_not_found"))?
    };

    if status.success() {
        println!("{} {}", "✓".green(), t("compile", "success"));

        // Handle encryption if requested
        if encrypt {
            // Check if qpdf is available first
            encrypt::check_qpdf_available()?;

            println!("{} {}", "→".blue(), "Encrypting PDF...");
            let encryption_opts = encrypt::prompt_encryption_options()?;
            let temp_path = output_path.with_extension("pdf.tmp");

            // Rename original to temp
            std::fs::rename(&output_path, &temp_path)?;

            // Encrypt temp to final output
            encrypt::encrypt_pdf(&temp_path, &output_path, encryption_opts)?;

            // Remove temp file
            std::fs::remove_file(&temp_path)?;

            println!("{} {}", "✓".green(), "PDF encrypted successfully");
        }

        Ok(())
    } else {
        anyhow::bail!("{}", t("compile", "failed"))
    }
}

fn load_company_data(path: &Path) -> Result<CompanyData> {
    if path.exists() {
        let content = fs::read(path)?;
        Ok(serde_json::from_slice(&content).context("Failed to parse data/company.json")?)
    } else {
        Ok(CompanyData {
            name: "Diagram".to_string(),
            language: "de".to_string(),
            logo: None,
            logo_width: None,
            branding: Default::default(),
            address: typst_business_templates::types::CompanyAddress {
                street: String::new(),
                house_number: String::new(),
                postal_code: String::new(),
                city: String::new(),
                country: None,
            },
            contact: typst_business_templates::types::CompanyContact {
                phone: None,
                email: None,
                website: None,
            },
            tax_id: None,
            vat_id: None,
            business_owner: None,
            bank_account: None,
        })
    }
}

fn build_all(path: &Path, output: &Path) -> Result<()> {
    println!(
        "{} {}",
        "→".blue(),
        tf("build", "building_all", &[&path.display().to_string()])
    );

    std::fs::create_dir_all(output)?;

    let mut count = 0;
    let mut errors = 0;

    // Find both .json and .typ files
    for entry in WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| {
            e.path()
                .extension()
                .map_or(false, |ext| ext == "json" || ext == "typ")
        })
    {
        let input = entry.path();
        let output_file = output
            .join(input.file_stem().unwrap())
            .with_extension("pdf");

        match compile_document(input, Some(output_file), None, false) {
            Ok(_) => count += 1,
            Err(e) => {
                println!(
                    "{} {}: {}",
                    "✗".red(),
                    tf("compile", "error_at", &[&input.display().to_string()]),
                    e
                );
                errors += 1;
            }
        }
    }

    println!();
    println!(
        "{} {}",
        if errors == 0 {
            "✓".green()
        } else {
            "!".yellow()
        },
        tf(
            "build",
            "documents_created",
            &[&count.to_string(), &errors.to_string()]
        )
    );

    Ok(())
}

fn watch_directory(path: &Path) -> Result<()> {
    use notify::{Config, EventKind, RecommendedWatcher, RecursiveMode, Watcher};
    use std::sync::mpsc::channel;
    use std::time::Duration;

    println!(
        "{} {}",
        "→".blue(),
        tf("watch", "watching", &[&path.display().to_string()])
    );

    let (tx, rx) = channel();
    let mut watcher = RecommendedWatcher::new(tx, Config::default())?;
    watcher.watch(path, RecursiveMode::Recursive)?;

    loop {
        match rx.recv_timeout(Duration::from_secs(1)) {
            Ok(Ok(event)) => {
                if matches!(event.kind, EventKind::Modify(_) | EventKind::Create(_)) {
                    for path in event.paths {
                        if path
                            .extension()
                            .map_or(false, |ext| ext == "json" || ext == "typ")
                        {
                            println!();
                            println!(
                                "{} {}: {}",
                                "⟳".yellow(),
                                t("watch", "change_detected"),
                                path.display()
                            );
                            let _ = compile_document(&path, None, None, false);
                        }
                    }
                }
            }
            Ok(Err(e)) => println!("{}: {}", t("common", "error"), e),
            Err(_) => {}
        }
    }
}

fn detect_document_type(path: &Path) -> Option<String> {
    let s = path.to_string_lossy().to_lowercase();

    // Accounting-Layout Templates
    if s.contains("invoice") || s.contains("rechnung") || s.contains("/re-") {
        Some("invoice".to_string())
    } else if s.contains("offer") || s.contains("angebot") || s.contains("/an-") {
        Some("offer".to_string())
    } else if s.contains("letter") || s.contains("brief") || s.contains("/br-") {
        Some("letter".to_string())
    } else if s.contains("credit-note")
        || s.contains("credit_note")
        || s.contains("gutschrift")
        || s.contains("/gs-")
    {
        Some("credit-note".to_string())
    } else if s.contains("reminder") || s.contains("mahnung") || s.contains("/m") {
        Some("reminder".to_string())
    } else if s.contains("delivery-note")
        || s.contains("delivery_note")
        || s.contains("lieferschein")
        || s.contains("/ls-")
    {
        Some("delivery-note".to_string())
    } else if s.contains("order-confirmation")
        || s.contains("order_confirmation")
        || s.contains("auftragsbestätigung")
        || s.contains("/ab-")
    {
        Some("order-confirmation".to_string())
    } else if s.contains("time-sheet")
        || s.contains("time_sheet")
        || s.contains("timesheet")
        || s.contains("stundenzettel")
        || s.contains("/ts-")
    {
        Some("time-sheet".to_string())
    } else if s.contains("quotation-request")
        || s.contains("quotation_request")
        || s.contains("angebotsanfrage")
        || s.contains("/anf-")
    {
        Some("quotation-request".to_string())
    }
    // Document-Layout Templates
    else if s.contains("credential") || s.contains("zugang") || s.contains("/zd-") {
        Some("credentials".to_string())
    } else if s.contains("concept") || s.contains("konzept") || s.contains("/ko-") {
        Some("concept".to_string())
    } else if s.contains("documentation") || s.contains("dokumentation") || s.contains("/dok-") {
        Some("documentation".to_string())
    } else if s.contains("diagram")
        || s.contains("mindmap")
        || s.contains("flowchart")
        || s.contains("organigram")
        || s.contains("visual")
    {
        Some("diagram".to_string())
    } else if s.contains("contract") || s.contains("vertrag") || s.contains("/vtr-") {
        Some("contract".to_string())
    } else if s.contains("protocol") || s.contains("protokoll") || s.contains("/prot-") {
        Some("protocol".to_string())
    } else if s.contains("specification") || s.contains("spezifikation") || s.contains("/spec-") {
        Some("specification".to_string())
    } else if s.contains("proposal") || s.contains("vorschlag") || s.contains("/pro-") {
        Some("proposal".to_string())
    } else if s.contains("sla") || s.contains("/sla-") {
        Some("sla".to_string())
    } else {
        None
    }
}

fn show_ai_guide() -> Result<()> {
    let guide = r##"
================================================================================
DOCGEN - AI ASSISTANT GUIDE
================================================================================

This guide helps AI assistants (like Claude, ChatGPT, etc.) quickly understand
and work with the docgen document generation system.

## QUICK OVERVIEW

docgen generates professional business documents (invoices, offers, credentials,
concepts, documentation) from JSON data or direct .typ files using Typst.

## PROJECT STRUCTURE

When you run `docgen init my-business`, it creates:

```
my-business/
├── data/
│   ├── docgen.db          # SQLite database (auto-created)
│   └── company.json       # Company data & branding
├── documents/
│   ├── invoices/2025/     # Invoice JSON files
│   ├── offers/2025/       # Offer JSON files
│   ├── credentials/2025/  # Credentials JSON files
│   ├── concepts/2025/     # Concept .typ files (or JSON)
│   └── documentation/2025/# Documentation .typ files (or JSON)
├── locale/                # 7 languages: de, en, es, fr, it, nl, pt
│   ├── de.json
│   ├── en.json
│   └── ...
├── templates/             # Typst templates (auto-installed)
│   ├── invoice/
│   ├── offer/
│   ├── credentials/
│   ├── concept/
│   ├── documentation/
│   └── common/
└── output/                # Generated PDFs
    └── 2025/
```

## DOCUMENT TYPES & WORKFLOWS

### 1. INVOICE (Rechnung) - JSON Workflow
File: `documents/invoices/2025/RE-2025-001.json`

**JSON Schema:**
```json
{
  "metadata": {
    "invoice_number": "RE-2025-001",
    "invoice_date": { "date": "2025-01-23" },
    "due_date": { "date": "2025-02-06" },
    "customer_number": "K-001",
    "project_reference": "Website Redesign"
  },
  "recipient": {
    "name": "Max Mustermann",
    "company": "Firma GmbH",
    "address": {
      "street": "Hauptstraße",
      "house_number": "123",
      "postal_code": "12345",
      "city": "Berlin",
      "country": "Deutschland"
    }
  },
  "items": [
    {
      "position": 1,
      "description": "Webentwicklung",
      "quantity": "40",
      "unit": "Stunden",
      "unit_price": { "amount": "95.00", "currency": "EUR" },
      "vat_rate": { "code": "Standard", "percentage": "19" },
      "total": { "amount": "3800.00", "currency": "EUR" }
    }
  ],
  "totals": {
    "subtotal": { "amount": "3800.00", "currency": "EUR" },
    "vat_breakdown": [
      {
        "rate": { "code": "Standard", "percentage": "19" },
        "base": { "amount": "3800.00", "currency": "EUR" },
        "amount": { "amount": "722.00", "currency": "EUR" }
      }
    ],
    "vat_total": { "amount": "722.00", "currency": "EUR" },
    "total": { "amount": "4522.00", "currency": "EUR" }
  },
  "payment": {
    "payment_terms": "Zahlbar innerhalb von 14 Tagen",
    "due_date": { "date": "2025-02-06" },
    "bank_account": {
      "bank_name": "Deutsche Bank",
      "account_holder": "Ihre Firma",
      "iban": "DE89 3704 0044 0532 0130 00",
      "bic": "COBADEFFXXX"
    }
  },
  "salutation": {
    "greeting": "Sehr geehrter Herr Mustermann,",
    "introduction": "anbei erhalten Sie die Rechnung für das Projekt."
  }
}
```

**Compile:**
```bash
docgen compile documents/invoices/2025/RE-2025-001.json
```

**Kleinunternehmer (No VAT):**
For §19 UStG small businesses, use empty vat_breakdown:
```json
{
  "items": [
    {
      "vat_rate": { "code": "Kleinunternehmer", "percentage": "0" }
    }
  ],
  "totals": {
    "subtotal": { "amount": "3800.00", "currency": "EUR" },
    "vat_breakdown": [],
    "vat_total": { "amount": "0", "currency": "EUR" },
    "total": { "amount": "3800.00", "currency": "EUR" }
  }
}
```

### 2. OFFER (Angebot) - JSON Workflow
File: `documents/offers/2025/AN-2025-001.json`

**JSON Schema:** (Similar to invoice)
```json
{
  "metadata": {
    "offer_number": "AN-2025-001",
    "offer_date": { "date": "2025-01-23" },
    "valid_until": { "date": "2025-02-23" },
    "customer_number": "K-001",
    "project_reference": "New Project"
  },
  "recipient": { /* same as invoice */ },
  "items": [ /* same as invoice */ ],
  "totals": { /* same as invoice */ },
  "terms": {
    "validity": "Dieses Angebot ist gültig bis zum 23.02.2025",
    "payment_terms": "30% Anzahlung, Rest bei Abnahme",
    "delivery_terms": "Lieferzeit: 4 Wochen"
  },
  "notes": "Optional closing text"
}
```

### 3. CREDENTIALS (Zugangsdaten) - JSON Workflow
File: `documents/credentials/2025/ZD-2025-001.json`

**JSON Schema:**
```json
{
  "metadata": {
    "document_number": "ZD-2025-001",
    "client_name": "Firma GmbH",
    "created_at": { "date": "2025-01-23" },
    "project_reference": "Website Setup"
  },
  "credentials": [
    {
      "system": "WordPress Admin",
      "access_url": "https://example.com/wp-admin",
      "username": "admin",
      "password": "super-secret-123",
      "notes": "Bitte Passwort nach erstem Login ändern"
    },
    {
      "system": "FTP Server",
      "access_url": "ftp://ftp.example.com",
      "username": "ftpuser",
      "password": "ftp-password-456",
      "notes": "Port 21, Passiv-Modus"
    }
  ],
  "security_notice": "Bitte bewahren Sie dieses Dokument sicher auf und geben Sie es nicht an Dritte weiter."
}
```

### 4. CONCEPT (Konzept) - .typ Workflow
File: `documents/concepts/2025/project-concept.typ`

**Templates auto-initialize on first compile. Create .typ file:**
```typst
#import "/.docgen/templates/concept/default.typ": concept

// Load company and locale from project root (absolute paths)
#let company = json("/data/company.json")
#let locale = json("/locale/de.json")

#show: concept.with(
  title: "E-Commerce Shop Entwicklung",
  document_number: "KO-2025-001",
  client_name: "Firma GmbH",
  company: company,
  locale: locale,
  project_name: "Online Shop",
  version: "1.0",
  status: "final",
  created_at: "23.01.2025",
  authors: ("Max Mustermann",),
)

= Projektziel

Entwicklung eines modernen E-Commerce Shops...

= Technische Anforderungen

== Frontend
- React.js
- Responsive Design
- Mobile-First

== Backend
- Node.js
- PostgreSQL
- REST API

= Zeitplan

Die Umsetzung erfolgt in 3 Phasen über 12 Wochen.
```

**Compile:**
```bash
docgen compile documents/concepts/2025/project-concept.typ
```

### 5. DOCUMENTATION - .typ Workflow
Similar to concept, use `#import "/.docgen/templates/documentation/default.typ": documentation`

## COMPANY.JSON CONFIGURATION

The `data/company.json` file controls branding, language, and defaults:

```json
{
  "name": "Your Company",
  "language": "de",
  "branding": {
    "accent_color": "#E94B3C",
    "primary_color": "#2c3e50",
    "font_preset": "inter"
  },
  "address": {
    "street": "Hauptstraße",
    "house_number": "1",
    "postal_code": "12345",
    "city": "Berlin",
    "country": "Deutschland"
  },
  "contact": {
    "phone": "+49 30 12345678",
    "email": "info@example.com",
    "website": "www.example.com"
  },
  "tax_id": "12/345/67890",
  "vat_id": "DE123456789",
  "bank_account": {
    "bank_name": "Deutsche Bank",
    "account_holder": "Your Company",
    "iban": "DE89 3704 0044 0532 0130 00",
    "bic": "COBADEFFXXX"
  },
  "numbering": {
    "year_format": "short",
    "prefixes": {
      "invoice": "RE",
      "offer": "AN",
      "credentials": "ZD",
      "concept": "KO",
      "documentation": "DOC"
    }
  },
  "default_terms": {
    "hourly_rate": "95.00",
    "currency": "EUR",
    "payment_days": 14,
    "vat_rate": 19
  }
}
```

**Font Presets:** inter, roboto, open-sans, lato, montserrat, source-sans,
poppins, raleway, nunito, work-sans, default

**Languages:** de, en, es, fr, it, nl, pt

## COMMON CLI COMMANDS

```bash
# Initialize new project
docgen init my-business

# Compile single document
docgen compile documents/invoices/2025/RE-2025-001.json

# Compile with custom output
docgen compile invoice.json -o output/custom-name.pdf

# Compile with encryption
docgen compile credentials.json --encrypt

# Build all documents
docgen build

# Build specific directory
docgen build documents/invoices

# Watch for changes
docgen watch documents/

# Template management
docgen template init              # Initialize project templates (one-time)
docgen template list              # Show available templates
docgen template fork concept --name branded-concept  # Customize a template
docgen template update            # Update templates (normally automatic)
```

## AI WORKFLOW RECOMMENDATIONS

When helping users create documents:

1. **Ask for document type first**: invoice, offer, credentials, concept, documentation

2. **For invoices/offers (JSON):**
   - Gather: client info, items/services, pricing, dates
   - Calculate totals (subtotal, VAT, total)
   - Check if Kleinunternehmer (no VAT) or regular business
   - Generate complete JSON matching schema above
   - Save to appropriate directory with proper naming (RE-YYYY-NNN.json)

3. **For concepts/documentation (.typ):**
   - Templates auto-initialize on first compile
   - Create .typ file with project-local import: `#import "/.docgen/templates/concept/default.typ": concept`
   - Use full Typst syntax (headings, lists, tables, etc.)
   - Load company and locale data with absolute paths:
     `#let company = json("/data/company.json")`
     `#let locale = json("/locale/de.json")`
   - Pass both to the template: `company: company, locale: locale`

4. **Validate before compile:**
   - Check all required fields are present
   - Verify monetary calculations are correct
   - Ensure proper date format: { "date": "YYYY-MM-DD" }
   - Check VAT rates match (19% standard, 0% Kleinunternehmer)

5. **File naming conventions:**
   - Invoices: RE-YYYY-NNN.json (e.g., RE-2025-001.json)
   - Offers: AN-YYYY-NNN.json
   - Credentials: ZD-YYYY-NNN.json
   - Concepts: descriptive-name.typ

## TROUBLESHOOTING

**"Template not found"** → Templates auto-initialize on compile. If issues persist, run `docgen template init`
**"Font not found"** → Font preset in company.json doesn't exist, use one from list
**"Locale not found"** → Check language in company.json matches available locales
**VAT calculation wrong** → Ensure vat_breakdown matches item totals
**Import error in .typ** → Use `/.docgen/templates/concept/default.typ` (leading slash required)

## GETTING HELP

- Full README: https://github.com/casoon/typst-business-templates
- Examples: See examples/ directory in repository
- Issues: https://github.com/casoon/typst-business-templates/issues

================================================================================
"##;

    println!("{}", guide);
    Ok(())
}
