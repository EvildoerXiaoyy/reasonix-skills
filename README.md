# Reasonix Workflow Skills

16 个 skill 组成的四层开发工作流（整体规划 → 模块循环 → 集成 → 回顾）。

## 安装

```bash
curl -sL https://raw.githubusercontent.com/EvildoerXiaoyy/reasonix-skills/main/install.sh | bash
```

## 包含的 skill

| 命令 | 用途 | 阶段 |
|------|------|------|
| `/workflow` | 四层开发工作流总控 | - |
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

## 使用

新会话中直接输入 `/workflow` 即可查看工作流总览和引导。
