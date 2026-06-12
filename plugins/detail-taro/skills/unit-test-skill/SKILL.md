---
name: unit-test-skill
description: detail-taro3 单元测试规范。编写 React Hook 的单元测试时使用；结构拆分请先走 testable-frontend-design。当用户提到"写单元测试、加测试用例、hook 难以测试、依赖注入、jest mock、renderHook"时触发。
---

# Unit Test Skill

## 第一步：检查结构是否可测

先按 **testable-frontend-design** 过自检（UI/Logic 分离、deps、测试范围）。再打开 hook 文件，检查以下问题：

**副作用函数是否硬编码导入？**
```typescript
// ❌ 有问题：测试时只能整包 mock，粒度粗
import { goNewPage, sendTrack } from '@guazi-fe/cross-utils';
import { checkLoginAndExec } from '@/utils/check-login';
```

如果 hook 内部直接 import 并调用副作用函数（跳转、埋点、网络请求、登录弹窗），必须先做 deps 注入改造，再写测试。

---

## 第二步：deps 注入改造（如需）

### 规则
- 副作用函数 ≤1 个：直接平铺为参数
- 副作用函数 ≥2 个：归组为 `deps` 对象，与业务数据分层

### 模板

```typescript
// 1. 别名导入原始函数
import { goNewPage as _goNewPage, sendTrack as _sendTrack } from '@guazi-fe/cross-utils';
import { checkLoginAndExec as _checkLoginAndExec } from '@/utils/check-login';

// 2. 声明 deps 接口
export interface XxxDeps {
  goNewPage: (url: string) => void;
  sendTrack: (params: Record<string, unknown>) => void;
  checkLoginAndExec: (opts: CheckLoginOptions) => void;
}

// 3. 生产默认值（调用方无感知）
const defaultDeps: XxxDeps = {
  goNewPage: _goNewPage,
  sendTrack: _sendTrack,
  checkLoginAndExec: _checkLoginAndExec,
};

// 4. hook 参数加 deps，内部通过 deps.xxx() 调用
export const useXxx = ({ data, deps = defaultDeps }: Options) => {
  const { goNewPage, sendTrack, checkLoginAndExec } = deps;
  // ...
};
```

组件调用侧不需要任何改动：`useXxx({ data })` 照旧。

---

## 第三步：写测试文件

### 文件位置
```
__tests__/<ComponentName>/useXxx.test.ts
```

### 固定结构

```typescript
import { renderHook, act } from '@testing-library/react';
import { useXxx } from '@/path/to/useXxx';
import type { XxxDeps } from '@/path/to/useXxx';

// 顶部：只 mock 测试运行必须的模块（路由别名解析等）
jest.mock('@guazi-fe/cross-utils', () => ({ goNewPage: jest.fn(), sendTrack: jest.fn() }));
jest.mock('@/utils/check-login', () => ({ checkLoginAndExec: jest.fn() }));
jest.mock('@/pages/index/utils/moduleId', () => ({
  xxxModuleId: { exposure: 'exposure_id', click: 'click_id' },
}));

// 工厂函数：管理测试数据，只写关心的字段
function makeDeps(overrides: Partial<XxxDeps> = {}): XxxDeps {
  return {
    goNewPage: jest.fn(),
    sendTrack: jest.fn(),
    checkLoginAndExec: jest.fn(),
    ...overrides,
  };
}

function makeData(overrides = {}) {
  return {
    show: true,
    jumpUrl: 'https://example.com',
    // ...合理默认值
    ...overrides,
  };
}

describe('useXxx', () => {
  describe('分组名（对应一个输出字段或一类行为）', () => {
    it('具体行为描述', () => {
      // Arrange
      const { result } = renderHook(() =>
        useXxx({ data: makeData(), deps: makeDeps() }),
      );

      // Act（如果需要触发行为）
      act(() => result.current.handlePress());

      // Assert
      expect(result.current.show).toBe(true);
    });
  });
});
```

---

## 覆盖矩阵：每条分支一个用例

遇到 `if / else / ?:` 必须每条分支写用例：

```typescript
// 对应代码
if (!replacePrice) return '***万';
if (replacePrice.value === 0) return '0元';
return `${replacePrice.priceDes}${replacePrice.unit}`;

// 对应三个用例
it('replacePrice 为 null 时显示 ***万', ...)
it('replacePrice.value 为 0 时显示 0元', ...)
it('replacePrice 有正常值时拼接 priceDes + unit', ...)
```

---

## 关键 Mock 模式

### 控制"外部事件"触发时机

```typescript
// 已登录：立即同步触发 onAlreadyLoggedIn
const checkLoginAndExec = jest.fn(({ onAlreadyLoggedIn }) => onAlreadyLoggedIn?.(null));

// 未登录（只弹框，不触发任何 callback）
const checkLoginAndExec = jest.fn();

// 新登录成功：立即同步触发 onLoginSuccess
const checkLoginAndExec = jest.fn(({ onLoginSuccess }) => onLoginSuccess?.(null));
```

### 测试两阶段流程（点击 → 等 prop 刷新 → 副作用）

```typescript
const { result, rerender } = renderHook(
  ({ data }) => useXxx({ data, deps }),
  { initialProps: { data: makeData() } },
);

// 阶段一：触发点击，设置内部标记
act(() => result.current.handlePress());

// 阶段二：模拟父组件 prop 更新（页面数据刷新）
act(() => rerender({ data: { ...makeData() } }));

expect(goNewPage).toHaveBeenCalledWith('https://example.com');
```

---

## 禁止事项

| 禁止 | 原因 |
|---|---|
| `jest.mock` 整包替换后不按用例隔离 mock 行为 | 用例间互相污染，顺序敏感 |
| 直接操作 hook 内部 ref / state | mock 了内部实现，重构即失效 |
| 只写 happy path，不写边界和失败分支 | 测试无法保护回归 |
| 在 `jest.mock()` 工厂函数里引用外部变量（如 `React`） | Jest 会报错，改用 `require('react')` |

---

## 更多细节

参考 `docs/unit-test-methodology.md`（方法论完整版，含副作用定义、mock 边界原则解释）。
