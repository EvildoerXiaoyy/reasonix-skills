# Reasonix Workflow Skills

16 个 skill 组成的四层开发工作流：**整体规划 → 模块循环 → 集成 → 回顾**。

以 [Reasonix](https://github.com/ReasonixAI/reasonix) 兼容的 `SKILL.md` 格式分发，可通过 `install.sh` 一键安装。

## 安装

```bash
# 全局安装（对所有项目生效）
curl -sL https://raw.githubusercontent.com/EvildoerXiaoyy/reasonix-skills/main/install.sh | bash

# 项目级安装（仅当前项目）
curl -sL https://raw.githubusercontent.com/EvildoerXiaoyy/reasonix-skills/main/install.sh | bash -s -- --project
```

## 包含的 skill

| 命令 | 用途 | 阶段 |
|------|------|------|
| `/workflow` | 四层工作流总控 | - |
| `/arch-workflow` | 架构蓝图 + 形式化契约 | 规划 |
| `/to-prd` | 结构化 PRD | 规划 |
| `/grill-me` | 拷问方案漏洞 | 规划 |
| `/plan-eng-review` | EM 视角工程评审 | 规划 |
| `/dep-status` | 前置依赖门禁检查 | 模块循环 |
| `/mock-gen` | 依赖未就绪时生成轻量 Mock | 模块循环 |
| `/test-gen` | 测试骨架生成器 | 模块循环 |
| `/review-request` | 外部模型二审 | 模块循环 |
| `/refactor` | 绿灯安全重构 | 模块循环 |
| `/debug` | 熔断诊断 | 模块循环/集成 |
| `/amend-contract` | 受控基线修订 | 模块循环 |
| `/codereview` | assistant 自查 + gate 门禁 | 模块循环/集成 |
| `/reconcile` | 漂移检测（仅报告） | 回顾 |
| `/adr` | 架构决策记录 | 贯穿 |
| `/handoff` | 上下文压缩交接 | 回顾 |

## 目录结构

```
reasonix-skills/
├── skills/           ← 所有 skill 在此目录，install.sh 自动发现
│   ├── workflow/SKILL.md
│   ├── arch-workflow/SKILL.md
│   └── ...
├── install.sh        ← 一键安装脚本（自动扫描 skills/）
└── README.md
```

## 工作原理

`install.sh` 通过 GitHub API 自动发现 `skills/` 下的所有子目录，逐一下载其中的 `SKILL.md` 到 Reasonix 的全局或项目级技能目录。新增 skill 只需在 `skills/` 下加一个新目录推送到 main 分支即可，无需修改安装脚本。
