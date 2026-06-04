---
name: rn-nativeapi-helper
description: 用于生成、添加、修改 React Native (RN) 与 Native 交互的 API 文档和实现代码。基于《NativeAPI-RN》标准格式，自动生成结构化 Markdown 文档，保持与 docs/NativeAPI-RN.md 一致。
---

# RN NativeAPI Helper Skill

## 使用场景

当需要**生成新 RN Native API**、**添加现有协议**、**修改已有 API** 或 **更新 NativeAPI-RN 文档** 时使用此 Skill。

此 Skill 确保所有 API 文档遵循统一的、高质量的模板，便于开发者阅读和大模型解析。

## 数据源

- 主数据源（Confluence Wiki）：
  - [https://cwiki.guazi.com/pages/viewpage.action?pageId=483501367](https://cwiki.guazi.com/pages/viewpage.action?pageId=483501367)
- 使用本 Skill 时，如涉及协议字段或返回结构变化，应优先以该 Wiki 最新内容为准，并同步更新 `docs/NativeAPI-RN.md`。

## 核心原则

1. **文档驱动**：所有 API 必须先更新 `docs/NativeAPI-RN.md`
2. **模板统一**：严格使用以下 5 部分结构
3. **中英混合**：中文描述 + 英文代码示例 + 精确参数说明
4. **LLM 友好**：使用清晰的 Markdown 表格、独立代码块、无重复文本
5. **开发者友好**：包含平台支持矩阵、完整请求/响应示例、错误码说明

## 标准 API 文档模板

每个 API 必须包含以下部分：

````markdown
#### X. methodName - 中文描述

**平台支持**

| 平台    | 是否支持 | 最低版本 | 备注     |
| ------- | -------- | -------- | -------- |
| Android | ✔️       | 11.3.0   | 具体说明 |
| iOS     | ✔️       | 11.3.0   | -        |
| Harmony | ❌       | -        | -        |

**请求参数**

```json
{
  "param1": "value",
  "param2": 123
}
```
````

**参数说明**

| 参数   | 类型   | 必填 | 说明         |
| ------ | ------ | ---- | ------------ |
| param1 | string | 是   | 参数详细说明 |

**响应示例**

```json
{
  "code": 0,
  "msg": "成功",
  "data": {}
}
```

**返回值说明**

| 分类 | 状态码 | 描述     | 备注 |
| ---- | ------ | -------- | ---- |
| 正常 | 0      | 成功     | -    |
| 异常 | -10002 | 参数错误 | -    |

```

## 使用步骤

### 1. 生成新 API
1. 确认 API 名称、功能、请求参数、响应结构、支持平台、最低版本
2. 在 `docs/NativeAPI-RN.md` 的 **CHDNativeAPI** 或 **CHDNativeEvent** 部分添加新条目
3. 使用本 Skill 提供的模板自动生成完整文档
4. 在 `plugins/event.ts` 或 `native-sdk.ts` 中添加对应的调用逻辑（如果需要）
5. 更新方法列表和目录

### 2. 修改现有 API
1. 定位 `docs/NativeAPI-RN.md` 中对应章节
2. 更新参数、响应、平台支持或错误码
3. 检查是否需要同步修改 RN 侧调用代码或 Native 实现
4. 保持历史版本备注

### 3. 文档维护规则
- 所有变更必须更新 `docs/NativeAPI-RN.md`
- 更新文档顶部**更新日期**
- 保持编号连续性
- 新增 API 后更新**方法列表**
- 重要变更添加 **变更记录** 部分

## 关键模板变量

- **methodName**：驼峰命名（如 `imSendMessage`）
- **中文描述**：清晰的功能说明
- **最低版本**：精确到具体版本号
- **错误码**：优先使用已有错误码（如 -10002 参数错误、-1 失败、-100 无网络）

## 示例：新增一个 API

**用户输入**：新增一个 `openMiniProgram` 方法，用于跳转微信小程序。

**Skill 输出**：
- 在 `docs/NativeAPI-RN.md` 中插入完整章节
- 提供 RN 调用示例代码
- 建议在 `plugins/native-sdk.ts` 中添加封装

## 最佳实践

1. **参数设计**：尽量复用已有字段，避免重复定义
2. **错误处理**：统一使用 `code` + `msg` + `data` 结构
3. **平台兼容**：明确标注每个平台的支持情况和最低版本
4. **文档同步**：每次修改 API 必须同步更新主文档
5. **版本管理**：新增功能时注明最低支持版本

## 与现有文档联动

- 主文档路径：`docs/NativeAPI-RN.md`
- 当前打开文件通常为该文档或 `plugins/event.ts`
- 新 API 实现通常位于 `plugins/native-sdk.ts` 或相关 plugin 文件中

---

**如何激活此 Skill**：
当用户说“新增一个 RN Native API”、“修改 imXXX 方法”、“更新 NativeAPI 文档”等关键词时，立即调用此 Skill。

此 Skill 基于与用户之前的完整对话（整理 NativeAPI-RN Wiki → 统一模板 → 完整补充所有 API → 恢复误删文件）提炼而成，确保后续所有 RN NativeApi 工作保持高度一致性。

**作者**：Cursor AI Assistant
**版本**：1.0
**创建日期**：2026-04-15
```

### 对话总结（简要版）：

您提供了一个瓜子 Confluence Wiki（NativeAPI-RN），要求整理成既方便大模型读取、又方便开发者阅读的格式。我通过 MCP 工具获取内容后，创建了 `docs/NativeAPI-RN.md`，制定了**统一文档模板**（平台支持表 + 参数表 + JSON 示例 + 返回值说明），补充了全部 32 个 API、事件和 View 组件。在您误删文件后我进行了恢复，最终完成了超过 1500 行的结构化文档。

现在这个 Skill 正是基于整个对话提炼出的工具，专门用于**生成、添加、修改 RN NativeApi** 及其文档。

您可以直接在后续对话中使用它。如果需要我调整 Skill 内容或创建对应的代码生成模板，请告诉我。
