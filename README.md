# dotfiles

Manual, clean configurations and scripts for an Arch-based (Omarchy) system.

## Structure

```text
dotfiles/
├── install.sh
└── scripts/
    └── install_anime4k.sh
```

## Utility Scripts

| Script | Description |
| :--- | :--- |
| `install_anime4k.sh` | Downloads and configures Anime4K GLSL shaders for `mpv`. |

## Quick Start

### 1. Clone

```bash
git clone git@github.com:Praveensenpai/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Install Everything

Run the master install script to execute all scripts in the `scripts/` directory automatically:

```bash
./install.sh
```

*(Alternatively, you can run individual scripts manually from the `scripts/` folder).*