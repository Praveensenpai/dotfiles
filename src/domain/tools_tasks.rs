use crate::domain::task::{Task, TaskCategory};

/// Returns tasks belonging to the tools category.
pub fn get_tasks() -> Vec<Task> {
    let mut tasks = get_cli_tools();
    tasks.extend(get_system_tools());
    tasks
}

fn get_cli_tools() -> Vec<Task> {
    vec![
        Task {
            id: "install_antigravity_cli",
            name: "Install Antigravity CLI",
            description: "Installs the official Antigravity coding assistant CLI",
            category: TaskCategory::Tools,
            script_filename: "install_antigravity_cli.sh",
            script_content: include_str!("../../scripts/install_antigravity_cli.sh"),
            default_selected: true,
        },
        Task {
            id: "install_codex",
            name: "Install Codex CLI",
            description: "Installs OpenAI Codex command line interface",
            category: TaskCategory::Tools,
            script_filename: "install_codex.sh",
            script_content: include_str!("../../scripts/install_codex.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_agym",
            name: "Setup agym CLI",
            description: "Deploys agym binary and configures shell aliases",
            category: TaskCategory::Tools,
            script_filename: "setup_agym.sh",
            script_content: include_str!("../../scripts/setup_agym.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_cxm",
            name: "Codex Account Switcher (cxm)",
            description: "Installs Codex account switcher tool",
            category: TaskCategory::Tools,
            script_filename: "setup_cxm.sh",
            script_content: include_str!("../../scripts/setup_cxm.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_sys_chronicle",
            name: "Sys Chronicle Activity Monitor",
            description: "Installs system activity logger and TUI dashboard",
            category: TaskCategory::Tools,
            script_filename: "setup_sys_chronicle.sh",
            script_content: include_str!("../../scripts/setup_sys_chronicle.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_toss",
            name: "Toss TUI Trash Manager",
            description: "Installs Rust-based FreeDesktop compliant trash manager",
            category: TaskCategory::Tools,
            script_filename: "setup_toss.sh",
            script_content: include_str!("../../scripts/setup_toss.sh"),
            default_selected: true,
        },
    ]
}

fn get_system_tools() -> Vec<Task> {
    vec![
        Task {
            id: "setup_dns",
            name: "DNS Resolver Setup",
            description: "Configures persistent systemd-resolved DNS servers",
            category: TaskCategory::Tools,
            script_filename: "setup_dns.sh",
            script_content: include_str!("../../scripts/setup_dns.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_mtu_fix",
            name: "Network MTU Optimization",
            description: "Applies and persists NetworkManager MTU settings",
            category: TaskCategory::Tools,
            script_filename: "setup_mtu_fix.sh",
            script_content: include_str!("../../scripts/setup_mtu_fix.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_tcp_keepalive",
            name: "TCP Keepalive Tuning",
            description: "Tunes sysctl TCP keepalive intervals for network stability",
            category: TaskCategory::Tools,
            script_filename: "setup_tcp_keepalive.sh",
            script_content: include_str!("../../scripts/setup_tcp_keepalive.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_tmux_resurrect",
            name: "Tmux Resurrect Auto-Save",
            description: "Configures TPM & tmux-resurrect session daemon",
            category: TaskCategory::Tools,
            script_filename: "setup_tmux_resurrect.sh",
            script_content: include_str!("../../scripts/setup_tmux_resurrect.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_ufw",
            name: "UFW Firewall Security",
            description: "Configures sensible firewall rules and enables service",
            category: TaskCategory::Tools,
            script_filename: "setup_ufw.sh",
            script_content: include_str!("../../scripts/setup_ufw.sh"),
            default_selected: true,
        },
        Task {
            id: "setup_vnstat_service",
            name: "Vnstat Traffic Monitor",
            description: "Enables vnstat lightweight network traffic monitoring daemon",
            category: TaskCategory::Tools,
            script_filename: "setup_vnstat_service.sh",
            script_content: include_str!("../../scripts/setup_vnstat_service.sh"),
            default_selected: true,
        },
    ]
}
