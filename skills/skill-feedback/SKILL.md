---
name: skill-feedback
description: >-
  记录用户对 Cursor Agent Skill 的评价与改进建议。当用户说某个 skill 好用/不好、
  要改 skill、skill 缺什么、对 skill 的反馈、@某 skill 的改进意见时，将本次对话
  中的反馈摘要写入仓库根目录 skill-feedback/ 下对应文件。
---

# Skill 反馈归档

将用户对 **Skill**（`.cursor/skills/*/SKILL.md` 或 `skills/*/SKILL.md`）的评价沉淀到仓库，供后续改 skill 时对照。

---

## 触发条件

用户话语中出现以下任一意图即执行本 skill（无需用户说「写入 skill-feedback」）：

- 某个 **skill 名称** + 好评 / 差评 / 改进 / 缺漏 / 太长 / 不好用
- 「这个 skill 应该…」「skill 里加上…」「别按这个 skill 做…」
- 明确 `@skill-name` 的体验反馈

**不触发**：仅讨论业务代码、与 skill 无关的通用编码偏好（除非用户点名要记入某 skill）。

---

## 执行步骤

1. **识别 skill**
   - 用户 @ 或提到的 `name`（如 `method-jsdoc-comments`）
   - 或从路径推断：`/.cursor/skills/foo/` → `foo`
   - 多个 skill 时各写一条记录（同一轮对话可更新多个文件）

2. **提炼摘要**（中文，每条 1～3 句）
   - **优点**：用户认为有效、应保留的点
   - **问题**：不好用、误导、遗漏、与项目冲突
   - **建议**：希望增删改的具体条目（可引用 skill 章节名）

3. **写入文件**
   - 路径：`skill-feedback/<skill-name>.md`（kebab-case，与 skill 的 `name` 一致）
   - **追加**新条目，不覆盖历史（除非用户明确要求「只保留最新一条」）
   - 文件不存在则创建，并带上文首说明块（见模板）

4. **回复用户**
   - 说明已写入的路径
   - 用 1～2 句复述归档内容，便于用户纠错

**禁止**：未经用户反馈内容，编造好评/差评；不要把业务需求误记成 skill 反馈。

---

## 文件模板

### 新建 `skill-feedback/<skill-name>.md`

```markdown
# Skill 反馈：`<skill-name>`

> 由 skill-feedback 自动归档。改 skill 前可先读此文件。
> Skill 路径：`.cursor/skills/<skill-name>/SKILL.md`（或项目内实际路径）

---

```

### 每次追加条目

```markdown
## YYYY-MM-DD

**来源**：对话摘要（可选：用户原话关键词）

### 优点
- …

### 问题
- …

### 建议
- …

---
```

某类无内容则写「（无）」或省略该小节，但三个小节标题至少保留「问题」或「建议」之一有内容。

---

## 示例

用户：「method-jsdoc-comments 一句注释挺好，但别强制给私有 handle 写注释。」

写入 `skill-feedback/method-jsdoc-comments.md`：

```markdown
## 2026-05-29

**来源**：用户认为导出函数注释足够，私有 handler 不必强制

### 优点
- 一行中文 JSDoc、说「做什么」的风格合适

### 问题
- （无）

### 建议
- 在 skill 中强调：组件内未导出的 handle 不要强制注释

---
```

---

## 与改 skill 的衔接

- 积累多条反馈后，用户若要求「按 feedback 改 skill」，应 **先读** `skill-feedback/<skill-name>.md`，再编辑对应 `SKILL.md`，改完后可在反馈文件追加「## YYYY-MM-DD 已处理」备注（可选）。
- 不在此 skill 内直接改 `SKILL.md`，除非用户同时要求「记下来并改掉」。

---

## 目录约定

| 路径 | 用途 |
|------|------|
| `skill-feedback/README.md` | 目录说明（勿删） |
| `skill-feedback/<skill-name>.md` | 单个 skill 的累积反馈 |

根目录 `skill-feedback/` **提交进 git**，便于团队共享对 skill 的迭代意见。
