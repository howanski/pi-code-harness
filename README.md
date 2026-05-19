# PiCode

A containerized **pi.dev** harness with convenience scripts for both **interactive** and **autonomous** AI-assisted development workflows.

## What is this?

PiCode packages the [pi.dev](https://pi.dev) coding agent inside a Docker container, providing a ready-to-run environment with common development tools pre-installed. It supports two distinct modes of operation:

- **Interactive mode** — You work alongside the agent in real-time via the TUI.
- **Autonomous mode** — The agent plans and executes tasks on its own, cycling through planner → executor → critic rounds until completion.

## Quick Start

```bash
# Start the container (builds image if needed, then attaches to TUI)
./start.sh

# Stop the container
./stop.sh

# Clean up everything (stops container, clears sessions and git history)
./cleanup.sh
```

## How It Works

### Container Setup

The Docker image (`data/docker/Dockerfile`) is based on Alpine Linux and includes:

- **pi.dev** coding agent (installed via the official install script)
- **pi-skills** extension (git:github.com/badlogic/pi-skills)
- Common development toolchains: `git`, `npm`, `vim`, `rust/cargo`, `php`, `go`, `java/gradle`, `android-tools`, `composer`

Volumes are mounted for:
- `data/config/` → Persistent pi configuration and session history
- `workdir/` → Your working directory (shared between host and container)

### Scripts Overview

| Script | Purpose |
|---|---|
| `start.sh` | Builds the container, starts it, and attaches to the internal TUI |
| `stop.sh` | Stops the container |
| `attach.sh` | Attaches an interactive bash shell to the running container |
| `cleanup.sh` | Stops the container, removes session data and git history |
| `create_plan_and_go.sh` | Full autonomous workflow: edit a sketch, stop and restart the container |

## Modes of Operation

### Interactive Mode

When the container starts and no `SKETCH_PICODE.md` or `TODO_PICODE.md` file exists in `workdir/`, it defaults to interactive mode. Inside the TUI you can:

```bash
pi        # Start a new session
pi -r     # Open session selector (pick an existing session)
pi -c     # Continue the last session
```

### Autonomous Mode

Autonomous mode is triggered by placing a `SKETCH_PICODE.md` file in the `workdir/` directory before starting the container. The workflow follows three phases:

#### 1. Planning Phase

The agent reads `SKETCH_PICODE.md` (your high-level description of what to build) and produces a `TODO_PICODE.md` with a detailed step-by-step plan. If missing tools or prerequisites are detected, it creates `MISSING_REQUIREMENTS.md` instead.

#### 2. Execution Loop

Once `TODO_PICODE.md` exists, the agent enters an execution loop:

- **Executor** — Advances development by one logical step, then updates `TODO_PICODE.md`
- **Critic** — Reviews the plan and progress, correcting `TODO_PICODE.md` if needed
- This cycle repeats until `TODO_PICODE.md` is removed (signaling completion)

#### 3. Handoff

By default, the agent pauses after the initial planning phase (`exitAfterInitialPlan=1` in `entrypoint.bash`), giving you a chance to review the plan before execution begins. Set this to `0` to run fully autonomously.

### Using `create_plan_and_go.sh`

This convenience script streamlines the autonomous workflow:

```bash
./create_plan_and_go.sh
```

1. Creates a `SKETCH_PICODE.md` in `workdir/`
2. Opens it in `vim` so you can describe what you want built
3. Stops the container (if running)
4. Starts it fresh — triggering autonomous mode with your sketch

## Configuration

### Container Settings

Edit `compose.yml` to adjust:
- User ID mapping (`user: "1000:1000"`)
- Volume mounts
- Log rotation settings
- Restart policy

### Autonomous Behavior

Edit `data/docker/entrypoint.bash` to tune:
- `useCritic=1` — Enable/disable the critic review step (set to `0` to skip)
- `exitAfterInitialPlan=1` — Pause after planning for human review (set to `0` for full autonomy)
- Prompt messages (`message_planner`, `message_executor`, `message_critic`) — Customize the instructions given to the agent at each phase

## Project Structure

```
.
├── compose.yml              # Docker Compose configuration
├── start.sh                 # Start container + attach to TUI
├── stop.sh                  # Stop container
├── attach.sh                # Attach shell to running container
├── cleanup.sh               # Stop container + clear sessions/git
├── create_plan_and_go.sh    # Quick autonomous workflow launcher
├── data/
│   ├── config/              # Persistent pi config & sessions (mounted)
│   └── docker/
│       ├── Dockerfile       # Container image definition
│       ├── entrypoint.bash  # Autonomous/interactive mode logic
│       └── start.bash       # TUI bootstrap script
└── workdir/                 # Working directory (mounted into container)
```

## Tips

- **Review before running** — Always check `TODO_PICODE.md` after the planning phase before letting the agent run unattended.
- **Use the critic** — The critic step helps catch missteps early. Keep `useCritic=1` for complex tasks.
- **Session persistence** — Pi sessions are saved in `data/config/agent/sessions/`. Use `pi -r` to resume a previous session.
- **Clean slate** — Run `./cleanup.sh` to reset everything and start fresh.
