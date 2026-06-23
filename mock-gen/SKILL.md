---
name: mock-gen
description: 基于 API_CONTRACT.yaml 为未就绪的依赖模块生成轻量 Mock/Stub，使当前模块能并行进入 TDD 循环，避免串行阻塞。由 /dep-status 在依赖未就绪时自动建议执行。
argument-hint: "目标模块名称（可选，默认根据 MODULE_DEPENDENCY.md 推断当前模块的缺失依赖）"
allowed-tools:
  - Read
  - Write
  - Glob
  - Bash
---

# Mock Generator — 契约驱动的轻量桩生成

当 `/dep-status` 发现前置依赖模块尚未通过门禁时，本 skill 被触发，用最小成本为该依赖生成一个行为可控的 Mock/Stub，允许当前模块**解除串行等待**，基于契约独立开发与测试。

## 前置条件

- 项目根目录下必须存在 `API_CONTRACT.yaml`（或等价类型定义文件），否则提示先执行 `/arch-workflow`。
- 已知当前模块名称（可由 `MODULE_DEPENDENCY.md` 与上下文推断）。

## 生成规则

### 1. 读取契约

解析 `API_CONTRACT.yaml` 中目标依赖模块的接口定义：
- 服务名
- 方法列表（名称、输入、输出、错误类型）

### 2. 选择 Mock 策略

根据依赖类型，选择默认策略（可被用户覆盖）：

| 依赖类型 | 默认策略 | 说明 |
|---------|---------|------|
| 内部服务（gRPC/HTTP） | **契约回放 Mock** | 根据契约定义的 output 返回固定合法响应，错误场景按 errors 定义模拟 |
| 数据库/缓存 | **内存实现** | 用内存 map 模拟简单 CRUD，行为记录在 `MOCK_BEHAVIOR.md` |
| 消息队列 | **同步回调桩** | 发布消息直接调用本地注册的 handler，不做真实网络调用 |
| 第三方 API | **可配置 Stub** | 生成可配置的 Stub，支持预设响应和延迟 |

### 3. 生成 Mock 代码

将 Mock 实现写入当前模块的测试工具目录（如 `pkg/<current_module>/testutil/mocks/` 或 `__mocks__/`）。

**要求：**
- 实现契约中定义的所有公共方法。
- 每个方法默认返回契约声明的合法响应（Happy Path），同时提供 `SetNextError()`、`SetResponse()` 等注入点，供后续测试中模拟异常。
- 代码顶部添加注释说明：
  ```
  // Auto-generated mock for <dependency_module> based on API_CONTRACT.yaml
  // Do not edit manually. Run /mock-gen to regenerate.
  // Behavior overrides: see MOCK_BEHAVIOR.md
  ```

### 4. 生成行为说明文件

在项目根目录或 mock 目录下创建/更新 `MOCK_BEHAVIOR.md`，记录：

```markdown
# Mock Behavior — <dependency_module>

- **Generated for:** <current_module>
- **Based on:** API_CONTRACT.yaml (version as of <timestamp>)
- **Default behaviors:**
  - Login: returns token "mock-token-123"
  - GetUser: returns user with id=1
- **Known limitations:**
  - Does not simulate token expiry
  - Does not enforce rate limiting
```

### 5. 质量检查

- 生成的 Mock 代码必须能编译通过（如果当前模块已有测试，应能链接成功）。
- 至少提供一个示例测试，展示如何使用该 Mock。

## 输出

完成后告知用户：
- Mock 文件路径
- `MOCK_BEHAVIOR.md` 路径
- 下一步：可以正常进入 `/test-gen` 和 TDD 循环，无需等待真实依赖

## 注意事项

- 当真实依赖模块通过门禁后，应移除对应的 Mock，恢复使用真实实现，并在集成测试中验证行为一致性。
- Mock 仅用于**开发与单元测试**，不可进入生产代码路径。
