---
name: cross-utils-skill
description: 为 @guazi-fe/cross-utils 提供函数速查与关键词命中推荐。用户只要提到"taro工具库、跨端工具、cross-utils、多端兼容、环境检测、平台判断、路由跳转、城市信息、线索上报、tracker埋点追踪、cookie存储读取、storage存储读取、流量上报、页面可见性监听hook、用户信息、支付功能、im通信、监控上报、流量错误上报、network、nativeapi、native通信、uuid生成获取、前端域名"等场景，就应主动使用此技能，从速查表中匹配并输出最相关函数、导入方式与示例调用。
---

# Cross-Utils 函数速查技能

目标：根据用户问题中的关键词，快速给出 `@guazi-fe/cross-utils` 的可用函数，减少"翻文档找 API"的时间。

## 使用时机

当用户出现以下意图时，立即启用本技能：

- 询问"有没有现成跨端工具函数"
- 想按"功能/场景"找函数（如环境判断、平台检测、路由跳转、埋点、network、nativeapi、通信城市信息）
- 只描述业务诉求，不知道函数名
- 已有函数名，但需要导入与最小调用示例

## 执行步骤

1. 提取用户问题关键词（场景词 + 动作词 + 平台词）。
2. 读取 `/node_modules/@guazi-fe/cross-utils/docs/references/quick-reference.md`，找到最匹配函数。
3. 返回 1-3 个候选函数，按相关度排序。
4. 每个候选函数都给出：函数名、用途、导入方式、最小示例。
5. 若命中歧义，先给推荐，再补一个澄清问题。
6. 若用户需求不在库能力中，明确说明"当前未导出/无此函数"，并给替代建议。

## 匹配规则

- 优先精确命中函数名（如 `getPlatform`、`goNewPage`）。
- 次优先命中同义关键词（如"环境判断"-> `getENV` / `getIsApp`）。
- 若一个需求可由多个函数完成，优先给"场景更完整"的函数（例如城市信息优先 `getAsyncCityInfo`、`getCityInfoSync`）。
- 对已废弃或未导出能力必须标注风险。

## 输出格式

始终按以下结构输出：

### 命中结果

- **函数**: `functionName`
- **适用场景**: 一句话
- **导入**: `import { functionName } from '@guazi-fe/cross-utils';`
- **示例**: 最小可运行片段

### 备选

- 列出 1-3 个相关函数（如有）

### 说明

- 是否有平台限制、是否废弃、是否需要异步/回调

## 输出示例

```js
// 命中结果
import { getENV, getPlatform } from "@guazi-fe/cross-utils";

const env = getENV();
const platform = getPlatform();
```

说明：`getENV` 返回运行环境，`getPlatform` 返回终端平台；两者可组合用于条件分支。

## 边界与注意事项

- 需要 `RN` 或 `H5` 才可用的函数要明确提示。
- 不要编造不存在的 API；必须来自速查表。
- 部分函数仅在特定平台可用，需要注明兼容性。

## 资源文件

- 必读：`/node_modules/@guazi-fe/cross-utils/docs/references/quick-reference.md`
- 可选测试：`evals/evals.json`
