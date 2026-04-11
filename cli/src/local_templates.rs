// Local template management for project-based templates
use anyhow::{Context, Result};
use include_dir::{include_dir, Dir};
use std::fs;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;

// Embed all templates at compile time
static TEMPLATES_DIR: Dir = include_dir!("$CARGO_MANIFEST_DIR/../templates");

/// Get the .docgen/templates directory in the current project
pub fn get_local_templates_dir() -> PathBuf {
    PathBuf::from(".docgen/templates")
}

/// Get the custom templates directory in the current project
pub fn get_custom_templates_dir() -> PathBuf {
    PathBuf::from("templates")
}

/// Get the current docgen version
pub fn get_docgen_version() -> String {
    env!("CARGO_PKG_VERSION").to_string()
}

/// Get list of available embedded template names
pub fn get_available_templates() -> Vec<String> {
    vec![
        "common".to_string(), // Shared styles and components
        "concept".to_string(),
        "contract".to_string(),
        "credentials".to_string(),
        "credit-note".to_string(),
        "delivery-note".to_string(),
        "diagram".to_string(),
        "documentation".to_string(),
        "invoice".to_string(),
        "letter".to_string(),
        "offer".to_string(),
        "order-confirmation".to_string(),
        "protocol".to_string(),
        "proposal".to_string(),
        "quotation-request".to_string(),
        "reminder".to_string(),
        "sla".to_string(),
        "specification".to_string(),
        "task-list".to_string(),
        "time-sheet".to_string(),
    ]
}

/// Ensure .docgen/templates/ is up-to-date with current docgen version
/// This is called automatically on every compile/build
pub fn ensure_local_templates_updated() -> Result<()> {
    let templates_dir = get_local_templates_dir();

    // Create .docgen/templates if it doesn't exist
    if !templates_dir.exists() {
        fs::create_dir_all(&templates_dir)
            .context("Failed to create .docgen/templates directory")?;
    }

    // Extract embedded templates to .docgen/templates/
    for template_name in get_available_templates() {
        let dest = templates_dir.join(&template_name);

        // Remove existing template if it exists
        if dest.exists() {
            fs::remove_dir_all(&dest)
                .with_context(|| format!("Failed to remove old template: {}", template_name))?;
        }

        // Get template from embedded resources
        if let Some(template_dir) = TEMPLATES_DIR.get_dir(&template_name) {
            // Extract template directory
            extract_embedded_dir(template_dir, &dest)
                .with_context(|| format!("Failed to extract template: {}", template_name))?;
        }
    }

    Ok(())
}

/// Extract an embedded directory to the filesystem
fn extract_embedded_dir(dir: &Dir, dest: &Path) -> Result<()> {
    fs::create_dir_all(dest)?;

    // Extract all files
    for file in dir.files() {
        let file_path = dest.join(file.path().file_name().unwrap());
        fs::write(&file_path, file.contents())?;
    }

    // Recursively extract subdirectories
    for subdir in dir.dirs() {
        let subdir_path = dest.join(subdir.path().file_name().unwrap());
        extract_embedded_dir(subdir, &subdir_path)?;
    }

    Ok(())
}

/// Recursively copy a directory
fn copy_dir_recursive(src: &Path, dst: &Path) -> Result<()> {
    fs::create_dir_all(dst)?;

    for entry in WalkDir::new(src)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file())
    {
        let relative_path = entry.path().strip_prefix(src)?;
        let target_path = dst.join(relative_path);

        if let Some(parent) = target_path.parent() {
            fs::create_dir_all(parent)?;
        }

        fs::copy(entry.path(), &target_path)?;
    }

    Ok(())
}

/// Fork a standard template to custom templates directory
pub fn fork_template(template_name: &str, custom_name: &str) -> Result<()> {
    let source = get_local_templates_dir().join(template_name);
    let dest = get_custom_templates_dir().join(custom_name);

    if !source.exists() {
        anyhow::bail!(
            "Template '{}' not found in .docgen/templates/. Run 'docgen init' first.",
            template_name
        );
    }

    if dest.exists() {
        anyhow::bail!(
            "Custom template '{}' already exists in templates/",
            custom_name
        );
    }

    // Create custom templates directory if it doesn't exist
    let custom_dir = get_custom_templates_dir();
    if !custom_dir.exists() {
        fs::create_dir_all(&custom_dir).context("Failed to create templates directory")?;
    }

    // Copy template
    copy_dir_recursive(&source, &dest).with_context(|| {
        format!(
            "Failed to fork template '{}' to '{}'",
            template_name, custom_name
        )
    })?;

    Ok(())
}

/// Initialize a project with .docgen structure
pub fn init_project() -> Result<()> {
    // Create .docgen/templates/
    ensure_local_templates_updated()?;

    // Create .gitignore for .docgen if it doesn't exist
    let gitignore_path = PathBuf::from(".gitignore");
    let docgen_ignore = ".docgen/\n";

    if gitignore_path.exists() {
        let content = fs::read_to_string(&gitignore_path)?;
        if !content.contains(".docgen/") {
            fs::write(&gitignore_path, format!("{}{}", content, docgen_ignore))?;
        }
    } else {
        fs::write(&gitignore_path, docgen_ignore)?;
    }

    // Create empty templates/ directory for custom templates
    let custom_dir = get_custom_templates_dir();
    if !custom_dir.exists() {
        fs::create_dir_all(&custom_dir)?;

        // Create .gitkeep to ensure directory is committed
        fs::write(custom_dir.join(".gitkeep"), "")?;
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_get_local_templates_dir() {
        let dir = get_local_templates_dir();
        assert_eq!(dir, PathBuf::from(".docgen/templates"));
    }

    #[test]
    fn test_get_custom_templates_dir() {
        let dir = get_custom_templates_dir();
        assert_eq!(dir, PathBuf::from("templates"));
    }
}
