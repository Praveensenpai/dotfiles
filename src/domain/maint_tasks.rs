use crate::domain::task::{Task, TaskCategory};

/// Returns tasks belonging to the maintenance category.
pub fn get_tasks() -> Vec<Task> {
    vec![Task {
        id: "setup_arch_cleaner",
        name: "Arch Cleaner Interactive",
        description: "Interactive system cleanup utility for packages & logs",
        category: TaskCategory::Maintenance,
        default_selected: false,
    }]
}
