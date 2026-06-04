# detail-taro3 编码约定（与仓库配置对齐）

本文档与根目录 [`.prettierrc.js`](../../../../.prettierrc.js)、[`.eslintrc`](../../../../.eslintrc)、[`tsconfig.json`](../../../../tsconfig.json)、[`commitlint.config.js`](../../../../commitlint.config.js)、[`.cursorrules`](../../../../.cursorrules) 保持一致；若配置变更，请同步更新本节。

## 技术栈与范围

- **框架**：Taro 3 + React + TypeScript，样式以 **Less** 为主。
- **多端**：微信小程序、H5、React Native 等；业务代码需考虑 API/样式在各端的差异，具体样式策略见 [less-modular Skill](../../less-modular/SKILL.md)。

## ESLint

- **扩展**：`taro/react`、`prettier`、`plugin:prettier/recommended`；`plugins` 含 `prettier`。
- **React**：`react/jsx-uses-react`、`react/react-in-jsx-scope` 为 off（与 React 17+ JSX 转换一致）。
- **React Hooks**：`react-hooks/rules-of-hooks` 为 **error**；`react-hooks/exhaustive-deps` 为 **warn**（修改依赖数组需有明确理由，避免静默引入 bug）。

## TypeScript（`tsconfig.json`）

- **路径别名**（优先使用，避免深层相对路径混乱）：
  - `@/*` → `./src/*`
  - `@index/*` → `./src/pages/index/*`
- **建议关注**：`strictNullChecks: true`；`noUnusedLocals: true`；`noUnusedParameters: true`；`noImplicitAny: false`（遗留代码可能较宽，新代码仍应明确类型）。
- **JSX**：`jsx: react-jsx`。

## Git 提交（commitlint + 团队习惯）

**允许的 `type`**（与 [`commitlint.config.js`](../../../../commitlint.config.js) 一致）：

`feat` | `fix` | `docs` | `style` | `refactor` | `perf` | `test` | `chore` | `revert` | `workflow` | `ci` | `types` | `build` | `wip`

- **格式**：`类型: 描述`（中文描述可；`subject-case` 不强制英文大小写）。
- **示例**：`feat: 添加订单详情埋点`、`fix: 修复视频小窗在 RN 上闪退`。
- **Cursor「Generate Commit Message」**：生成**中文**提交说明（见 [`.cursorrules`](../../../../.cursorrules)）。

## React / Taro 习惯（补充）

- 函数组件 + Hooks；遵守上述 hooks 规则。
- 条件渲染与列表 `key` 保持合理稳定；避免在 render 中创建大量内联新函数/对象（除非有性能测量依据或体量很小）。
- 优先使用 Taro/React 官方文档与项目现有模式；**UI 组件**以 `@guazi-fe/koala-ui` 为准，见 [koala-skill](../../koala-skill/SKILL.md)。

## 跨端注意（简述）

- 使用条件编译或项目既有模式处理 `weapp` / `h5` / `rn` 差异；不要假设浏览器专有 API 在小程或 RN 可用。
- 样式与主题：见 [less-modular Skill](../../less-modular/SKILL.md)。

## 与「只做当前任务」一致

- 改动范围聚焦需求，不做无关重构；新增代码应与同目录风格一致。
