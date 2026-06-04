---
name: method-jsdoc-comments
description: >-
  为 TypeScript/JavaScript 函数、Hook、类方法编写简洁明确的中文 JSDoc 注释。
  说明「做什么」而非实现步骤。在新增或修改 utils、hooks、service、store 导出 API、
  用户要求补注释/写方法说明/JSDoc/函数文档时使用。
---

# 方法注释（JSDoc）规范

> 与「代码自解释、少注释」并存：**导出 API 与跨文件调用的方法**默认要有**一句话职责说明**；组件内私有实现、样式、测试文件不在此 skill 强制范围。

---

## 核心原则

| 原则 | 要求 |
|------|------|
| **说做什么** | 动词开头：解析、拼出、格式化、校验、根据…返回… |
| **不说怎么做** | 不写 `先…再…`、不写与代码逐行对应的步骤 |
| **一句为主** | 1 行 JSDoc；仅在有非显而易见业务规则时加第 2 行 |
| **中文** | 注释用简体中文；类型名、类名、字段名保留英文 |
| **不重复类型** | 参数/返回值已在 TS 类型中表达时，不在注释里再抄一遍 |

---

## 必须写注释的范围

- `export function` / `export const xxx = () =>`（含箭头导出）
- `export` 的 class 对外 **public** 方法
- 自定义 **Hook** 的导出函数（`useXxx`）
- `utils.ts`、`service`、`store` slice 中供多处引用的函数

## 可不写或慎写注释的范围

| 场景 | 做法 |
|------|------|
| 组件 `index.tsx` 内未导出的 handler | 命名清晰即可，除非业务规则难懂 |
| 单行 getter、显而易见的 `return !!x` | 可不写 |
| 测试文件 `describe` / `it` | 用用例名表达意图，不强制 JSDoc |
| 仅 re-export 的 barrel 文件 | 不重复注释，注释写在定义处 |

---

## 注释模板

### 纯函数 / utils

```typescript
/**
 * 根据车价形态与首屏邻接关系，拼出 FirstScreenPrice 外壳的 className 字符串。
 */
export function buildFirstScreenPriceShellClassName(
  input: BuildFirstScreenPriceShellClassNameInput,
): string {
```

### 带业务优先级 / 互斥规则

第二行只写**调用方需要知道的规则**：

```typescript
/**
 * 解析首屏价外壳形态，优先级与 SimplePrice 渲染分支一致：新车 4S > 活动价 > 普通价。
 */
export function resolveFirstScreenPriceVariant(/* ... */): FirstScreenPriceVariant {
```

### Hook

```typescript
/**
 * 聚合首屏车价展示数据：格式化价格、补贴列表、外壳 className 与活动态。
 */
export function useFirstScreenPrice(/* ... */) {
```

### 异步 / 副作用函数

点明**副作用类型**（请求、跳转、写 Store），仍不写实现步骤：

```typescript
/**
 * 拉取同款在售列表并写入 sameCarOnSaleSlice。
 */
export async function fetchSameCarOnSaleList(clueId: string): Promise<void> {
```

### 类型 / 接口（可选）

仅当类型名无法表达用途时，在类型上一行注释：

```typescript
/** 拼外壳 className 的入参：形态标记 + 与 Banner/同款邻接 */
export interface BuildFirstScreenPriceShellClassNameInput {
```

---

## 正反例

### ✅ 合格

```typescript
/** 将 priceInfoV2 按场景（详情/分期）格式化为 SimplePrice 消费的结构。 */
export function formatPriceInfoV2(formatPriceData: any, priceScene: PriceScene) {}
```

```typescript
/** 判断首屏四模块在页面链中是否相邻（中间隐藏的面板不参与）。 */
export function areDetailFirstScreenModulesAdjacent(/* ... */): boolean {}
```

### ❌ 不合格

```typescript
// 遍历 classes 数组并用 join 拼接  ← 复述实现
/** @param input 入参对象 */  ← 无信息量
/** buildFirstScreenPriceShellClassName 方法 */  ← 重复函数名
/** 这是一个工具函数 */  ← 空洞
```

---

## 工作流程（Agent 执行）

1. **新增或修改导出方法时**：写完签名后立刻补 JSDoc，再写函数体。
2. **批量改文件时**：同一 PR 内 touched 的 `export function` / `useXxx` 应一并补齐，避免只注释一半。
3. **Review 自检**：
   - [ ] 每个本次新增/改名的导出函数都有 1 句职责说明
   - [ ] 注释里无「先/然后/接着」类流程描述
   - [ ] 含业务优先级、互斥、默认值来源时已写明
4. **不要求**给每个私有 `const handleXxx` 补注释，除非用户明确要求。

---

## 与项目其他规范的关系

| 规范 | 关系 |
|------|------|
| 可读性优先（AGENTS.md） | 命名 + 本 skill 注释，共同降低阅读成本 |
| testable-frontend-design | `utils` / `useXxx` 导出函数**建议**有注释，便于测试与 Code Review 对齐语义 |
| detail-taro3-coding-standards | 格式仍遵循 Prettier/ESLint；JSDoc 使用 `/** */` 块注释 |

---

## 快速检查命令（可选）

查找可能缺注释的导出函数（需人工判断是否真的需要）：

```bash
rg '^export (async )?function ' src --glob '*.ts' --glob '*.tsx' -n
```

对 `utils/`、`hooks/`、`service/` 目录优先核对。
