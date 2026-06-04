---
name: testable-frontend-design
description: detail-taro3 前端可测试代码结构设计规范（UI / Logic 分离、Hook、纯函数、Store 接入）。在新建或修改页面功能、组件、Hook 之前使用，确保逻辑可单测、UI 保持薄层。当用户提到「UI 和 logic 分离、可测试结构、deps 注入、新建组件、业务逻辑放哪」时触发。与 unit-test-skill 配合：本 skill 管结构设计，unit-test-skill 管测试写法。默认不测 UI 组件层。
---

# Testable Frontend Design

> 面向 detail-taro3 前端开发：**先定结构，再写代码，再进 TDD**。
> 本 skill 覆盖 Hook 之外的常见落点；Hook 仍是**承载业务逻辑的首选位置**。

---

## 核心原则

| 原则 | 含义 |
|------|------|
| **UI 与 Logic 分离** | `index.tsx` 只负责渲染与事件绑定；分支、副作用、状态机在 Hook / 纯函数里 |
| **可测试性前置** | 结构在 RED 之前定好，避免「先写实现 → 写测试时发现 mock 不了」 |
| **测 Logic，不测 UI** | 单元测试覆盖 Hook + 纯函数；组件层暂不写单测（样式、布局、埋点容器用人工 / E2E） |
| **副作用可替换** | 跳转、埋点、登录、请求、Native 必须能注入 mock |

**判断标准**：给定相同输入，纯逻辑是否总能得到相同输出？若否，说明混入了不可控副作用。

---

## 第一步：判断本需求属于哪种形态

实现前先选形态，**禁止**把所有逻辑堆进 `index.tsx`。

| 形态 | 特征 | Logic 放哪 | 测什么 |
|------|------|------------|--------|
| **A. 纯展示** | 无点击副作用，仅根据 prop 显隐 / 文案 | 父级或极薄 Hook；复杂格式化 → `utils.ts` | 有分支则测 `utils`；否则可不写单测 |
| **B. 交互区块**（最常见） | 点击、登录、跳转、埋点 | `useXxx.ts` + 可选 `utils.ts` | **Hook** + 纯函数 |
| **C. 列表 / 表单项** | 多条数据映射、选中态 | `useXxx.ts`；映射逻辑可抽 `mapXxxItems` | Hook + 纯函数 |
| **D. 强依赖 Store** | 读写 PageStore / Zustand | `useXxx.ts` 内 selector + setter；Store 动作经 deps 注入 | Hook（mock deps） |
| **E. 跨模块编排** | 多个子区块组合 | Feature 入口 Hook 或父组件 Hook 编排子 Hook | 各子 Hook 分别测 |

**默认选型**：有交互或 2 个以上分支 → **形态 B**，建 `useXxx.ts`。

---

## 第二步：目录与文件职责（标准 Feature 结构）

> **仓库落点**（`features/Common` vs `pages/index/hooks`、页面挂载、白名单）见 **detail-structure-naming**（`skills/detail-structure-naming/SKILL.md`）。本节只讲 **Feature 目录内部** 怎么拆。

```
FeatureName/
├── index.tsx           # UI：JSX、className、绑定 handleXxx
├── index.less          # 样式（RN 禁止 background-image）
├── useFeatureName.ts   # Logic：状态、副作用、派生字段（与 Feature 同域命名）
├── utils.ts            # 可选：纯函数（格式化、校验、映射）
└── types.ts            # 可选：入参 / 出参类型
```

### Hook 归属决策

| 条件 | Hook 放哪 |
|------|-----------|
| 逻辑服务**一个** Feature（UI + utils + Tab/显隐/文案状态），被 1～N 个页面编排 | **`Feature/useXxx.ts`**（推荐，如 `DetailFinanceTabBar/useDetailFinanceTab.ts`） |
| 逻辑围绕**页面级**能力（同款吸顶、横向滚动同步、PanResponder） | **`pages/index/hooks/`**（如 `useSameCarOnSale`） |
| **禁止** | `pages/index/hooks/` 中的 hook 再 `import` 某 Feature 的 `utils`（依赖倒挂） |
| **禁止** | 与 Feature 无关的 hook 名（如 `useSameCarOnSaleTab` 管理 `DetailFinanceTabBar`） |

### 页面编排

- 页面（`FuelVehicle` / `NewEnergy`）从 Feature 目录 `import` 组件与 `useXxx`，负责 **兄弟节点挂载**与内容区互斥（如 `installment ? <BuyCar /> : <CarBaseInfo ...>`）。
- 独立 Tab/UI 组件保持薄层，状态由 Feature 内 hook 提供，通过 props 下发。

### 测试目录（镜像 src）

```
__tests__/pages/index/features/Common/FeatureName/
├── utils.test.ts
└── useFeatureName.test.ts    # 不测 index.tsx / index.less
```

### `index.tsx`（UI 层）—— 允许做什么

```tsx
const TradeInEntrance = ({ tradeInEntrance }: Props) => {
  const { show, priceText, handlePress, replacementStatus } = useTradeInEntrance({ tradeInEntrance });

  if (!show) return null; // ✅ 仅消费 hook 的 show，不在此写业务分支

  return (
    <TrackerBeseenInView trackParams={{ replacement_status: replacementStatus, /* ... */ }}>
      <View onClick={handlePress}>
        <Text>{priceText}</Text>
      </View>
    </TrackerBeseenInView>
  );
};
```

| 允许 | 禁止 |
|------|------|
| 使用 Hook 返回值渲染 | `onClick` 内写 `if (loggedIn) goNewPage(...)` |
| `if (!show) return null`（显隐由 Logic 决定） | 直接 `import` 并调用 `goNewPage` / `sendTrack` |
| 把 Hook 提供的字段填入 `trackParams` | `useEffect` 里发请求、改 Store |
| `memo` 包裹无状态展示组件 | 在组件内 `useState` 承载业务流程状态 |

### `useXxx.ts`（Logic 层）—— 必须承载什么

- 显隐、文案、枚举态等**派生状态**
- 事件处理（`handlePress`、`handleSubmit`）
- 副作用编排（登录 → 跳转、曝光埋点）
- 多阶段异步（登录成功 → 等 prop 刷新 → 跳转）

### `utils.ts`（纯函数层）—— 何时抽出

满足任一即抽出：

- 同一计算在 Hook 与测试中都要用
- `if/else` 超过 2 层或单函数超过 ~15 行
- 输入输出明确，无 Hook / 无副作用

```typescript
export function computePriceText(replacePrice: ReplacePrice | null): string {
  if (!replacePrice) return '***万';
  if (replacePrice.value === 0) return '0元';
  return `${replacePrice.priceDes}${replacePrice.unit}`;
}
```

测试：`expect(computePriceText(input)).toBe('...')`，无需 `renderHook`。

---

## 第三步：识别副作用（全文件扫描）

在 **Hook 或 utils** 中列出所有副作用调用：

| 类型 | 本项目常见 API |
|------|----------------|
| 页面跳转 | `goNewPage` |
| 埋点 | `sendTrack` |
| 登录弹窗 | `checkLoginAndExec` |
| 网络 | `getUserInfo`、`requestXxx` |
| Native | bridge / `NativeApi` |
| Store 写操作 | `setXxx`、`updateSlice` |

> 调用后改变了「函数外部的世界」（UI、网络、存储）即为副作用。

---

## 第四步：副作用注入策略

| 情况 | 做法 |
|------|------|
| Hook 内直接 `import` 并调用副作用 | **必须** deps 注入 |
| 副作用已由父组件通过 prop 传入 | 已可测，无需再包一层 deps |
| 仅纯计算、无副作用 | 直接 TDD，用 `utils` 或裸 Hook |
| 组件 `index.tsx` 内出现副作用 import | **违规**，上移到 Hook |

### deps 规则

- 副作用 **≤ 1 个**：可平铺为 Hook 可选参数
- 副作用 **≥ 2 个**：归组为 `deps` 对象
- **业务数据**（`tradeInEntrance`、`list`）与 **deps** 分参数：前者每次渲染变，后者生产环境固定、仅测试替换

### Hook 标准模板

```typescript
import { goNewPage as _goNewPage, sendTrack as _sendTrack } from '@guazi-fe/cross-utils';
import { checkLoginAndExec as _checkLoginAndExec } from '@/utils/check-login';

export interface XxxDeps {
  goNewPage: (url: string) => void;
  sendTrack: (params: Record<string, unknown>) => void;
  checkLoginAndExec: (opts: CheckLoginOptions) => void;
}

const defaultDeps: XxxDeps = {
  goNewPage: _goNewPage,
  sendTrack: _sendTrack,
  checkLoginAndExec: _checkLoginAndExec,
};

export interface UseXxxOptions {
  data: XxxData | null | undefined;
  deps?: XxxDeps;
}

export const useXxx = ({ data, deps = defaultDeps }: UseXxxOptions) => {
  const { goNewPage, sendTrack, checkLoginAndExec } = deps;
  // 纯计算 → useMemo 或 utils
  // 副作用 → useCallback / useEffect，且只通过 deps 调用
};
```

**组件调用侧零改动**：`useXxx({ data })`。

---

## 第五步：Hook 内部分层（Logic 内部）

```
┌─────────────────────────────────────┐
│  useXxx                             │
│  ├─ 纯计算：useMemo / utils         │  ← 优先单测 utils
│  ├─ 事件：useCallback(handleXxx)    │  ← renderHook + act
│  └─ 副作用：useEffect + deps.xxx()  │  ← mock deps 断言调用
└─────────────────────────────────────┘
```

- **纯计算**与**副作用调用**不要写在同一个未拆分的函数里
- 复杂 `useMemo` 逻辑优先下沉到 `utils.ts`

---

## 第六步：多阶段流程显式建模

「A 触发 → 等外部事件 → B 执行」必须用显式中间状态：

```typescript
const pendingJumpAfterLogin = useRef(false);

// 阶段一：handlePress
onLoginSuccess: () => { pendingJumpAfterLogin.current = true; }

// 阶段二：data 更新后 effect
useEffect(() => {
  if (!pendingJumpAfterLogin.current) return;
  pendingJumpAfterLogin.current = false;
  if (data?.show && data.jumpUrl) goNewPage(data.jumpUrl);
}, [data]);
```

测试：`act(handlePress)` → `rerender(newData)` → 断言 `goNewPage`，不依赖真实时序。

---

## 第七步：Store / 父组件数据

| 场景 | 做法 |
|------|------|
| 只读 Store | Hook 内 `usePageStore(selector)`；selector 保持纯函数 |
| 写 Store | 写入函数放进 `deps` 或封装为 `deps.updateXxx` |
| 父组件下发 prop | Hook 只消费 prop；不在子组件再请求一份 |
| 路由 / 页面参数 | 在 Feature 入口 Hook 读取，向下传业务 data |

**禁止**：在 `index.tsx` 里 `usePageStore` 再写一长串业务分支。

---

## 第八步：测试范围（本项目约定）

| 层级 | 是否写单测 | 说明 |
|------|------------|------|
| `utils.ts` 纯函数 | ✅ 推荐 | 成本低、收益高 |
| `useXxx.ts` | ✅ 必须（有逻辑时） | `renderHook` + `makeDeps` |
| `index.tsx` | ❌ 暂不写 | 布局、样式、Tracker 容器；回归靠人工 / E2E |
| `index.less` | ❌ | — |
| Store slice | 视情况 | 有复杂 reducer 再单测 slice |

组件层若只需验证「`show=false` 不渲染」，**优先在 Hook 测试 `show`**，不为 `index.tsx` 单独写 `render(<Component />)`，除非后续引入 UI 测试策略。

---

## 形态速查：没有 Hook 时怎么办

| 场景 | 结构建议 |
|------|----------|
| 子组件仅展示父传入的 `label`、`onClick` | 无 Hook；父级 Hook 测逻辑 |
| 逻辑 < 5 行且无副作用 | 可放父 Hook，不强行拆文件 |
| 逻辑有副作用 | **必须**独立 `useXxx.ts` |
| 多个兄弟组件共享逻辑 | 抽 `useSharedXxx.ts`，兄弟组件只渲染 |
| 工具函数被多处引用 | `utils.ts`，与 UI 无关 |

---

## 反模式（见到就改）

| 反模式 | 问题 | 改法 |
|--------|------|------|
| `index.tsx` 里 `goNewPage` / `sendTrack` | UI 层不可测、难 mock | 移到 Hook + deps |
| Hook 内 200 行未拆分 | 难测、难维护 | 抽 `utils` + 小 Hook |
| 测试里 mock 组件内部 state/ref | 绑死实现 | 只 mock 边界 deps |
| 为测 UI 而测 `className` | 脆、价值低 | 改测 Hook 输出字段 |
| 先写实现再补 deps | 走 TDD 弯路 | 先过本 skill 自检再 RED |

---

## DESIGN 阶段：写入 design.md

Phase 3 **[DESIGN]** 须将 **Feature 内文件树**、形态、deps 概要、单测范围写入变更文档：

`openspec/changes/<change-name>/design.md` → **`## 目录结构（待确认）`**

与 **detail-structure-naming** 填写的落点清单合并为同一节。**用户书面确认该节后**，方可进入 RED / 写实现。

填写说明见模板：`openspec/schemas/spec-driven/templates/design.md`。

---

## 可测性自检清单（TDD / RED 之前必过）

**门禁**

- [ ] `design.md` 的 `## 目录结构（待确认）` 已填写且 **用户已确认**

**结构与职责**

- [ ] 已选定形态（A–E），交互类默认有 `useXxx.ts`
- [ ] `index.tsx` 无业务分支、无副作用 import、无流程型 `useState`
- [ ] 复杂计算在 `utils.ts` 或 Hook 内 `useMemo`，且可单独测

**副作用**

- [ ] 已列出全部副作用
- [ ] Hook 内副作用均通过 `deps`（或 prop）调用，生产有 `defaultDeps`
- [ ] 多阶段流程有 `useRef` 等显式标记

**测试范围**

- [ ] 明确本需求单测目标：Hook / utils，不写 `index.tsx` 单测
- [ ] BDD 场景已映射到 Hook 行为（非 DOM 细节）

全部通过 → 使用 **unit-test-skill** 进入 RED → GREEN → REFACTOR。

---

## 与 unit-test-skill 的分工

| skill | 职责 |
|-------|------|
| **testable-frontend-design**（本 skill） | 文件怎么拆、Logic 放哪、deps 怎么设计、测哪一层 |
| **unit-test-skill** | `renderHook`、`makeDeps`、mock 模式、用例结构 |

---

## 参考实现

- UI / Logic 分离：`TradeInEntrance/index.tsx` + `useTradeInEntrance.ts`
- deps 注入 + 两阶段登录跳转：`useTradeInEntrance.ts`
- 纯函数：`computePriceText`（若在 utils 或 hook 同文件导出）
- Feature 包 + 页面兄弟挂载 + Hook 在 Feature 内：`DetailFinanceTabBar/`（`index.tsx`、`utils.ts`、`useDetailFinanceTab.ts`；`FuelVehicle` / `NewEnergy` 中 TabBar 在同款在售下方）

完整测试写法见 `docs/unit-test-methodology.md`。
