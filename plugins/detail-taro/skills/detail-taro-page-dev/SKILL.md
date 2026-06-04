---
name: detail-taro-page-dev
description: detail-taro3 商详页功能开发工作流。用于新增/重构 features 业务模块、页面组件、store slice、service、hooks，以及 RN/H5/小程序差异实现。当用户开发商详页、detail-taro、车详、商品详情相关功能时使用。
---

# detail-taro 商详页开发

## 何时激活

- 用户要在商详页新增或修改业务模块、UI、数据流
- 提到 `detail-taro3`、`商详`、`features`、`PageStore`、多端兼容

## 开发流程

1. **确认落点**
   - 业务 UI → `src/pages/index/features/<一级>/<模块>/`
   - 页面级复用 → `src/pages/index/components/`
   - 数据 → `service/`；状态 → `store/`；逻辑复用 → `hooks/`
2. **读现有模式**
   - 找同业务线（`Common` / `FuelVehicle` / `NewEnergy`）的相邻模块，对齐目录结构、props 与样式类名
3. **实现顺序（建议）**
   - 类型与 service 接口 → store slice / selector → 组件与 Less → 平台分支（如需）
4. **多端**
   - 先实现共享路径；再按 `TARO_ENV` 或项目既有 compat 工具处理 RN/H5/小程序差异
   - 测量、滚动、布局差异参考仓库内已有 feature 做法，不引入新依赖除非必要
5. **收尾**
   - 自检：命名、BEM、无组件内直连请求、无无效平台分支
   - 说明影响范围与需人工验证的端（RN / H5 / 小程序）

## 输出要求

- 列出新增/修改的文件路径
- 若新增一级或二级 `features` 目录，明确标注需用户确认
- 多端改动时注明各端验证要点

## 与其他规范的分工

本 skill 负责**商详功能交付流程**；细粒度规范（Koala UI、Less BEM、图片资源、Native API、PageStore API）应在插件内补充对应专项 skill 后按需加载。
