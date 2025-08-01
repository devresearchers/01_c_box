# ClaudeBox CLI Implementation

## Overview

The ClaudeBox CLI now uses a clean four-bucket architecture that parses all arguments in a single location, eliminating the previous scattered parsing and unpredictable behavior.

## Architecture

### 1. Four Flag Buckets

All arguments are classified into exactly one of four buckets:

1. **Host-only flags** - Processed and consumed by the host script
2. **Control flags** - Environmental settings passed to container
3. **Script commands** - Commands handled entirely on host
4. **Pass-through** - Everything else forwarded to Claude CLI

### 2. Single Parser (`lib/cli.sh`)

```bash
# Four flag buckets (Bash 3.2 compatible - no associative arrays)
readonly HOST_ONLY_FLAGS=(--verbose rebuild tmux)
readonly CONTROL_FLAGS=(--enable-sudo --disable-firewall)
readonly SCRIPT_COMMANDS=(shell create slot slots revoke profiles projects profile info help -h --help add remove install denylist)

parse_cli_args() {
    # Single parsing loop - each arg goes into exactly ONE bucket
    for arg in "${all_args[@]}"; do
        if [[ " ${HOST_ONLY_FLAGS[*]} " == *" $arg "* ]]; then
            host_flags+=("$arg")
        elif [[ " ${CONTROL_FLAGS[*]} " == *" $arg "* ]]; then
            control_flags+=("$arg")
        elif [[ "$found_script_command" == "false" ]] && [[ " ${SCRIPT_COMMANDS[*]} " == *" $arg "* ]]; then
            script_command="$arg"
            found_script_command=true
        else
            pass_through+=("$arg")
        fi
    done
}
```

### 3. Main Script Flow

1. **Parse once**: All arguments (defaults + user) parsed in single location
2. **Process host flags**: Sets environment variables (VERBOSE, REBUILD, etc.)
3. **Docker checks**: Ensure Docker is installed and running
4. **Initialize project**: Set up project directory structure
5. **Handle rebuild**: If requested, force image rebuild
6. **Check requirements**: Determine if command needs Docker/slot
7. **Build if needed**: Build Docker image if required
8. **Single dispatch**: Either run script command or launch container

### 4. Docker Entrypoint

The container entrypoint has minimal logic - only extracts control flags:

```bash
# Single parsing loop - only extract control flags
for arg in "$@"; do
    case "$arg" in
        --enable-sudo)      ENABLE_SUDO=true ;;
        --disable-firewall) DISABLE_FIREWALL=true ;;
        *)                  CLAUDE_ARGS+=("$arg") ;;
    esac
done
```

## Complete Flag Reference

| Flag/Switch | Bucket | Handled In | Action | Forwarded? |
|-------------|---------|------------|---------|------------|
| `--verbose` | Host-only | CLI parser | Sets VERBOSE=true | No |
| `rebuild` | Host-only | CLI parser | Sets REBUILD=true | No |
| `tmux` | Host-only | CLI parser | Sets CLAUDEBOX_WRAP_TMUX=true | No |
| `--enable-sudo` | Control | Entrypoint | Enables sudo in container | Yes |
| `--disable-firewall` | Control | Entrypoint | Disables firewall | Yes |
| `shell` | Script command | Host | Launches interactive shell | No |
| `create` | Script command | Host | Creates new slot | No |
| `slot`/`slots` | Script command | Host | Manages slots | No |
| `revoke` | Script command | Host | Removes slots | No |
| `profiles` | Script command | Host | Manages profiles | No |
| `projects` | Script command | Host | Lists projects | No |
| `profile` | Script command | Host | Shows current profile | No |
| `add`/`remove` | Script command | Host | Package management | No |
| `install` | Script command | Host | Installs packages | No |
| `denylist` | Script command | Host | Manages firewall denylist | No |
| `info` | Script command | Host | Shows project info | No |
| `help`/`-h`/`--help` | Script command | Host | Shows help | No |
| `update` | Pass-through | Container | Updates Claude CLI | Yes |
| `config` | Pass-through | Container | Configures Claude | Yes |
| Everything else | Pass-through | Container | Claude CLI args | Yes |

## Key Improvements

### 1. Predictable Behavior
- Arguments always parsed the same way
- `--verbose` no longer changes program flow
- `rebuild` properly continues to next command

### 2. Clean Separation
- Host-only flags never reach container
- Control flags handled minimally in entrypoint
- Script commands execute entirely on host
- Claude args pass through untouched

### 3. Single Source of Truth
- All parsing in `lib/cli.sh`
- No scattered flag checks throughout codebase
- Easy to understand and maintain

### 4. Bash 3.2 Compatible
- Uses arrays instead of associative arrays
- Works on both macOS and Linux
- No GNU-specific features

## Testing

Test the implementation with various flag combinations:

```bash
# Basic commands
claudebox --verbose help
claudebox rebuild shell
claudebox --enable-sudo shell
claudebox tmux shell

# Combined flags
claudebox --verbose rebuild shell
claudebox --verbose --enable-sudo --disable-firewall shell

# Pass-through to Claude
claudebox --verbose chat "Hello"
claudebox update
claudebox config set theme dark
```

## Migration Notes

The new implementation maintains full backward compatibility while fixing the broken behaviors:
- All existing commands work as before
- Flags are processed more predictably
- No more hidden dependencies on flag presence
- `--verbose` is purely for debug output

This clean architecture makes the CLI maintainable and extensible for future enhancements.