#!/bin/bash

# -*- coding: utf-8 -*-
# task-planner.sh - AI Task Planner
# Description: A simple AI-powered task planner that supports step-by-step workflow
# Author: @sakumoto-shota
# Version: 2.0.0
#
# Usage:
#   ./task-planner.sh plan "requirements..." [task-name]
#   ./task-planner.sh task task-name
#   ./task-planner.sh execute task-name
#   ./task-planner.sh list
#   ./task-planner.sh config [claude|cursor]

set -euo pipefail

# UTF-8 encoding setup
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Global Configuration
readonly SCRIPT_VERSION="2.0.0"
readonly AI_PLAN_DIR="AI_TASKS"
readonly CONFIG_DIR="config"
readonly TEMP_DIR="/tmp/task-planner-$$"

# Default settings
AI_TOOL="claude"

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;37m'
readonly NC='\033[0m' # No Color

# =============================================================================
# Utility Functions
# =============================================================================

# Setup temporary directory
setup_temp_dir() {
    mkdir -p "$TEMP_DIR"
    trap cleanup_temp_dir EXIT
}

# Cleanup temporary directory
cleanup_temp_dir() {
    rm -rf "$TEMP_DIR" 2>/dev/null || true
}

# Validate required commands
validate_dependencies() {
    local missing_deps=()
    
    if ! command -v "${AI_TOOL}" &> /dev/null; then
        missing_deps+=("${AI_TOOL}")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        show_error "Missing required dependencies: ${missing_deps[*]}"
        show_info "Please install the missing tools and try again"
        exit 1
    fi
}

# Validate task name format
validate_task_name() {
    local task_name="$1"
    
    if [[ ! "$task_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        show_error "Invalid task name: $task_name"
        show_info "Task name must contain only alphanumeric characters, hyphens, and underscores"
        return 1
    fi
    
    return 0
}

# =============================================================================
# UI Display Functions
# =============================================================================

show_header() {
    echo ""
    echo -e "${CYAN}+===============================================+${NC}"
    echo -e "${CYAN}|${WHITE}  _____ _    ____  _  __  ____  _      _      ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE} |_   _/ \\  / ___|| |/ / |  _ \\| |    / \\     ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}   | |/ _ \\ \\___ \\|   /  | |_) | |   / _ \\    ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}   | / ___ \\ ___) |   \\  |  __/| |__/ ___ \\   ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}   |_\\_/   \\_\\____/|_|\\_\\ |_|   |____/_/   \\_\\  ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}                                               ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}              AI Task Planner v${SCRIPT_VERSION}       ${CYAN}|${NC}"
    echo -e "${CYAN}+===============================================+${NC}"
    echo ""
}

show_section() {
    local title="$1"
    echo -e "${BLUE}▶ ${WHITE}$title${NC}"
}

show_info() {
    local message="$1"
    echo -e "  ${GRAY}$message${NC}"
}

show_success() {
    local message="$1"
    echo -e "  ${GREEN}✅ $message${NC}"
}

show_warning() {
    local message="$1"
    echo -e "  ${YELLOW}⚠️  $message${NC}"
}

show_error() {
    local message="$1"
    echo -e "  ${RED}❌ $message${NC}"
}

# =============================================================================
# Progress Display Functions
# =============================================================================

# Show streaming progress with enhanced status detection
show_streaming_progress() {
    local message="$1"
    local output_file="$2"
    local pid="$3"
    
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    local start_time=$(date +%s)
    local content_started=false
    local generation_started=false
    
    # Progress messages for different stages
    local init_messages=("準備中" "初期化中" "接続中" "セットアップ中")
    local exec_messages=("分析中" "検討中" "実行中" "処理中")
    local gen_messages=("生成中" "作成中" "構築中" "記述中" "整理中")
    
    local init_index=0
    local exec_index=0
    local gen_index=0
    
    echo -e -n "  ${YELLOW}$message${NC} "
    
    while kill -0 $pid 2>/dev/null; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local mins=$((elapsed / 60))
        local secs=$((elapsed % 60))
        
        # JSONストリームから情報を抽出
        local status="準備中"
        local tokens=""
        
        if [ -f "$output_file" ]; then
            # systemメッセージがあるが、assistantメッセージがまだない場合
            if grep -q '"type":"system"' "$output_file" 2>/dev/null && ! grep -q '"type":"assistant"' "$output_file" 2>/dev/null; then
                # 初期化段階のメッセージを循環
                local msg_cycle=$((elapsed / 3))  # 3秒ごとに変更
                init_index=$((msg_cycle % ${#init_messages[@]}))
                status="${init_messages[$init_index]}"
            fi
            
            # assistantメッセージが開始されたかチェック
            if grep -q '"type":"assistant"' "$output_file" 2>/dev/null; then
                if ! $content_started; then
                    content_started=true
                fi
                
                if ! grep -q '"type":"result"' "$output_file" 2>/dev/null; then
                    # まだ生成中
                    local msg_cycle=$((elapsed / 2))  # 2秒ごとに変更
                    gen_index=$((msg_cycle % ${#gen_messages[@]}))
                    status="${gen_messages[$gen_index]}"
                else
                    status="完了処理中"
                fi
            elif $content_started; then
                # contentは始まったが、まだassistantメッセージが来ていない
                local msg_cycle=$((elapsed / 2))  # 2秒ごとに変更
                exec_index=$((msg_cycle % ${#exec_messages[@]}))
                status="${exec_messages[$exec_index]}"
            fi
            
            # 完了情報があるかチェック
            if grep -q '"type":"result"' "$output_file" 2>/dev/null; then
                # トークン数を抽出
                local token_count=$(grep '"output_tokens"' "$output_file" 2>/dev/null | grep -o '[0-9]\+' | tail -1)
                if [ -n "$token_count" ]; then
                    tokens=" [${token_count} tokens]"
                fi
                status="完了処理中"
            fi
        else
            # ファイルがまだ作成されていない
            local msg_cycle=$((elapsed / 4))  # 4秒ごとに変更
            init_index=$((msg_cycle % ${#init_messages[@]}))
            status="${init_messages[$init_index]}"
        fi
        
        printf "\r  ${YELLOW}$message${NC} ${MAGENTA}%c${NC} ${GRAY}(%02d:%02d)${NC} ${CYAN}%s${NC}${GREEN}%s${NC}" \
            "${spinner:$i:1}" $mins $secs "$status" "$tokens"
        
        i=$(((i + 1) % ${#spinner}))
        sleep 0.3
    done
    
    local end_time=$(date +%s)
    local total_elapsed=$((end_time - start_time))
    local total_mins=$((total_elapsed / 60))
    local total_secs=$((total_elapsed % 60))
    
    # 最終結果の表示
    local final_tokens=""
    if [ -f "$output_file" ] && command -v jq &> /dev/null; then
        local token_count=$(tail -1 "$output_file" 2>/dev/null | jq -r '.usage.output_tokens' 2>/dev/null)
        if [ "$token_count" != "null" ] && [ -n "$token_count" ]; then
            final_tokens=" [${token_count} tokens]"
        fi
    fi
    
    printf "\r  ${YELLOW}$message${NC} ${GREEN}✅ 完了${NC} ${GRAY}(%02d:%02d)${NC}${GREEN}%s${NC}\n" $total_mins $total_secs "$final_tokens"
}

# =============================================================================
# JSON Stream Processing Functions
# =============================================================================

# Extract final result from stream-json output
extract_final_result() {
    local stream_file="$1"
    local output_file="$2"
    
    if [ ! -f "$stream_file" ]; then
        echo "エラー: 結果ファイルが見つかりません" > "$output_file"
        return 1
    fi
    
    # Check if file is empty
    if [ ! -s "$stream_file" ]; then
        echo "エラー: 結果ファイルが空です" > "$output_file"
        return 1
    fi
    
    # Try to extract result using jq if available
    if command -v jq &> /dev/null; then
        if _extract_with_jq "$stream_file" "$output_file"; then
            # Verify the output doesn't contain null values
            if ! grep -q "^null$" "$output_file"; then
                return 0
            fi
        fi
    fi
    
    # Fallback to manual parsing
    if _extract_manually "$stream_file" "$output_file"; then
        # Verify the output doesn't contain null values
        if ! grep -q "^null$" "$output_file"; then
            return 0
        fi
    fi
    
    # Last resort: copy raw file with warning
    _handle_extraction_failure "$stream_file" "$output_file"
    return 1
}

# Extract result using jq
_extract_with_jq() {
    local stream_file="$1"
    local output_file="$2"
    
    # Debug: show file structure
    if [ "${DEBUG:-0}" = "1" ]; then
        echo "Debug: Stream file content:" >&2
        head -3 "$stream_file" >&2
        echo "Debug: Assistant messages:" >&2
        grep '"type":"assistant"' "$stream_file" | head -1 >&2
    fi
    
    # Try to extract complete assistant message content by combining all content pieces
    local complete_content=""
    
    # Claude CLI stream-json format: extract all content from assistant messages
    while IFS= read -r line; do
        # Try different content extraction methods
        local content_part=""
        
        # Method 1: Extract from content[0].text
        content_part=$(echo "$line" | jq -r '.message.content[0].text // empty' 2>/dev/null)
        
        # Method 2: Extract from content array (in case of multiple parts)
        if [ -z "$content_part" ] || [ "$content_part" = "null" ]; then
            content_part=$(echo "$line" | jq -r '.message.content[] | select(.type == "text") | .text // empty' 2>/dev/null)
        fi
        
        # Method 3: Extract from simple text field
        if [ -z "$content_part" ] || [ "$content_part" = "null" ]; then
            content_part=$(echo "$line" | jq -r '.message.text // .text // empty' 2>/dev/null)
        fi
        
        if [ -n "$content_part" ] && [ "$content_part" != "null" ]; then
            complete_content="${complete_content}${content_part}"
        fi
    done < <(grep '"type":"assistant"' "$stream_file" 2>/dev/null)
    
    if [ -n "$complete_content" ]; then
        echo "$complete_content" > "$output_file"
        return 0
    fi
    
    # Fallback: try to extract from result field
    local result=$(tail -1 "$stream_file" 2>/dev/null | jq -r '.result // empty' 2>/dev/null)
    if [ -n "$result" ] && [ "$result" != "null" ] && [ "$result" != "" ]; then
        echo "$result" > "$output_file"
        return 0
    fi
    
    return 1
}

# Extract result manually without jq
_extract_manually() {
    local stream_file="$1"
    local output_file="$2"
    
    # Try to extract result field manually
    local manual_result=$(grep -o '"result":"[^"]*"' "$stream_file" 2>/dev/null | tail -1 | sed 's/"result":"//;s/"$//')
    if [ -n "$manual_result" ] && [ "$manual_result" != "" ] && [ "$manual_result" != "null" ]; then
        # Process escape characters
        echo "$manual_result" | sed 's/\\n/\n/g;s/\\t/\t/g;s/\\"/"/g' > "$output_file"
        return 0
    fi
    
    # Try to extract assistant message text manually
    local assistant_line=$(grep '"type":"assistant"' "$stream_file" 2>/dev/null | tail -1)
    if [ -n "$assistant_line" ]; then
        local text_content=$(echo "$assistant_line" | sed -n 's/.*"text":"\([^"]*\)".*/\1/p')
        if [ -n "$text_content" ] && [ "$text_content" != "null" ]; then
            echo "$text_content" | sed 's/\\n/\n/g;s/\\t/\t/g;s/\\"/"/g' > "$output_file"
            return 0
        fi
    fi
    
    return 1
}

# Handle extraction failure
_handle_extraction_failure() {
    local stream_file="$1"
    local output_file="$2"
    
    echo "⚠️ JSON形式の結果から純粋なテキストを抽出できませんでした。以下に生ファイルを表示します：" > "$output_file"
    echo "" >> "$output_file"
    cat "$stream_file" >> "$output_file"
}

# =============================================================================
# Help and Information Functions
# =============================================================================

# Display help information
show_help() {
    cat << EOF
Task Planner v${SCRIPT_VERSION} - AI-powered Task Planner

USAGE:
  $0 plan "requirements..." [task-name]     Create implementation plan
  $0 task task-name                         Generate specific tasks
  $0 execute task-name                      Execute implementation
  $0 list                                   Show task list
  $0 config [claude|cursor]                Configure AI tool
  $0 help                                   Show this help

EXAMPLES:
  $0 plan "Implement login functionality" login-feature
  $0 task login-feature
  $0 execute login-feature

FILES:
  ${AI_PLAN_DIR}/[task-name]/PLAN.md        Implementation plan
  ${AI_PLAN_DIR}/[task-name]/TASK.md        Specific task procedures
  ${AI_PLAN_DIR}/[task-name]/PR.md          Implementation report
  ${CONFIG_DIR}/plan-prompt.md              Plan creation prompt template
  ${CONFIG_DIR}/task-prompt.md              Task creation prompt template
  ${CONFIG_DIR}/execute-prompt.md           Execution prompt template

FOR MORE INFORMATION:
  See README.md for detailed documentation
EOF
}

# =============================================================================
# Prompt Management Functions
# =============================================================================

# Load and process prompt templates
load_prompt() {
    local prompt_type="$1"
    local task_name="$2"
    local content="$3"
    
    local prompt_file="$CONFIG_DIR/${prompt_type}-prompt.md"
    
    if [ ! -f "$prompt_file" ]; then
        show_error "Prompt file not found: $prompt_file"
        show_info "Please ensure the config directory contains the required prompt templates"
        return 1
    fi
    
    if [ ! -r "$prompt_file" ]; then
        show_error "Cannot read prompt file: $prompt_file"
        return 1
    fi
    
    local prompt_content
    prompt_content=$(cat "$prompt_file")
    
    # Replace placeholders with actual values
    prompt_content="${prompt_content//\{\{TASK_NAME\}\}/$task_name}"
    prompt_content="${prompt_content//\{\{REQUIREMENT\}\}/$content}"
    prompt_content="${prompt_content//\{\{PLAN_CONTENT\}\}/$content}"
    prompt_content="${prompt_content//\{\{TASK_CONTENT\}\}/$content}"
    
    echo "$prompt_content"
}

# Validate prompt template files exist
validate_prompt_templates() {
    local missing_templates=()
    local templates=("plan" "task" "execute")
    
    for template in "${templates[@]}"; do
        local template_file="$CONFIG_DIR/${template}-prompt.md"
        if [ ! -f "$template_file" ]; then
            missing_templates+=("${template_file}")
        fi
    done
    
    if [ ${#missing_templates[@]} -gt 0 ]; then
        show_error "Missing prompt template files:"
        for template in "${missing_templates[@]}"; do
            show_info "  - $template"
        done
        show_info "Please ensure all prompt templates are present in the ${CONFIG_DIR}/ directory"
        return 1
    fi
    
    return 0
}

# =============================================================================
# AI Tool Configuration Functions
# =============================================================================

# Get AI command with appropriate flags
get_ai_command() {
    local mode="${1:-""}"
    
    case "$AI_TOOL" in
        "cursor")
            echo "cursor-agent"
            ;;
        "claude")
            local base_cmd="claude --print --input-format text --output-format stream-json --verbose --add-dir $(pwd)"
            
            # Add dangerous permissions for execute mode
            if [ "$mode" = "execute" ]; then
                echo "$base_cmd --dangerously-skip-permissions"
            else
                echo "$base_cmd"
            fi
            ;;
        *)
            show_error "Unsupported AI tool: $AI_TOOL"
            return 1
            ;;
    esac
}

# Validate AI tool availability
validate_ai_tool() {
    local tool_cmd
    tool_cmd=$(get_ai_command 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    local tool_name="${tool_cmd%% *}"
    
    if ! command -v "$tool_name" &> /dev/null; then
        show_error "AI tool not found: $tool_name"
        show_info "Please install $tool_name or configure a different AI tool"
        return 1
    fi
    
    return 0
}

# =============================================================================
# Task Management Functions
# =============================================================================

# Generate task name from requirement
generate_task_name() {
    local requirement="$1"
    
    # Generate timestamp-based task name
    # TODO: Future enhancement - use AI to generate meaningful names
    echo "task-$(date +%Y%m%d-%H%M%S)"
}

# Validate task directory structure
validate_task_directory() {
    local task_name="$1"
    local task_dir="$AI_PLAN_DIR/$task_name"
    
    if [ ! -d "$task_dir" ]; then
        show_error "Task directory not found: $task_dir"
        return 1
    fi
    
    return 0
}

# Create task directory with proper permissions
create_task_directory() {
    local task_name="$1"
    local task_dir="$AI_PLAN_DIR/$task_name"
    
    if ! mkdir -p "$task_dir"; then
        show_error "Failed to create task directory: $task_dir"
        return 1
    fi
    
    return 0
}

# =============================================================================
# Core Workflow Functions
# =============================================================================

# Create implementation plan
create_plan() {
    local requirement="$1"
    local task_name="$2"
    
    # Validate inputs
    if [ -z "$requirement" ]; then
        show_error "Requirement is required"
        show_info "Usage: $0 plan \"requirements...\" [task-name]"
        exit 1
    fi
    
    # Generate task name if not provided
    if [ -z "$task_name" ]; then
        task_name=$(generate_task_name "$requirement")
    fi
    
    # Validate task name format
    if ! validate_task_name "$task_name"; then
        exit 1
    fi
    
    # Validate dependencies
    validate_prompt_templates || exit 1
    validate_ai_tool || exit 1
    
    local task_dir="$AI_PLAN_DIR/$task_name"
    
    show_header
    show_section "Plan Creation"
    show_info "Task Name: ${WHITE}$task_name${NC}"
    show_info "Requirements: ${WHITE}$requirement${NC}"
    echo ""
    
    # Create task directory
    if ! create_task_directory "$task_name"; then
        exit 1
    fi
    
    # Load prompt template
    local plan_prompt
    if ! plan_prompt=$(load_prompt "plan" "$task_name" "$requirement"); then
        exit 1
    fi
    
    # Save prompt for reference
    echo "$plan_prompt" > "$task_dir/plan_prompt.txt"
    
    # Execute AI tool
    if ! _execute_ai_workflow "$task_dir" "$plan_prompt" "AI is creating plan" "PLAN.md" ""; then
        show_warning "Plan creation completed with fallback"
    fi
    
    echo ""
    show_success "Plan created: $task_dir/PLAN.md"
    show_info "Next step: ${CYAN}$0 task $task_name${NC}"
}

# Create specific tasks from plan
create_task() {
    local task_name="$1"
    
    # Validate inputs
    if [ -z "$task_name" ]; then
        show_error "Task name is required"
        show_info "Usage: $0 task \"task-name\""
        exit 1
    fi
    
    # Validate task name format
    if ! validate_task_name "$task_name"; then
        exit 1
    fi
    
    local task_dir="$AI_PLAN_DIR/$task_name"
    local plan_file="$task_dir/PLAN.md"
    
    # Validate prerequisites
    if ! validate_task_directory "$task_name"; then
        show_info "Please run 'plan' command first"
        exit 1
    fi
    
    if [ ! -f "$plan_file" ]; then
        show_error "Plan file not found: $plan_file"
        show_info "Please run 'plan' command first"
        exit 1
    fi
    
    # Validate dependencies
    validate_prompt_templates || exit 1
    validate_ai_tool || exit 1
    
    show_header
    show_section "Task Creation"
    show_info "Task Name: ${WHITE}$task_name${NC}"
    show_info "Plan File: ${WHITE}$plan_file${NC}"
    echo ""
    
    # Read plan content
    local plan_content
    if ! plan_content=$(cat "$plan_file" 2>/dev/null); then
        show_error "Failed to read plan file: $plan_file"
        exit 1
    fi
    
    # Load prompt template
    local task_prompt
    if ! task_prompt=$(load_prompt "task" "$task_name" "$plan_content"); then
        exit 1
    fi
    
    # Execute AI tool
    if ! _execute_ai_workflow "$task_dir" "$task_prompt" "AI is creating tasks" "TASK.md" ""; then
        show_warning "Task creation completed with fallback"
    fi
    
    echo ""
    show_success "Tasks created: $task_dir/TASK.md"
    show_info "Next step: ${CYAN}$0 execute $task_name${NC}"
}

# Execute implementation tasks
execute_task() {
    local task_name="$1"
    
    # Validate inputs
    if [ -z "$task_name" ]; then
        show_error "Task name is required"
        show_info "Usage: $0 execute \"task-name\""
        exit 1
    fi
    
    # Validate task name format
    if ! validate_task_name "$task_name"; then
        exit 1
    fi
    
    local task_dir="$AI_PLAN_DIR/$task_name"
    local task_file="$task_dir/TASK.md"
    
    # Validate prerequisites
    if ! validate_task_directory "$task_name"; then
        show_info "Please run 'task' command first"
        exit 1
    fi
    
    if [ ! -f "$task_file" ]; then
        show_error "Task file not found: $task_file"
        show_info "Please run 'task' command first"
        exit 1
    fi
    
    # Validate dependencies
    validate_prompt_templates || exit 1
    validate_ai_tool || exit 1
    
    show_header
    show_section "Task Execution"
    show_info "Task Name: ${WHITE}$task_name${NC}"
    show_info "Task File: ${WHITE}$task_file${NC}"
    echo ""
    
    # Read task content
    local task_content
    if ! task_content=$(cat "$task_file" 2>/dev/null); then
        show_error "Failed to read task file: $task_file"
        exit 1
    fi
    
    # Load prompt template
    local execute_prompt
    if ! execute_prompt=$(load_prompt "execute" "$task_name" "$task_content"); then
        exit 1
    fi
    
    # Execute AI tool with dangerous permissions
    if ! _execute_ai_workflow "$task_dir" "$execute_prompt" "AI is executing implementation" "PR.md" "execute"; then
        show_warning "Task execution completed with fallback"
    fi
    
    echo ""
    show_success "Task executed: $task_dir/PR.md"
    show_success "Implementation complete! Please review the deliverables"
}

# =============================================================================
# Task Listing and Management Functions
# =============================================================================

# List all tasks with their status
list_tasks() {
    show_header
    show_section "Task List"
    echo ""
    
    if [ ! -d "$AI_PLAN_DIR" ]; then
        show_info "No tasks found. Create your first task with:"
        show_info "  ${CYAN}$0 plan \"your requirements\" task-name${NC}"
        return 0
    fi
    
    local task_count=0
    
    for task_dir in "$AI_PLAN_DIR"/*; do
        if [ -d "$task_dir" ]; then
            local task_name=$(basename "$task_dir")
            local status_icon status_text
            
            # Determine task status
            if [ -f "$task_dir/PR.md" ]; then
                status_icon="✅"
                status_text="Complete"
            elif [ -f "$task_dir/TASK.md" ]; then
                status_icon="📝"
                status_text="Tasks Created"
            elif [ -f "$task_dir/PLAN.md" ]; then
                status_icon="📋"
                status_text="Plan Created"
            else
                status_icon="🔄"
                status_text="In Progress"
            fi
            
            printf "  %s %-20s %s\n" "$status_icon" "$task_name" "$status_text"
            ((task_count++))
        fi
    done
    
    if [ $task_count -eq 0 ]; then
        show_info "No tasks found. Create your first task with:"
        show_info "  ${CYAN}$0 plan \"your requirements\" task-name${NC}"
    else
        echo ""
        show_info "Total tasks: $task_count"
    fi
}

# Configure AI tool
config_tool() {
    local tool="$1"
    
    if [ -z "$tool" ]; then
        show_info "Current AI tool: ${WHITE}$AI_TOOL${NC}"
        show_info "Available tools: claude, cursor"
        show_info "Usage: $0 config [claude|cursor]"
        return 0
    fi
    
    case "$tool" in
        "claude")
            if command -v claude &> /dev/null; then
                AI_TOOL="claude"
                show_success "AI tool set to Claude CLI"
            else
                show_error "Claude CLI not found. Please install Claude CLI first"
                show_info "Visit: https://docs.anthropic.com/cli"
                return 1
            fi
            ;;
        "cursor")
            if command -v cursor-agent &> /dev/null; then
                AI_TOOL="cursor"
                show_success "AI tool set to Cursor Agent"
            else
                show_error "Cursor Agent not found. Please install Cursor Agent first"
                return 1
            fi
            ;;
        *)
            show_error "Unknown tool: $tool"
            show_info "Available tools: claude, cursor"
            return 1
            ;;
    esac
}

# =============================================================================
# AI Workflow Execution (Internal)
# =============================================================================

# Execute AI workflow with common error handling
_execute_ai_workflow() {
    local task_dir="$1"
    local prompt="$2"
    local progress_message="$3"
    local output_file="$4"
    local mode="${5:-""}"
    
    local ai_cmd
    if ! ai_cmd=$(get_ai_command "$mode"); then
        show_error "Failed to get AI command"
        return 1
    fi
    
    local temp_prompt="$TEMP_DIR/prompt_$$.txt"
    local temp_output="$TEMP_DIR/output_$$.json"
    
    # Write prompt to temporary file
    echo "$prompt" > "$temp_prompt"
    
    # Change to task directory
    local original_dir=$(pwd)
    cd "$task_dir" || return 1
    
    # Execute AI command in background
    $ai_cmd < "$temp_prompt" > "$temp_output" 2>/dev/null &
    local ai_pid=$!
    
    # Show progress
    show_streaming_progress "$progress_message" "$temp_output" $ai_pid
    
    # Wait for completion
    wait $ai_pid
    local exit_code=$?
    
    # Process results
    if [ $exit_code -eq 0 ]; then
        extract_final_result "$temp_output" "$output_file"
    else
        show_warning "AI execution failed, creating fallback file"
        echo "$prompt" > "$output_file"
        cd "$original_dir"
        return 1
    fi
    
    cd "$original_dir"
    return 0
}

# =============================================================================
# Main Application Logic
# =============================================================================

# Main function - command dispatcher
main() {
    local command="${1:-""}"
    
    # Setup temporary directory
    setup_temp_dir
    
    # Dispatch commands
    case "$command" in
        "plan")
            create_plan "$2" "$3"
            ;;
        "task")
            create_task "$2"
            ;;
        "execute")
            execute_task "$2"
            ;;
        "list")
            list_tasks
            ;;
        "config")
            config_tool "$2"
            ;;
        "help"|"-h"|"--help"|"")
            show_help
            ;;
        "version"|"-v"|"--version")
            echo "Task Planner v${SCRIPT_VERSION}"
            ;;
        "debug")
            # Debug mode - analyze stream file
            if [ -n "$2" ]; then
                echo "Analyzing stream file: $2"
                echo "File size: $(wc -c < "$2") bytes"
                echo "Line count: $(wc -l < "$2") lines"
                echo ""
                echo "First 5 lines:"
                head -5 "$2"
                echo ""
                echo "Assistant messages:"
                grep '"type":"assistant"' "$2" | head -3
                echo ""
                echo "Result field:"
                grep '"result"' "$2" | tail -1
            else
                echo "Usage: $0 debug <stream-file>"
            fi
            ;;
        *)
            show_error "Unknown command: '$command'"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# =============================================================================
# Script Entry Point
# =============================================================================

# Execute main function with all arguments
main "$@"