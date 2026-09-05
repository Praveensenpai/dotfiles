use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, List, ListItem, Paragraph};
use ratatui::Frame;

use crate::app::{App, TaskItem};
use crate::ui::theme::Theme;

/// Renders the task selection screen body.
pub fn render_body(frame: &mut Frame, area: Rect, app: &App) {
    let body_chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(55), Constraint::Percentage(45)])
        .split(area);

    let indices = app.filtered_indices();
    let items: Vec<ListItem<'_>> = indices
        .iter()
        .enumerate()
        .map(|(i, &idx)| format_selection_item(&app.tasks[idx], i == app.cursor))
        .collect();

    let selected_count = app.tasks.iter().filter(|t| t.selected).count();
    let title = format!(
        " Task Selection ({selected_count}/{} Active) ",
        app.tasks.len()
    );

    let list_block = Block::default()
        .title(title)
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Theme::BORDER_COLOR))
        .style(Style::default().bg(Theme::BG_OVERLAY));

    frame.render_widget(List::new(items).block(list_block), body_chunks[0]);
    render_detail_panel(frame, body_chunks[1], app);
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
