---
name: taro-rn-codegen
description: 为本项目（Taro3 + React Native + TypeScript + Less）生成符合项目规范的组件、页面、service hook、store slice 代码。当用户需要新建组件、feature 模块、service、store 时调用此技能。
---

# Taro RN 代码生成规范

此技能用于在本项目中生成符合规范的代码，覆盖三个维度：

- **模板（Template）**：组件 JSX 结构规范 → [docs/template.md](./docs/template.md)
- **样式（Style）**：Less 文件规范 → [docs/style.md](./docs/style.md)
- **逻辑（Script）**：TypeScript 逻辑规范 → [docs/script.md](./docs/script.md)

## 输出文件结构

```
ComponentName/
├── index.tsx     # 组件模板 + 逻辑
└── index.less    # 样式
```

## 执行流程

1. 确认组件名、所在目录（components / features/Common / features/FuelVehicle 等）
2. 参阅 `docs/template.md`，生成 `index.tsx` 的 JSX 结构
3. 参阅 `docs/style.md`，生成 `index.less`
4. 参阅 `docs/script.md`，补充 `index.tsx` 的逻辑部分
5. 输出两个文件
