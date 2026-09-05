use ratatui::style::Color;

/// Visual theme colors inspired by pastel sakura and Omarchy aesthetics.
pub struct Theme;

impl Theme {
    pub const SAKURA_PINK: Color = Color::Rgb(255, 183, 197);
    pub const ROSE_PINK: Color = Color::Rgb(243, 139, 168);
    pub const LAVENDER: Color = Color::Rgb(203, 166, 247);
    pub const SOFT_GREEN: Color = Color::Rgb(166, 227, 161);
    pub const PASTEL_YELLOW: Color = Color::Rgb(249, 226, 175);
    pub const SKY_BLUE: Color = Color::Rgb(137, 220, 235);
    pub const TEXT_PRIMARY: Color = Color::Rgb(205, 214, 244);
    pub const TEXT_MUTED: Color = Color::Rgb(108, 112, 134);
    pub const BORDER_COLOR: Color = Color::Rgb(180, 190, 254);
    pub const BG_OVERLAY: Color = Color::Rgb(24, 24, 37);
}
