# dmenu_run2 - Enhanced Application Launcher

A customizable application launcher that extends the functionality of `dmenu_run` by allowing custom commands, dynamic script outputs, and alias support. Perfect for i3 window manager users who want more than just application launching.

## Features

- **Custom Commands**: Add frequently used commands without modifying system-wide configurations
- **Dynamic Scripts**: Integration of scripts that generate entries on demand
- **Alias Support**: Define and use aliases in your command list
- **Cross-Platform**: Seamless support for both X11 (dmenu) and Wayland (bemenu)
- **FZF Integration**: Provides FZF environment variable for nested fuzzy finding
- **Extensible**: Easy to extend with your own scripts and commands

## Installation

### Prerequisites

- `dmenu` (for X11) or `bemenu` (for Wayland)
- Shell environment (bash, zsh, etc.)

### Quick Install

1. Save the script as `dmenu_run2`
2. Make it executable:
```bash
chmod +x dmenu_run2
```
3. Place it in your PATH or use the full path in your window manager config

## Configuration

### Environment Variables

- **`DMENU_RUN_COMMANDS`**: Path to a file containing custom commands (one per line)
- **`DMENU_RUN_BIN`**: Path to a directory containing executable scripts that output commands
- **`DMENU`**: Override the default dmenu command (default: `dmenu`, `bemenu` on Wayland)
- **`DMENU_NO_PATH`**: Set to "true" to exclude system PATH applications
- **`FZF`**: Automatically set to current dmenu command for nested script usage

### Example Setup

```bash
# In your shell profile or window manager config
export DMENU_RUN_COMMANDS="$HOME/.config/dmenu/commands"
export DMENU_RUN_BIN="$HOME/.config/dmenu/scripts"
```

## Usage

### Basic Usage

```bash
# Simple launch
./dmenu_run2

# With dmenu options
./dmenu_run2 -p 'Run:' -i -l 10
```

### i3 Window Manager Integration

Add to your i3 config (`~/.config/i3/config`):

```
bindsym $mod+d exec DMENU_RUN_BIN="$HOME/.config/dmenu/scripts" DMENU_RUN_COMMANDS="$HOME/.config/dmenu/commands" /path/to/dmenu_run2 -p 'Run:'
```

## Custom Commands File

Create a file at `$DMENU_RUN_COMMANDS` with your frequently used commands:

```bash
# Network commands
nmcli radio wifi on
nmcli radio wifi off
systemctl suspend
systemctl poweroff

# Aliases
alias wifi-on="nmcli radio wifi on"
alias wifi-off="nmcli radio wifi off"
alias suspend="systemctl suspend"
```

### Alias Format

Aliases should follow this format:
```bash
alias name="command --with-args"
alias "name with spaces"="command2"
```

The script will extract the alias name for display and resolve to the actual command when selected.

## Dynamic Scripts

Check the [examples/scripts](examples/scripts/) directory for additional example scripts:
- **[examples/scripts/network](examples/scripts/network)**: NetworkManager connection management
- **[examples/scripts/bluetooth](examples/scripts/bluetooth)**: Bluetooth device control
- **[examples/scripts/tmux](examples/scripts/tmux)**: Tmux script loader

All scripts in the repository are ready to use - just copy them to your `$DMENU_RUN_BIN` directory and make them executable.

## FZF Integration

Scripts executed through dmenu_run2 can use the `FZF` environment variable to maintain consistency:

```bash
#!/bin/sh
# File: ~/.config/dmenu/scripts/dictionary

fuzzy_find="${FZF:-fzf}"
$fuzzy_find < /usr/share/dict/words
```

When called from dmenu_run2, this will use dmenu. When called directly, it falls back to fzf. That way, you can use the same script in different contexts without modification.

## Advanced Configuration

### Custom dmenu Command

Override the default dmenu command:

```bash
export DMENU="rofi -dmenu -i -no-fixed-num-lines -no-show-icons"
```

### Exclude System Applications

To only show custom commands and scripts:

```bash
export DMENU_NO_PATH="true"
```

## Examples

### Complete Setup

1. Create directories:

```bash
mkdir -p ~/.config/dmenu/scripts
```

2. Create commands file `~/.config/dmenu/commands`:

```bash
# System controls
systemctl suspend
systemctl poweroff
systemctl reboot

# Network
nmcli radio wifi on
nmcli radio wifi off

# Aliases
alias lock="i3lock -c 000000"
alias screenshot="scrot ~/Pictures/screenshot_%Y%m%d_%H%M%S.png"
```

3. Create a network script ~/.config/dmenu/scripts/network:

```bash
#!/bin/sh
nmcli -f active,name connection show | awk 'BEGIN { FS="  +" } NR > 1 {
  if ($1 == "no") {
    printf("alias %s up=nmcli connection up \"%s\"\n", $2, $2)
  } else {
    printf("alias %s down=nmcli connection down \"%s\"\n", $2, $2)
  }
}'

```bash
chmod +x ~/.config/dmenu/scripts/network
```

4. Add to i3 config:

```i3config
bindsym $mod+d exec DMENU_RUN_BIN="$HOME/.config/dmenu/scripts" DMENU_RUN_COMMANDS="$HOME/.config/dmenu/commands" dmenu_run2 -p 'Run:'
```

## Troubleshooting

### Scripts Not Executing

Ensure scripts in `DMENU_RUN_BIN` are executable:
```bash
chmod +x ~/.config/dmenu/scripts/*
```

### Commands Not Appearing

Check that your files exist and are readable:
```bash
ls -la "$DMENU_RUN_COMMANDS"
ls -la "$DMENU_RUN_BIN"
```

### Wayland Issues

The script automatically detects Wayland and uses `bemenu`. Install it if needed:
```bash
# Ubuntu/Debian
sudo apt install bemenu

# Arch Linux
sudo pacman -S bemenu
```

## Related Links

- [Original blog post](https://ajnasz.hu/blog/20250213/enhancing-dmenu_run--a-customizable-application-launcher-for-i3)
- [GitHub Gist](https://gist.github.com/Ajnasz/4f1586775d4c6edd3666fc376d4b3296)
- [dmenu](https://tools.suckless.org/dmenu/)
- [bemenu](https://github.com/Cloudef/bemenu)
- [i3 window manager](https://i3wm.org/)

## Interactive Pipeline Script (`dmenu_script`)

The repository also includes `dmenu_script`, a utility that creates interactive command pipelines where each dmenu selection becomes input for the next command execution.

### How It Works

The script creates a loop where:
1. An executable script generates options
2. User selects an option via dmenu
3. The selection becomes input to the script for the next iteration
4. Process continues until empty selection or command completion

### Usage

```bash
./dmenu_script <executable_file> <dmenu_options>
```

### Example Script

Create an interactive script that responds to selections ~/.config/dmenu/scripts/interactive_example:

```bash
#!/usr/bin/env sh

case "$1" in
  "")
    # Initial menu
    printf 'System\nNetwork\nApplications'
    ;;
  "System")
    printf 'Lock Screen\nSuspend\nReboot\nShutdown'
    ;;
  "Network")
    printf 'WiFi On\nWiFi Off\nConnections'
    ;;
  "Applications")
    printf 'Firefox\nTerminal\nText Editor'
    ;;
  "Lock Screen")
    i3lock -c 000000
    exit 0
    ;;
  "Suspend")
    systemctl suspend
    exit 0
    ;;
  "WiFi On")
    nmcli radio wifi on
    exit 0
    ;;
  "Firefox")
    firefox &
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
esac
```

```bash
chmod +x ~/.config/dmenu/scripts/interactive_example
```

### Running Interactive Scripts

```bash
# Basic usage
./dmenu_script ~/.config/dmenu/scripts/interactive_example

# With dmenu options
./dmenu_script ~/.config/dmenu/scripts/interactive_example -p "Select:" -l 10

# i3 binding
bindsym $mod+i exec /path/to/dmenu_script ~/.config/dmenu/scripts/interactive_example -p "Menu:"
```

### Script Requirements

Interactive scripts should:
- Accept an optional argument (`$1`)
- Output selectable options (one per line)
- Handle the empty case (`""`) for initial menu
- Exit with status 0 when a final action is performed
- Exit with non-zero status on errors

### Advanced Example

Here's a system monitor that demonstrates the interactive pipeline concept ~/.config/dmenu/scripts/system_monitor:

```bash
#!/usr/bin/env sh

case "$1" in
    ""|"Back to main menu")
        # Main menu
        echo "CPU Usage"
        echo "Memory Usage"
        echo "Disk Usage"
        echo "Network"
        echo "Processes"
        echo "Quit"
        ;;
    "CPU Usage")
        # Show CPU info and options
        top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,/% CPU usage/'
        echo "Show top CPU processes"
        echo "Back to main menu"
        echo "Quit"
        ;;
    "Memory Usage")
        # Show memory info and options
        free -h | grep "Mem:" | awk '{printf "Memory: %s used / %s total\n", $3, $2}'
        echo "Show memory-heavy processes"
        echo "Back to main menu"
        echo "Quit"
        ;;
    "Disk Usage")
        # Show disk usage
        df -h / | tail -1 | awk '{printf "Root: %s used / %s total (%s)\n", $3, $2, $5}'
        echo "Back to main menu"
        echo "Quit"
        ;;
    "Network")
        # Show network info
        echo "Active connections:"
        ss -tuln | wc -l | awk '{printf "%d active connections\n", $1-1}'
        echo "Show network connections"
        echo "Back to main menu"
        echo "Quit"
        ;;
    "Show top CPU processes")
        ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "%s: %.1f%%\n", $11, $3}'
        echo "Back to main menu"
        echo "Quit"
        ;;
    "Show memory-heavy processes")
        ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "%s: %.1f%%\n", $11, $4}'
        echo "Back to main menu"
        ;;
    "Quit")
        exit 0
        ;;
    *)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
esac
```

```bash
chmod +x ~/.config/dmenu/scripts/system_monitor
```

This example shows practical navigation:
1. **First run**: Shows main system categories
2. **User selects**: `Memory Usage`
3. **Second run**: Shows current memory usage + options to drill down
4. **User selects**: `Show memory-heavy processes`
5. **Third run**: Shows top memory-consuming processes + actions

Each selection navigates deeper into system information while maintaining context.

## License

MIT License - See the script header for full license text.
