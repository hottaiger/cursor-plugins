# guazi-cursor-plugins

瓜子前端团队**内部** Cursor 插件市场，面向 detail-taro3 商详及相关研发场景。

> 仅限公司内部使用，不面向公开 Marketplace 发布。

## 插件列表

| 插件 | 说明 | 典型场景 |
|:-----|:-----|:---------|
| [detail-taro](./plugins/detail-taro/) | 商详页开发规范与工具 | 写 feature、Koala UI、埋点、单测 |
| [dev-toolkit](./plugins/dev-toolkit/) | 通用开发工具 | Figma 切图、BDD 需求、死代码清理 |
| [guazi-workflow](./plugins/guazi-workflow/) | 内部工作流 | 飞书需求池、Jira Changelog |

## 在 Cursor 中启用

### 方式一：打开本仓库

1. 用 Cursor 打开 `cursor-plugins` 根目录。
2. **Settings → Plugins** 中启用需要的插件。

仓库已预配置 `.cursor/settings.json`，默认启用 `detail-taro`。

### 方式二：同步到本地插件目录

```bash
cp -R plugins/detail-taro ~/.cursor/plugins/local/detail-taro
cp -R plugins/dev-toolkit ~/.cursor/plugins/local/dev-toolkit
cp -R plugins/guazi-workflow ~/.cursor/plugins/local/guazi-workflow
```

在业务仓库（如 detail-taro3）的 `.cursor/settings.json` 中启用对应插件。

## 依赖说明

| 插件 | 前置依赖 |
|:-----|:---------|
| detail-taro | detail-taro3 仓库、`@guazi-fe/koala-ui`、`@guazi-fe/cross-utils` |
| dev-toolkit | Figma token（figma-png-export）；BDD 可选公司 wiki MCP |
| guazi-workflow | `guazi-jira-mcp`、`lark-cli`、飞书权限 |

## 目录结构

```text
.cursor-plugin/marketplace.json
plugins/
  detail-taro/skills/...
  dev-toolkit/skills/...
  guazi-workflow/skills/...
```

## 参考

- https://github.com/cursor/plugin-template
- https://cursor.directory/plugins/new
