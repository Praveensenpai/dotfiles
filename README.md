# dotfiles

Manual, clean configurations for an Arch-based (Omarchy) system.

## Structure

```text
dotfiles/
├── .config/
│   ├── hypr/      # Tiling WM configs
│   ├── nvim/      # Editor setup
│   └── mpv/       # Media player & shaders
└── scripts/
    └── install_anime4k.sh
```

## Utility Scripts

| Script | Description |
| :--- | :--- |
| `install_anime4k.sh` | Downloads and configures Anime4K GLSL shaders for `mpv`. |

## Quick Start

Clone via SSH and symlink the configurations. GNU `stow` is recommended.

### 1. Clone

```bash
git clone https://github.com/Praveensenpai/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Deploy

**Using GNU Stow:**

```bash
stow .
```
*(Ensure your dotfiles directory structure matches your home directory structure if using `stow .`, or target specific directories like `stow -t ~/.config .config`)*

**Manual Symlinking:**

```bash
ln -s ~/dotfiles/.config/hypr ~/.config/hypr
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
ln -s ~/dotfiles/.config/mpv ~/.config/mpv
```