use crate::domain::task::{Task, TaskCategory};

/// Returns tasks belonging to the media category.
pub fn get_tasks() -> Vec<Task> {
    vec![
        Task {
            id: "install_anime4k",
            name: "Install Anime4K Shaders",
            description: "Installs high quality Anime4K real-time upscaling shaders for mpv",
            category: TaskCategory::Media,
            default_selected: true,
        },
        Task {
            id: "set_mpv_lang",
            name: "MPV Audio & Subtitle Lang",
            description: "Sets Japanese audio and English subtitle defaults for mpv",
            category: TaskCategory::Media,
            default_selected: true,
        },
        Task {
            id: "setup_kotonoha",
            name: "Kotonoha Sentence Miner",
            description: "Installs kotonoha Japanese immersion i+1 sentence miner",
            category: TaskCategory::Media,
            default_selected: true,
        },
        Task {
            id: "setup_mpd",
            name: "MPD Music Player Daemon",
            description: "Installs Music Player Daemon and configures user systemd service",
            category: TaskCategory::Media,
            default_selected: true,
        },
        Task {
            id: "setup_mpv_resume",
            name: "MPV Playback Resume",
            description: "Configures mpv to remember playback position on quit",
            category: TaskCategory::Media,
            default_selected: true,
        },
        Task {
            id: "setup_mpv_youtube",
            name: "MPV YouTube Quality Profiles",
            description: "Configures optimal yt-dlp streaming formats for mpv",
            category: TaskCategory::Media,
            default_selected: true,
        },
        Task {
            id: "setup_otopod",
            name: "Otopod Audio Condenser",
            description: "Installs otopod audio condenser for anime immersion",
            category: TaskCategory::Media,
            default_selected: true,
        },
        Task {
            id: "setup_ototune",
            name: "Ototune Pitch Profiler",
            description: "Installs ototune Japanese pitch accent training utility",
            category: TaskCategory::Media,
            default_selected: true,
        },
        Task {
            id: "setup_subsink",
            name: "Subsink Subtitle Syncer",
            description: "Installs automatic Japanese subtitle synchronization tool",
            category: TaskCategory::Media,
            default_selected: true,
        },
    ]
}
