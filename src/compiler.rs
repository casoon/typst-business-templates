use std::path::PathBuf;

use include_dir::{include_dir, Dir};

use crate::diagram::preprocess_diagram_data;
use crate::types::CompanyData;
use crate::world::DocgenWorld;

/// All Typst templates, embedded at compile time
pub static TEMPLATES: Dir<'static> = include_dir!("$CARGO_MANIFEST_DIR/templates");

/// Locale JSON files, embedded at compile time
pub static LOCALE: Dir<'static> = include_dir!("$CARGO_MANIFEST_DIR/locale");

/// Bundled Google Fonts, embedded at compile time
pub static FONTS: Dir<'static> = include_dir!("$CARGO_MANIFEST_DIR/fonts");

/// Compiles business document templates to PDF bytes.
///
/// # Example
/// ```rust,ignore
/// let compiler = DocgenCompiler::new();
/// let pdf = compiler.compile_invoice(invoice_data, company_data)?;
/// ```
pub struct DocgenCompiler {
    font_paths: Vec<PathBuf>,
    use_system_fonts: bool,
}

impl Default for DocgenCompiler {
    fn default() -> Self {
        Self::new()
    }
}

impl DocgenCompiler {
    /// Creates a compiler that uses system fonts.
    pub fn new() -> Self {
        Self {
            font_paths: Vec::new(),
            use_system_fonts: true,
        }
    }

    /// Add an extra font directory (e.g. the bundled `fonts/` directory).
    pub fn with_fonts_dir(mut self, path: impl Into<PathBuf>) -> Self {
        self.font_paths.push(path.into());
        self
    }

    /// Disable system font discovery (useful for reproducible builds).
    pub fn without_system_fonts(mut self) -> Self {
        self.use_system_fonts = false;
        self
    }

    /// Compile the invoice template to PDF bytes.
    pub fn compile_invoice(
        &self,
        invoice: &crate::types::InvoiceData,
        company: &CompanyData,
    ) -> anyhow::Result<Vec<u8>> {
        let data_json = serde_json::to_vec(invoice)?;
        let language = company.language.clone();
        self.compile("invoice", data_json, company, &language)
    }

    /// Generic compile: renders any embedded template by name.
    ///
    /// `template_name` must match a directory in `templates/` (e.g. `"invoice"`, `"offer"`).
    /// `data_json` is the raw bytes of the document-specific JSON payload.
    pub fn compile(
        &self,
        template_name: &str,
        mut data_json: Vec<u8>,
        company: &CompanyData,
        language: &str,
    ) -> anyhow::Result<Vec<u8>> {
        if template_name == "diagram" {
            data_json = preprocess_diagram_data(&data_json)?;
        }

        // Load template source
        let template_path = format!("{}/default.typ", template_name);
        let template_file = TEMPLATES
            .get_file(&template_path)
            .ok_or_else(|| anyhow::anyhow!("Template not found: {}", template_name))?;
        let template_source = std::str::from_utf8(template_file.contents())
            .map_err(|_| anyhow::anyhow!("Template is not valid UTF-8: {}", template_name))?
            .to_string();

        // Load locale
        let locale_filename = format!("{}.json", language);
        let locale_file = LOCALE
            .get_file(&locale_filename)
            .ok_or_else(|| anyhow::anyhow!("Locale not found: {}", language))?;
        let locale_json = locale_file.contents().to_vec();

        // Serialize company data
        let company_json = serde_json::to_vec(company)?;

        // Build world and compile
        let world = DocgenWorld::new(
            template_name,
            template_source,
            data_json,
            company_json,
            locale_json,
            language,
            &self.font_paths,
            self.use_system_fonts,
        );

        let result = typst::compile(&world);

        match result.output {
            Ok(document) => {
                let pdf = typst_pdf::pdf(&document, &typst_pdf::PdfOptions::default()).map_err(
                    |errors| {
                        let msgs: Vec<String> = errors.iter().map(|e| format!("{:?}", e)).collect();
                        anyhow::anyhow!("PDF rendering failed: {}", msgs.join("; "))
                    },
                )?;
                Ok(pdf)
            }
            Err(errors) => {
                let msgs: Vec<String> = errors
                    .iter()
                    .map(|e| format!("{:?}: {}", e.span, e.message))
                    .collect();
                Err(anyhow::anyhow!(
                    "Typst compilation failed: {}",
                    msgs.join("\n")
                ))
            }
        }
    }
}
