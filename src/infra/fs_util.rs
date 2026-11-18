use anyhow::{Context, Result};
use std::fs::{self, OpenOptions};
use std::io::{self, Write};
use std::path::Path;
#[cfg(test)]
use std::sync::atomic::{AtomicUsize, Ordering};

/// Creates a unique scratch directory for unit tests.
#[cfg(test)]
pub fn test_dir(label: &str) -> std::path::PathBuf {
    static NEXT: AtomicUsize = AtomicUsize::new(0);
    let id = NEXT.fetch_add(1, Ordering::Relaxed);
    let dir =
        std::env::temp_dir().join(format!("dotfiles-test-{label}-{}-{id}", std::process::id()));
    let _ = fs::create_dir_all(&dir);
    dir
}

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

/// Deploys embedded assets under `base`, rewriting only files whose content changed.
///
/// Each entry is `(relative path, content, executable)`. Re-running is idempotent:
/// unchanged files are left untouched, so user edits are preserved until content
/// actually differs from the embedded version.
pub fn deploy_assets(base: &Path, assets: &[(&str, &str, bool)]) -> Result<()> {
    for (relative, content, executable) in assets {
        let target = base.join(relative);
        let current = fs::read_to_string(&target).ok();
        if current.as_deref() == Some(*content) {
            continue;
        }
        if *executable {
            write_executable_file(&target, content)?;
        } else {
            write_file(&target, content)?;
        }
    }
    Ok(())
}

/// Replaces a marker-delimited managed block, or appends it when absent.
pub fn replace_managed_block(content: &str, start: &str, end: &str, block: &str) -> String {
    if let Some(start_idx) = content.find(start) {
        if let Some(end_rel) = content[start_idx..].find(end) {
            let end_idx = start_idx + end_rel + end.len();
            let head = content[..start_idx].trim_end();
            let tail = content[end_idx..].trim();
            let mut result = String::new();
            if !head.is_empty() {
                result.push_str(head);
                result.push_str("\n\n");
            }
            result.push_str(block);
            if !tail.is_empty() {
                result.push_str("\n\n");
                result.push_str(tail);
            }
            result.push('\n');
            return result;
        }
    }

    let mut result = content.trim_end().to_string();
    if !result.is_empty() {
        result.push_str("\n\n");
    }
    result.push_str(block);
    result.push('\n');
    result
}

/// Writes a file readable only by its owner (0600), used for API key config.
pub fn write_private_file(path: &Path, content: &str) -> Result<()> {
    write_file(path, content)?;
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        fs::set_permissions(path, fs::Permissions::from_mode(0o600))
            .with_context(|| format!("Failed to set permissions on {}", path.display()))?;
    }
    Ok(())
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
