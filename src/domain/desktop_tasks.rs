use crate::domain::task::{Task, TaskCategory};

fn dt(id: &'static str, name: &'static str, desc: &'static str, default_selected: bool) -> Task {
    Task {
        id,
        name,
        description: desc,
        category: TaskCategory::Desktop,
        default_selected,
    }
}

/// Returns tasks belonging to the desktop category.
pub fn get_tasks() -> Vec<Task> {
    vec![
        dt(
            "disable_bluetooth",
            "Disable Bluetooth on Boot",
            "Disables bluetooth service on boot to save battery",
            true,
        ),
        dt(
            "disable_voxtype",
            "Disable Voxtype Service",
            "Disables Voxtype service and dictation keybind",
            true,
        ),
        dt(
            "remove_omarchy_preinstalls",
            "Omarchy Debloat",
            "Runs omarchy-debloat tool to clean default bloatware",
            true,
        ),
        dt(
            "set_alacritty_font_size",
            "Alacritty Font Size",
            "Configures Alacritty font size to 10 for clean readability",
            true,
        ),
        dt(
            "set_hyprland_gaps_and_borders",
            "Hyprland Gaps & Borders",
            "Configures aesthetic window gaps and border colors",
            true,
        ),
        dt(
            "set_hyprland_idle_and_keybinds",
            "Hyprland Idle & Keybinds",
            "Configures Hyprland idle timeouts and custom shortcut bindings",
            true,
        ),
        dt(
            "set_hyprland_monitor_scale",
            "Hyprland Monitor Scale",
            "Sets monitor scale to 1.5 for crisp HiDPI rendering",
            true,
        ),
        dt(
            "set_omarchy_shell_bar",
            "Omarchy Shell Bar Customizer",
            "Configures Quickshell bar colors, system resources, and Japanese calendar",
            true,
        ),
        dt(
            "setup_omarchy_refined_menu",
            "Omarchy Refined Menu",
            "Customizes Omarchy application menu presentation",
            true,
        ),
        dt(
            "setup_poweroff_hibernation",
            "Hibernate on Shutdown & Low Battery",
            "Configures system to hibernate instead of direct poweroff on low battery and shutdown",
            true,
        ),
    ]
}
