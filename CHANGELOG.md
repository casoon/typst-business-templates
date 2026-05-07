# Changelog

All notable changes to this project will be documented in this file.

## [0.7.2] - 2026-05-07

### Changed
- **Installation:** Removed Homebrew support; curl install script is now the recommended method
- **README:** Clarified that `docgen compile` passes `--font-path fonts` automatically

## [0.7.1] - 2026-05-07

### Fixed
- **Font path not passed to typst:** `docgen compile` now passes `--font-path fonts` to `typst compile`, so bundled fonts are found as documented
- **Hardcoded document language:** All templates now read `language` from `company.json` instead of always using `"de"`; added `get-language(company)` helper to `styles.typ`

## [0.7.0] - 2026-04-12

### Added
- **More integrated diagram layouts:** Added `timeline`, `swimlane`, `quadrant`, and `roadmap` to the built-in `diagram` document type
- **More diagram examples:** Added showcase examples for all four new layouts under `examples/`

### Fixed
- **Parallel compile race in local template updates:** `.docgen/templates/` now uses a version marker and lock file to avoid concurrent delete/extract failures during parallel `docgen compile` runs

## [0.6.12] - 2026-04-11

### Added
- **Integrated diagram document type:** New `diagram` template with internal preprocessing and automatic layout rendering
  - Supports `tree` / `hierarchical`, `flow` / `layered`, `mindmap` / `radial`, and simple `architecture` diagrams
  - No manual positioning required in JSON
  - No external Typst packages required
- **CLI support for diagram JSON:** `docgen compile diagram.json` now routes diagram documents through the embedded Rust renderer
- **Example diagrams:** Added four showcase examples under `examples/`
  - `diagram-flow`
  - `diagram-mindmap`
  - `diagram-orgchart`
  - `diagram-architecture`

## [0.6.11] - 2026-01-27

### Changed
- **Task-list template:** Description now renders inline after title with ` -- ` separator
  - Previously: Description on separate line with vertical spacing
  - Now: Compact inline display, reducing visual clutter

## [0.6.10] - 2026-01-27

### Added
- **Display options for all templates:** `show-title-page` and `show-footer`
  - Function-based templates (8): `show-title-page: true` and `show-footer: true` parameters
    - task-list, documentation, concept, contract, protocol, specification, proposal, sla
  - Inline/accounting templates (9): `show_footer` flag via `data.metadata.show_footer`
    - invoice, offer, credit-note, delivery-note, letter, order-confirmation, quotation-request, reminder, time-sheet
  - Both default to `true` — existing behavior is fully preserved
  - Set to `false` to hide title page or footer

### Removed
- **Tag rendering removed from task-list template**
  - Tags were visually disruptive and redundant with category headings
  - Tag data in `.typ` files is still accepted but no longer rendered

## [0.6.9] - 2026-01-27

### Fixed
- **Critical:** Fixed missing `#` prefix for subtask rendering in task-list template
  - `if "subtasks" in task ...` inside content block was rendered as plain text
  - Added `#` prefix so subtasks are now recursively rendered instead of showing raw Typst code
  - **Impact:** Task lists with subtasks now display correctly

## [0.6.8] - 2026-01-27

### Fixed
- **Critical:** Fixed missing `#` prefix in `standard-title-page` subtitle rendering
  - `v(10pt)`, `align(center)` and `text(...)` were rendered as plain text instead of being executed as Typst functions
  - Added `#` prefix to all function calls inside the content block
  - **Impact:** Task list and other templates using `subtitle` now display correctly instead of showing raw code
  - Error: `v(10pt) align(center)[ text(size: size-large, fill: color-text-light)[...] ]` visible in PDF

## [0.6.7] - 2026-01-27

### Fixed
- **Critical:** Made `vat_breakdown` optional in offer template
  - Offers without VAT (e.g., international offers) now compile successfully
  - Template now checks if `vat_breakdown` exists before accessing it
  - Falls back to empty array `()` if not present
  - Error: `dictionary does not contain key "vat_breakdown"`

## [0.6.6] - 2026-01-27

### Fixed
- **Critical:** Fixed incorrect `#` prefix inside for-loop in `totals-summary.typ`
  - Removed `#` from `rows.push()` inside `#for` loop body (line 58)
  - **Context:** Typst `#for { }` creates a code block where `#` is NOT allowed
  - **Impact:** Invoices and offers now compile successfully
  - Error: `the character # is not valid in code` at line 58

## [0.6.5] - 2026-01-27

### Fixed
- **Partial Fix:** Added `#` to code inside content blocks, but incorrectly added it inside for-loop body
  - Note: v0.6.5 introduced a new error. Upgrade to v0.6.6 for complete fix

## [0.6.4] - 2026-01-27

### Fixed
- **Partial Fix:** Changed for-loop brackets from `[]` to `{}` but missed `#` prefix
  - Note: v0.6.4 didn't fully fix the issue. Upgrade to v0.6.5 for complete fix

## [0.6.3] - 2026-01-27

### Fixed
- **Critical:** Fixed missing `#` prefix in accounting templates causing function calls to render as text
  - Fixed `invoice/default.typ`: Added `#` to accounting-header, din5008-address-block, invoice-totals
  - Fixed `offer/default.typ`: Added `#` to accounting-header, din5008-address-block, invoice-totals
  - Fixed `delivery-note/default.typ`: Added `#` to accounting-header, din5008-address-block
  - Fixed `reminder/default.typ`: Added `#` to accounting-header, din5008-address-block
  - Fixed `time-sheet/default.typ`: Added `#` to accounting-header, din5008-address-block
  - **Impact:** PDFs now display correctly with rendered headers, addresses, and totals instead of raw code

## [0.6.2] - 2026-01-27

### Fixed
- **Critical:** Fixed metadata type handling in ALL title-page components
  - `standard-title-page()` now accepts both array and dictionary metadata
  - `document-title-page()` already fixed in v0.6.1
  - `parties-title-page()` now accepts both array and dictionary metadata
  - Fixes compilation errors in credentials and contract templates
  - Error: `type array has no method pairs` when using array-based metadata

### Technical Details
All three title-page functions now include type checking to handle both data formats:
- **Array format:** `[(key1, value1), (key2, value2)]` (used by some templates)
- **Dictionary format:** `(key1: value1, key2: value2)` (used by other templates)

This ensures 100% compatibility across all templates using title-page components.

## [0.6.1] - 2026-01-27

### Fixed
- **Partial Fix:** Fixed metadata type handling in `document-title-page()` only
  - Note: v0.6.1 missed fixes for `standard-title-page()` and `parties-title-page()`
  - Upgrade to v0.6.2 for complete fix

## [0.6.0] - 2026-01-27

### 🎉 Major: Simplification & Code Consolidation

**Breaking Changes:** Complete architectural simplification following Unix philosophy.

**Philosophy:** Do one thing well. Plain text over binary. Composable tools. DRY (Don't Repeat Yourself).

### Removed
- **SQLite database** → Replaced with JSON files (`data/clients.json`, `data/projects.json`, `data/counters.json`)
- **Interactive TUI** → Removed 696 lines of terminal UI code
- **Global package management** → Removed 304 lines of dead code
- **5 dependencies removed:**
  - `rusqlite` - No longer needed (JSON-based storage)
  - `dialoguer` - No interactive prompts
  - `console` - No terminal styling
  - `comfy-table` - Output simplified
  - `lopdf` - Was never used

### Changed
- **Data storage:** Human-readable JSON files instead of binary SQLite
- **CLI behavior:** No arguments → shows help (was: interactive UI)
- **Commands:** All require explicit parameters (e.g., `docgen client add --name "Name"`)
- **Binary size:** ~20% smaller due to dependency reduction
- **Git-friendly:** JSON files can be diff'd, merged, and version controlled

### Added
- **New task-list template:** Professional task/todo list template with checklists, priorities, categories, dependencies
- **Client/Project delete commands:** `docgen client delete <id>`, `docgen project delete <id>`
- **6 reusable components in `templates/common/`:**
  - `formatting.typ` - Date/money formatting (9 templates)
  - `din5008-address.typ` - DIN 5008 address blocks (9 templates)
  - `accounting-header.typ` - Logo + metadata box (9 templates)
  - `unit-formatter.typ` - Unit translations (4 templates)
  - `locale-helpers.typ` - Locale string resolution
  - `totals-summary.typ` - Right-aligned totals (4 templates)
- **4 title-page components:** standard, document, parties, enhanced (used by 9 templates)
- **Integration tests:** 14 test cases covering client, project, and delete operations
- **Simpler workflow:** Direct CLI commands integrate easily into scripts and AI workflows
- **Code reduction:** ~1,200+ lines of duplicate code eliminated
  - ~710 lines in Phase 1 (formatting, DIN 5008, headers)
  - ~100 lines in Phase 2 (units, totals)
  - ~425 lines (title pages)
- **CLI refactoring:** Commands moved to `cli/src/commands/` module, main.rs reduced by 333 lines (-23%)

### Migration from v0.5.x
**Note:** No migration tool needed - v0.6.0 had no production users.

If you used v0.5.x locally:
1. Backup your data: `cp -r data/ data.backup/`
2. Upgrade: `brew upgrade docgen`
3. No automatic migration - re-enter data via CLI or edit JSON files directly

JSON format:
```json
// data/clients.json
[{"id":1,"number":1,"name":"Client Name","created_at":"2026-01-26T10:00:00Z", ...}]

// data/counters.json
{"client":0,"invoice":0,"offer":0,"credentials":0,"concept":0,"documentation":0}
```

## [0.5.2] - 2026-01-25

### Fixed
- **Critical: JSON workflow template paths**
  - Fixed: JSON documents (invoice, offer, credentials) used wrong template path
  - Changed from `templates/` to `.docgen/templates/` for JSON workflow
  - Fixed: Syntax error in offer template (extra closing brackets)
  - Fixed: `docgen init` now uses new v0.5.0 template system
  - All JSON and .typ documents now work correctly

## [0.5.1] - 2026-01-25

### Fixed
- **Critical: Templates now embedded in binary**
  - Fixed: Templates were not extracted from binary (empty .docgen/templates/)
  - Templates are now embedded at compile-time using `include_dir` crate
  - Works immediately after installation without repository access
  - Fixes issue where `docgen template init` created empty directory

## [0.5.0] - 2026-01-25

### 🎉 Major: Project-Local Template System

**Breaking Change:** Complete redesign of template architecture for portability and simplicity.

**Old System (≤ 0.4.x):**
- Templates installed globally in `~/Library/Application Support/typst/packages/`
- Required manual version management
- Not portable across machines
- Hard to customize

**New System (0.5.0+):**
- **Standard templates** in `.docgen/templates/` (auto-updated, not in Git)
- **Custom templates** in `templates/` (stable, in Git)
- Everything project-local - works on any machine
- Simple forking workflow for customization

### Added
- **`docgen template init`** - Initialize project templates
- **`docgen template fork <name> --name <custom>`** - Fork and customize templates
- **`docgen template list`** - List standard and custom templates
- **`docgen template update`** - Manually update standard templates
- **Auto-update on compile** - Standard templates sync with docgen version automatically
- **`.gitignore` management** - Auto-adds `.docgen/` to gitignore

### Changed
- **Template imports** now use project-relative paths:
  - Standard: `#import "/.docgen/templates/concept/default.typ": concept`
  - Custom: `#import "/templates/my-concept/default.typ": my_concept`
- **No more package installation** - Templates copied to project instead
- **Documentation rewritten** - New workflow explained in README

### Removed
- ~~`docgen template install`~~ - No longer needed
- ~~`docgen template remove`~~ - No longer needed
- ~~Global package management~~ - All templates are project-local now
- ~~Version pinning in imports~~ - Standard templates always current

### Migration Guide (0.4.x → 0.5.0)

**For existing projects:**

1. Run `docgen template init` in your project
2. Update .typ files to use new import paths:
   ```typ
   // Old:
   #import "@local/docgen-concept:0.4.12": concept
   
   // New:
   #import "/.docgen/templates/concept/default.typ": concept
   ```
3. If you had customized templates, fork them:
   ```bash
   docgen template fork concept --name my-concept
   # Then copy your customizations to templates/my-concept/
   ```

**Benefits:**
- ✅ Clone project → works immediately (no setup)
- ✅ Upgrade docgen → templates auto-update
- ✅ Custom templates protected from updates
- ✅ Everything in Git → full version control

## [0.4.12] - 2025-01-25

### Added
- **Automatic Template Package Installation**
  - `docgen compile` now automatically installs templates as Typst packages if not already installed
  - No manual `docgen template install` required anymore
  - Ensures templates are always at the correct version matching docgen CLI
- **Versionless Package Imports** (Recommended)
  - Symlinks created for versionless imports: `@local/docgen-concept` → latest version
  - Old versioned imports still supported: `@local/docgen-concept:0.4.12`
  - Recommendation: Use versionless imports to always get latest template version
  - Templates automatically update when docgen is updated

### Changed
- **Documentation Updated for Versionless Imports**
  - Example code now shows recommended versionless syntax: `#import "@local/docgen-concept": concept`
  - Installation message shows both versionless (recommended) and versioned options
  - Solves fundamental versioning problem: templates now sync with docgen version

### Fixed
- **Template Version Mismatch**
  - Fixed: Hard-coded template versions in .typ files prevented updates from taking effect
  - Fixed: Users had to manually update version numbers in all .typ files after docgen update
  - Now: Versionless imports automatically use newest installed version

## [0.4.11] - 2025-01-25

### Fixed
- **Concept Template Logo & Footer**
  - Logo now displays correctly in package-import mode (`@local/docgen-concept`)
  - Logo pre-loading: Automatically converts `company.logo` path to `_logo_image`
  - Footer: Changed to simple one-line layout (like credentials template)
    - Format: [Client Name] | [Page X] | [Date]
    - Previous multi-line accounting-footer was incorrect for concept documents
  - Concept template now matches credentials template layout (clean & minimal)

## [0.4.10] - 2025-01-25

### Fixed
- **Concept Template Footer**
  - Concept template now uses `accounting-footer` (same as invoice/offer)
  - Consistent business footer across all accounting and concept documents

### Changed
- **Complete Footer Migration to Centralized System**
  - All accounting templates now use `accounting-footer` from `common/footers.typ`:
    - invoice, offer, credit-note, delivery-note, letter
    - order-confirmation, quotation-request, reminder, time-sheet
  - Concept template migrated to `accounting-footer`
  - Code reduction: -515 lines of duplicate footer code eliminated
  - Total footer code reduction (v0.4.9 + v0.4.10): -806 lines
  - Single source of truth for all footer layouts

## [0.4.9] - 2025-01-25

### Added
- **Centralized Footer System** in `templates/common/footers.typ`
  - `document-footer`: Standard 4-column footer for most document-layout templates
  - `minimal-footer`: Simplified 3-column footer for protocol templates
  - `accounting-footer`: Business-specific footer (reserved for invoice/offer)
  - Reduces code duplication: -291 lines of duplicate footer code eliminated
  - Single source of truth for footer styling and layout

### Fixed
- **Logo Loading in Package-Import Mode**
  - Logo now displays correctly when using `#import "@local/docgen-documentation:0.4.9"`
  - Fixed: Logo pre-loading (`_logo_image`) only worked in JSON-workflow mode
  - Changed to direct `image()` loading from `company.logo` path
  - Works in both package-import and JSON-workflow modes
- **Footer Consistency Across Templates**
  - All document-layout templates now use centralized footer functions
  - Unified footer styling and layout across documentation, concept, protocol, specification, contract, proposal, sla

### Changed
- Updated all document-layout templates to use `common/footers.typ`:
  - `documentation/default.typ`: Uses `document-footer` with created_at style
  - `concept/default.typ`: Uses `document-footer` with created_at style
  - `protocol/default.typ`: Uses `minimal-footer` (3-column)
  - `specification/default.typ`: Uses `document-footer` with version/last_updated style
  - `contract/default.typ`: Uses `document-footer` with created_at style
  - `proposal/default.typ`: Uses `document-footer` with created_at style
  - `sla/default.typ`: Uses `document-footer` with version/last_updated style

## [0.4.8] - 2025-01-25

### Fixed
- **Content-Loading in protocol und specification Templates**
  - Protocol Template rendert jetzt vollständigen Content aus JSON
  - Specification Template rendert jetzt vollständigen Content aus JSON
  - Syntax-Fehler mit `#v()` in protocol Template behoben
  - `<` Zeichen in JSON-Beispielen escaped um "unclosed label" Fehler zu vermeiden

### Changed
- Protocol Template: Content-Loading von `eval(data.content, mode: "markup")` zu `eval("[" + data.content + "]", mode: "code")`
- Specification Template: Content-Check vereinfacht (direkter Zugriff auf `data.content`)

## [0.4.7] - 2025-01-25

### Fixed
- **CLI Template-Erkennung** für alle 12 neuen Template-Typen erweitert
  - letter, credit-note, reminder, delivery-note, order-confirmation, time-sheet, quotation-request
  - contract, protocol, specification, proposal, sla
- **Init-Befehl** erstellt jetzt Verzeichnisse für alle Template-Typen

### Changed
- `docgen compile` erkennt automatisch alle neuen Template-Typen anhand von Pfad und Dateinamen
- `docgen init` erstellt vollständige Verzeichnisstruktur mit allen 17 Template-Typen

## [0.4.6] - 2025-01-25

### Added
- **12 neue Template-Typen** für verschiedene Geschäftsdokumente:
  - `letter` - Geschäftsbrief (DIN 5008 konform)
  - `credit-note` - Gutschrift für Rückerstattungen
  - `reminder` - Zahlungserinnerung/Mahnung (Multi-Level)
  - `delivery-note` - Lieferschein mit Unterschriftsfeldern
  - `order-confirmation` - Auftragsbestätigung
  - `time-sheet` - Stundenzettel für Arbeitszeiterfassung
  - `contract` - Vertrag mit Unterschriftsseite
  - `protocol` - Besprechungsprotokoll/Meeting Notes
  - `specification` - Spezifikation/Pflichtenheft mit Code-Blocks
  - `proposal` - Projektvorschlag für Agenturen/Beratung
  - `sla` - Service Level Agreement
  - `quotation-request` - Angebotsanfrage an Lieferanten

### Fixed
- **Footer-Position** in `concept` und `documentation` Templates von 100pt auf 80pt korrigiert
- **Logo-Pfade** konsistent in allen Templates (`"/" + company.logo` oder `company._logo_image`)

### Changed
- Alle Templates verwenden jetzt konsistente Margins und Footer-Position (80pt)
- Templates folgen durchgängig Accounting-Layout oder Document-Layout Standards

### Documentation
- Neue Datei `DOCUMENT-TYPES.md` mit vollständiger Übersicht aller Templates
- Umfangreiche Examples für IT-Consultant Szenario hinzugefügt:
  - 12 vollständige JSON-Beispieldateien
  - README mit Verwendungsbeispielen und Szenarien
  - Realistische Projekt-Workflows (API-Migration, Cloud-Migration)

## [0.4.5] - 2025-01-24

### Fixed
- Invoice footer positioning corrected (bottom margin 122pt → 80pt)
- Logo path consistency across all templates
- Consistent use of `image("/" + company.logo)` pattern

## [0.4.4] - 2025-01-23

### Fixed
- Invoice footer positioning issue (bottom margin reduced from 122pt to 71pt)

## [0.4.3] - 2025-01-23

### Added
- Initial templates for invoice, offer, concept, documentation, credentials

## [0.4.2] - 2025-01-20

### Added
- Basic CLI functionality
- Template generation support
- JSON-based document workflow

## [0.4.1] - 2025-01-18

### Added
- Initial release
- Core template system
- Typst integration
