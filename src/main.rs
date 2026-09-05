use std::io::{self, stdout};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::Arc;
use std::time::{Duration, Instant};

use anyhow::Result;
use clap::Parser;
use crossterm::event::{self, Event, KeyCode, KeyEvent, KeyEventKind, KeyModifiers};
use crossterm::terminal::{
    disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen,
};
use crossterm::ExecutableCommand;
use ratatui::backend::CrosstermBackend;
use ratatui::Terminal;
use tokio::sync::mpsc;

mod app;
mod cli;
mod domain;
mod infra;
mod ui;

use app::{App, AppState, TaskStatus};
use cli::Cli;
use domain::Task;
use infra::{ProcessRunner, RunnerEvent};

struct RunContext {
    tx: mpsc::Sender<RunnerEvent>,
    rx: mpsc::Receiver<RunnerEvent>,
    handle: Option<tokio::task::JoinHandle<()>>,
    dry_run: bool,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Cli::parse();
    if args.list {
        cli::print_task_list();
        return Ok(());
    }

    infra::sudo::warmup()?;
    let sudo_running = Arc::new(AtomicBool::new(true));
    infra::sudo::spawn_keepalive(sudo_running.clone());

    let mut app = App::new();
    let (tx, rx) = mpsc::channel::<RunnerEvent>(100);
    let mut ctx = RunContext {
        tx,
        rx,
        handle: None,
        dry_run: args.dry_run,
    };

    if args.all {
        start_execution(&mut app, &mut ctx)?;
    }

    enable_raw_mode()?;
    stdout().execute(EnterAlternateScreen)?;
    let mut terminal = Terminal::new(CrosstermBackend::new(stdout()))?;

    let res = run_event_loop(&mut terminal, &mut app, &mut ctx);

    disable_raw_mode()?;
    stdout().execute(LeaveAlternateScreen)?;
    sudo_running.store(false, Ordering::Relaxed);

    if let Err(err) = res {
        eprintln!("\n❌ Error running dotfiles setup: {err:#}");
    } else {
        println!("\n🌸 \x1b[1;32mOmarchy Dotfiles setup finished successfully!\x1b[0m ✨");
        println!("📜 Logs saved to: \x1b[36m~/.local/state/omarchy-dotfiles/install.log\x1b[0m\n");
    }

    Ok(())
}

fn start_execution(app: &mut App, ctx: &mut RunContext) -> Result<()> {
    app.state = AppState::Running;
    app.start_time = Some(Instant::now());

    let runner = ProcessRunner::new()?;
    let tx = ctx.tx.clone();
    let dry_run = ctx.dry_run;
    let tasks: Vec<Task> = app
        .tasks
        .iter()
        .filter(|t| t.selected)
        .map(|t| t.task.clone())
        .collect();

    ctx.handle = Some(tokio::spawn(async move {
        for task in tasks {
            if dry_run {
                simulate_dry_run(&task, &tx).await;
            } else {
                let _ = runner.run_task(&task, tx.clone()).await;
            }
        }
        let _ = tx.send(RunnerEvent::AllFinished).await;
    }));

    Ok(())
}

async fn simulate_dry_run(task: &Task, tx: &mpsc::Sender<RunnerEvent>) {
    let _ = tx
        .send(RunnerEvent::TaskStarted {
            id: task.id.to_string(),
        })
        .await;
    tokio::time::sleep(Duration::from_millis(150)).await;
    let _ = tx
        .send(RunnerEvent::TaskProgress {
            id: task.id.to_string(),
            line: format!("[dry-run] Simulating {}", task.name),
        })
        .await;
    tokio::time::sleep(Duration::from_millis(200)).await;
    let _ = tx
        .send(RunnerEvent::TaskFinished {
            id: task.id.to_string(),
            success: true,
            duration: Duration::from_millis(350),
            error: None,
        })
        .await;
}

fn run_event_loop(
    terminal: &mut Terminal<CrosstermBackend<io::Stdout>>,
    app: &mut App,
    ctx: &mut RunContext,
) -> Result<()> {
    let mut last_tick = Instant::now();
    let tick_rate = Duration::from_millis(100);

    loop {
        terminal.draw(|f| ui::view::render(f, app))?;
        drain_runner_events(app, ctx);

        let timeout = tick_rate.saturating_sub(last_tick.elapsed());
        if event::poll(timeout)? {
            if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press && handle_key_input(app, ctx, key)? {
                    break;
                }
            }
        }

        if last_tick.elapsed() >= tick_rate {
            app.spinner_tick = app.spinner_tick.wrapping_add(1);
            last_tick = Instant::now();
        }
    }
    Ok(())
}

fn drain_runner_events(app: &mut App, ctx: &mut RunContext) {
    while let Ok(event) = ctx.rx.try_recv() {
        match event {
            RunnerEvent::TaskStarted { id } => {
                if let Some(item) = app.tasks.iter_mut().find(|t| t.task.id == id) {
                    item.status = TaskStatus::Running {
                        started_at: Instant::now(),
                    };
                    item.live_subtask = "Starting...".to_string();
                }
            }
            RunnerEvent::TaskProgress { id, line } => {
                if let Some(item) = app.tasks.iter_mut().find(|t| t.task.id == id) {
                    item.live_subtask.clone_from(&line);
                }
                app.add_log(line);
            }
            RunnerEvent::TaskFinished {
                id,
                success,
                duration,
                error,
            } => {
                apply_task_finish(app, &id, success, duration, error);
            }
            RunnerEvent::AllFinished => {
                app.state = AppState::Finished;
                if let Some(start) = app.start_time {
                    app.total_duration = Some(start.elapsed());
                }
            }
        }
    }
}

fn apply_task_finish(
    app: &mut App,
    id: &str,
    success: bool,
    duration: Duration,
    error: Option<String>,
) {
    let Some(item) = app.tasks.iter_mut().find(|t| t.task.id == id) else {
        return;
    };
    if success {
        item.status = TaskStatus::Success { duration };
        item.live_subtask = "Done ✔".to_string();
    } else {
        let err = error.unwrap_or_else(|| "Failed".to_string());
        item.status = TaskStatus::Failed {
            error: err.clone(),
            duration,
        };
        item.live_subtask = format!("Failed: {err}");
    }
}

fn handle_key_input(app: &mut App, ctx: &mut RunContext, key: KeyEvent) -> Result<bool> {
    if app.show_log_drawer {
        return Ok(handle_log_drawer_keys(app, key));
    }

    match key.code {
        KeyCode::Char('q') | KeyCode::Esc => {
            if app.state == AppState::Running {
                if let Some(h) = ctx.handle.take() {
                    h.abort();
                }
            }
            return Ok(true);
        }
        KeyCode::Char('l') => {
            app.show_log_drawer = true;
            app.log_scroll = 0;
        }
        KeyCode::Up | KeyCode::Char('k') if app.state == AppState::Selecting => {
            app.move_cursor_up();
        }
        KeyCode::Down | KeyCode::Char('j') if app.state == AppState::Selecting => {
            app.move_cursor_down();
        }
        KeyCode::Char(' ') if app.state == AppState::Selecting => app.toggle_selected(),
        KeyCode::Char('a') if app.state == AppState::Selecting => app.toggle_all(),
        KeyCode::Tab if app.state == AppState::Selecting => {
            if key.modifiers.contains(KeyModifiers::SHIFT) {
                app.prev_category();
            } else {
                app.next_category();
            }
        }
        KeyCode::BackTab if app.state == AppState::Selecting => app.prev_category(),
        KeyCode::Enter => {
            if app.state == AppState::Selecting {
                start_execution(app, ctx)?;
            } else if app.state == AppState::Finished {
                return Ok(true);
            }
        }
        _ => {}
    }

    Ok(false)
}

fn handle_log_drawer_keys(app: &mut App, key: KeyEvent) -> bool {
    match key.code {
        KeyCode::Esc | KeyCode::Char('l') => app.show_log_drawer = false,
        KeyCode::Up => app.log_scroll = app.log_scroll.saturating_add(3),
        KeyCode::Down => app.log_scroll = app.log_scroll.saturating_sub(3),
        _ => {}
    }
    false
}
