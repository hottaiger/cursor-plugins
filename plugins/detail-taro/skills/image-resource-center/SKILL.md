---
name: detail-image-assets
description: detail-taro3 图片与业务资源引用规范。用于新增、导出、移动、导入、评审或重构 PNG/JPG/WebP 等图片资源、资源 index.ts、CDN URL 与 resolveImageByEnv 用法。
---

# detail-taro3 图片与资源

约束业务图片落盘、从 Figma 导出后的接入方式，以及组件侧如何引用。

## 与 Figma 导出的关系

- 从 Figma 按节点导出 PNG（含倍率、校验等）时，遵循 **`.cursor/skills/figma-png-export/SKILL.md`**，在仓库根执行 **`.cursor/skills/figma-png-export/scripts/export_node_png_figma_api.sh`** 等流程（与 `skills/figma-png-export/` 下为同内容副本时二选一即可）。
- 导出文件落地到业务目录后，再按本节规则写入对应 **`index.ts`**。

## 基本规则

- 业务图统一放入 `src/assets/resources/<业务>/`，并通过 `src/assets/resources/<业务>/index.ts` 导出图片常量。
- 跨业务通用小图才放入 `src/assets/images`。
- 业务组件内禁止新增裸 CDN URL 或裸 `require('*.png')`。
- 业务组件只引用资源中心导出的图片常量。
- 命名优先扁平 key，采用“业务 + 场景 + 元素 + 状态”，例如 `guaziLightHeadTitle`。
- 业务组件 **禁止** 直接写 CDN URL。
- 业务组件 **禁止** 直接写 `require('*.png')`。

## 统一用 `resolveImageByEnv`（不在组件里分支多端）

- **唯一**允许的跨端选图方式：在 **`src/assets/resources/<业务>/index.ts`** 内使用 **`resolveImageByEnv`**（实现见 `src/assets/resources/utils/resolveImageByEnv.ts`）。
- **`resolveImageByEnv` 两个参数（顺序固定）**：
  1. **第一个参数：本地图** — RN 端走离线包，须为同目录下业务 PNG 的 **`require('./xxx.png')`**（即本地落盘资源的打包引用，不要用外链占位）。
  2. **第二个参数：云端地址** — 非 RN 端使用的 **CDN 静态 URL**（如 `https://image-pub.guazistatic.com/...`）。业务图经 CDN 上传后，将接口返回的 **`globalUrl`**（或等价可长期访问的 URL）填入此处；上传流程、MCP 参数与 **`figma-png-export` 落盘后再上传** 的约束见 **`.cursor/skills/image-resource-center/SKILL.md`** 中「CDN 上传流程」一节。
- 运行时语义：`TARO_ENV === 'rn'` 时取第一个参数，否则取第二个参数。组件内 **不写** `TARO_ENV`、**不** 再包一层多端 if/else；只使用 `index.ts` 已解析好的字符串（如 `src={priceImages.xxx}`）。

## `index.ts` 导出写法

### resolveImageByEnv（首屏推荐）

- **每条导出**都写 **`resolveImageByEnv(require('./与 key 对应的 png'), 'globalUrl')`**，**不要把** `require` 先赋给文件顶层的 `const`（少声明、风格统一，见 `src/assets/resources/price/index.ts`）。
- 文件顶用 **一段短 JSDoc** 说明「首参 RN、次参同源 CDN」即可；每个 key 上一行 **`//`** 说明场景。
- **例外**：多个 export **共用同一份本地 PNG** 时，允许 **一个** `const` 持有 `require`，多处 `resolveImageByEnv(该 const, …)`，并在注释里写明「与 xxx 同文件」。

### globalUrl（非首屏场景）

对图片加载速度要求不高的非首屏场景，可以直接写 CDN URL，减少 RN 离线包体积：

```ts
export const checkReportImages = {
  // 官方自营三非条；非首屏，使用直接 URL
  guaziLightHeadSanfeiOfficial:
    'https://image-pub.guazistatic.com/qnbdp2744x7955ce86b9ee4e8992192646000050b01778138319.png',
};
```

示例（业务目录 `price`；`globalUrl` 须与上传响应一致）：

```ts
import { resolveImageByEnv } from '../utils/resolveImageByEnv';

/** RN：require；其它端：同源图 CDN globalUrl。 */
export const priceImages = {
  // 场景说明
  personalDirectExclusivePriceWrapBg: resolveImageByEnv(
    require('./personal-direct-exclusive-price-wrap-bg.png'),
    'https://image-pub.guazistatic.com/....png',
  ),
};
```

组件侧示例：

```tsx
import { priceImages } from '@/assets/resources/price';

<Image src={isPersonalDirectSale ? priceImages.personalDirectExclusivePriceWrapBg : bgExclusivePrice} />;
```

## Workflow

1. 确认或新建 **`src/assets/resources/<业务>/`**。
2. Figma 导出 PNG 后放入该目录（流程见 **figma-png-export**）。
3. 本地图经 CDN 上传得到 **`globalUrl`** 后，在 **`index.ts`** 按上文 **「`index.ts` 导出写法」** 逐条内联 **`resolveImageByEnv(require('./xxx.png'), 'globalUrl')`**，导出 **`xxxImages` 对象**（或等价命名）。
4. **上传失败时**：须按 **`.cursor/skills/image-resource-center/SKILL.md`** 中「**CDN / MCP 上传失败时**」一节，**向用户说明原因**（错误信息、环境限制、未返回 `globalUrl` 等），**禁止** 静默或编造 CDN 地址；未拿到 `globalUrl` 时若暂用双 `require` 等折中方案，须在代码注释或回复中写明待替换。
5. 组件 **`import`** 业务资源模块字段，**禁止** 裸 URL / 裸 `require`。

## 校验与评审

- PR 中检查：无组件内直链 CDN、无组件内散落的 `require` 图片路径。
