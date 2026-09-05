use ratatui::layout::{Constraint, Direction, Layout};
use ratatui::Frame;

use crate::app::{App, AppState};
use crate::ui::{header, log_drawer, running_view, selection_view};

/// Top-level view rendering entrypoint.
pub fn render(frame: &mut Frame, app: &App) {
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),
            Constraint::Length(3),
            Constraint::Min(8),
            Constraint::Length(3),
        ])
        .split(frame.area());

    header::render_banner(frame, chunks[0]);

    match app.state {
        AppState::Selecting => {
            header::render_category_tabs(frame, chunks[1], app);
            selection_view::render_body(frame, chunks[2], app);
            selection_view::render_footer(frame, chunks[3]);
        }
        AppState::Running | AppState::Finished => {
            running_view::render_progress_bar(frame, chunks[1], app);
            running_view::render_body(frame, chunks[2], app);
            running_view::render_footer(frame, chunks[3], app);
        }
    }

    if app.show_log_drawer {
        log_drawer::render(frame, frame.area(), &app.logs, app.log_scroll);
    }
}
