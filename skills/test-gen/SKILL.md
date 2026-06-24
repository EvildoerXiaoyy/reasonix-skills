---
name: test-gen
description: 基于 API 契约和 PRD 生成基础测试框架，覆盖 Happy Path，并用 TODO 占位符预留边界、异常、并发等高级用例。人类稍后填补这些 TODO。
argument-hint: "模块名称（如 UserAuth）或具体功能描述"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
---

# Test Generator — AI 生成测试骨架

本 skill 严格按照 **"AI 生成基础 + 人类补充边界"** 模式，为指定模块生成初始测试代码。

## 前置条件

必须存在以下文件（否则报错并引导先执行 `/arch-workflow`）：
- `API_CONTRACT.yaml` 或对应的类型定义文件（Go struct / TS Interface / proto 等）
- `PRD`（或相关 feature 文档）
- 模块的 `ARCHITECTURE.md` 上下文

## 生成规则

1. **读取契约**
   解析 API 契约，提取模块的公共接口、方法签名、数据结构。

2. **生成测试框架**
   根据契约和 PRD 中的用户故事，生成：
   - 测试套件骨架（describe/it 块或 Go table-driven test）
   - Mock/Stub 初始化代码
   - 所有 Happy Path 测试用例（完整可运行的测试代码）
   - 对于每个接口方法，额外插入带有 `// TODO:` 的占位测试方法，明确标注需要人类补充的场景，例如：
     - `// TODO: 边界条件 — 输入为空字符串`
     - `// TODO: 异常路径 — 数据库连接超时`
     - `// TODO: 并发安全 — 100 个并发请求共享同一资源`
     - `// TODO: 极限数据 — 传入超大 payload (>10MB)`
   - **可观测性约束：** 如果当前模块是 RPC 边界（gRPC/HTTP handler）、消息队列消费者或复杂状态机，生成的测试骨架中**必须包含 Trace ID 透传测试（Context Propagation）**，以及对关键 Span 的 Mock 校验断言。这确保后续进行分布式根因分析时，代码插桩质量从一开始就是达标的。
   - 如果项目中已有测试工具库（如自定义 matchers、fixtures），复用它们。

3. **代码风格**
   遵循项目现有的测试风格（框架、断言库）。在文件顶部添加注释，说明哪些部分由 AI 生成，哪些部分需要人类完成。

4. **输出位置**
   将生成的测试文件写入模块对应的测试目录（如 `pkg/userauth/userauth_test.go` 或 `__tests__/userAuth.test.ts`）。如果测试文件已存在，则追加新的测试用例，不覆盖已有内容。

5. **生成测试意图清单**
   在模块测试目录下创建 `TEST_INTENT.md`，用一句话记录每个边界测试"到底在防御什么"：

```markdown
# Test Intent — <module_name>

## <MethodName>
- test_<name>: 防御 <场景描述> — 注释和测试打架时以此为准
- test_<name>: 防御 <场景描述>
```
  这是整个测试体系的**真值来源**——注释和测试都只是意图的表达，意图本身才是最终仲裁依据。后续 review 时对照此清单判断测试是否跑偏。

## 交接

完成后向用户说明：
- 测试文件路径及生成的测试数量
- 列出所有 `TODO` 项，方便用户逐个处理
- 提示下一步：请人工补充边界用例，然后执行 `/review-request`（可选）二审测试设计
