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
            id: "setup_japanese_ime",
            name: "Japanese IME (Fcitx5 + Mozc)",
            description: "Deploys standalone paisen.japanese-ime plugin for Omarchy",
            category: TaskCategory::Rice,
            default_selected: true,
        },
        Task {
            id: "setup_omo_anitrack",
            name: "Omo Anitrack Anime Widget",
            description: "Installs anime schedule and watchlist bar widget",
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
