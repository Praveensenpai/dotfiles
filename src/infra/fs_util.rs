use anyhow::{Context, Result};
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::Path;

/// Appends a line to a file if it is not already present.
pub fn ensure_line(path: &Path, line: &str) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }

    let existing = if path.exists() {
        fs::read_to_string(path).with_context(|| format!("Failed to read {}", path.display()))?
    } else {
        String::new()
    };

    if !existing.contains(line) {
        let mut file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(path)
            .with_context(|| format!("Failed to open {} for appending", path.display()))?;

        writeln!(file, "{line}")?;
    }

    Ok(())
}

/// Safely writes content to a file, creating parent directories if needed.
pub fn write_file(path: &Path, content: &str) -> Result<()> {
    if let Some(parent) = path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(path, content).with_context(|| format!("Failed to write {}", path.display()))
}
