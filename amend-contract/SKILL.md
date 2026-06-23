---
name: amend-contract
description: 在阶段二中，当实现过程发现基线契约需要调整时，发起轻量级修订：记录变更原因 → 更新契约文件 → 标记受影响模块为"需重新验证"。这是对"基线锁定"的受控打破，而非静默偏离。
argument-hint: "需要修订的契约内容简述"
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash
  - Grep
---

# Amend Contract — 受控的基线修订

本 skill 提供一种**显式、受追溯**的机制，在模块开发过程中安全地修改阶段一锁定的形式化契约（`API_CONTRACT.yaml`、`DB_SCHEMA.sql`、类型定义文件等）。它取代了"硬写代码再等阶段四漂移检测"的模式，让变更可回溯、可广播。

## 触发时机

- 编写实现或测试时，发现当前 API 契约缺少必要字段、参数或错误类型。
- 需要调整数据结构以解决性能问题或满足新的约束。
- 任何"按原契约实现会导致明显错误或无法实现"的场景。

## 流程

### 1. 描述变更

要求开发者（或 AI）描述：
- **变更类型**：添加字段 / 修改类型 / 删除接口 / 新增错误码 / 其他
- **影响范围**：涉及哪个模块、哪个方法
- **变更原因**：为什么原契约不适用（具体场景、错误、性能数据）
- **潜在影响**：哪些其他模块依赖此契约，是否会破坏它们的假设

### 2. 生成变更影响分析

基于 `MODULE_DEPENDENCY.md` 和 `API_CONTRACT.yaml`，自动列出所有**直接或间接依赖该契约的模块**，并标记为"需重新验证"。

示例输出：
```
Contract amendment impact:
- 修改方法: user-auth.Login (新增参数 device_id)
- 受影响模块:
  - order-core (depends on user-auth) → 需重新验证
  - payment-gateway (depends on user-auth, order-core) → 需重新验证
- 建议: 先更新 API_CONTRACT.yaml，然后通知受影响模块执行 /dep-status 重检。
```

### 3. 执行变更

在获得人类确认后，执行以下操作：
1. **更新契约文件**（如 `API_CONTRACT.yaml`），并在文件顶部或变更处注释说明修订原因、日期和关联 ADR 编号（若有）。
2. **生成增量 ADR**（如果是架构级决策），记录为何在实现阶段修改基线。
3. **更新 `MODULE_STATUS.md`**（如果存在），将受影响模块的状态从 ✅ 改为 ⚠️ REVALIDATE_REQUIRED。
4. **在 `MODULE_DEPENDENCY.md` 中受影响模块旁添加注释**，例如：
   ```
   2. user-auth ✅  (contract amended: 2026-06-23, see ADR-011)
   3. order-core (depends on user-auth) ⚠️ REVALIDATE_REQUIRED
   ```

### 4. 广播通知

向用户输出明确的下一步动作：
```
✅ 契约已修订: API_CONTRACT.yaml updated.
📢 需要重新验证的模块: order-core, payment-gateway
➡️ 请在这些模块中重新运行 /dep-status，必要时调整 Mock 或测试。
```

## 约束

- 不得跳过此 skill 直接修改契约文件——任何手动修改必须被 `/reconcile` 识别为漂移。
- 如果变更影响超过 2 个模块，**必须**生成一份 ADR，说明为何在开发中期修改基线。
- 如果变更导致已通过的模块门禁失效，**必须**先重新运行该模块的测试和 `/codereview --gate`，才能合并。

## 交接

完成后，提醒用户：
- 契约文件已更新
- 受影响模块列表已刷新
- 建议调用 `/adr` 记录此次修订
