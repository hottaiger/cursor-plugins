---
name: changelog-updater
description: 自动生成 CHANGELOG.md 更新信息并提交代码。当用户需要更新 CHANGELOG、生成提交信息或推送代码时调用。使用 Jira 脚本获取 issue 信息并生成标准格式。
---

# CHANGELOG 更新助手

此技能用于自动生成标准的 CHANGELOG.md 更新信息，并执行 git 提交和推送。

## 执行逻辑

**重要**：执行过程中任何步骤失败立即停止当前流程，不继续执行后续步骤。

## 工作流程

1. **检查分支名称**：验证当前分支是否符合 `SFE-\d{5}` 格式
2. **获取 Jira 信息**：通过 guazi-jira MCP 获取当前分支的 Jira issue 信息
3. **生成更新内容**：根据 Jira 返回的 summary 和 customfield_10245 生成标准格式
4. **插入 CHANGELOG**：在 CHANGELOG.md 的最末尾最新日期区块后空一行插入更新信息
5. **提交并推送**：生成 "UPDATE CHANGELOG.md" 提交信息，执行提交和推送

## 标准格式

根据是否为新的一年，生成的 CHANGELOG 条目格式有所不同：

### 新的一年（需要添加年份区块）

```markdown
</p>
</details>

<details open>
<summary><span style="font-size: larger;">YYYY年</span></summary>
<p>

### YYYY-MM-DD

- {Jira Summary} [文档]({customfield_10245链接})

```

### 非新的一年（只需添加日期条目）

```markdown
### YYYY-MM-DD

- {Jira Summary} [文档]({customfield_10245链接})

```

### 执行步骤

1. **检查分支名称**
   - 运行命令：`git rev-parse --abbrev-ref HEAD`
   - 验证分支名称是否符合 `SFE-\d{5}` 格式
   - **失败**：显示错误信息并停止执行

2. **获取 Jira 信息**
   - 通过 guazi-jira MCP 获取当前分支的 Jira issue 信息
   - **失败**：显示错误信息并停止执行

3. **读取 CHANGELOG.md**
   - 检查文件是否存在
   - **失败**：显示错误信息并停止执行

4. **更新 CHANGELOG.md**
   - 生成新的更新条目
   - 插入到 CHANGELOG.md 的最末尾最新日期区块后空一行的位置
   - **失败**：显示错误信息并停止执行

5. **提交并推送**
   - 执行：`git add CHANGELOG.md`
   - 执行：`git commit -m "UPDATE CHANGELOG.md"`
   - 执行：`git push`
   - **失败**：显示错误信息并停止执行

## 错误处理

- **分支名称错误**：确保分支名称符合 `SFE-\d{5}` 格式
- **Jira 信息获取失败**：检查网络连接和 Jira 权限
- **文件操作失败**：确保有写入 CHANGELOG.md 的权限
- **Git 操作失败**：确保有 Git 提交和推送权限

## 插入位置规则

- 找到 CHANGELOG.md 中最近的日期区块（`### YYYY-MM-DD`）
- 在该区块的最后一项空一行后插入新的更新条目

## 示例

假设 Jira 返回：
- Summary: "商详页首屏实验转全"
- customfield_10245: "https://cwiki.guazi.com/pages/viewpage.action?pageId=631510705"

如果是新的一年，生成的 CHANGELOG 条目：
```markdown
</p>
</details>

<details open>
<summary><span style="font-size: larger;">2026年</span></summary>
<p>

### 2026-03-04

- 商详页首屏实验转全 [文档](https://cwiki.guazi.com/pages/viewpage.action?pageId=631510705)

```

如果不是新的一年，生成的 CHANGELOG 条目：
```markdown
### 2026-03-04

- 商详页首屏实验转全 [文档](https://cwiki.guazi.com/pages/viewpage.action?pageId=631510705)

```
