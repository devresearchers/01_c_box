Below is the **complete, self-contained CLI spec**—no gaps or second “full” parser in the entrypoint. It shows:

1. **Four flag buckets**
2. **One unified Bash 3.2–compatible parser + dispatcher** in `claudebox.sh`
3. **Minimal entrypoint handling** of only the **Control** flags
4. A **full three-bucket flag table** for every switch

---

# ClaudeBox CLI: Single Parser + Minimal Entrypoint

## 1. Four Buckets

```bash
# 1) Host-only flags
HOST_ONLY=(--verbose rebuild tmux)

# 2) Control flags (environmental for container)
CONTROL=(--enable-sudo --disable-firewall)

# 3) Script commands (handled entirely on host)
SCRIPT_CMDS=(shell create slot slots revoke profiles projects profile info help -h --help add remove install denylist)

# 4) Pass-through (everything else → Claude CLI)
PASS_THROUGH=()
```

---

## 2. Unified Parser & Dispatcher (`claudebox.sh`)

```bash
#!/usr/bin/env bash
# Bash 3.2 compatible, single parsing location.

main() {
  # A) Globals
  export PROJECT_DIR="$(pwd)"
  IMAGE_NAME="claudebox-$(basename "$PROJECT_DIR")"

  # B) Load default flags
  DEFAULT_FLAGS=()
  if [[ -f "$HOME/.claudebox/default-flags" ]]; then
    while IFS= read -r f; do [[ -n $f ]] && DEFAULT_FLAGS+=("$f"); done \
      < "$HOME/.claudebox/default-flags"
  fi

  # C) Buckets setup
  HOST_ONLY=(--verbose rebuild tmux)
  CONTROL=(--enable-sudo --disable-firewall)
  SCRIPT_CMDS=(shell create slot slots revoke profiles projects profile info help -h --help add remove install denylist)
  host_flags=(); control_flags=(); script_flags=()

  # D) Single parse loop
  all_args=("${DEFAULT_FLAGS[@]}" "$@")
  for arg in "${all_args[@]}"; do
    if [[ " ${HOST_ONLY[*]} " == *" $arg "* ]]; then
      host_flags+=("$arg")
    elif [[ " ${CONTROL[*]} " == *" $arg "* ]]; then
      control_flags+=("$arg")
    elif [[ ${#script_flags[@]} -eq 0 && " ${SCRIPT_CMDS[*]} " == *" $arg "* ]]; then
      script_flags+=("$arg")
    else
      PASS_THROUGH+=("$arg")
    fi
  done

  # E) Consume host-only flags
  for f in "${host_flags[@]}"; do
    case "$f" in
      --verbose)        export VERBOSE=true ;;
      rebuild)          REBUILD=true       ;;
      tmux)             export CLAUDEBOX_WRAP_TMUX=true ;;
    esac
  done

  # F) Handle rebuild once
  if [[ "${REBUILD:-}" == true ]]; then
    docker rmi -f "$IMAGE_NAME" 2>/dev/null || true
    unset REBUILD
  fi

  # G) Build image if missing
  if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    build_docker_image
  fi

  # H) Script command dispatch
  if [[ ${#script_flags[@]} -gt 0 ]]; then
    cmd=${script_flags[0]}
    dispatch_host "$cmd" "${PASS_THROUGH[@]}"
    rc=$?
    # If handler returns 2 → image needed
    if [[ $rc -eq 2 ]]; then
      build_docker_image
      dispatch_host "$cmd" "${PASS_THROUGH[@]}"
    fi
    exit $?
  fi

  # I) Default: run container
  docker run -it --rm \
    -e VERBOSE="${VERBOSE:-false}" \
    -e CLAUDEBOX_WRAP_TMUX="${CLAUDEBOX_WRAP_TMUX:-false}" \
    "$IMAGE_NAME" "${control_flags[@]}" "${PASS_THROUGH[@]}"
}

main "$@"
```

---

## 3. Docker Entrypoint (`docker-entrypoint.sh`)

```bash
#!/usr/bin/env bash
# **Minimal** handling of *only* Control flags.
# Everything else in "$@" is passed directly to `claude`.

ENABLE_SUDO=false
DISABLE_FIREWALL=false
CLAUDE_ARGS=()

for arg in "$@"; do
  case "$arg" in
    --enable-sudo)      ENABLE_SUDO=true        ;;
    --disable-firewall) DISABLE_FIREWALL=true   ;;
    *)                  CLAUDE_ARGS+=("$arg")  ;;
  esac
done

# Apply firewall logic
if [[ "$DISABLE_FIREWALL" != true ]]; then
  /home/claude/init-firewall
fi

# Optionally enable sudo inside container
if [[ "$ENABLE_SUDO" == true ]]; then
  echo "Sudo enabled inside container"
  # (any sudo config steps here)
fi

# Finally launch Claude with all the pass-through args
exec claude "${CLAUDE_ARGS[@]}"
```

> **Note:**
>
> * There is **no second full parser** in the entrypoint—only a tiny `case` on the two Control flags.
> * **All** other flags/commands were handled and classified by `claudebox.sh` before `docker run`, so the entrypoint never needs to re-parse anything beyond `--enable-sudo / --disable-firewall`.

---

## 4. Complete Three-Bucket Flag Table

| Flag/Switch              | Bucket         | Handled In     | Action Taken                                          | Forwarded? |
| ------------------------ | -------------- | -------------- | ----------------------------------------------------- | ---------- |
| `--verbose`              | Host-only      | parse loop (D) | `VERBOSE=true`; never forwarded                       | No         |
| `rebuild`                | Host-only      | parse loop (D) | `REBUILD=true`; removed; purges image                 | No         |
| `tmux`                   | Host-only      | parse loop (D) | `CLAUDEBOX_WRAP_TMUX=true`; removed                   | No         |
| `--enable-sudo`          | Control        | parse loop (D) | Adds to `control_flags[]`                             | Yes        |
| `--disable-firewall`     | Control        | parse loop (D) | Adds to `control_flags[]`                             | Yes        |
| `shell`                  | Script command | parse loop (D) | `dispatch_host shell`, handled by `_cmd_shell`        | No         |
| `create`                 | Script command | parse loop (D) | `dispatch_host create`, handled by `_cmd_create`      | No         |
| `slot` / `slots`         | Script command | parse loop (D) | `dispatch_host slot/slots`, handled by `_cmd_slot(s)` | No         |
| `revoke`                 | Script command | parse loop (D) | `dispatch_host revoke`, handled by `_cmd_revoke`      | No         |
| `profiles`               | Script command | parse loop (D) | `dispatch_host profiles`                              | No         |
| `projects`               | Script command | parse loop (D) | `dispatch_host projects`                              | No         |
| `profile`                | Script command | parse loop (D) | `dispatch_host profile`                               | No         |
| `add` / `remove`         | Script command | parse loop (D) | `dispatch_host add/remove`                            | No         |
| `install`                | Script command | parse loop (D) | `dispatch_host install`                               | No         |
| `info`                   | Script command | parse loop (D) | `dispatch_host info`                                  | No         |
| `denylist`              | Script command | parse loop (D) | `dispatch_host denylist`                             | No         |
| `help` / `-h` / `--help` | Script command | parse loop (D) | `dispatch_host help` → `show_help`; exit              | No         |
| `update`                 | Pass-through   | parse loop (D) | Left in `PASS_THROUGH[]`, runs inside container       | Yes        |
| `config`                 | Pass-through   | parse loop (D) | Left in `PASS_THROUGH[]`, runs inside container       | Yes        |
