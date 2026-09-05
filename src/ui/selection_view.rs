use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{
    Block, BorderType, Borders, List, ListItem, Paragraph, Scrollbar, ScrollbarOrientation,
    ScrollbarState,
};
use ratatui::Frame;

use crate::app::{App, TaskItem};
use crate::ui::theme::Theme;

/// Renders the task selection screen body.
pub fn render_body(frame: &mut Frame, area: Rect, app: &App) {
    let body_chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(55), Constraint::Percentage(45)])
        .split(area);

    render_task_list(frame, body_chunks[0], app);
    render_detail_panel(frame, body_chunks[1], app);
}

fn calculate_start_idx(cursor: usize, total: usize, visible_rows: usize) -> usize {
    if total <= visible_rows || visible_rows == 0 {
        0
    } else if cursor >= visible_rows / 2 {
        let max_start = total.saturating_sub(visible_rows);
        let ideal_start = cursor.saturating_sub(visible_rows / 2);
        ideal_start.min(max_start)
    } else {
        0
    }
}

fn render_task_list(frame: &mut Frame, area: Rect, app: &App) {
    let indices = app.filtered_indices();
    let total = indices.len();
    let visible_rows = area.height.saturating_sub(2) as usize;
    let start_idx = calculate_start_idx(app.cursor, total, visible_rows);

    let items: Vec<ListItem<'_>> = indices
        .iter()
        .enumerate()
        .skip(start_idx)
        .take(visible_rows)
        .map(|(i, &idx)| format_selection_item(&app.tasks[idx], i == app.cursor))
        .collect();

    let selected_count = app.tasks.iter().filter(|t| t.selected).count();
    let pos = if total > visible_rows {
        format!(" • {}/{} ", app.cursor + 1, total)
    } else {
        String::new()
    };
    let title = format!(
        " Task Selection ({selected_count}/{} Active){pos} ",
        app.tasks.len()
    );

    let list_block = Block::default()
        .title(title)
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Theme::BORDER_COLOR))
        .style(Style::default().bg(Theme::BG_OVERLAY));

    frame.render_widget(List::new(items).block(list_block), area);

    if total > visible_rows {
        render_list_scrollbar(frame, area, total, app.cursor);
    }
}

fn render_list_scrollbar(frame: &mut Frame, area: Rect, total: usize, cursor: usize) {
    let mut scroll_state = ScrollbarState::new(total).position(cursor);
    let scrollbar = Scrollbar::default()
        .orientation(ScrollbarOrientation::VerticalRight)
        .thumb_style(Style::default().fg(Theme::SAKURA_PINK))
        .track_style(Style::default().fg(Theme::BORDER_COLOR));
    frame.render_stateful_widget(scrollbar, area, &mut scroll_state);
}

fn format_selection_item(item: &TaskItem, is_cursor: bool) -> ListItem<'_> {
    let checkbox = if item.selected {
        Span::styled(
            "[✔] ",
            Style::default()
                .fg(Theme::SOFT_GREEN)
                .add_modifier(Modifier::BOLD),
        )
    } else {
        Span::styled("[ ] ", Style::default().fg(Theme::TEXT_MUTED))
    };

    let prefix = if is_cursor {
        Span::styled(
            "▶ 🌸 ",
            Style::default()
                .fg(Theme::SAKURA_PINK)
                .add_modifier(Modifier::BOLD),
        )
    } else {
        Span::styled("    ", Style::default())
    };

    let name_style = if is_cursor {
        Style::default()
            .fg(Theme::SAKURA_PINK)
            .add_modifier(Modifier::BOLD)
    } else if item.selected {
        Style::default().fg(Theme::TEXT_PRIMARY)
    } else {
        Style::default().fg(Theme::TEXT_MUTED)
    };

    let line = Line::from(vec![
        prefix,
        checkbox,
        Span::styled(item.task.name, name_style),
    ]);
    ListItem::new(line)
}

fn render_detail_panel(frame: &mut Frame, area: Rect, app: &App) {
    let block = Block::default()
        .title(" Task Details ")
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Theme::BORDER_COLOR))
        .style(Style::default().bg(Theme::BG_OVERLAY));

    let Some(item) = app.current_selected_task() else {
        frame.render_widget(Paragraph::new("No tasks in category.").block(block), area);
        return;
    };

    let status_span = if item.selected {
        Span::styled(
            "Will be executed ✨",
            Style::default().fg(Theme::SOFT_GREEN),
        )
    } else {
        Span::styled("Skipped ⏭", Style::default().fg(Theme::TEXT_MUTED))
    };

    let text = vec![
        Line::from(vec![
            Span::styled(
                "Name: ",
                Style::default()
                    .fg(Theme::SKY_BLUE)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled(
                item.task.name,
                Style::default()
                    .fg(Theme::SAKURA_PINK)
                    .add_modifier(Modifier::BOLD),
            ),
        ]),
        Line::from(""),
        Line::from(vec![
            Span::styled(
                "Category: ",
                Style::default()
                    .fg(Theme::SKY_BLUE)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled(
                item.task.category.label(),
                Style::default().fg(Theme::PASTEL_YELLOW),
            ),
        ]),
        Line::from(""),
        Line::from(vec![
            Span::styled(
                "Task ID: ",
                Style::default()
                    .fg(Theme::SKY_BLUE)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled(item.task.id, Style::default().fg(Theme::LAVENDER)),
        ]),
        Line::from(""),
        Line::from(Span::styled(
            "Description:",
            Style::default()
                .fg(Theme::SKY_BLUE)
                .add_modifier(Modifier::BOLD),
        )),
        Line::from(Span::styled(
            item.task.description,
            Style::default().fg(Theme::TEXT_PRIMARY),
        )),
        Line::from(""),
        Line::from(vec![
            Span::styled(
                "Status: ",
                Style::default()
                    .fg(Theme::SKY_BLUE)
                    .add_modifier(Modifier::BOLD),
            ),
            status_span,
        ]),
    ];

    frame.render_widget(Paragraph::new(text).block(block), area);
}

/// Renders the footer guide for the selection screen.
pub fn render_footer(frame: &mut Frame, area: Rect) {
    let footer_text = Line::from(vec![
        Span::styled(
            " [Space] ",
            Style::default()
                .fg(Theme::PASTEL_YELLOW)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled("Toggle", Style::default().fg(Theme::TEXT_PRIMARY)),
        Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
        Span::styled(
            "[a] ",
            Style::default()
                .fg(Theme::PASTEL_YELLOW)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled("All/None", Style::default().fg(Theme::TEXT_PRIMARY)),
        Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
        Span::styled(
            "[Tab] ",
            Style::default()
                .fg(Theme::PASTEL_YELLOW)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled("Category", Style::default().fg(Theme::TEXT_PRIMARY)),
        Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
        Span::styled(
            "[Enter] ",
            Style::default()
                .fg(Theme::SOFT_GREEN)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled(
            "Start Setup",
            Style::default()
                .fg(Theme::SOFT_GREEN)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
        Span::styled(
            "[q] ",
            Style::default()
                .fg(Theme::ROSE_PINK)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled("Quit", Style::default().fg(Theme::TEXT_PRIMARY)),
    ]);

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
