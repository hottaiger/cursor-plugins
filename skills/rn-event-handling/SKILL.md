---
name: rn-event-handling
description: RN 端事件处理规范与技巧。当在 Taro3 RN 端编写嵌套点击事件、处理触摸响应、遇到点击穿透/拦截问题时使用。涵盖条件性绑定 onClick 实现事件穿透、手动模拟冒泡、pointerEvents 等核心技巧。
---

# RN 事件处理规范与技巧

## 何时激活

- 编写含嵌套 `onClick` 的组件（父子层级都有点击事件）
- 遇到"点击子元素，父元素没反应"或"点击子元素，父元素被意外触发"的问题
- 需要子元素在某些条件下拦截点击、其他条件下穿透到父层
- 用户询问 RN 中事件冒泡、事件穿透相关问题

## 核心差异：RN 没有事件冒泡

Web 中事件默认冒泡（子 → 父），RN 中**内层组件只要绑定了 onClick/onPress，就会抢占响应权，外层不会触发**。

```
// Web：点击子元素，父的 onClick 也会触发（冒泡）
// RN：点击子元素，父的 onClick 不触发（内层优先抢占）
```

---

## 技巧一：条件性绑定 onClick 实现事件穿透

**场景**：子元素在某些条件下需要自己处理点击，其他情况下应该"透明"，让父元素的 onClick 生效。

**❌ 错误写法**（条件为假时仍绑定 onClick，阻断父级）：

```tsx
// 即使 condition 为假，onClick handler 存在本身就会拦截触摸，父级点击被阻断
<View onClick={(e) => condition && handleChild(e, data)}>
```

**✅ 正确写法**（条件为假时传 undefined，事件穿透到父层）：

```tsx
// 条件为假时不绑定 onClick，RN 不会拦截触摸，事件自然穿透到外层父元素
<View
  onClick={
    condition ? (e) => handleChild(e, data) : undefined
  }
>
```

**实际案例**（SimpleConfig/index.tsx）：

```tsx
// 外层：点击整个列表项跳转
<TrackerBeseenInView onClick={() => handlePop(item2, item)}>
  {/* 内层：只有 bottomBall 存在时才拦截，否则穿透到外层 */}
  <View
    onClick={
      item2?.bottomBall || item2?.equityJumpFlag
        ? (e) => showBottomBall(e, item2)
        : undefined
    }
  >
```

---

## 技巧二：子元素手动调用父逻辑（模拟冒泡）

**场景**：子元素有自己的点击逻辑，但在某些分支下需要执行父元素的逻辑。

```tsx
const handleChild = (data: Item2, parentData: Item) => {
  if (data.jumpUrl) {
    goNewPage(data.jumpUrl); // 子元素自己的逻辑
  } else {
    handleParent(parentData); // 手动"冒泡"到父逻辑
  }
};
```

---

## 技巧三：pointerEvents 禁止子元素响应触摸

**场景**：需要让某个区域完全不响应触摸，事件穿透到下层。

```tsx
<View pointerEvents="none">{/* 此区域内所有触摸事件穿透，不会被拦截 */}</View>
```

---

## 无效操作（RN 中禁止）

- `e.stopPropagation()` — **在 RN 中无效**，不要使用
- 依赖事件冒泡做事件委托 — RN 不支持，需改为逐层绑定

---

## 编写嵌套点击时的检查清单

1. 内层 View 是否有条件性的 onClick？→ 用三元表达式，条件为假时传 `undefined`
2. 子元素是否需要在某些情况下走父元素逻辑？→ 在子 handler 内手动调用父函数
3. 是否用了 `e.stopPropagation()`？→ **在 RN 中无效，删掉**
4. 是否需要整块区域穿透？→ 用 `pointerEvents="none"`
