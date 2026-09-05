pub mod catalog;
pub mod core_tasks;
pub mod desktop_tasks;
pub mod exec_core;
pub mod exec_desktop;
pub mod exec_maint;
pub mod exec_media;
pub mod exec_rice;
pub mod exec_shell_bar;
pub mod exec_tools;
pub mod executor;
pub mod maint_tasks;
pub mod media_tasks;
pub mod rice_tasks;
pub mod task;
pub mod tools_tasks;

pub use executor::execute_task;
pub use task::{Task, TaskCategory};
