use ratatui::layout::{Alignment, Constraint, Direction, Layout, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Clear, Paragraph};
use ratatui::Frame;

use crate::ui::theme::Theme;

/// Renders a centered modal displaying the recent raw execution logs.
pub fn render(frame: &mut Frame, area: Rect, logs: &[String], scroll: usize) {
    let popup_area = centered_rect(88, 80, area);
    frame.render_widget(Clear, popup_area);

    let block = Block::default()
        .title(" 🌸 Live Execution Log (~/.local/state/omarchy-dotfiles/install.log) ")
        .title_alignment(Alignment::Center)
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Theme::SAKURA_PINK))
        .style(Style::default().bg(Theme::BG_OVERLAY));

    let visible_height = popup_area.height.saturating_sub(2) as usize;
    let log_lines = format_log_lines(logs, visible_height, scroll);

    let footer = Line::from(vec![
        Span::styled(
            " [Esc/l] Close ",
            Style::default()
                .fg(Theme::PASTEL_YELLOW)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled(" │ ", Style::default().fg(Theme::TEXT_MUTED)),
        Span::styled(" [↑/↓] Scroll ", Style::default().fg(Theme::SKY_BLUE)),
    ]);

    let inner = block.inner(popup_area);
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Min(1), Constraint::Length(1)])
        .split(inner);

    frame.render_widget(block, popup_area);
    frame.render_widget(Paragraph::new(log_lines), chunks[0]);
    frame.render_widget(
        Paragraph::new(footer).alignment(Alignment::Right),
        chunks[1],
    );
}

fn format_log_lines(logs: &[String], visible: usize, scroll: usize) -> Vec<Line<'_>> {
    let total = logs.len();
    let start = if total > visible {
        total.saturating_sub(visible + scroll)
    } else {
        0
    };

    logs.iter()
        .skip(start)
        .take(visible)
        .map(|line| colorize_log_line(line))
        .collect()
}

fn colorize_log_line(line: &str) -> Line<'_> {
    if line.contains("Error") || line.contains("Failed") || line.contains("[err]") {
        Line::from(vec![
            Span::styled(
                "✖ ",
                Style::default()
                    .fg(Theme::ROSE_PINK)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled(line, Style::default().fg(Theme::ROSE_PINK)),
        ])
    } else if line.contains("✔") || line.contains("Finished") {
        Line::from(vec![
            Span::styled(
                "✔ ",
                Style::default()
                    .fg(Theme::SOFT_GREEN)
                    .add_modifier(Modifier::BOLD),
            ),
            Span::styled(line, Style::default().fg(Theme::SOFT_GREEN)),
        ])
    } else {
        Line::from(Span::styled(line, Style::default().fg(Theme::TEXT_PRIMARY)))
    }
}

fn centered_rect(percent_x: u16, percent_y: u16, r: Rect) -> Rect {
    let v_chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Percentage((100 - percent_y) / 2),
            Constraint::Percentage(percent_y),
            Constraint::Percentage((100 - percent_y) / 2),
        ])
        .split(r);

    Layout::default()
        .direction(Direction::Horizontal)
        .constraints([
            Constraint::Percentage((100 - percent_x) / 2),
            Constraint::Percentage(percent_x),
            Constraint::Percentage((100 - percent_x) / 2),
        ])
        .split(v_chunks[1])[1]
}
