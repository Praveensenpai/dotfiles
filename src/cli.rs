use clap::Parser;

use crate::domain::{catalog, TaskCategory};

/// CLI arguments for the Omarchy Dotfiles installer.
#[derive(Parser, Debug)]
#[command(name = "omarchy-dotfiles")]
#[command(about = "🌸 Cute, aesthetic, and clutter-free Omarchy dotfiles installer & manager")]
#[command(version = "0.1.0")]
pub struct Cli {
    /// Run all default tasks immediately without launching the selection TUI
    #[arg(short, long)]
    pub all: bool,

    /// Simulate execution without running the underlying scripts
    #[arg(short, long)]
    pub dry_run: bool,

    /// List all embedded tasks by category and exit
    #[arg(short, long)]
    pub list: bool,
}

/// Prints a categorized terminal listing of all embedded tasks.
pub fn print_task_list() {
    println!("\x1b[1;35m🌸 Omarchy Dotfiles Tasks Registry ✨\x1b[0m\n");
    let all = catalog::get_all_tasks();
    for cat in TaskCategory::all() {
        println!("\x1b[1;36m{}\x1b[0m", cat.label());
        for t in all.iter().filter(|t| t.category == *cat) {
            let def = if t.default_selected {
                " [default: on]"
            } else {
                " [optional]"
            };
            println!(
                "  • \x1b[1m{:<32}\x1b[0m {:<26} \x1b[90m{}\x1b[0m{}",
                t.name, t.id, t.description, def
            );
        }
        println!();
    }
}
