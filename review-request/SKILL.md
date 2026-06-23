---
name: review-request
description: 打包最终 diff 给外部模型做独立二审，发现一审可能遗漏的问题。在 Reasonix 一审 (/codereview --assistant) 之后、合并之前运行。
argument-hint: "哪个功能或模块需要二审？（可选：--exclude testdata/,vendor/）"
---

# 审查请求 — 外部二审包

将最终 diff 打包送给外部审查模型（如 zcoder / GLM 5.2 / 其他）做独立**二审**。不同模型的视角能发现一审可能遗漏的问题。

## 输入

生成审查包前读取以下内容：
- `git diff` 对比基准分支 — 实际变更内容
- `ARCHITECTURE.md` — 系统上下文、组件、数据流
- `docs/adr/` — 相关架构决策（特别是 trade-off）
- 最新的 `/codereview --assistant` 报告 — Reasonix 一审已检查的内容

**Diff 压缩策略：** 如果 diff 超过 500 行，优先提取核心业务逻辑文件，排除自动生成的代码（如 `pb.go`、`mock_*.go`、`generated.go`）。在审查包开头注明跳过了哪些文件。

**忽略范围：** 如果用户指定了 `--exclude` 参数（如 `--exclude "testdata/,vendor/"`），对应文件不出现在 diff 中。默认排除 `vendor/`、`*.pb.go`。注意：当审查对象本身就是测试文件时，`testdata/` 默认**不排除**；如需排除请显式指定 `--exclude testdata/`。

## 输出格式

写入 `review-request/<feature>-review.md`：

```markdown
# Review Request: <feature name>

## Context
<one-line: what does this change do?>

## Diff
<git diff output, or key file changes with before/after snippets>

## Architecture Context
<how this change fits into the system — 3-5 lines max>

## Trade-offs to Respect

These are conscious decisions. **Do NOT suggest reverting them.**

> **Decision:** X > Y — <reason>
> **Decision:** ... — <reason>

## What Reasonix Already Checked

- Code quality / readability
- Comment coverage ("why" not "what")
- Test diversity
- Mock coverage

## Reasonix 一审结论（High/Medium 问题列表）

提取一审报告中的关键结论，按文件行号列出，供二审做**冲突判断**依据。格式示例：

> Reasonix 一审结论示例：
> **High**
> - pkg/auth.go:42 — no security issue (validated input sanitization)
> - pkg/cache.go:88 — no race condition (protected by mutex)
>
> **Medium**
> - pkg/handler.go:15 — missing edge case for empty input

**冲突判断规则：** 对比二审发现 vs 一审结论。如果二审在某行发现**新的 High 问题**，而一审结论**未覆盖该行**（或认定了"安全"），则标记 `CONFLICT: Yes`。反之，如果二审在该行发现了同一问题，则 `CONFLICT: No`。

## What We Want From You

Focus on things the primary review might miss:
- **Security**: injection, authz gaps, data leakage
- **Concurrency**: race conditions, deadlocks, incorrect locking
- **Performance**: N+1 queries, unnecessary allocations, hot paths
- **Edge cases**: boundary conditions, error paths, nil/empty handling
- **Consistency**: does this match ARCHITECTURE.md and existing ADRs?
- **API design**: does the interface feel right from a consumer's perspective?

## Response Format

**输出原则：** JSON 是唯一完整数据源（Source of Truth），Markdown 是摘要。不要写两遍描述。

### Markdown（摘要，不带长描述）

```
## Summary
- High: X | Medium: Y | Low: Z
- Overall: approve / conditional / reject
- CONFLICT: Yes/No — based on line-level comparison with Reasonix findings
```

### JSON（完整数据源）

Include this JSON block as the source of truth:

```json
{
  "review": {
    "overall": "approve|conditional|reject",
    "conflict_with_reasonix": false,
    "conflict_detail": "pkg/auth.go:42 — Reasonix said no issue, but found SQL injection risk",
    "summary": {
      "high": 0,
      "medium": 0,
      "low": 0
    },
    "findings": [
      {
        "severity": "high",
        "file": "pkg/foo/bar.go",
        "line": 42,
        "issue": "description",
        "conflict": false
      }
    ]
  }
}
```
```

## 质量检查清单

保存前确认：
- [ ] Diff 已包含（不是"see the changes"）
- [ ] Diff 超过 500 行时已压缩，自动生成文件已排除
- [ ] Trade-offs 已明确列出（不是"check the ADRs"）
- [ ] 审查范围涵盖安全 + 并发 + 性能 + 边界条件
- [ ] Reasonix 一审结论已按文件行号提取，供冲突判断
- [ ] JSON 是完整数据源，Markdown 仅为摘要（不写两遍）
- [ ] CONFLICT 标记有明确的行号级判断依据
- [ ] 用户指定的 `--exclude` 参数已应用

## 交接

告诉用户，并**用实际文件名替换 `<feature>`**，直接输出可直接复制的内容：

```
✅ 审查请求已写入 review-request/<feature>-review.md

📋 复制以下全部内容发给外部模型：

Read review-request/<feature>-review.md carefully.

This is a second review request. The diff has already passed Reasonix's first review.
Focus on what the primary review might miss: security, concurrency, performance, edge cases, consistency.

Do NOT suggest reverting conscious trade-offs — they're documented in the file.

Output:
1. JSON as source of truth (complete findings with file:line)
2. Markdown as summary only (no long descriptions)

Conflict judgment: compare your High findings against Reasonix's key findings (listed by file:line).
If you find a High issue on a line Reasonix marked as safe, mark CONFLICT: Yes.
```
