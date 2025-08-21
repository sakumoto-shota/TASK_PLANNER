#!/bin/bash

# -*- coding: utf-8 -*-
# task-planner.sh - 簡易的なAIタスクプランナー
# 使用方法:
#   ./task-planner.sh plan "要件..." [タスク名]
#   ./task-planner.sh task タスク名
#   ./task-planner.sh execute タスク名
#   ./task-planner.sh list
#   ./task-planner.sh config [claude|cursor]

set -e

# UTF-8エンコーディングを設定
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# 設定
AI_PLAN_DIR="ai-plan"
AI_TOOL="claude" # または "cursor"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# UI表示関数
show_header() {
    echo ""
    echo -e "${CYAN}+===============================================+${NC}"
    echo -e "${CYAN}|${WHITE}  _____ _    ____  _  __  ____  _      _      ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE} |_   _/ \\  / ___|| |/ / |  _ \\| |    / \\     ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}   | |/ _ \\ \\___ \\|   /  | |_) | |   / _ \\    ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}   | / ___ \\ ___) |   \\  |  __/| |__/ ___ \\   ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}   |_\\_/   \\_\\____/|_|\\_\\ |_|   |____/_/   \\_\\  ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}                                               ${CYAN}|${NC}"
    echo -e "${CYAN}|${WHITE}              AI Task Planner                 ${CYAN}|${NC}"
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

# stream-json用プログレス表示関数
show_streaming_progress() {
    local message="$1"
    local output_file="$2"
    local pid="$3"
    
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    local start_time=$(date +%s)
    local content_started=false
    local generation_started=false
    
    # 初期化段階のメッセージ
    local init_messages=("準備中" "初期化中" "接続中" "セットアップ中")
    local init_index=0
    
    # 実行段階のメッセージ
    local exec_messages=("分析中" "検討中" "実行中" "処理中")
    local exec_index=0
    
    # 生成段階のメッセージ
    local gen_messages=("生成中" "作成中" "構築中" "記述中" "整理中")
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

# stream-jsonから最終結果を抽出する関数
extract_final_result() {
    local stream_file="$1"
    local output_file="$2"
    
    if [ -f "$stream_file" ]; then
        if command -v jq &> /dev/null; then
            # jqを使って結果を抽出（最後の行のresultフィールドから）
            local result=$(tail -1 "$stream_file" 2>/dev/null | jq -r '.result' 2>/dev/null)
            if [ "$result" != "null" ] && [ -n "$result" ] && [ "$result" != "" ]; then
                echo "$result" > "$output_file"
                return 0
            fi
            
            # assistantメッセージからテキストを抽出を試す
            local assistant_text=$(grep '"type":"assistant"' "$stream_file" 2>/dev/null | jq -r '.message.content[0].text' 2>/dev/null)
            if [ "$assistant_text" != "null" ] && [ -n "$assistant_text" ] && [ "$assistant_text" != "" ]; then
                echo "$assistant_text" > "$output_file"
                return 0
            fi
        fi
        
        # jqが使えない場合やJSONパースに失敗した場合は手動で抽出
        # "result":"..."の部分を抽出
        local manual_result=$(grep -o '"result":"[^"]*"' "$stream_file" 2>/dev/null | tail -1 | sed 's/"result":"//;s/"$//')
        if [ -n "$manual_result" ] && [ "$manual_result" != "" ]; then
            # エスケープ文字を処理
            echo "$manual_result" | sed 's/\\n/\n/g;s/\\t/\t/g;s/\\"/"/g' > "$output_file"
            return 0
        fi
        
        # それでも失敗した場合は、エラーメッセージと共にJSONファイルをコピー
        echo "⚠️ JSON形式の結果から純粋なテキストを抽出できませんでした。以下に生ファイルを表示します：" > "$output_file"
        echo "" >> "$output_file"
        cat "$stream_file" >> "$output_file"
    else
        echo "エラー: 結果ファイルが見つかりません" > "$output_file"
    fi
    
    return 1
}

# ヘルプ表示
show_help() {
    echo "Task Planner - 簡易的なAIタスクプランナー"
    echo ""
    echo "使用方法:"
    echo "  $0 plan \"要件...\" [タスク名] - プランを立てる"
    echo "  $0 task タスク名            - タスクを作成する"
    echo "  $0 execute タスク名         - タスクを実行する"
    echo "  $0 list                    - タスク一覧を表示"
    echo "  $0 config [claude|cursor]  - AIツールを設定"
    echo ""
    echo "例:"
    echo "  $0 plan \"Webアプリのログイン機能を実装する\" login-feature"
    echo "  $0 task login-feature"
    echo "  $0 execute login-feature"
}

# AIツール設定
get_ai_command() {
    local mode="$1"
    if [ "$AI_TOOL" = "cursor" ]; then
        echo "cursor-agent"
    else
        local base_cmd="claude --print --input-format text --output-format stream-json --verbose --add-dir $(pwd)"
        
        # 実行モードの場合は危険な権限とファイル操作権限を追加
        if [ "$mode" = "execute" ]; then
            echo "$base_cmd --dangerously-skip-permissions"
        else
            echo "$base_cmd"
        fi
    fi
}

# タスク名を生成（要件から自動生成）
generate_task_name() {
    local requirement="$1"
    # 日本語を英語に変換し、適切なタスク名を生成
    # 簡易版：現在時刻を使用
    echo "task-$(date +%Y%m%d-%H%M%S)"
}

# プラン作成
create_plan() {
    local requirement="$1"
    local task_name="$2"
    
    if [ -z "$requirement" ]; then
        show_error "要件を指定してください"
        show_info "使用方法: $0 plan \"要件...\" [タスク名]"
        exit 1
    fi
    
    # タスク名が指定されていない場合は自動生成
    if [ -z "$task_name" ]; then
        task_name=$(generate_task_name "$requirement")
    fi
    
    local task_dir="$AI_PLAN_DIR/$task_name"
    
    show_header
    show_section "プラン作成"
    show_info "タスク名: ${WHITE}$task_name${NC}"
    show_info "要件: ${WHITE}$requirement${NC}"
    echo ""
    
    # ディレクトリ作成
    mkdir -p "$task_dir"
    
    # プラン作成用のプロンプトを準備
    local plan_prompt="以下の要件に基づいて詳細な実装プランを作成してください:

要件: $requirement

以下の形式でPLAN.mdを作成してください:

# $task_name - 実装プラン

## 概要
- 要件の詳細説明

## アーキテクチャ
- システム構成
- 使用技術

## 実装手順
1. 環境セットアップ
2. 基本構造の作成
3. 機能実装
4. テスト
5. ドキュメント作成

## ファイル構成
- 作成予定のファイル一覧

## 注意点・考慮事項
- セキュリティ
- パフォーマンス
- その他重要な点

このプランは後続のタスク作成と実装で参照されます。"
    
    # プロンプトをファイルに保存
    echo "$plan_prompt" > "$task_dir/plan_prompt.txt"
    
    # AIツールを実行
    local ai_cmd=$(get_ai_command)
    
    if command -v ${ai_cmd%% *} &> /dev/null; then
        cd "$task_dir"
        # プロンプトをファイルに書き出してからclaudeに渡す
        echo "$plan_prompt" > temp_prompt.txt
        
        # バックグラウンドでclaudeを実行（stream-json形式で）- 出力を非表示
        $ai_cmd < temp_prompt.txt > stream_output.json 2>/dev/null &
        local claude_pid=$!
        
        # ストリーミングプログレス表示
        show_streaming_progress "AIがプランを作成中" "stream_output.json" $claude_pid
        
        # 完了待機
        wait $claude_pid
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # ストリームから最終結果を抽出してPLAN.mdに保存
            extract_final_result "stream_output.json" "PLAN.md"
        else
            show_warning "AI実行でエラーが発生しましたが、手動でPLAN.mdを作成してください"
            echo "$plan_prompt" > PLAN.md
        fi
        
        # ストリーミング一時ファイルをクリーンアップ
        rm -f stream_output.json
        
        rm -f temp_prompt.txt
        cd - > /dev/null
    else
        show_warning "${ai_cmd%% *} が見つかりません。手動でPLAN.mdを作成します"
        echo "$plan_prompt" > "$task_dir/PLAN.md"
    fi
    
    echo ""
    show_success "プランが作成されました: $task_dir/PLAN.md"
    show_info "次のステップ: ${CYAN}$0 task $task_name${NC}"
}

# タスク作成
create_task() {
    local task_name="$1"
    
    if [ -z "$task_name" ]; then
        show_error "タスク名を指定してください"
        show_info "使用方法: $0 task \"タスク名\""
        exit 1
    fi
    
    local task_dir="$AI_PLAN_DIR/$task_name"
    local plan_file="$task_dir/PLAN.md"
    
    if [ ! -f "$plan_file" ]; then
        show_error "PLAN.mdが見つかりません: $plan_file"
        show_info "最初に 'plan' コマンドを実行してください"
        exit 1
    fi
    
    show_header
    show_section "タスク作成"
    show_info "タスク名: ${WHITE}$task_name${NC}"
    show_info "プランファイル: ${WHITE}$plan_file${NC}"
    echo ""
    
    # PLAN.mdの内容を読み込む
    local plan_content
    if [ -f "$plan_file" ]; then
        plan_content=$(cat "$plan_file")
    else
        plan_content="プランファイルが見つかりません"
    fi
    
    # タスク作成用のプロンプトを準備
    local task_prompt="以下のPLAN.mdの内容を基に、具体的な実装タスクを作成してください。

=== PLAN.mdの内容 ===
$plan_content
=== PLAN.mdの内容ここまで ===

以下の形式でTASK.mdを作成してください:

# $task_name - 実装タスク

## 実装概要
PLAN.mdから抽出した実装の要点

## 実装手順
### 1. 環境セットアップ
- 必要なツール・ライブラリのインストール
- プロジェクト初期化

### 2. ファイル作成
- 作成するファイルと内容の詳細
- ディレクトリ構造

### 3. コード実装
- 各ファイルの実装内容
- 関数・クラスの定義

### 4. テスト実装
- テストケースの作成
- テスト実行方法

### 5. 動作確認
- 確認手順
- 期待される結果

## チェックリスト
- [ ] 環境セットアップ完了
- [ ] 基本ファイル作成完了
- [ ] 機能実装完了
- [ ] テスト実装完了
- [ ] 動作確認完了

## コマンド例
実際に実行するコマンドの例を記載

このタスクは実装時に参照され、最終的にPR.mdが作成されます。"
    
    # AIツールを実行
    local ai_cmd=$(get_ai_command)
    echo "🤖 AIを実行中: $ai_cmd $plan_file"
    
    if command -v ${ai_cmd%% *} &> /dev/null; then
        cd "$task_dir"
        # プロンプトをファイルに書き出してからclaudeに渡す
        echo "$task_prompt" > temp_prompt.txt
        
        # バックグラウンドでclaudeを実行（stream-json形式で）- 出力を非表示
        $ai_cmd < temp_prompt.txt > stream_output.json 2>/dev/null &
        local claude_pid=$!
        
        # ストリーミングプログレス表示
        show_streaming_progress "AIがタスクを作成中" "stream_output.json" $claude_pid
        
        # 完了待機
        wait $claude_pid
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # ストリームから最終結果を抽出してTASK.mdに保存
            extract_final_result "stream_output.json" "TASK.md"
        else
            echo "⚠️  AI実行でエラーが発生しましたが、手動でTASK.mdを作成してください"
            echo "$task_prompt" > TASK.md
        fi
        
        # ストリーミング一時ファイルをクリーンアップ
        rm -f stream_output.json
        
        rm -f temp_prompt.txt
        cd - > /dev/null
    else
        echo "⚠️  ${ai_cmd%% *} が見つかりません。手動でTASK.mdを作成します"
        echo "$task_prompt" > "$task_dir/TASK.md"
    fi
    
    echo "✅ タスクが作成されました: $task_dir/TASK.md"
    echo "次のステップ: $0 execute $task_name"
}

# タスク実行
execute_task() {
    local task_name="$1"
    
    if [ -z "$task_name" ]; then
        echo "エラー: タスク名を指定してください"
        echo "使用方法: $0 execute \"タスク名\""
        exit 1
    fi
    
    local task_dir="$AI_PLAN_DIR/$task_name"
    local task_file="$task_dir/TASK.md"
    
    if [ ! -f "$task_file" ]; then
        echo "エラー: TASK.mdが見つかりません: $task_file"
        echo "最初に 'task' コマンドを実行してください"
        exit 1
    fi
    
    echo "🚀 タスクを実行しています..."
    echo "タスク名: $task_name"
    echo "タスクファイル: $task_file"
    echo ""
    
    # TASK.mdの内容を読み込む
    local task_content
    if [ -f "$task_file" ]; then
        task_content=$(cat "$task_file")
    else
        task_content="タスクファイルが見つかりません"
    fi
    
    # 実行用のプロンプトを準備
    local execute_prompt="以下のTASK.mdの内容に基づいて実装を行い、成果物としてPR.mdを作成してください。

=== TASK.mdの内容 ===
$task_content
=== TASK.mdの内容ここまで ===

以下の形式でPR.md（プルリクエスト形式の成果物）を作成してください:

# $task_name - 実装完了報告

## 実装概要
実装した内容の概要

## 変更内容
### 追加ファイル
- ファイル名: 説明

### 変更ファイル
- ファイル名: 変更内容

## 実装詳細
### 主要機能
実装した主要機能の説明

### 技術的な実装ポイント
- 使用した技術・ライブラリ
- 設計上の工夫
- パフォーマンス考慮点

## テスト結果
### 実行したテスト
- テストケース
- 結果

### 動作確認
- 確認した項目
- スクリーンショット（必要に応じて）

## 使用方法
### セットアップ
インストール・セットアップ手順

### 実行方法
基本的な使用方法

## 今後の課題・改善点
- 残課題
- 改善提案

## レビューポイント
レビュー時に確認してほしい点

---
このPR.mdは実装の完了を示し、レビューや今後の参考資料として使用されます。"
    
    # AIツールを実行
    local ai_cmd=$(get_ai_command "execute")
    echo "🤖 AIを実行中: $ai_cmd $task_file"
    
    if command -v ${ai_cmd%% *} &> /dev/null; then
        cd "$task_dir"
        # プロンプトをファイルに書き出してからclaudeに渡す
        echo "$execute_prompt" > temp_prompt.txt
        
        # バックグラウンドでclaudeを実行（stream-json形式で）- 出力を非表示
        $ai_cmd < temp_prompt.txt > stream_output.json 2>/dev/null &
        local claude_pid=$!
        
        # ストリーミングプログレス表示
        show_streaming_progress "AIが実装を実行中" "stream_output.json" $claude_pid
        
        # 完了待機
        wait $claude_pid
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            # ストリームから最終結果を抽出してPR.mdに保存
            extract_final_result "stream_output.json" "PR.md"
        else
            echo "⚠️  AI実行でエラーが発生しましたが、手動でPR.mdを作成してください"
            echo "$execute_prompt" > PR.md
        fi
        
        # ストリーミング一時ファイルをクリーンアップ
        rm -f stream_output.json
        
        rm -f temp_prompt.txt
        cd - > /dev/null
    else
        echo "⚠️  ${ai_cmd%% *} が見つかりません。手動でPR.mdを作成します"
        echo "$execute_prompt" > "$task_dir/PR.md"
    fi
    
    echo "✅ タスクが実行されました: $task_dir/PR.md"
    echo "🎉 実装完了！成果物を確認してください"
}

# タスク一覧表示
list_tasks() {
    echo "📋 タスク一覧:"
    echo ""
    
    if [ ! -d "$AI_PLAN_DIR" ]; then
        echo "タスクが見つかりません。"
        return
    fi
    
    for task_dir in "$AI_PLAN_DIR"/*; do
        if [ -d "$task_dir" ]; then
            local task_name=$(basename "$task_dir")
            local status="🔄 進行中"
            
            if [ -f "$task_dir/PR.md" ]; then
                status="✅ 完了"
            elif [ -f "$task_dir/TASK.md" ]; then
                status="📝 タスク作成済み"
            elif [ -f "$task_dir/PLAN.md" ]; then
                status="📋 プラン作成済み"
            fi
            
            echo "$status $task_name"
        fi
    done
}

# 設定変更
config_tool() {
    local tool="$1"
    
    if [ "$tool" = "claude" ]; then
        AI_TOOL="claude"
        echo "✅ AIツールをclaudeに設定しました"
    elif [ "$tool" = "cursor" ]; then
        AI_TOOL="cursor"
        echo "✅ AIツールをcursor-agentに設定しました"
    else
        echo "現在の設定: $AI_TOOL"
        echo "利用可能なツール: claude, cursor"
    fi
}

# メイン処理
main() {
    case "$1" in
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
        *)
            echo "エラー: 不明なコマンド '$1'"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# スクリプト実行
main "$@"
