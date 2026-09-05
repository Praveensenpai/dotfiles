/// Categories grouping related dotfiles setup routines.
#[derive(Debug, Clone, Copy, PartialEq, Eq, PartialOrd, Ord)]
pub enum TaskCategory {
    Core,
    Desktop,
    Rice,
    Media,
    Tools,
    Maintenance,
}

impl TaskCategory {
    /// Human-friendly display label with icon for tabs.
    pub fn label(self) -> &'static str {
        match self {
            Self::Core => "📦 Core & Dev",
            Self::Desktop => "🖥️ Desktop & Hyprland",
            Self::Rice => "🌸 Rice & Aesthetics",
            Self::Media => "🎵 Media & MPV",
            Self::Tools => "🛠️ System Tools & Net",
            Self::Maintenance => "🧹 Maintenance (Optional)",
        }
    }

    /// List of all categories in display order.
    pub fn all() -> &'static [Self] {
        &[
            Self::Core,
            Self::Desktop,
            Self::Rice,
            Self::Media,
            Self::Tools,
            Self::Maintenance,
        ]
    }
}

/// Represents a distinct configuration or installation task.
#[derive(Debug, Clone)]
pub struct Task {
    pub id: &'static str,
    pub name: &'static str,
    pub description: &'static str,
    pub category: TaskCategory,
    pub script_filename: &'static str,
    pub script_content: &'static str,
    pub default_selected: bool,
}
