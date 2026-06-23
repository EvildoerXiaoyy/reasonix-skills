---
name: dep-status
description: 读取 MODULE_DEPENDENCY.md，检查当前模块的前置依赖是否全部通过门禁，返回 go/no-go 状态。在进入模块 TDD 循环前必须执行。
argument-hint: "当前模块名称（可选，默认可从上下文或 MODULE_DEPENDENCY.md 推断）"
allowed-tools:
  - Read
  - Glob
  - Grep
---

# Dependency Status Check

在进行模块 TDD 循环之前，必须确认所有前置依赖已通过门禁。本 skill 读取 `MODULE_DEPENDENCY.md` 并结合门禁标记，给出"可以开始"或"等待"的结论。

## 流程

1. **定位依赖文件**
   读取项目根目录下的 `MODULE_DEPENDENCY.md`。如果不存在，警告用户并建议先执行 `/arch-workflow` 生成依赖顺序。

2. **提取依赖列表**
   解析文档中的依赖图（通常是 Markdown 有序列表），识别目标模块的直接前置模块。格式示例：
   ```markdown
   1. common-utils ✅
   2. user-auth (depends on common-utils)
   3. order-core (depends on user-auth)
   4. payment-gateway (depends on user-auth, order-core)
   ```

3. **检查门禁状态**
   对于每个前置模块，检查以下标记之一（优先级从高到低）：
   - `MODULE_DEPENDENCY.md` 中模块名后是否有 `✅`
   - 该模块目录下是否存在 `.gate-passed` 文件
   如果未找到任何标记，则假定未通过。

4. **输出结果**
   - 若所有前置模块均已通过门禁 → `DEPENDENCIES SATISFIED`，提示可以开始模块开发
   - 若有缺失 → `DEPENDENCIES BLOCKED`，列出未就绪的模块及建议动作

## 输出示例

```
DEPENDENCIES SATISFIED: 模块 payment-gateway 的所有前置模块 [user-auth, order-core] 已通过门禁。可以进入 Stage 2 TDD 循环。
```

```
DEPENDENCIES BLOCKED: 模块 payment-gateway 依赖 user-auth（未通过门禁）。
➡️ 建议执行 /mock-gen 生成 user-auth 的轻量 Mock，以解除串行阻塞，进入并行开发。
```

## 交接

将结论清晰地告知用户，不要自动进入下一步，等待用户确认。
