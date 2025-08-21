# Task Planner

簡易的なAIタスクプランナー - 要件から実装まで段階的にサポートするBashツール

## 概要

Task Plannerは、要件定義から実装まで以下の3段階でサポートするツールです：

1. **Plan**: 要件を基に詳細な実装プランを作成
2. **Task**: プランを基に具体的なタスクを生成  
3. **Execute**: タスクを実行し、PR形式の成果物を出力

## 機能

- 🎯 要件から自動的にプラン・タスク・実装を段階的に生成
- 🤖 Claude AIとの連携
- 📊 視覚的なプログレス表示（スピナー・ステータス・経過時間）
- 📝 構造化されたドキュメント生成（PLAN.md → TASK.md → PR.md）
- 📋 タスク一覧管理
- ⚙️ カスタマイズ可能なプロンプトテンプレート（config/ディレクトリ）

## 必要な環境

- Bash (macOS/Linux)
- Claude CLI
- jq (JSONパース用、オプション)

## セットアップ

1. スクリプトを実行可能にする:
```bash
chmod +x task-planner.sh
```

2. AIツールの設定:
```bash
./task-planner.sh config claude    # Claude CLIを使用
```

## 使用方法

### 基本的なワークフロー

```bash
# 1. プラン作成
./task-planner.sh plan "Webアプリのログイン機能を実装する" login-feature

# 2. タスク作成  
./task-planner.sh task login-feature

# 3. タスク実行
./task-planner.sh execute login-feature
```

### コマンド一覧

| コマンド | 説明 | 使用例 |
|---------|------|--------|
| `plan` | 要件からプランを作成 | `./task-planner.sh plan "要件..." [タスク名]` |
| `task` | プランからタスクを生成 | `./task-planner.sh task タスク名` |
| `execute` | タスクを実行 | `./task-planner.sh execute タスク名` |
| `list` | タスク一覧を表示 | `./task-planner.sh list` |
| `config` | AIツール設定 | `./task-planner.sh config claude` |

### ファイル構成

実行すると以下の構造でファイルが作成されます：

```
AI_TASKS/
└── [タスク名]/
    ├── PLAN.md        # 詳細な実装プラン
    ├── TASK.md        # 具体的なタスク手順
    └── PR.md          # 実装完了報告（最終成果物）

config/
├── plan-prompt.md    # プラン作成用プロンプト
├── task-prompt.md    # タスク作成用プロンプト
└── execute-prompt.md # 実行用プロンプト
```

## 出力例

### プラン作成時
```
╭─────────────────────────────────────────────────────────────────╮
│                        Task Planner                           │
╰─────────────────────────────────────────────────────────────────╯

▶ プラン作成
  タスク名: login-feature
  要件: Webアプリのログイン機能を実装する

  AIがプランを作成中 ✅ 完了 (01:23) [1250 tokens]

✅ プランが作成されました: AI_TASKS/login-feature/PLAN.md
  次のステップ: ./task-planner.sh task login-feature
```

## 特徴

- **段階的アプローチ**: 要件 → プラン → タスク → 実装の明確な流れ
- **リアルタイムフィードバック**: AI処理中のプログレス表示
- **構造化出力**: Markdown形式での統一されたドキュメント
- **履歴管理**: タスクの進捗状況を一覧で確認可能
- **カスタマイズ可能**: プロンプトテンプレートを編集してAI出力を調整可能

## ⚠️ 重要な注意事項

**executeコマンドはファイル操作権限を必要とします**

`execute`コマンドは実装を実際に行うため、Claude CLIに`--dangerously-skip-permissions`フラグを自動的に付与します。これにより以下が可能になります：

- ファイルの作成・編集・削除
- ディレクトリの作成
- コードの実行

**使用前に以下を理解した上で実行してください：**
- AIが自動的にファイルシステムを変更する可能性があります
- 実行前に重要なファイルをバックアップすることを推奨します
- 信頼できるプロジェクトディレクトリでのみ使用してください

## プロンプトカスタマイズ

`config/`ディレクトリ内のMarkdownファイルを編集することで、AIの動作をカスタマイズできます：

- `plan-prompt.md`: プラン作成時の指示
- `task-prompt.md`: タスク作成時の指示  
- `execute-prompt.md`: 実装実行時の指示

プレースホルダー：
- `{{TASK_NAME}}`: タスク名
- `{{REQUIREMENT}}`: 要件（plan用）
- `{{PLAN_CONTENT}}`: プラン内容（task用）
- `{{TASK_CONTENT}}`: タスク内容（execute用）

## トラブルシューティング

- Claude CLIが見つからない場合は適切にインストールされているか確認してください
- `jq`がない場合も動作しますが、より正確なJSON処理のため推奨されます
- AI処理でエラーが発生した場合も、テンプレートファイルが作成され手動編集が可能です
