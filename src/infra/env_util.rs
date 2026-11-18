use std::path::PathBuf;

/// Returns the effective user name, falling back to the default dotfiles owner.
pub fn user_name() -> String {
    std::env::var("USER").unwrap_or_else(|_| "paisen".to_string())
}

/// Returns the effective home directory, falling back to the current directory.
pub fn home_dir() -> PathBuf {
    PathBuf::from(std::env::var("HOME").unwrap_or_else(|_| ".".to_string()))
}

/// Returns the XDG config directory (`$XDG_CONFIG_HOME` or `~/.config`).
pub fn config_dir() -> PathBuf {
    std::env::var_os("XDG_CONFIG_HOME").map_or_else(|| home_dir().join(".config"), PathBuf::from)
}
