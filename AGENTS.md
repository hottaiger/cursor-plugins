# AGENTS.md — guazi-cursor-plugins

瓜子前端团队内部 Cursor 插件市场。无构建、无测试、无 package.json —— 纯插件/skill 仓库。

## 目录结构

```
.cursor-plugin/marketplace.json   # 顶层市场清单
.cursor/settings.json             # 本地启用的插件
plugins/
  <plugin-name>/
    .cursor-plugin/plugin.json    # 插件清单
    skills/<skill-name>/SKILL.md  # skill 入口
    README.md
```

三个插件：`detail-taro`、`dev-toolkit`、`guazi-workflow`。每个 `plugin.json` 的 `skills` 字段指向 `./skills/`，Cursor 从该路径自动发现 skill。

## 约定

- **所有内容用中文**（skill 描述、README、SKILL.md 正文），保持一致。
- **SKILL.md frontmatter** 必须包含 `name` 和 `description`。`description` 是 Cursor 判断何时激活 skill 的依据——要具体、场景化。
- **参考材料放 `references/`** 子目录，按需加载，避免 SKILL.md 内联大段引用。
- **脚本放 `scripts/`**，与 skill 同级。用 shell 脚本，本仓库不依赖 Node。
- **禁止提交密钥。** Figma token 等放 `*.local.env`，不进仓库。

## 编辑 skill

1. 找到 skill：`plugins/<plugin>/skills/<skill-name>/SKILL.md`
2. SKILL.md 保持精简：触发条件、核心流程、注意事项。引用材料移到 `references/`。
3. 新增 skill 时更新 `plugin.json`——Cursor 从 `skills` 目录路径发现 skill。

## 同步到本地 Cursor 插件

```bash
cp -R plugins/<plugin-name> ~/.cursor/plugins/local/<plugin-name>
```

然后在目标仓库的 `.cursor/settings.json` 中启用。

## Git 说明

- `main` 为当前分支。`v1`、`v2` 为旧分支（plugin-template 实验）。
- 无 CI、无 lint、无 typecheck 命令——直接提交。
