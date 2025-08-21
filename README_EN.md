# Task Planner

<div align="center">
  <img src="logo.png" alt="Task Planner Logo" width="400">
</div>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Claude AI](https://img.shields.io/badge/AI-Claude-blue.svg)](https://claude.ai/)

A simple AI-powered task planner - A Bash tool that provides step-by-step support from requirements to implementation

> [English README](README_EN.md) | [日本語 README](README.md)

## Overview

Task Planner supports the entire process from requirement definition to implementation through the following 3 stages:

1. **Plan**: Create detailed implementation plans based on requirements
2. **Task**: Generate specific tasks based on the plan
3. **Execute**: Execute tasks and output deliverables in PR format

## Features

- 🎯 Automatically generate plans, tasks, and implementations step-by-step from requirements
- 🤖 Integration with Claude AI
- 📊 Visual progress display (spinner, status, elapsed time)
- 📝 Structured document generation (PLAN.md → TASK.md → PR.md)
- 📋 Task list management
- ⚙️ Customizable prompt templates (config/ directory)

## Requirements

- Bash (macOS/Linux)
- Claude CLI
- jq (for JSON parsing, optional)

## Setup

### Basic Setup

1. Make the script executable:

```bash
chmod +x task-planner.sh
```

2. Configure AI tool:

```bash
./task-planner.sh config claude    # Use Claude CLI
```

### Integration into Existing Projects

Steps to integrate Task Planner into existing projects:

#### 1. Copy Files

```bash
# Navigate to your existing project directory
cd /path/to/your/project

# Copy Task Planner files
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/task-planner.sh
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/plan-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/task-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/execute-prompt.md

# Or copy from this repository
cp /path/to/task_planner/task-planner.sh .
cp -r /path/to/task_planner/config .
```

#### 2. Set Execution Permissions

```bash
chmod +x task-planner.sh
```

#### 3. Verify Directory Structure

Example project structure after integration:

```
your-project/
├── src/                  # Existing source code
├── docs/                 # Existing documentation
├── task-planner.sh       # ✅ Added
├── config/               # ✅ Added
│   ├── plan-prompt.md
│   ├── task-prompt.md
│   └── execute-prompt.md
└── AI_TASKS/             # ✅ Auto-created during execution
    └── [task-name]/
        ├── PLAN.md
        ├── TASK.md
        └── PR.md
```

#### 4. Configure .gitignore (Recommended)

```bash
# Add to .gitignore (whether to manage AI_TASKS directory depends on project)
echo "AI_TASKS/" >> .gitignore

# Or exclude only work-in-progress tasks
echo "AI_TASKS/*/plan_prompt.txt" >> .gitignore
echo "AI_TASKS/*/stream_output.json" >> .gitignore
```

#### 5. Project-Specific Customization

```bash
# Customize prompts to match your project's technology stack
vim config/plan-prompt.md
vim config/task-prompt.md
vim config/execute-prompt.md
```

## Usage

### 3-Stage Workflow

Task Planner progresses from requirements to implementation through the following 3 stages:

#### 1. Plan Stage - Requirements Analysis & Design

```bash
./task-planner.sh plan "Implement login functionality for web app" login-feature
```

- **Input**: Requirements text and task name
- **Process**: AI analyzes requirements and creates detailed implementation plan
- **Output**: `PLAN.md` - Architecture, technology stack, detailed implementation steps

#### 2. Task Stage - Specific Task Generation

```bash
./task-planner.sh task login-feature
```

- **Input**: Created `PLAN.md`
- **Process**: Generate executable specific task lists based on the plan
- **Output**: `TASK.md` - Implementation steps in checklist format

#### 3. Execute Stage - Implementation Execution

```bash
./task-planner.sh execute login-feature
```

- **Input**: Created `TASK.md`
- **Process**: AI actually writes code and creates/edits files
- **Output**: `PR.md` - Implementation completion report and deliverable documentation

### Benefits of Step-by-Step Execution

- **Step-by-step confirmation**: Content can be reviewed and adjusted at each stage
- **Quality improvement**: Quality improves through detailed progression from plan → task → implementation
- **Risk reduction**: Risk is reduced by being able to review plan and tasks before the execute stage

### Command List

| Command   | Description                    | Usage Example                                  |
| --------- | ------------------------------ | ---------------------------------------------- |
| `plan`    | Create plan from requirements  | `./task-planner.sh plan "requirements..." [task-name]` |
| `task`    | Generate tasks from plan       | `./task-planner.sh task task-name`            |
| `execute` | Execute tasks                  | `./task-planner.sh execute task-name`         |
| `list`    | Display task list              | `./task-planner.sh list`                      |
| `config`  | Configure AI tool              | `./task-planner.sh config claude`             |
| `help`    | Show help information          | `./task-planner.sh help`                      |

### File Structure

Execution creates files in the following structure:

```
AI_TASKS/
└── [task-name]/
    ├── PLAN.md        # Detailed implementation plan
    ├── TASK.md        # Specific task procedures
    └── PR.md          # Implementation completion report (final deliverable)

config/
├── plan-prompt.md    # Prompt for plan creation
├── task-prompt.md    # Prompt for task creation
└── execute-prompt.md # Prompt for execution
```

## Output Example

### Plan Creation

```
╭─────────────────────────────────────────────────────────────────╮
│                        Task Planner                           │
╰─────────────────────────────────────────────────────────────────╯

▶ Plan Creation
  Task Name: login-feature
  Requirements: Implement login functionality for web app

  AI creating plan ✅ Complete (01:23) [1250 tokens]

✅ Plan created: AI_TASKS/login-feature/PLAN.md
  Next step: ./task-planner.sh task login-feature
```

## Features

- **Step-by-step approach**: Clear flow from requirements → plan → task → implementation
- **Real-time feedback**: Progress display during AI processing
- **Structured output**: Unified documentation in Markdown format
- **History management**: View task progress at a glance
- **Customizable**: Adjust AI output by editing prompt templates

## ⚠️ Important Security & Safety Notes

### File Operation Permissions for execute Command

**The execute stage grants extensive file operation permissions**

The `execute` command automatically grants the `--dangerously-skip-permissions` flag to Claude CLI to perform actual implementation.

#### Enabled Operations

- Creating, editing, deleting files
- Creating, deleting directories
- Executing system commands
- Installing dependencies
- Modifying configuration files

### Safety Checklist for Secure Usage

**Please confirm before execution:**

- [ ] Create backups

  ```bash
  # For Git repositories
  git add . && git commit -m "Backup before Execute"

  # Copy important files
  cp -r important_files/ backup/
  ```

- [ ] Verify execution environment

  - Development environment, not production
  - No important system files included
  - Write permissions properly restricted

- [ ] Pre-review plans and tasks
  - `PLAN.md` content meets expectations
  - `TASK.md` implementation steps are safe
  - No suspicious commands or dangerous operations included

### Recommended Usage Environments

- **Development directories**: `/home/user/dev/`, `/Users/user/projects/`, etc.
- **Virtual environments**: Execution within Docker containers, VMs
- **Sandboxes**: Isolated development environments
- **Version control**: Projects under Git management

### Places to Avoid

- System directories (`/usr/`, `/etc/`, `/System/`, etc.)
- Production environments
- Shared directories
- Directories containing sensitive information

## Prompt Customization

You can customize AI behavior at each stage by editing Markdown files in the `config/` directory.

### Prompt File Configuration

| File               | Purpose                | Timing                            | Customization Examples               |
| ------------------ | ---------------------- | --------------------------------- | ------------------------------------ |
| `plan-prompt.md`   | Instructions for plan creation | When `./task-planner.sh plan` is executed | Specify design methods, adjust output format |
| `task-prompt.md`   | Instructions for task creation | When `./task-planner.sh task` is executed | Specify checklist format, assign priorities |
| `execute-prompt.md`| Instructions for implementation execution | When `./task-planner.sh execute` is executed | Coding style, test procedure instructions |

### Available Placeholders

The following placeholders are automatically replaced in prompt templates:

- `{{TASK_NAME}}`: Task name
- `{{REQUIREMENT}}`: Requirements (for plan-prompt.md)
- `{{PLAN_CONTENT}}`: Plan content (for task-prompt.md)
- `{{TASK_CONTENT}}`: Task content (for execute-prompt.md)

### Customization Example

```markdown
# Example config/plan-prompt.md

Requirements: {{REQUIREMENT}}
Task Name: {{TASK_NAME}}

Please create a detailed implementation plan from the following perspectives:

1. Architecture design
2. Security considerations
3. Performance optimization
4. Test strategy
5. Deployment procedures
```

## Practical Examples & Use Cases

### Project-Specific Usage Examples

#### Web Application Development

```bash
# REST API implementation
./task-planner.sh plan "REST API with user authentication" user-auth-api
./task-planner.sh task user-auth-api
./task-planner.sh execute user-auth-api

# Frontend features
./task-planner.sh plan "React dashboard screen" react-dashboard
```

#### Data Processing & Analysis

```bash
# Data pipeline construction
./task-planner.sh plan "CSV to PostgreSQL conversion tool" csv-converter
./task-planner.sh task csv-converter

# Machine learning models
./task-planner.sh plan "Image classification ML model implementation" image-classifier
```

#### DevOps & Automation

```bash
# CI/CD setup
./task-planner.sh plan "GitHub Actions workflow setup" gh-workflow
./task-planner.sh task gh-workflow

# Infrastructure construction
./task-planner.sh plan "Docker Compose development environment" docker-env
```

### Recommended Folder Structure

```
project/
├── AI_TASKS/           # Tasks managed by Task Planner
│   ├── feature-a/
│   ├── bugfix-b/
│   └── refactor-c/
├── src/               # Implemented source code
├── docs/              # Documentation
└── tests/             # Test files
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Claude CLI Related

```bash
# Claude CLI not found
which claude
# → Install: https://docs.anthropic.com/cli

# Authentication error
claude auth
# → Set API key
```

#### 2. Permission Errors

```bash
# No execution permission
chmod +x task-planner.sh

# No directory creation permission
sudo chown $USER:$USER /path/to/project
```

#### 3. AI Processing Errors

- **Network connection**: Check internet connection
- **API rate limits**: Wait a while and retry
- **Prompt too long**: Shorten requirements text and retry

#### 4. File Processing Errors

```bash
# JSON processing error (jq not required but recommended)
# macOS
brew install jq
# Ubuntu
sudo apt install jq

# File creation permission error
ls -la AI_TASKS/
# Check permissions and modify if necessary
```

### Debugging Methods

#### Log Verification

```bash
# Check detailed logs during AI processing
tail -f AI_TASKS/[task-name]/stream_output.json

# Check created files
ls -la AI_TASKS/[task-name]/
```

#### Step-by-step Problem Identification

1. **plan stage** failure → Review requirements text
2. **task stage** failure → Check PLAN.md content
3. **execute stage** failure → Check TASK.md implementation instructions

### Performance Optimization

- **Parallel processing**: Multiple tasks can progress in parallel through plan → task stages
- **Prompt optimization**: Adjust `config/` files to improve response speed
- **Cache utilization**: Use similar task PLAN.md as reference templates

## License & Contribution

### License

This project is released under the [MIT License](LICENSE).

### Contribute & Fork

- 🍴 **Free to fork**: Feel free to fork this repository and customize it to your needs
- 🛠️ **Improvement suggestions**: We welcome improvement suggestions through Issues and Pull Requests
- 💡 **Idea sharing**: Sharing new feature ideas and usage examples is also welcome

Let's build a better tool together through everyone's cooperation!