---
name: koala-skill
description: 当用户在 taro项目中 已经使用或者想使用 @guazi-fe/koala-ui 组件库进行构建或重构移动端 UI 页面（按钮、表单、列表、弹窗、低弹、toast提示、卡片、导航等）时激活。优先检索并复用 @guazi-fe/koala-ui 组件，确保所有组件用法有文档或源码依据，仅当组件库无法覆盖需求时才允许业务自定义实现。
---

# koala-skill

优先检索并复用 `@guazi-fe/koala-ui` 组件库完成 taro 页面构建，仅当组件库无法覆盖需求时才允许业务自定义补充实现。

## Instructions

### 核心原则（强约束）

1. 所有 UI 结构**必须优先使用 @guazi-fe/koala-ui 组件**实现
2. **禁止**直接使用原生 taro 基础组件替代已有 @guazi-fe/koala-ui 组件
3. **禁止**引入其他第三方 UI 库（如 taroify / @antmjs/vantui 等）
4. 所有组件用法**必须有文档或源码依据**
5. **不允许**臆造组件 Props参数 / Events事件

### Step 1. 组件库引入

只有当用户初始化引入了 `@guazi-fe/koala-ui` 组件库时，才需要读取`node_modules/@guazi-fe/koala-ui/docs/references/quick-start.md`，进行快速上手引导，确保用户正确引入组件库并具备基本使用能力。


### Step 2. 解析用户 UI 结构

将用户描述的页面拆解为结构化 UI 模块清单，逐一标注模块类型（容器布局 / 导航 / 表单 / 按钮 / 列表 / 卡片 / 弹窗 / 反馈 / 视图等）。

> 如需查看完整的组件分类速查表和输出格式示例，读取 `node_modules/@guazi-fe/koala-ui/docs/references/component-categories.md`

如果用户描述的 UI 模块过于模糊或不完整，无法明确模块类型或功能意图，可以查看组件库具体页面示例`https://koala.guazi-cloud.com/h5/index.html#/pages/index/index`，并结合用户描述进行合理推断。

### Step 3. 组件库检索

按 P0 → P1 → P2 优先级逐级检索可复用组件，仅当前一级无法满足时才降级。

> 如需查看各优先级的具体检索路径和策略，读取 `node_modules/@guazi-fe/koala-ui/docs/references/component-lookup.md`

### Step 4. 生成代码

- 根据组件文档 / 源码中的 Props参数、Events事件 编写代码
- 组件引用路径统一使用 `@guazi-fe/koala-ui`
- 输出完整可运行的 Taro React函数式组件 文件

## 相关链接
[koala-ui官方文档](https://koala-ui.guazi.com/#/docs/introduction)