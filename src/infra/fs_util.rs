use anyhow::{Context, Result};
use std::fs::{self, OpenOptions};
use std::io::{self, Write};
use std::path::Path;

/// Creates parent directories for `path`, tolerating the case where they
/// already exist (EEXIST / `AlreadyExists` is not an error).
fn ensure_parent_dir(path: &Path) -> Result<()> {
    let Some(parent) = path.parent() else {
        return Ok(());
    };
    match fs::create_dir_all(parent) {
        Ok(()) => Ok(()),
        Err(e) if e.kind() == io::ErrorKind::AlreadyExists && parent.is_dir() => Ok(()),
        Err(e) => {
            Err(e).with_context(|| format!("Failed to create directory {}", parent.display()))
        }
    }
}

/// Appends a line to a file if it is not already present.
pub fn ensure_line(path: &Path, line: &str) -> Result<()> {
    ensure_parent_dir(path)?;

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
    ensure_parent_dir(path)?;
    fs::write(path, content).with_context(|| format!("Failed to write {}", path.display()))
}

/// Safely writes content to a file with executable permissions (0755).
pub fn write_executable_file(path: &Path, content: &str) -> Result<()> {
    write_file(path, content)?;
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let perms = fs::Permissions::from_mode(0o755);
        fs::set_permissions(path, perms)
            .with_context(|| format!("Failed to set permissions on {}", path.display()))?;
    }
    Ok(())
}
