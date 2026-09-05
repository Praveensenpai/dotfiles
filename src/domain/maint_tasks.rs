use crate::domain::task::{Task, TaskCategory};

/// Returns tasks belonging to the maint category.
pub fn get_tasks() -> Vec<Task> {
    vec![
        Task {
            id: "install_voicevox",
            name: "Install VOICEVOX Engine",
            description: "Voicevox TTS engine (optional/disabled by default)",
            category: TaskCategory::Maintenance,
            script_filename: "install_voicevox.sh",
            script_content: include_str!("../../scripts/install_voicevox.sh"),
            default_selected: false,
        },
        Task {
            id: "setup_arch_cleaner",
            name: "Arch Cleaner Interactive",
            description: "Interactive system cleanup utility for packages & logs",
            category: TaskCategory::Maintenance,
            script_filename: "setup_arch_cleaner.sh",
            script_content: include_str!("../../scripts/setup_arch_cleaner.sh"),
            default_selected: false,
        },
    ]
}
