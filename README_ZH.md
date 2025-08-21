# Task Planner

<div align="center">
  <img src="logo.png" alt="Task Planner Logo" width="400">
</div>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Claude AI](https://img.shields.io/badge/AI-Claude-blue.svg)](https://claude.ai/)

简易 AI 任务规划器 - 从需求到实现逐步支持的 Bash 工具

> [English README](README_EN.md) | [日本語 README](README.md) | [中文 README](README_ZH.md) | [한국어 README](README_KO.md) | [Español README](README_ES.md) | [Français README](README_FR.md)

## 概述

Task Planner 通过以下 3 个阶段支持从需求定义到实现的整个过程：

1. **Plan**: 基于需求创建详细的实现计划
2. **Task**: 基于计划生成具体任务
3. **Execute**: 执行任务并输出 PR 格式的交付物

## 功能特性

- 🎯 从需求自动逐步生成计划、任务和实现
- 🤖 与 Claude AI 集成
- 📊 可视化进度显示（旋转器、状态、耗时）
- 📝 结构化文档生成（PLAN.md → TASK.md → PR.md）
- 📋 任务列表管理
- ⚙️ 可自定义的提示模板（config/ 目录）

## 环境要求

- Bash (macOS/Linux)
- Claude CLI
- jq (JSON 解析用，可选)

## 安装设置

### 基础设置

1. 让脚本可执行：

```bash
chmod +x task-planner.sh
```

2. 配置 AI 工具：

```bash
./task-planner.sh config claude    # 使用 Claude CLI
```

### 集成到现有项目

将 Task Planner 集成到现有项目的步骤：

#### 1. 复制文件

```bash
# 进入现有项目目录
cd /path/to/your/project

# 复制 Task Planner 文件
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/task-planner.sh
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/plan-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/task-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/execute-prompt.md

# 或者从本仓库复制必需文件
cp /path/to/task_planner/task-planner.sh .
cp -r /path/to/task_planner/config .
```

#### 2. 设置执行权限

```bash
chmod +x task-planner.sh
```

#### 3. 验证目录结构

集成后的项目结构示例：

```
your-project/
├── src/                  # 现有源代码
├── docs/                 # 现有文档
├── task-planner.sh       # ✅ 已添加
├── config/               # ✅ 已添加
│   ├── plan-prompt.md
│   ├── task-prompt.md
│   └── execute-prompt.md
└── AI_TASKS/             # ✅ 执行时自动创建
    └── [task-name]/
        ├── PLAN.md
        ├── TASK.md
        └── PR.md
```

#### 4. 配置 .gitignore（推荐）

```bash
# 添加到 .gitignore（是否管理 AI_TASKS 目录取决于项目需要）
echo "AI_TASKS/" >> .gitignore

# 或者只排除工作中的任务
echo "AI_TASKS/*/plan_prompt.txt" >> .gitignore
echo "AI_TASKS/*/stream_output.json" >> .gitignore
```

#### 5. 项目特定的自定义

```bash
# 根据项目的技术栈自定义提示
vim config/plan-prompt.md
vim config/task-prompt.md
vim config/execute-prompt.md
```

## 使用方法

### 3 阶段工作流

Task Planner 通过以下 3 个阶段从需求到实现：

#### 1. Plan 阶段 - 需求分析和设计

```bash
./task-planner.sh plan "实现 Web 应用的登录功能" login-feature
```

- **输入**: 需求文本和任务名称
- **处理**: AI 分析需求并创建详细的实现计划
- **输出**: `PLAN.md` - 架构、技术栈、详细实现步骤

#### 2. Task 阶段 - 具体任务生成

```bash
./task-planner.sh task login-feature
```

- **输入**: 已创建的 `PLAN.md`
- **处理**: 基于计划生成可执行的具体任务列表
- **输出**: `TASK.md` - 清单格式的实现步骤

#### 3. Execute 阶段 - 实现执行

```bash
./task-planner.sh execute login-feature
```

- **输入**: 已创建的 `TASK.md`
- **处理**: AI 实际编写代码并创建/编辑文件
- **输出**: `PR.md` - 实现完成报告和交付物文档

### 逐步执行的优势

- **逐步确认**: 每个阶段都可以审查和调整内容
- **质量提升**: 通过计划 → 任务 → 实现的顺序细化提高质量
- **风险降低**: 在执行阶段之前可以审查计划和任务，降低风险

### 命令列表

| 命令      | 说明               | 使用示例                                       |
| --------- | ------------------ | ---------------------------------------------- |
| `plan`    | 从需求创建计划     | `./task-planner.sh plan "需求..." [task-name]` |
| `task`    | 从计划生成任务     | `./task-planner.sh task task-name`            |
| `execute` | 执行任务           | `./task-planner.sh execute task-name`         |
| `list`    | 显示任务列表       | `./task-planner.sh list`                      |
| `config`  | 配置 AI 工具       | `./task-planner.sh config claude`             |
| `help`    | 显示帮助信息       | `./task-planner.sh help`                      |

### 文件结构

执行后创建以下结构的文件：

```
AI_TASKS/
└── [task-name]/
    ├── PLAN.md        # 详细实现计划
    ├── TASK.md        # 具体任务步骤
    └── PR.md          # 实现完成报告（最终交付物）

config/
├── plan-prompt.md    # 计划创建提示模板
├── task-prompt.md    # 任务创建提示模板
└── execute-prompt.md # 执行提示模板
```

## 输出示例

### 计划创建时

```
╭─────────────────────────────────────────────────────────────────╮
│                        Task Planner                           │
╰─────────────────────────────────────────────────────────────────╯

▶ 计划创建
  任务名称: login-feature
  需求: 实现 Web 应用的登录功能

  AI 正在创建计划 ✅ 完成 (01:23) [1250 tokens]

✅ 计划已创建: AI_TASKS/login-feature/PLAN.md
  下一步: ./task-planner.sh task login-feature
```

## 特性

- **逐步方法**: 需求 → 计划 → 任务 → 实现的清晰流程
- **实时反馈**: AI 处理期间的进度显示
- **结构化输出**: Markdown 格式的统一文档
- **历史管理**: 一目了然地查看任务进度
- **可自定义**: 编辑提示模板来调整 AI 输出

## ⚠️ 安全性和安全使用的重要注意事项

### execute 命令的文件操作权限

**execute 阶段会授予广泛的文件操作权限**

`execute` 命令为了执行实际实现，会自动向 Claude CLI 授予 `--dangerously-skip-permissions` 标志。

#### 可能的操作

- 创建、编辑、删除文件
- 创建、删除目录
- 执行系统命令
- 安装依赖项
- 修改配置文件

### 安全使用检查清单

**执行前请务必确认：**

- [ ] 创建备份

  ```bash
  # 对于 Git 仓库
  git add . && git commit -m "Execute 前的备份"

  # 复制重要文件
  cp -r important_files/ backup/
  ```

- [ ] 验证执行环境

  - 是开发环境而非生产环境
  - 不包含重要的系统文件
  - 写入权限得到适当限制

- [ ] 事先审查计划和任务
  - `PLAN.md` 内容符合预期
  - `TASK.md` 实现步骤是安全的
  - 不包含可疑命令或危险操作

### 推荐的使用环境

- **开发目录**: `/home/user/dev/`, `/Users/user/projects/` 等
- **虚拟环境**: Docker 容器、VM 内执行
- **沙盒**: 隔离的开发环境
- **版本控制**: Git 管理下的项目

### 应避免的使用场所

- 系统目录 (`/usr/`, `/etc/`, `/System/` 等)
- 生产环境
- 共享目录
- 包含机密信息的目录

## 提示自定义

通过编辑 `config/` 目录中的 Markdown 文件，可以自定义各阶段的 AI 行为。

### 提示文件配置

| 文件               | 用途               | 时机                              | 自定义示例                   |
| ------------------ | ------------------ | --------------------------------- | ---------------------------- |
| `plan-prompt.md`   | 计划创建时的指示   | 执行 `./task-planner.sh plan` 时    | 指定设计方法、调整输出格式   |
| `task-prompt.md`   | 任务创建时的指示   | 执行 `./task-planner.sh task` 时    | 指定清单格式、分配优先级     |
| `execute-prompt.md`| 实现执行时的指示   | 执行 `./task-planner.sh execute` 时 | 编码风格、测试步骤指示       |

### 可用占位符

提示模板中会自动替换以下占位符：

- `{{TASK_NAME}}`: 任务名称
- `{{REQUIREMENT}}`: 需求（用于 plan-prompt.md）
- `{{PLAN_CONTENT}}`: 计划内容（用于 task-prompt.md）
- `{{TASK_CONTENT}}`: 任务内容（用于 execute-prompt.md）

### 自定义示例

```markdown
# config/plan-prompt.md 的示例

需求: {{REQUIREMENT}}
任务名称: {{TASK_NAME}}

请从以下角度创建详细的实现计划：

1. 架构设计
2. 安全考虑
3. 性能优化
4. 测试策略
5. 部署步骤
```

## 实用示例和用例

### 按项目类型的活用示例

#### Web 应用开发

```bash
# REST API 实现
./task-planner.sh plan "带用户认证功能的 REST API" user-auth-api
./task-planner.sh task user-auth-api
./task-planner.sh execute user-auth-api

# 前端功能
./task-planner.sh plan "React 制作的仪表板界面" react-dashboard
```

#### 数据处理和分析

```bash
# 数据管道构建
./task-planner.sh plan "CSV 到 PostgreSQL 转换工具" csv-converter
./task-planner.sh task csv-converter

# 机器学习模型
./task-planner.sh plan "图像分类 ML 模型实现" image-classifier
```

#### DevOps 和自动化

```bash
# CI/CD 设置
./task-planner.sh plan "GitHub Actions 工作流设置" gh-workflow
./task-planner.sh task gh-workflow

# 基础设施构建
./task-planner.sh plan "Docker Compose 开发环境" docker-env
```

### 推荐的文件夹结构

```
project/
├── AI_TASKS/           # Task Planner 管理的任务
│   ├── feature-a/
│   ├── bugfix-b/
│   └── refactor-c/
├── src/               # 实现的源代码
├── docs/              # 文档
└── tests/             # 测试文件
```

## 故障排除

### 常见问题和解决方法

#### 1. Claude CLI 相关

```bash
# 找不到 Claude CLI
which claude
# → 安装: https://docs.anthropic.com/cli

# 认证错误
claude auth
# → 设置 API 密钥
```

#### 2. 权限错误

```bash
# 没有执行权限
chmod +x task-planner.sh

# 没有目录创建权限
sudo chown $USER:$USER /path/to/project
```

#### 3. AI 处理错误

- **网络连接**: 确认互联网连接
- **API 速率限制**: 等待一段时间后重新执行
- **提示过长**: 缩短需求文本后重新执行

#### 4. 文件处理错误

```bash
# JSON 处理错误（不需要 jq 但推荐）
# macOS
brew install jq
# Ubuntu
sudo apt install jq

# 文件创建权限错误
ls -la AI_TASKS/
# 确认权限并根据需要修改
```

### 调试方法

#### 日志确认

```bash
# 确认 AI 处理期间的详细日志
tail -f AI_TASKS/[task-name]/stream_output.json

# 确认创建的文件
ls -la AI_TASKS/[task-name]/
```

#### 逐步问题识别

1. **plan 阶段**失败 → 审查需求文本
2. **task 阶段**失败 → 确认 PLAN.md 内容
3. **execute 阶段**失败 → 确认 TASK.md 实现指示

### 性能优化

- **并行处理**: 多个任务可以并行进行到 plan → task 阶段
- **提示优化**: 调整 `config/` 文件来提高响应速度
- **缓存利用**: 将类似任务的 PLAN.md 作为参考模板使用

## 许可证和贡献

### 许可证

本项目基于 [MIT 许可证](LICENSE) 发布。

### 贡献和分叉

- 🍴 **自由分叉**: 欢迎分叉本仓库并根据您的需求进行自定义
- 🛠️ **改进建议**: 欢迎通过 Issues 和 Pull Requests 提出改进建议
- 💡 **想法分享**: 也欢迎分享新功能想法和使用示例

让我们通过大家的合作来构建更好的工具！