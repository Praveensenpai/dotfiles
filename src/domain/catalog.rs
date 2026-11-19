use crate::domain::task::Task;
use crate::domain::{core_tasks, desktop_tasks, maint_tasks, media_tasks, rice_tasks, tools_tasks};

/// Assembles the complete list of all 48 embedded tasks.
pub fn get_all_tasks() -> Vec<Task> {
    let mut tasks = Vec::with_capacity(48);
    tasks.extend(core_tasks::get_tasks());
    tasks.extend(desktop_tasks::get_tasks());
    tasks.extend(rice_tasks::get_tasks());
    tasks.extend(media_tasks::get_tasks());
    tasks.extend(tools_tasks::get_tasks());
    tasks.extend(maint_tasks::get_tasks());
    tasks
}
