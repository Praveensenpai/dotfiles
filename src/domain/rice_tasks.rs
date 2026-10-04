use crate::domain::task::{Task, TaskCategory};

/// Returns tasks belonging to the rice category.
pub fn get_tasks() -> Vec<Task> {
    vec![
        Task {
            id: "install_wallpapers",
            name: "Install Kawaii Wallpapers",
            description: "Deploys custom aesthetic anime wallpapers to current theme",
            category: TaskCategory::Rice,
            default_selected: true,
        },
        Task {
            id: "setup_starship",
            name: "Starship Prompt & Nerd Font",
            description: "Installs JetBrainsMono Nerd Font & kawaii Starship prompt config",
            category: TaskCategory::Rice,
            default_selected: true,
        },
    ]
}
