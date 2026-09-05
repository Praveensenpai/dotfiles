use crate::domain::{catalog, Task, TaskCategory};
use std::time::{Duration, Instant};

/// Represents the current stage of the TUI application lifecycle.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum AppState {
    Selecting,
    Running,
    Finished,
}

/// Execution status of an individual dotfiles task.
#[derive(Debug, Clone)]
pub enum TaskStatus {
    Pending,
    Running { started_at: Instant },
    Success { duration: Duration },
    Failed { error: String, duration: Duration },
}

/// A registered dotfiles task bundled with UI selection and execution state.
#[derive(Debug, Clone)]
pub struct TaskItem {
    pub task: Task,
    pub selected: bool,
    pub status: TaskStatus,
    pub live_subtask: String,
}

/// Root state holder for the Omarchy Dotfiles installer TUI.
pub struct App {
    pub state: AppState,
    pub tasks: Vec<TaskItem>,
    pub cursor: usize,
    pub active_category: Option<TaskCategory>,
    pub show_log_drawer: bool,
    pub log_scroll: usize,
    pub logs: Vec<String>,
    pub spinner_tick: usize,
    pub start_time: Option<Instant>,
    pub total_duration: Option<Duration>,
}

impl App {
    /// Initializes application state with all embedded tasks loaded from catalog.
    pub fn new() -> Self {
        let tasks = catalog::get_all_tasks()
            .into_iter()
            .map(|t| {
                let default_sel = t.default_selected;
                TaskItem {
                    task: t,
                    selected: default_sel,
                    status: TaskStatus::Pending,
                    live_subtask: String::new(),
                }
            })
            .collect();

        Self {
            state: AppState::Selecting,
            tasks,
            cursor: 0,
            active_category: None,
            show_log_drawer: false,
            log_scroll: 0,
            logs: Vec::new(),
            spinner_tick: 0,
            start_time: None,
            total_duration: None,
        }
    }

    /// Returns task indices matching the currently active category filter.
    pub fn filtered_indices(&self) -> Vec<usize> {
        self.tasks
            .iter()
            .enumerate()
            .filter(|(_, item)| {
                let Some(cat) = self.active_category else {
                    return true;
                };
                item.task.category == cat
            })
            .map(|(i, _)| i)
            .collect()
    }

    /// Returns a reference to the task currently highlighted by cursor.
    pub fn current_selected_task(&self) -> Option<&TaskItem> {
        let indices = self.filtered_indices();
        indices.get(self.cursor).map(|&idx| &self.tasks[idx])
    }

    /// Inverts the selection checkbox of the highlighted task.
    pub fn toggle_selected(&mut self) {
        let indices = self.filtered_indices();
        if let Some(&idx) = indices.get(self.cursor) {
            self.tasks[idx].selected = !self.tasks[idx].selected;
        }
    }

    /// Toggles all tasks in the current category between selected and unselected.
    pub fn toggle_all(&mut self) {
        let indices = self.filtered_indices();
        let any_unselected = indices.iter().any(|&i| !self.tasks[i].selected);
        for &i in &indices {
            self.tasks[i].selected = any_unselected;
        }
    }

    /// Moves the cursor up by one item, wrapping around.
    pub fn move_cursor_up(&mut self) {
        let total = self.filtered_indices().len();
        if total > 0 {
            self.cursor = if self.cursor == 0 {
                total - 1
            } else {
                self.cursor - 1
            };
        }
    }

    /// Moves the cursor down by one item, wrapping around.
    pub fn move_cursor_down(&mut self) {
        let total = self.filtered_indices().len();
        if total > 0 {
            self.cursor = if self.cursor + 1 >= total {
                0
            } else {
                self.cursor + 1
            };
        }
    }

    /// Cycles forward to the next category tab.
    pub fn next_category(&mut self) {
        let cats = TaskCategory::all();
        self.active_category = match self.active_category {
            None => Some(cats[0]),
            Some(curr) => {
                let idx = cats.iter().position(|&c| c == curr).unwrap_or(0);
                if idx + 1 >= cats.len() {
                    None
                } else {
                    Some(cats[idx + 1])
                }
            }
        };
        self.cursor = 0;
    }

    /// Cycles backward to the previous category tab.
    pub fn prev_category(&mut self) {
        let cats = TaskCategory::all();
        self.active_category = match self.active_category {
            None => Some(cats[cats.len() - 1]),
            Some(curr) => {
                let idx = cats.iter().position(|&c| c == curr).unwrap_or(0);
                if idx == 0 {
                    None
                } else {
                    Some(cats[idx - 1])
                }
            }
        };
        self.cursor = 0;
    }

    /// Adds a line to the recent in-memory log buffer, retaining up to 2000 lines.
    pub fn add_log(&mut self, line: String) {
        if self.logs.len() > 2000 {
            self.logs.remove(0);
        }
        self.logs.push(line);
    }

    /// Returns completed tasks count, total selected count, and percentage (0 to 100).
    pub fn get_progress(&self) -> (usize, usize, u16) {
        let total_selected = self.tasks.iter().filter(|t| t.selected).count();
        let completed = self
            .tasks
            .iter()
            .filter(|t| {
                t.selected
                    && matches!(
                        t.status,
                        TaskStatus::Success { .. } | TaskStatus::Failed { .. }
                    )
            })
            .count();

        let percent =
            u16::try_from(completed.saturating_mul(100) / total_selected.max(1)).unwrap_or(0);
        (completed, total_selected, percent)
    }

    /// Returns the current animated spinner character for active tasks.
    pub fn spinner_char(&self) -> &'static str {
        const FRAMES: &[&str] = &["🌸", "✨", "🌺", "💫", "🎀", "💖"];
        FRAMES[self.spinner_tick % FRAMES.len()]
    }
}
