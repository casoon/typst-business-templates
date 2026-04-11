//! Typst World implementation for embedded compilation without CLI.

use std::collections::HashMap;
use std::path::PathBuf;
use std::sync::{OnceLock, RwLock};

use fontdb::Database;
use typst::diag::{FileError, FileResult};
use typst::foundations::{Bytes, Datetime, Dict, Value};
use typst::syntax::{FileId, Source, VirtualPath};
use typst::text::{Font, FontBook};
use typst::{Library, World};

use include_dir::Dir;

use crate::compiler::{FONTS, LOCALE, TEMPLATES};

pub struct DocgenWorld {
    main_id: FileId,
    main_source: Source,
    library: typst::utils::LazyHash<Library>,
    book: typst::utils::LazyHash<FontBook>,
    fonts: Vec<Font>,
    /// In-memory files: data JSON, company JSON, locale JSON
    virtual_files: RwLock<HashMap<FileId, Bytes>>,
    now: OnceLock<Option<Datetime>>,
}

impl DocgenWorld {
    pub fn new(
        template_name: &str,
        template_source: String,
        data_json: Vec<u8>,
        company_json: Vec<u8>,
        locale_json: Vec<u8>,
        language: &str,
        font_paths: &[PathBuf],
        use_system_fonts: bool,
    ) -> Self {
        // Main source lives at a virtual path so relative imports resolve
        let main_path = format!("/templates/{}/default.typ", template_name);
        let main_id = FileId::new(None, VirtualPath::new(&main_path));
        let main_source = Source::new(main_id, template_source);

        // sys.inputs keys match what the templates expect:
        //   data   → path to invoice/offer/... JSON
        //   company → path to company.json (also hardcoded in templates as /data/company.json)
        //   locale  → path to locale JSON
        let data_path = "/data/render-data.json";
        let company_path = "/data/company.json";
        let locale_path = format!("/locale/{}.json", language);

        let mut inputs = Dict::new();
        inputs.insert("data".into(), Value::Str(data_path.into()));
        inputs.insert("company".into(), Value::Str(company_path.into()));
        inputs.insert("locale".into(), Value::Str(locale_path.as_str().into()));

        let library = typst::utils::LazyHash::new(Library::builder().with_inputs(inputs).build());

        // Font setup — embedded fonts first, then system/custom paths
        let mut fontdb = Database::new();
        load_embedded_fonts(&FONTS, &mut fontdb);
        if use_system_fonts {
            fontdb.load_system_fonts();
        }
        for path in font_paths {
            if path.is_dir() {
                fontdb.load_fonts_dir(path);
            } else if path.is_file() {
                let _ = fontdb.load_font_file(path);
            }
        }

        let mut book = FontBook::new();
        let mut fonts = Vec::new();
        for face in fontdb.faces() {
            let data: Option<Vec<u8>> = match &face.source {
                fontdb::Source::File(path) => std::fs::read(path).ok(),
                fontdb::Source::Binary(data) => Some(data.as_ref().as_ref().to_vec()),
                fontdb::Source::SharedFile(_, data) => Some(data.as_ref().as_ref().to_vec()),
            };
            if let Some(data) = data {
                let buffer = Bytes::new(data);
                for font in Font::iter(buffer) {
                    book.push(font.info().clone());
                    fonts.push(font);
                }
            }
        }

        // Mount virtual data files
        let mut vfiles = HashMap::new();
        vfiles.insert(
            FileId::new(None, VirtualPath::new(data_path)),
            Bytes::new(data_json),
        );
        vfiles.insert(
            FileId::new(None, VirtualPath::new(company_path)),
            Bytes::new(company_json),
        );
        vfiles.insert(
            FileId::new(None, VirtualPath::new(locale_path.as_str())),
            Bytes::new(locale_json),
        );

        Self {
            main_id,
            main_source,
            library,
            book: typst::utils::LazyHash::new(book),
            fonts,
            virtual_files: RwLock::new(vfiles),
            now: OnceLock::new(),
        }
    }

    /// Resolve a FileId to embedded template bytes, if available.
    fn resolve_template_bytes(&self, id: FileId) -> Option<Vec<u8>> {
        let path = id.vpath().as_rooted_path();
        let path_str = path.to_string_lossy();

        // Templates are mounted under /templates/
        if let Some(rel) = path_str.strip_prefix("/templates/") {
            if let Some(file) = TEMPLATES.get_file(rel) {
                return Some(file.contents().to_vec());
            }
        }
        // Locale files are mounted under /locale/
        if let Some(rel) = path_str.strip_prefix("/locale/") {
            if let Some(file) = LOCALE.get_file(rel) {
                return Some(file.contents().to_vec());
            }
        }
        None
    }
}

impl World for DocgenWorld {
    fn library(&self) -> &typst::utils::LazyHash<Library> {
        &self.library
    }

    fn book(&self) -> &typst::utils::LazyHash<FontBook> {
        &self.book
    }

    fn main(&self) -> FileId {
        self.main_id
    }

    fn source(&self, id: FileId) -> FileResult<Source> {
        if id == self.main_id {
            return Ok(self.main_source.clone());
        }

        // Check in-memory virtual files (JSON data)
        {
            let vfiles = self.virtual_files.read().unwrap();
            if let Some(bytes) = vfiles.get(&id) {
                let text =
                    std::str::from_utf8(bytes.as_slice()).map_err(|_| FileError::InvalidUtf8)?;
                return Ok(Source::new(id, text.to_string()));
            }
        }

        // Try embedded template files
        if let Some(content) = self.resolve_template_bytes(id) {
            let text = std::str::from_utf8(&content).map_err(|_| FileError::InvalidUtf8)?;
            return Ok(Source::new(id, text.to_string()));
        }

        Err(FileError::NotFound(
            id.vpath().as_rooted_path().to_path_buf(),
        ))
    }

    fn file(&self, id: FileId) -> FileResult<Bytes> {
        // Check in-memory virtual files
        {
            let vfiles = self.virtual_files.read().unwrap();
            if let Some(bytes) = vfiles.get(&id) {
                return Ok(bytes.clone());
            }
        }

        // Try embedded template assets (images etc.)
        if let Some(content) = self.resolve_template_bytes(id) {
            return Ok(Bytes::new(content));
        }

        // Allow loading absolute filesystem assets such as uploaded logos.
        let rooted = id.vpath().as_rooted_path().to_path_buf();
        if rooted.is_absolute() {
            if let Ok(bytes) = std::fs::read(&rooted) {
                return Ok(Bytes::new(bytes));
            }
        }

        Err(FileError::NotFound(
            id.vpath().as_rooted_path().to_path_buf(),
        ))
    }

    fn font(&self, index: usize) -> Option<Font> {
        self.fonts.get(index).cloned()
    }

    fn today(&self, _offset: Option<i64>) -> Option<Datetime> {
        *self.now.get_or_init(|| {
            let now = chrono::Local::now();
            Datetime::from_ymd_hms(
                now.format("%Y").to_string().parse().ok()?,
                now.format("%m").to_string().parse().ok()?,
                now.format("%d").to_string().parse().ok()?,
                now.format("%H").to_string().parse().ok()?,
                now.format("%M").to_string().parse().ok()?,
                now.format("%S").to_string().parse().ok()?,
            )
        })
    }
}

/// Recursively load all embedded .ttf/.otf font files into fontdb.
fn load_embedded_fonts(dir: &Dir, fontdb: &mut Database) {
    for file in dir.files() {
        let name = file.path().to_string_lossy().to_lowercase();
        if name.ends_with(".ttf") || name.ends_with(".otf") {
            fontdb.load_font_data(file.contents().to_vec());
        }
    }
    for subdir in dir.dirs() {
        load_embedded_fonts(subdir, fontdb);
    }
}
