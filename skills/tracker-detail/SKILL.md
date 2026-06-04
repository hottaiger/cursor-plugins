---
name: tracker-detail
description: detail-taro3 埋点实现规范。用于新增、修改、评审埋点（曝光/点击/导航点击），以及 moduleId 管理。当用户提到埋点、曝光、点击上报、beseen、sendTrack、TrackerBeseenInView、moduleId 时使用。
---

# tracker-detail

## 三类事件

### 1. 曝光（beseen）

使用 `TrackerBeseenInView` 包裹目标区块，`trackParams` 只传 `moduleId`，组件自动触发 `beseen`：

```tsx
import { TrackerBeseenInView } from '@/components/tracker-beseen';
import { xxxModuleId } from '@/pages/index/utils/moduleId';

<TrackerBeseenInView
  className="..."
  trackParams={{ moduleId: xxxModuleId.exposure }}
>
  {children}
</TrackerBeseenInView>
```

> 若需要在曝光时附加业务字段，直接加进 `trackParams`：
> `trackParams={{ moduleId: xxxModuleId.exposure, replacement_status: 'default' }}`

### 2. 点击（click）

```tsx
import { sendTrack } from '@guazi-fe/cross-utils';
import { xxxModuleId } from '@/pages/index/utils/moduleId';

sendTrack({
  moduleId: xxxModuleId.click,
  // 业务字段（可选）：
  type: 'tel',   // 同一模块内的子行为区分
  clueId,
});
```

> `sendTrack` 默认 `tracking_type: 'click'`，**无需显式传入**。

### 3. 导航点击（跳转时一并上报）

```tsx
import { goNewPage } from '@guazi-fe/cross-utils';
import { xxxModuleId } from '@/pages/index/utils/moduleId';

goNewPage(url, {
  sendTrack: true,
  track: {
    moduleId: xxxModuleId.click,
    type: 'store',   // 业务字段
  },
});
```

---

## moduleId 管理

所有 moduleId **必须**集中定义在 `src/pages/index/utils/moduleId.ts`，禁止在组件或 hook 内硬编码字符串：

```ts
// moduleId.ts
/** XXX 模块 */
export const xxxModuleId = {
  exposure: 'module-action',   // 曝光
  click: 'module-action',      // 点击
};
```

**moduleId 来源**：由需求文档埋点表格中的 `module` 字段与 `action` 字段以 `-` 拼接而成：

```
moduleId = `${module}-${action}`
// 示例：module="replacement", action="replacement" → "replacement-replacement"
```

## 业务字段（extra）平铺规则

需求文档埋点表中 `extra` 列下的字段，在代码中**与 `moduleId` 同级**传入，不得嵌套在 `extra: {}` 对象中：

```tsx
// ✅ 正确：extra 字段平铺
sendTrack({
  moduleId: xxxModuleId.click,
  tracking_type: 'click',
  replacement_status: 'default',   // extra.replacement_status → 平铺
});

// ✅ 正确：trackParams 中同样平铺
trackParams={{
  moduleId: xxxModuleId.exposure,
  replacement_status: status,
}}

// ❌ 错误：不要嵌套 extra
sendTrack({
  moduleId: xxxModuleId.click,
  extra: { replacement_status: 'default' },
});
```

---

## 评审清单

- [ ] 曝光用 `TrackerBeseenInView`，不手动调 `sendTrack` 发 beseen
- [ ] `trackParams` 仅含 `moduleId` + 必要业务字段，无冗余参数
- [ ] 点击用 `sendTrack`，导航点击用 `goNewPage + sendTrack: true`
- [ ] 所有 `moduleId` 来自 `moduleId.ts`，无内联字符串
- [ ] 无重复上报风险（避免在 `useEffect` 依赖频繁变化时触发）

---

## 参考实现

`src/pages/index/features/Common/CarBaseInfo/components/SimpleStore/index.tsx`
