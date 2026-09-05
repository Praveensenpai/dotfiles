use ratatui::layout::{Alignment, Rect};
use ratatui::style::{Color, Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Gauge, List, ListItem, Paragraph};
use ratatui::Frame;

use crate::app::{App, AppState, TaskItem, TaskStatus};
use crate::ui::theme::Theme;

/// Renders the overall progress bar gauge.
pub fn render_progress_bar(frame: &mut Frame, area: Rect, app: &App) {
    let (completed, total, percent) = app.get_progress();
    let label = format!("🌸 Progress: {completed}/{total} tasks completed ({percent}%)");

    let gauge = Gauge::default()
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_type(BorderType::Rounded)
                .border_style(Style::default().fg(Theme::BORDER_COLOR))
                .style(Style::default().bg(Theme::BG_OVERLAY)),
        )
        .gauge_style(
            Style::default()
                .fg(Theme::SAKURA_PINK)
                .bg(Color::Rgb(40, 40, 60))
                .add_modifier(Modifier::BOLD),
        )
        .percent(percent)
        .label(label);

    frame.render_widget(gauge, area);
}

/// Renders the list of tasks undergoing execution.
pub fn render_body(frame: &mut Frame, area: Rect, app: &App) {
    let selected_items: Vec<&TaskItem> = app.tasks.iter().filter(|t| t.selected).collect();
    let visible_rows = area.height.saturating_sub(2) as usize;
    let active_idx = find_active_index(&selected_items);

    let start_idx = if active_idx > visible_rows / 2 {
        active_idx.saturating_sub(visible_rows / 2)
    } else {
        0
    };

    let items: Vec<ListItem<'_>> = selected_items
        .iter()
        .skip(start_idx)
        .take(visible_rows)
        .map(|item| format_running_item(item, app.spinner_char()))
        .collect();

    let title = if app.state == AppState::Running {
        " 🌸 Execution Progress (Zero Noise) "
    } else {
        " 🎉 Setup Finished! "
    };

    let block = Block::default()
        .title(title)
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Theme::BORDER_COLOR))
        .style(Style::default().bg(Theme::BG_OVERLAY));

    frame.render_widget(List::new(items).block(block), area);
}

fn find_active_index(items: &[&TaskItem]) -> usize {
    items
        .iter()
        .position(|t| matches!(t.status, TaskStatus::Running { .. }))
        .unwrap_or_else(|| {
            items
                .iter()
                .position(|t| matches!(t.status, TaskStatus::Pending))
                .unwrap_or(items.len().saturating_sub(1))
        })
}

fn format_running_item<'a>(item: &'a TaskItem, spinner: &'a str) -> ListItem<'a> {
    match &item.status {
        TaskStatus::Pending => {
            let line = Line::from(vec![
                Span::styled("  · ", Style::default().fg(Theme::TEXT_MUTED)),
                Span::styled(item.task.name, Style::default().fg(Theme::TEXT_MUTED)),
            ]);
            ListItem::new(line)
        }
        TaskStatus::Running { started_at } => {
            let elapsed = format!(" ({:.1}s)", started_at.elapsed().as_secs_f32());
            let h = Line::from(vec![
                Span::styled(
                    format!("  {spinner} ▶ "),
                    Style::default()
                        .fg(Theme::SAKURA_PINK)
                        .add_modifier(Modifier::BOLD),
                ),
                Span::styled(
                    item.task.name,
                    Style::default()
                        .fg(Theme::SAKURA_PINK)
                        .add_modifier(Modifier::BOLD),
                ),
                Span::styled(elapsed, Style::default().fg(Theme::TEXT_MUTED)),
            ]);
            let sub = if item.live_subtask.is_empty() {
                "Executing..."
            } else {
                item.live_subtask.as_str()
            };
            let s = Line::from(vec![
                Span::styled("        ↳ ", Style::default().fg(Theme::LAVENDER)),
                Span::styled(
                    sub,
                    Style::default()
                        .fg(Theme::SKY_BLUE)
                        .add_modifier(Modifier::ITALIC),
                ),
            ]);
            ListItem::new(vec![h, s])
        }
        TaskStatus::Success { duration } => {
            let line = Line::from(vec![
                Span::styled(
                    "  ✔ ",
                    Style::default()
                        .fg(Theme::SOFT_GREEN)
                        .add_modifier(Modifier::BOLD),
                ),
                Span::styled(item.task.name, Style::default().fg(Theme::TEXT_PRIMARY)),
                Span::styled(
                    format!(" ({:.1}s)", duration.as_secs_f32()),
                    Style::default().fg(Theme::TEXT_MUTED),
                ),
            ]);
            ListItem::new(line)
        }
        TaskStatus::Failed { error, duration } => {
            let line = Line::from(vec![
                Span::styled(
                    "  ✖ ",
                    Style::default()
                        .fg(Theme::ROSE_PINK)
                        .add_modifier(Modifier::BOLD),
                ),
                Span::styled(
                    item.task.name,
                    Style::default()
                        .fg(Theme::ROSE_PINK)
                        .add_modifier(Modifier::BOLD),
                ),
                Span::styled(
                    format!(" ({:.1}s) - {error}", duration.as_secs_f32()),
                    Style::default().fg(Theme::ROSE_PINK),
                ),
            ]);
            ListItem::new(line)
        }
    }
}

/// Renders the footer guide during and after execution.
pub fn render_footer(frame: &mut Frame, area: Rect, app: &App) {
    let footer_text = match app.state {
        AppState::Running => Line::from(vec![
            Span::styled(
                " [l] ",
                Style::default()
                    .fg(Theme::PASTEL_YELLOW)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled("Live Log Drawer", Style::default().fg(Theme::TEXT_PRIMARY)),
            Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
            Span::styled(
                "[q] ",
                Style::default()
                    .fg(Theme::ROSE_PINK)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled("Cancel Setup", Style::default().fg(Theme::TEXT_PRIMARY)),
            Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
            Span::styled(
                "Logs saved to ~/.local/state/omarchy-dotfiles/install.log",
                Style::default()
                    .fg(Theme::TEXT_MUTED)
                    .add_modifier(Modifier::ITALIC),
            ),
        ]),
        AppState::Finished => Line::from(vec![
            Span::styled(
                " 🎉 All Selected Dotfiles Installed! ",
                Style::default()
                    .fg(Theme::SOFT_GREEN)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
            Span::styled(
                "[l] ",
                Style::default()
                    .fg(Theme::PASTEL_YELLOW)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled("Inspect Full Log", Style::default().fg(Theme::TEXT_PRIMARY)),
            Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
            Span::styled(
                "[Enter / q] ",
                Style::default()
                    .fg(Theme::SKY_BLUE)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled("Exit", Style::default().fg(Theme::TEXT_PRIMARY)),
        ]),
        AppState::Selecting => Line::from(""),
    };

    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Theme::BORDER_COLOR))
        .style(Style::default().bg(Theme::BG_OVERLAY));

    frame.render_widget(
        Paragraph::new(footer_text)
            .alignment(Alignment::Center)
            .block(block),
        area,
    );
}
