use crate::domain::task::{Task, TaskCategory};

/// Returns tasks belonging to the core category.
pub fn get_tasks() -> Vec<Task> {
    let mut tasks = get_essential_tasks();
    tasks.extend(get_shell_tasks());
    tasks
}

fn get_essential_tasks() -> Vec<Task> {
    vec![
        Task {
            id: "install_essential_apps",
            name: "Install Essential Apps",
            description: "Installs mpv, anki, qbittorrent, neovim, firefox, yazi, zoxide, rust",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "install_jdk",
            name: "Install OpenJDK 21 LTS",
            description: "Installs OpenJDK 21 and hides desktop launcher entries",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "install_uv",
            name: "Install uv Python Manager",
            description: "Installs high-performance uv package and project manager",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "setup_android_sdk",
            name: "Setup Android SDK",
            description: "Configures Android development environment variables",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "setup_docker",
            name: "Setup Docker Service",
            description: "Enables docker.service/socket and configures user permissions",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "setup_editor",
            name: "Default Editor Configuration",
            description: "Sets EDITOR and VISUAL environment variables to Neovim",
            category: TaskCategory::Core,
            default_selected: true,
        },
    ]
}

fn get_shell_tasks() -> Vec<Task> {
    vec![
        Task {
            id: "setup_blesh",
            name: "Setup ble.sh Auto-Suggestions",
            description: "Configures ble.sh for real-time Bash syntax highlighting & suggestions",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "setup_cli_tools",
            name: "Modern CLI Tools (eza & bat)",
            description: "Installs modern terminal utilities with icons and syntax highlighting",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "setup_fzf_keybinds",
            name: "FZF Interactive Keybinds",
            description: "Configures fuzzy finder interactive shell shortcuts",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "setup_git_config",
            name: "Global Git Configuration",
            description: "Configures user name, email, and default main branch",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "setup_github_ssh",
            name: "GitHub SSH Key Setup",
            description: "Generates Ed25519 SSH key and guides GitHub key connection",
            category: TaskCategory::Core,
            default_selected: true,
        },
        Task {
            id: "setup_zoxide",
            name: "Zoxide Smart Navigation",
            description: "Configures zoxide smarter cd command navigation",
            category: TaskCategory::Core,
            default_selected: true,
        },
    ]
}
