use crate::domain::task::{Task, TaskCategory};

/// Returns tasks belonging to the desktop category.
pub fn get_tasks() -> Vec<Task> {
    vec![
        Task {
            id: "disable_bluetooth",
            name: "Disable Bluetooth on Boot",
            description: "Disables bluetooth service on boot to save battery",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
        Task {
            id: "disable_voxtype",
            name: "Disable Voxtype Service",
            description: "Disables Voxtype service and dictation keybind",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
        Task {
            id: "remove_omarchy_preinstalls",
            name: "Omarchy Debloat",
            description: "Runs omarchy-debloat tool to clean default bloatware",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
        Task {
            id: "set_alacritty_font_size",
            name: "Alacritty Font Size",
            description: "Configures Alacritty font size to 10 for clean readability",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
        Task {
            id: "set_hyprland_gaps_and_borders",
            name: "Hyprland Gaps & Borders",
            description: "Configures aesthetic window gaps and border colors",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
        Task {
            id: "set_hyprland_idle_and_keybinds",
            name: "Hyprland Idle & Keybinds",
            description: "Configures Hyprland idle timeouts and custom shortcut bindings",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
        Task {
            id: "set_hyprland_monitor_scale",
            name: "Hyprland Monitor Scale",
            description: "Sets monitor scale to 1.5 for crisp HiDPI rendering",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
        Task {
            id: "set_omarchy_shell_bar",
            name: "Omarchy Shell Bar Customizer",
            description:
                "Configures Quickshell bar colors, system resources, and Japanese calendar",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
        Task {
            id: "setup_omarchy_refined_menu",
            name: "Omarchy Refined Menu",
            description: "Customizes Omarchy application menu presentation",
            category: TaskCategory::Desktop,
            default_selected: true,
        },
    ]
}
