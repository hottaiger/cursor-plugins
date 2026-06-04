---
name: feishu-requirement-pool
description: >-
  通过 guazi-jira-mcp 与 lark-cli 维护组织飞书「需求池管理」多维表格：按 git 分支
  SFE-\d{5} 新建或更新需求行；使用者未指定需求号时默认当前分支，显式给出 SFE-xxxxx
  时以指定号为准。适用于「需求池」「登记需求」「更新需求进度」「同步 Jira 到飞书需求池」等场景。
metadata:
  requires:
    bins: ["lark-cli", "git"]
  relatedSkills: ["lark-base", "lark-shared", "lark-wiki", "workflow-skill"]
---

# 飞书需求池（feishu-requirement-pool）

维护组织飞书知识库中的**需求池管理**多维表格。依赖：

- **guazi-jira-mcp**：`jira_get_issue`
- **lark-cli**：`wiki +node-get`、`base +table-list`、`base +field-list`、`base +record-search`、`base +record-upsert`
- **git**：读取当前分支

执行前必须先读 **lark-shared** skill；写 Base 记录前读 **lark-base** skill 中的 `references/lark-base-cell-value.md`。

## 固定资源

| 项 | 值 |
|----|-----|
| 飞书 Wiki 链接 | `https://uah6uaojst7.feishu.cn/wiki/Gi90wcLZSixwF5kNXeMcKw0anqf` |
| Wiki token | `Gi90wcLZSixwF5kNXeMcKw0anqf` |
| Base token | `VONmbSOv4aokHdshk9Mca9xHnSb`（由 Wiki 解析得到，勿硬编码为 wiki token） |
| 数据表 | `需求列表`（`tblnjxR6wB3v32Kq`） |
| 默认视图 | `需求优先级表`（按「优先级」分组） |
| Jira 前缀 | `https://cjira.guazi-corp.com/browse/` |
| 分支正则 | `^SFE-\d{5}$`（整段分支名匹配，如 `SFE-41758`） |

## 解析 Wiki → Base

```bash
lark-cli wiki +node-get --as user --token "https://uah6uaojst7.feishu.cn/wiki/Gi90wcLZSixwF5kNXeMcKw0anqf"
```

- `data.obj_type` 必须为 `bitable`；`data.obj_token` 即 `--base-token`。
- 再用 `+table-list` / `+field-list` 确认表名与字段名（禁止猜字段）。

```bash
lark-cli base +table-list --as user --base-token "<base_token>" --table-id "需求列表"
lark-cli base +field-list --as user --base-token "<base_token>" --table-id "需求列表" --limit 200
```

## 字段与类型

更新/新建时字段名必须与表格一致（以 `+field-list` 为准）：

| 字段名 | 类型 | 写入说明 |
|--------|------|----------|
| 需求描述 | 链接 | `[需求名称](需求文档链接)` |
| Jira | 链接 | `[SFE-xxxxx](https://cjira.guazi-corp.com/browse/SFE-xxxxx)` |
| 进展状态 | 单选 | `待排期` / `开发中` / `测试中` / `已上线` |
| 涉及端 | 多选 | `["H5"]` / `["H5","RN"]` / `["小程序"]` 等 |
| 需求跟进人 | 人员 | `[{"id":"ou_xxx"}]`；未知 ID 时用 `lark-cli contact +search-user` 查询 |
| 优先级 | 单选 | `P0` / `P1` / `P2` / `P3`（新建时优先取 Jira 优先级，见 B 步；无法解析时默认 `P3`） |
| 后端 / UI | 链接 | `[文本](URL)` |
| 提测日期 / 上线日期 | 时间 | `YYYY-MM-DD HH:mm:ss` |
| 备注 | 文本 | 纯文本 |

### 超链接写法

对 `style.type=url` 的列，使用 Markdown 链接字符串：

```text
[商详页电池健康度与预估续航文案优化](https://cwiki.guazi.com/pages/viewpage.action?pageId=670109804)
```

### 时间列快捷规则

用户说「更新某时间字段」且未给具体日期时：**写入当天日期**，时间部分默认 `00:00:00`。

用户说「明天提测」时：提测日期 = 次日 `00:00:00`。

```bash
date +%Y-%m-%d   # 拼 " 00:00:00"
```

### 分组说明

当前视图「需求优先级表」按 **优先级** 分组。新建行默认写入 Jira 解析出的优先级；用户未指定且 Jira 无法解析时，字段默认值为 `P3`，记录会自动落入对应分组。

---

## 公共步骤

### A. 确定 ISSUE_KEY（需求号）

**优先级**：用户显式指定的 `SFE-xxxxx` > 当前 git 分支。

1. 读取当前分支：

```bash
git branch --show-current
```

2. 解析用户指令：
   - **未说明**是哪个分支 / Jira / 需求号（如只说「登记需求」「更新提测日期」）→ `ISSUE_KEY` = 当前分支名。
   - **显式给出** `SFE-xxxxx`（如「新建 SFE-41784 的需求」「更新 SFE-41710 的进展状态」）→ `ISSUE_KEY` = 用户指定的号，**不要求**当前分支与其一致。

3. 校验 `ISSUE_KEY` 须匹配 `^SFE-\d{5}$`：
   - 不匹配 → **结束流程**。
   - 因默认当前分支导致不匹配 → 告知用户需先切到如 `SFE-41758` 的需求分支，或显式指定 `SFE-xxxxx`。
   - 因用户指定号格式不对 → 请用户给出合法需求号。

4. 汇报时：
   - 默认当前分支且一致 → 写「分支：SFE-41758」。
   - 用户显式指定且与当前分支不同 → 写「需求：SFE-41784（当前 git 分支：SFE-41710）」。

### B. 拉取 Jira 信息

调用 MCP：`CallMcpTool` → server `user-guazi-jira-mcp`，tool `jira_get_issue`，参数 `{ "issueKey": "<ISSUE_KEY>" }`。

从返回中解析：

| 用途 | 来源 |
|------|------|
| 需求名称 | 标题中 `SFE-xxxxx: ` 后的摘要；若无前缀则用完整标题去掉 key |
| 需求文档链接 | 扩展字段 **需求文档链接**（Confluence URL） |
| Jira 链接 | `https://cjira.guazi-corp.com/browse/{ISSUE_KEY}` |
| 优先级 | 返回中的 **优先级** 字段（如 `P0-最高`、`P1-高`） |

**优先级映射**（Jira → 飞书「优先级」列）：

- 从 Jira **优先级** 字符串中提取 `P0` / `P1` / `P2` / `P3`/ `P4`（通常位于 `-` 前，如 `P0-最高` → `P0`）。
- 映射结果须落在表格可选项内（以 `+field-list` 为准）。
- **新建需求**时：若用户未显式指定优先级，**必须**写入 Jira 解析出的优先级；用户显式指定时以用户为准。
- Jira 无优先级或无法解析时：新建不写「优先级」列，由表格默认值 `P3` 生效，并在汇报中说明。

缺 **需求文档链接** 时：仍创建/更新其他列，并向用户说明需补文档链接。

### C. 定位表格记录（更新 / 查重用）

```bash
lark-cli base +record-search \
  --as user \
  --base-token "<base_token>" \
  --table-id "需求列表" \
  --json '{"keyword":"SFE-41758","search_fields":["Jira"],"limit":20}'
```

- 优先在 **Jira** 列搜索。
- 0 条 → 提示是否走「新建需求」流程。
- 多条 → 列出 `record_id` 与关键列，请用户确认一条。

### D. 查重（新建用）

新建前先执行 C；若已存在同 `ISSUE_KEY` 行，**不要重复创建**，提示改走「更新需求」。

---

## 功能 1：新建需求

**触发**：用户要「登记/新建/同步需求到飞书需求池」。

**流程**：

1. A → B → 解析 Base（Wiki → `base-token`）→ `+field-list`。
2. D：已存在则停止。
3. 解析用户额外指定的字段（涉及端、需求跟进人、提测日期、进展状态等）；**优先级**若用户未指定，使用 B 步从 Jira 解析的值。
4. 若指定人员姓名，先 `lark-cli contact +search-user --query "<姓名>"` 获取 `open_id`。
5. `+record-upsert` 创建行，**至少写入**：

```json
{
  "需求描述": "[商详页电池健康度与预估续航文案优化](https://cwiki.guazi.com/pages/viewpage.action?pageId=670109804)",
  "Jira": "[SFE-41758](https://cjira.guazi-corp.com/browse/SFE-41758)",
  "优先级": "P0"
}
```

将示例中的需求名称、文档链接、`ISSUE_KEY`、Jira 链接、**优先级**替换为 B 步解析结果；用户显式指定的字段覆盖 Jira 默认值，其他用户指定字段一并写入。

6. 可选：`+record-share-link-create` 生成行分享链接。
7. 返回：已写字段摘要、Wiki 表格链接、Jira 链接。

**完整命令示例**：

```bash
lark-cli base +record-upsert \
  --as user \
  --base-token "VONmbSOv4aokHdshk9Mca9xHnSb" \
  --table-id "需求列表" \
  --json '{"需求描述":"[需求名称](https://cwiki.example.com/...)","Jira":"[SFE-41758](https://cjira.guazi-corp.com/browse/SFE-41758)","优先级":"P1","涉及端":["小程序"],"需求跟进人":[{"id":"ou_xxx"}],"提测日期":"2026-05-26 00:00:00","进展状态":"开发中"}'
```

---

## 功能 2：更新需求

**触发**：用户要「更新飞书需求池的 xxx 字段」。

**流程**：

1. A → C 定位 `record_id`。
2. 解析用户要改的**字段名**与**新值**（见字段表）。
3. 按类型构造 patch：
   - **文本**：直接字符串。
   - **链接**：`[文本](URL)`。
   - **时间**：未指定日期 → 今天；「明天」→ 次日（见「时间列快捷规则」）。
   - **单选**：选项字符串。
   - **多选**：选项数组，如 `["H5","RN"]`。
   - **人员**：先查 `open_id`，再 `[{"id":"ou_xxx"}]`。
4. `+record-upsert --record-id <id> --json '{ ... }'` 仅更新用户指定的列（勿覆盖未提及字段）。
5. 汇总变更字段与新值。

**示例指令映射**：

| 用户说法 | 动作 |
|----------|------|
| 更新提测日期为今天 | `"提测日期": "2026-05-25 00:00:00"` |
| 明天提测 | `"提测日期": "2026-05-26 00:00:00"` |
| 进展状态改成开发中 | `"进展状态": "开发中"` |
| 涉及端改为 H5 和 RN | `"涉及端": ["H5","RN"]` |
| 优先级改为 P1 | `"优先级": "P1"` |
| UI 改为 xxx，链接 yyy | `"UI": "[xxx](yyy)"` |
| 备注改成「已提测」 | `"备注": "已提测"` |
| 需求跟进人改为张硕 | 先 `contact +search-user` 查 `ou_xxx`，再 `"需求跟进人": [{"id":"ou_xxx"}]` |

**完整命令示例**：

```bash
lark-cli base +record-upsert \
  --as user \
  --base-token "VONmbSOv4aokHdshk9Mca9xHnSb" \
  --table-id "需求列表" \
  --record-id "recXXXXXXXX" \
  --json '{"进展状态":"开发中","提测日期":"2026-05-25 00:00:00"}'
```

---

## 错误与权限

| 情况 | 处理 |
|------|------|
| `wiki +node-get` Forbidden | 引导 `lark-cli auth login --as user`，确认 Wiki 权限 |
| Jira MCP 失败 | 检查 VPN/内网；提示手动提供需求名称与文档链接 |
| 字段名不匹配 | 重新 `+field-list`，以真实字段名为准 |
| 写入只读字段 | 从 JSON 中移除公式/创建时间等只读列 |

## 完成汇报模板

```markdown
## 飞书需求池 — 已完成

- 分支：SFE-41758
<!-- 若 ISSUE_KEY 来自用户显式指定且与当前 git 分支不同，改为：需求：SFE-41784（当前 git 分支：SFE-41710） -->
- 操作：新建 | 更新
- 记录：rec_xxx（可选分享链接）
- 变更字段：需求描述、Jira、…
- 表格：https://uah6uaojst7.feishu.cn/wiki/Gi90wcLZSixwF5kNXeMcKw0anqf
- Jira：https://cjira.guazi-corp.com/browse/SFE-41758
```

## 相关技能

- 研发全流程：**workflow-skill**
- Base 明细：**lark-base**
- 另一张需求列表表（字段含「项目」「Jira号」）：**feishu-requirement-list**
