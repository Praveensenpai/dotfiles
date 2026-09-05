use ratatui::layout::{Alignment, Rect};
use ratatui::style::{Modifier, Style};
use ratatui::text::{Line, Span};
use ratatui::widgets::{Block, BorderType, Borders, Paragraph, Tabs};
use ratatui::Frame;

use crate::app::App;
use crate::domain::TaskCategory;
use crate::ui::theme::Theme;

/// Renders the top kawaii banner.
pub fn render_banner(frame: &mut Frame, area: Rect) {
    let header_text = Line::from(vec![
        Span::styled("🌸 ", Style::default().fg(Theme::SAKURA_PINK)),
        Span::styled(
            "Omarchy Dotfiles Setup",
            Style::default()
                .fg(Theme::SAKURA_PINK)
                .add_modifier(Modifier::BOLD),
        ),
        Span::styled(" ✨ ", Style::default().fg(Theme::PASTEL_YELLOW)),
        Span::styled(
            "(Cute, Clean & Minimal Arch Installer)",
            Style::default()
                .fg(Theme::TEXT_MUTED)
                .add_modifier(Modifier::ITALIC),
        ),
    ]);

    let block = Block::default()
        .borders(Borders::ALL)
        .border_type(BorderType::Rounded)
        .border_style(Style::default().fg(Theme::BORDER_COLOR))
        .style(Style::default().bg(Theme::BG_OVERLAY));

    frame.render_widget(
        Paragraph::new(header_text)
            .alignment(Alignment::Center)
            .block(block),
        area,
    );
}

/// Renders the category filter tabs.
pub fn render_category_tabs(frame: &mut Frame, area: Rect, app: &App) {
    let mut titles = vec![Line::from(" ✨ All Tasks ")];
    for cat in TaskCategory::all() {
        titles.push(Line::from(format!(" {} ", cat.label())));
    }

    let selected_index = match app.active_category {
        None => 0,
        Some(cat) => TaskCategory::all()
            .iter()
            .position(|&c| c == cat)
            .map_or(0, |idx| idx + 1),
    };

    let tabs = Tabs::new(titles)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .border_type(BorderType::Rounded)
                .border_style(Style::default().fg(Theme::BORDER_COLOR))
                .title(" Categories [Tab / Shift-Tab] ")
                .title_alignment(Alignment::Left)
                .style(Style::default().bg(Theme::BG_OVERLAY)),
        )
        .select(selected_index)
        .style(Style::default().fg(Theme::TEXT_MUTED))
        .highlight_style(
            Style::default()
                .fg(Theme::SAKURA_PINK)
                .add_modifier(Modifier::BOLD | Modifier::UNDERLINED),
        );

    frame.render_widget(tabs, area);
}
