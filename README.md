# Task Planner

簡易的な AI タスクプランナー - 要件から実装まで段階的にサポートする Bash ツール

## 概要

Task Planner は、要件定義から実装まで以下の 3 段階でサポートするツールです：

1. **Plan**: 要件を基に詳細な実装プランを作成
2. **Task**: プランを基に具体的なタスクを生成
3. **Execute**: タスクを実行し、PR 形式の成果物を出力

## 機能

- 🎯 要件から自動的にプラン・タスク・実装を段階的に生成
- 🤖 Claude AI との連携
- 📊 視覚的なプログレス表示（スピナー・ステータス・経過時間）
- 📝 構造化されたドキュメント生成（PLAN.md → TASK.md → PR.md）
- 📋 タスク一覧管理
- ⚙️ カスタマイズ可能なプロンプトテンプレート（config/ディレクトリ）

## 必要な環境

- Bash (macOS/Linux)
- Claude CLI
- jq (JSON パース用、オプション)

## セットアップ

1. スクリプトを実行可能にする:

```bash
chmod +x task-planner.sh
```

2. AI ツールの設定:

```bash
./task-planner.sh config claude    # Claude CLIを使用
```

## 使用方法

### 3 段階ワークフロー

Task Planner は要件から実装まで以下の 3 つの段階で進行します：

#### 1. Plan 段階 - 要件分析・設計

```bash
./task-planner.sh plan "Webアプリのログイン機能を実装する" login-feature
```

- **入力**: 要件文とタスク名
- **処理**: AI が要件を分析し、詳細な実装プランを作成
- **出力**: `PLAN.md` - アーキテクチャ、技術スタック、実装手順の詳細

#### 2. Task 段階 - 具体的タスク生成

```bash
./task-planner.sh task login-feature
```

- **入力**: 作成済みの `PLAN.md`
- **処理**: プランを基に実行可能な具体的タスクリストを生成
- **出力**: `TASK.md` - チェックリスト形式の実装手順

#### 3. Execute 段階 - 実装実行

```bash
./task-planner.sh execute login-feature
```

- **入力**: 作成済みの `TASK.md`
- **処理**: AI が実際にコードを書き、ファイルを作成・編集
- **出力**: `PR.md` - 実装完了報告と成果物のドキュメント

### 段階的実行のメリット

- **段階的確認**: 各段階で内容を確認・調整が可能
- **品質向上**: プラン → タスク → 実装の順で詳細化により品質向上
- **リスク軽減**: execute 段階前にプランとタスクを確認できるためリスク軽減

### コマンド一覧

| コマンド  | 説明                   | 使用例                                        |
| --------- | ---------------------- | --------------------------------------------- |
| `plan`    | 要件からプランを作成   | `./task-planner.sh plan "要件..." [タスク名]` |
| `task`    | プランからタスクを生成 | `./task-planner.sh task タスク名`             |
| `execute` | タスクを実行           | `./task-planner.sh execute タスク名`          |
| `list`    | タスク一覧を表示       | `./task-planner.sh list`                      |
| `config`  | AI ツール設定          | `./task-planner.sh config claude`             |

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
- **リアルタイムフィードバック**: AI 処理中のプログレス表示
- **構造化出力**: Markdown 形式での統一されたドキュメント
- **履歴管理**: タスクの進捗状況を一覧で確認可能
- **カスタマイズ可能**: プロンプトテンプレートを編集して AI 出力を調整可能

## ⚠️ セキュリティ・安全性に関する重要な注意事項

### execute コマンドのファイル操作権限について

**execute 段階では広範囲なファイル操作権限が付与されます**

`execute`コマンドは実際の実装を行うため、Claude CLI に`--dangerously-skip-permissions`フラグを自動的に付与します。

#### 可能になる操作

- ファイルの作成・編集・削除
- ディレクトリの作成・削除
- システムコマンドの実行
- 依存関係のインストール
- 設定ファイルの変更

### 安全な使用のためのチェックリスト

**実行前に必ず確認してください：**

- [ ] バックアップの作成

  ```bash
  # Gitリポジトリの場合
  git add . && git commit -m "Execute前のバックアップ"

  # 重要なファイルのコピー
  cp -r important_files/ backup/
  ```

- [ ] 実行環境の確認

  - 本番環境ではなく開発環境であること
  - 重要なシステムファイルが含まれていないこと
  - 書き込み権限が適切に制限されていること

- [ ] プランとタスクの事前レビュー
  - `PLAN.md` の内容が期待通りであること
  - `TASK.md` の実装手順が安全であること
  - 不審なコマンドや危険な操作が含まれていないこと

### 推奨される使用環境

- **開発用ディレクトリ**: `/home/user/dev/`, `/Users/user/projects/` など
- **仮想環境**: Docker コンテナ、VM 内での実行
- **サンドボックス**: 隔離された開発環境
- **バージョン管理**: Git 管理下にあるプロジェクト

### 避けるべき使用場所

- システムディレクトリ（`/usr/`, `/etc/`, `/System/` など）
- 本番環境
- 共有ディレクトリ
- 機密情報を含むディレクトリ

## プロンプトカスタマイズ

`config/`ディレクトリ内の Markdown ファイルを編集することで、各段階での AI の動作をカスタマイズできます。

### プロンプトファイル構成

| ファイル            | 用途               | タイミング                        | カスタマイズ例                         |
| ------------------- | ------------------ | --------------------------------- | -------------------------------------- |
| `plan-prompt.md`    | プラン作成時の指示 | `./task-planner.sh plan`実行時    | 設計手法の指定、出力形式の調整         |
| `task-prompt.md`    | タスク作成時の指示 | `./task-planner.sh task`実行時    | チェックリスト形式の指定、優先度の付与 |
| `execute-prompt.md` | 実装実行時の指示   | `./task-planner.sh execute`実行時 | コーディングスタイル、テスト手順の指示 |

### 使用可能なプレースホルダー

プロンプトテンプレート内で以下のプレースホルダーが自動置換されます：

- `{{TASK_NAME}}`: タスク名
- `{{REQUIREMENT}}`: 要件（plan-prompt.md 用）
- `{{PLAN_CONTENT}}`: プラン内容（task-prompt.md 用）
- `{{TASK_CONTENT}}`: タスク内容（execute-prompt.md 用）

### カスタマイズ例

```markdown
# config/plan-prompt.md の例

要件: {{REQUIREMENT}}
タスク名: {{TASK_NAME}}

以下の観点で詳細な実装プランを作成してください：

1. アーキテクチャ設計
2. セキュリティ考慮事項
3. パフォーマンス最適化
4. テスト戦略
5. デプロイメント手順
```

## 実用例・ユースケース

### プロジェクト別活用例

#### Web アプリケーション開発

```bash
# REST API実装
./task-planner.sh plan "ユーザー認証機能付きREST API" user-auth-api
./task-planner.sh task user-auth-api
./task-planner.sh execute user-auth-api

# フロントエンド機能
./task-planner.sh plan "React製ダッシュボード画面" react-dashboard
```

#### データ処理・分析

```bash
# データパイプライン構築
./task-planner.sh plan "CSV to PostgreSQL変換ツール" csv-converter
./task-planner.sh task csv-converter

# 機械学習モデル
./task-planner.sh plan "画像分類MLモデルの実装" image-classifier
```

#### DevOps・自動化

```bash
# CI/CD設定
./task-planner.sh plan "GitHub Actions ワークフロー設定" gh-workflow
./task-planner.sh task gh-workflow

# インフラ構築
./task-planner.sh plan "Docker Compose開発環境" docker-env
```

### 推奨フォルダ構成

```
project/
├── AI_TASKS/           # Task Plannerで管理するタスク
│   ├── feature-a/
│   ├── bugfix-b/
│   └── refactor-c/
├── src/               # 実装されるソースコード
├── docs/              # ドキュメント
└── tests/             # テストファイル
```

## トラブルシューティング

### よくある問題と解決法

#### 1. Claude CLI 関連

```bash
# Claude CLIが見つからない
which claude
# → インストール: https://docs.anthropic.com/cli

# 認証エラー
claude auth
# → APIキーを設定
```

#### 2. 権限エラー

```bash
# 実行権限がない
chmod +x task-planner.sh

# ディレクトリ作成権限がない
sudo chown $USER:$USER /path/to/project
```

#### 3. AI プロセシングエラー

- **ネットワーク接続**: インターネット接続を確認
- **API レート制限**: しばらく時間をおいて再実行
- **プロンプトが長すぎる**: 要件文を短縮して再実行

#### 4. ファイル処理エラー

```bash
# JSON処理エラー（jq不要だが推奨）
# macOS
brew install jq
# Ubuntu
sudo apt install jq

# ファイル作成権限エラー
ls -la AI_TASKS/
# 権限を確認し、必要に応じて修正
```

### デバッグ方法

#### ログの確認

```bash
# AI処理中の詳細ログを確認
tail -f AI_TASKS/[task-name]/stream_output.json

# 作成されたファイルの確認
ls -la AI_TASKS/[task-name]/
```

#### 段階的な問題の特定

1. **plan 段階**で失敗 → 要件文の見直し
2. **task 段階**で失敗 → PLAN.md の内容確認
3. **execute 段階**で失敗 → TASK.md の実装指示確認

### パフォーマンス最適化

- **並列処理**: 複数タスクを並行して plan → task まで進行可能
- **プロンプト最適化**: `config/`ファイルを調整して応答速度向上
- **キャッシュ活用**: 類似タスクの PLAN.md を参考テンプレートとして活用
