# CODEBASE.md: omarchy-dotfiles Semantic Digest

> **Notice**: AI-optimized semantic index. Do not write narrative prose. Keep token density high.

## 1. System Topology & Data Flow
```text
Entrypoint ──> CLI/Parser ──> Domain Logic ──> Infra/IO
```

## 2. Global Constraints & Architecture Patterns
- **Primary Language**: Rust 2021 edition
- **Architectural Paradigm**: Role-based (domain/, infra/, api/cli/, tui/)
- **Hard Constraints**: <400 lines/file, <60 lines/fn, zero production unwrap(), 0 warnings.
- **Target Distribution**: Linux x86_64 standalone binary

## 3. Module & Interface Skeleton

### `src/app.rs` (Role: general, Lines: 203)
- **Responsibility**: Core general logic in src/app.rs
- **Imports**: use crate :: domain :: { catalog , Task , TaskCategory } , use std :: time :: { Duration , Instant } 
- **Types & Enums**:
  ```rust
  pub enum AppState
  pub enum TaskStatus
  pub struct TaskItem
  pub struct App
  ```
- **Public Functions & Signatures**:
  ```rust
  fn new () -> Self
  fn filtered_indices (& self) -> Vec < usize >
  fn current_selected_task (& self) -> Option < & TaskItem >
  fn toggle_selected (& mut self)
  fn toggle_all (& mut self)
  fn move_cursor_up (& mut self)
  fn move_cursor_down (& mut self)
  fn next_category (& mut self)
  fn prev_category (& mut self)
  fn add_log (& mut self , line : String)
  fn get_progress (& self) -> (usize , usize , u16)
  fn spinner_char (& self) -> & 'static str
  ```

### `src/cli.rs` (Role: cli, Lines: 43)
- **Responsibility**: Core cli logic in src/cli.rs
- **Imports**: use clap :: Parser , use crate :: domain :: { catalog , TaskCategory } 
- **Types & Enums**:
  ```rust
  pub struct Cli
  ```
- **Public Functions & Signatures**:
  ```rust
  fn print_task_list ()
  ```

### `src/domain/catalog.rs` (Role: domain, Lines: 14)
- **Responsibility**: Core domain logic in src/domain/catalog.rs
- **Imports**: use crate :: domain :: task :: Task , use crate :: domain :: { core_tasks , desktop_tasks , maint_tasks , media_tasks , rice_tasks , tools_tasks } 
- **Public Functions & Signatures**:
  ```rust
  fn get_all_tasks () -> Vec < Task >
  ```

### `src/domain/core_tasks.rs` (Role: domain, Lines: 102)
- **Responsibility**: Core domain logic in src/domain/core_tasks.rs
- **Imports**: use crate :: domain :: task :: { Task , TaskCategory } 
- **Public Functions & Signatures**:
  ```rust
  fn get_tasks () -> Vec < Task >
  ```

### `src/domain/desktop_tasks.rs` (Role: domain, Lines: 71)
- **Responsibility**: Core domain logic in src/domain/desktop_tasks.rs
- **Imports**: use crate :: domain :: task :: { Task , TaskCategory } 
- **Public Functions & Signatures**:
  ```rust
  fn get_tasks () -> Vec < Task >
  ```

### `src/domain/exec_core.rs` (Role: domain, Lines: 158)
- **Responsibility**: Core domain logic in src/domain/exec_core.rs
- **Imports**: use anyhow :: Result , use std :: path :: PathBuf , use tokio :: sync :: mpsc , use crate :: infra :: cmd , use crate :: infra :: fs_util , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn execute (id : & str , tx : & mpsc :: Sender < RunnerEvent >) -> Result < () >
  ```

### `src/domain/exec_desktop.rs` (Role: domain, Lines: 148)
- **Responsibility**: Core domain logic in src/domain/exec_desktop.rs
- **Imports**: use anyhow :: Result , use std :: path :: PathBuf , use tokio :: sync :: mpsc , use crate :: domain :: exec_shell_bar , use crate :: infra :: cmd , use crate :: infra :: fs_util , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn execute (id : & str , tx : & mpsc :: Sender < RunnerEvent >) -> Result < () >
  ```

### `src/domain/exec_maint.rs` (Role: domain, Lines: 19)
- **Responsibility**: Core domain logic in src/domain/exec_maint.rs
- **Imports**: use anyhow :: Result , use tokio :: sync :: mpsc , use crate :: infra :: cmd , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn execute (id : & str , tx : & mpsc :: Sender < RunnerEvent >) -> Result < () >
  ```

### `src/domain/exec_media.rs` (Role: domain, Lines: 115)
- **Responsibility**: Core domain logic in src/domain/exec_media.rs
- **Imports**: use anyhow :: Result , use std :: path :: PathBuf , use tokio :: sync :: mpsc , use crate :: infra :: cmd , use crate :: infra :: fs_util , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn execute (id : & str , tx : & mpsc :: Sender < RunnerEvent >) -> Result < () >
  ```

### `src/domain/exec_rice.rs` (Role: domain, Lines: 110)
- **Responsibility**: Core domain logic in src/domain/exec_rice.rs
- **Imports**: use anyhow :: Result , use std :: path :: PathBuf , use tokio :: sync :: mpsc , use crate :: infra :: cmd , use crate :: infra :: fs_util , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn execute (id : & str , tx : & mpsc :: Sender < RunnerEvent >) -> Result < () >
  ```

### `src/domain/exec_shell_bar.rs` (Role: domain, Lines: 196)
- **Responsibility**: Core domain logic in src/domain/exec_shell_bar.rs
- **Imports**: use anyhow :: Result , use std :: path :: { Path , PathBuf } , use tokio :: sync :: mpsc , use crate :: infra :: cmd , use crate :: infra :: fs_util , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn execute (tx : & mpsc :: Sender < RunnerEvent >) -> Result < () >
  ```

### `src/domain/exec_tools.rs` (Role: domain, Lines: 110)
- **Responsibility**: Core domain logic in src/domain/exec_tools.rs
- **Imports**: use anyhow :: Result , use tokio :: sync :: mpsc , use crate :: infra :: cmd , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn execute (id : & str , tx : & mpsc :: Sender < RunnerEvent >) -> Result < () >
  ```

### `src/domain/executor.rs` (Role: domain, Lines: 18)
- **Responsibility**: Core domain logic in src/domain/executor.rs
- **Imports**: use anyhow :: Result , use tokio :: sync :: mpsc , use crate :: domain :: task :: { Task , TaskCategory } , use crate :: domain :: { exec_core , exec_desktop , exec_maint , exec_media , exec_rice , exec_tools } , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn execute_task (task : & Task , tx : & mpsc :: Sender < RunnerEvent >) -> Result < () >
  ```

### `src/domain/maint_tasks.rs` (Role: domain, Lines: 12)
- **Responsibility**: Core domain logic in src/domain/maint_tasks.rs
- **Imports**: use crate :: domain :: task :: { Task , TaskCategory } 
- **Public Functions & Signatures**:
  ```rust
  fn get_tasks () -> Vec < Task >
  ```

### `src/domain/media_tasks.rs` (Role: domain, Lines: 70)
- **Responsibility**: Core domain logic in src/domain/media_tasks.rs
- **Imports**: use crate :: domain :: task :: { Task , TaskCategory } 
- **Public Functions & Signatures**:
  ```rust
  fn get_tasks () -> Vec < Task >
  ```

### `src/domain/rice_tasks.rs` (Role: domain, Lines: 21)
- **Responsibility**: Core domain logic in src/domain/rice_tasks.rs
- **Imports**: use crate :: domain :: task :: { Task , TaskCategory } 
- **Public Functions & Signatures**:
  ```rust
  fn get_tasks () -> Vec < Task >
  ```

### `src/domain/task.rs` (Role: domain, Lines: 46)
- **Responsibility**: Core domain logic in src/domain/task.rs
- **Types & Enums**:
  ```rust
  pub enum TaskCategory
  pub struct Task
  ```
- **Public Functions & Signatures**:
  ```rust
  fn label (self) -> & 'static str
  fn all () -> & 'static [Self]
  ```

### `src/domain/tools_tasks.rs` (Role: domain, Lines: 95)
- **Responsibility**: Core domain logic in src/domain/tools_tasks.rs
- **Imports**: use crate :: domain :: task :: { Task , TaskCategory } 
- **Public Functions & Signatures**:
  ```rust
  fn get_tasks () -> Vec < Task >
  ```

### `src/domain.rs` (Role: domain, Lines: 19)
- **Responsibility**: Core domain logic in src/domain.rs
- **Imports**: pub use executor :: execute_task , pub use task :: { Task , TaskCategory } 

### `src/infra/cmd.rs` (Role: infra, Lines: 158)
- **Responsibility**: Core infra logic in src/infra/cmd.rs
- **Imports**: use anyhow :: { anyhow , Context , Result } , use std :: fs :: OpenOptions , use std :: io :: Write , use std :: path :: PathBuf , use std :: process :: Stdio , use tokio :: io :: { AsyncBufReadExt , BufReader } , use tokio :: process :: Command , use tokio :: sync :: mpsc , use crate :: infra :: runner :: RunnerEvent 
- **Public Functions & Signatures**:
  ```rust
  async fn run (program : & str , args : & [& str] , tx : & mpsc :: Sender < RunnerEvent > , task_id : & str ,) -> Result < () >
  async fn run_sudo (program : & str , args : & [& str] , tx : & mpsc :: Sender < RunnerEvent > , task_id : & str ,) -> Result < () >
  async fn run_curl_bash (url : & str , tx : & mpsc :: Sender < RunnerEvent > , task_id : & str) -> Result < () >
  async fn run_curl_bash_args (url : & str , script_args : & str , tx : & mpsc :: Sender < RunnerEvent > , task_id : & str ,) -> Result < () >
  async fn command_exists (name : & str) -> bool
  async fn run_pacman (packages : & [& str] , tx : & mpsc :: Sender < RunnerEvent > , task_id : & str ,) -> Result < () >
  ```

### `src/infra/fs_util.rs` (Role: infra, Lines: 50)
- **Responsibility**: Core infra logic in src/infra/fs_util.rs
- **Imports**: use anyhow :: { Context , Result } , use std :: fs :: { self , OpenOptions } , use std :: io :: Write , use std :: path :: Path 
- **Public Functions & Signatures**:
  ```rust
  fn ensure_line (path : & Path , line : & str) -> Result < () >
  fn write_file (path : & Path , content : & str) -> Result < () >
  fn write_executable_file (path : & Path , content : & str) -> Result < () >
  ```

### `src/infra/runner.rs` (Role: infra, Lines: 101)
- **Responsibility**: Core infra logic in src/infra/runner.rs
- **Imports**: use anyhow :: Result , use chrono :: Local , use std :: fs :: OpenOptions , use std :: io :: Write , use std :: path :: { Path , PathBuf } , use std :: time :: { Duration , Instant } , use tokio :: sync :: mpsc , use crate :: domain :: { execute_task , Task } 
- **Types & Enums**:
  ```rust
  pub enum RunnerEvent
  pub struct ProcessRunner
  ```
- **Public Functions & Signatures**:
  ```rust
  fn new () -> Result < Self >
  async fn run_task (& self , task : & Task , tx : mpsc :: Sender < RunnerEvent >) -> Result < bool >
  ```

### `src/infra/sudo.rs` (Role: infra, Lines: 38)
- **Responsibility**: Core infra logic in src/infra/sudo.rs
- **Imports**: use anyhow :: { bail , Context , Result } , use std :: process :: Command , use std :: sync :: atomic :: { AtomicBool , Ordering } , use std :: sync :: Arc , use std :: time :: Duration , use tokio :: time :: sleep 
- **Public Functions & Signatures**:
  ```rust
  fn warmup () -> Result < () >
  fn spawn_keepalive (running : Arc < AtomicBool >)
  ```

### `src/infra.rs` (Role: infra, Lines: 6)
- **Responsibility**: Core infra logic in src/infra.rs
- **Imports**: pub use runner :: { ProcessRunner , RunnerEvent } 

### `src/main.rs` (Role: general, Lines: 274)
- **Responsibility**: Core general logic in src/main.rs
- **Imports**: use std :: io :: { self , stdout } , use std :: sync :: atomic :: { AtomicBool , Ordering } , use std :: sync :: Arc , use std :: time :: { Duration , Instant } , use anyhow :: Result , use clap :: Parser , use crossterm :: event :: { self , Event , KeyCode , KeyEvent , KeyEventKind , KeyModifiers } , use crossterm :: terminal :: { disable_raw_mode , enable_raw_mode , EnterAlternateScreen , LeaveAlternateScreen , } , use crossterm :: ExecutableCommand , use ratatui :: backend :: CrosstermBackend , use ratatui :: Terminal , use tokio :: sync :: mpsc , use app :: { App , AppState , TaskStatus } , use cli :: Cli , use domain :: Task , use infra :: { ProcessRunner , RunnerEvent } 

### `src/ui/header.rs` (Role: tui, Lines: 78)
- **Responsibility**: Core tui logic in src/ui/header.rs
- **Imports**: use ratatui :: layout :: { Alignment , Rect } , use ratatui :: style :: { Modifier , Style } , use ratatui :: text :: { Line , Span } , use ratatui :: widgets :: { Block , BorderType , Borders , Paragraph , Tabs } , use ratatui :: Frame , use crate :: app :: App , use crate :: domain :: TaskCategory , use crate :: ui :: theme :: Theme 
- **Public Functions & Signatures**:
  ```rust
  fn render_banner (frame : & mut Frame , area : Rect)
  fn render_category_tabs (frame : & mut Frame , area : Rect , app : & App)
  ```

### `src/ui/log_drawer.rs` (Role: tui, Lines: 109)
- **Responsibility**: Core tui logic in src/ui/log_drawer.rs
- **Imports**: use ratatui :: layout :: { Alignment , Constraint , Direction , Layout , Rect } , use ratatui :: style :: { Modifier , Style } , use ratatui :: text :: { Line , Span } , use ratatui :: widgets :: { Block , BorderType , Borders , Clear , Paragraph } , use ratatui :: Frame , use crate :: ui :: theme :: Theme 
- **Public Functions & Signatures**:
  ```rust
  fn render (frame : & mut Frame , area : Rect , logs : & [String] , scroll : usize)
  ```

### `src/ui/running_view.rs` (Role: tui, Lines: 246)
- **Responsibility**: Core tui logic in src/ui/running_view.rs
- **Imports**: use ratatui :: layout :: { Alignment , Rect } , use ratatui :: style :: { Color , Modifier , Style } , use ratatui :: text :: { Line , Span } , use ratatui :: widgets :: { Block , BorderType , Borders , Gauge , List , ListItem , Paragraph , Scrollbar , ScrollbarOrientation , ScrollbarState , } , use ratatui :: Frame , use crate :: app :: { App , AppState , TaskItem , TaskStatus } , use crate :: ui :: theme :: Theme 
- **Public Functions & Signatures**:
  ```rust
  fn render_progress_bar (frame : & mut Frame , area : Rect , app : & App)
  fn render_body (frame : & mut Frame , area : Rect , app : & App)
  fn render_footer (frame : & mut Frame , area : Rect , app : & App)
  ```

### `src/ui/selection_view.rs` (Role: tui, Lines: 272)
- **Responsibility**: Core tui logic in src/ui/selection_view.rs
- **Imports**: use ratatui :: layout :: { Alignment , Constraint , Direction , Layout , Rect } , use ratatui :: style :: { Modifier , Style } , use ratatui :: text :: { Line , Span } , use ratatui :: widgets :: { Block , BorderType , Borders , List , ListItem , Paragraph , Scrollbar , ScrollbarOrientation , ScrollbarState , } , use ratatui :: Frame , use crate :: app :: { App , TaskItem } , use crate :: ui :: theme :: Theme 
- **Public Functions & Signatures**:
  ```rust
  fn render_body (frame : & mut Frame , area : Rect , app : & App)
  fn render_footer (frame : & mut Frame , area : Rect)
  ```

### `src/ui/theme.rs` (Role: tui, Lines: 17)
- **Responsibility**: Core tui logic in src/ui/theme.rs
- **Imports**: use ratatui :: style :: Color 
- **Types & Enums**:
  ```rust
  pub struct Theme
  ```

### `src/ui/view.rs` (Role: tui, Lines: 37)
- **Responsibility**: Core tui logic in src/ui/view.rs
- **Imports**: use ratatui :: layout :: { Constraint , Direction , Layout } , use ratatui :: Frame , use crate :: app :: { App , AppState } , use crate :: ui :: { header , log_drawer , running_view , selection_view } 
- **Public Functions & Signatures**:
  ```rust
  fn render (frame : & mut Frame , app : & App)
  ```

### `src/ui.rs` (Role: tui, Lines: 6)
- **Responsibility**: Core tui logic in src/ui.rs

## 4. Execution Lifecycle Trace
1. **Startup**: Entrypoint parses CLI flags & dispatches command.
2. **Execution**: Core domain logic processes inputs and evaluates rules.
3. **Persistence / I/O**: Domain logic calls infra for disk/terminal I/O.
4. **Exit**: Graceful termination with standard exit codes.

## 5. Verification Commands
```bash
cargo build --release --target x86_64-unknown-linux-gnu
cargo test --all-targets
cargo clippy --all-targets -- -D warnings && cargo fmt --check
```
