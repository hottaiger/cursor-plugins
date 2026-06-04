---
name: figma-png-export
description: 通过 Figma REST Images API 按节点 ID 导出 PNG；支持倍率（默认 3×）与输出目录（默认当前目录）。Use when exporting Figma nodes to PNG, background images, cuts, or when MCP asset URLs may be SVG but the project needs raster PNG.
---

# Figma PNG Export（通用）

用 **`export_node_png_figma_api.sh`** 调用 [Figma Images API](https://www.figma.com/developers/api#get-images-endpoint)，按 **`file_key` + `node_id`** 导出 **PNG**，支持 **`scale` 倍率**；导出后应用 **`validate_png.sh`** 校验真实文件类型。

## 触发场景

- 用户提供 Figma 设计链接或 `file_key` / `node_id`，需要落盘 PNG
- 需要 **指定倍率**（如 2×、3×），且希望由 Figma 服务端栅格化（而非对 1× 截图插值放大）
- `get_design_context` 等资源 URL 可能是 **SVG**，业务需要 **PNG**

## 必须原则

- **不要相信**资源 URL 的文件后缀；下载后必须用 `file` 或 `scripts/validate_png.sh` 校验是否为真 PNG。
- **Personal access token** 仅通过环境变量或本地 `figma.local.env` 提供，**禁止**写入仓库内可跟踪文件、禁止写进 skill 示例中的真实令牌。
- 组件/业务代码内禁止长期保留裸 Figma 临时 URL、裸 CDN 图链（按各业务仓库规范落盘与 `import`）。

## 核心命令（AI / 本地通用）

在任意**当前工作目录**下均可调用脚本（建议用仓库内绝对或相对路径指向脚本）：

```bash
./skills/figma-png-export/scripts/export_node_png_figma_api.sh <file_key> <node_id> [scale] [输出文件或目录]
```

### 默认值

| 项 | 默认 |
|----|------|
| **倍率 `scale`** | **3**（三倍图） |
| **输出位置** | **当前工作目录** 下的 `figma-node-<node_id>.png`（节点 ID 中 `:` 会换成 `-`） |

### 从链接解析参数

- 链接形如：`https://www.figma.com/design/<file_key>/...?node-id=1-3616`
- **`file_key`**：路径中 `/design/` 后第一段  
- **`node_id`**：把 `node-id=1-3616` 转成 **`1:3616`**

### 参数形态说明

1. **仅 2 个参数**：`file_key` + `node_id` → `scale=3`，输出 **`$PWD/figma-node-1-3616.png`**。
2. **3 个参数**：第三个为 **纯数字** →视为 **倍率**；否则若为 **已存在目录** 或 **以 `/` 结尾的路径** →视为 **输出目录**（文件名仍为默认 `figma-node-<node_id>.png`）；否则视为 **输出文件路径**（`scale` 仍为 3）。
3. **4 个参数**：`file_key` `node_id` **`scale`（必须为数字）** **`输出文件或目录`**（目录规则同上）。

完整说明与边界情况：`./skills/figma-png-export/scripts/export_node_png_figma_api.sh --help`

## 认证（FIGMA_TOKEN）

脚本会 **按顺序** 尝试：

1. 环境变量 **`FIGMA_TOKEN`**
2. **当前工作目录**下的 **`figma.local.env`**
3. **仓库根目录**下的 **`figma.local.env`**（脚本相对路径 `skills/figma-png-export/scripts` 向上三级）

仓库内可复制示例（勿提交真实令牌）：

```bash
cp figma.local.env.example figma.local.env
# 编辑 figma.local.env 填入 export FIGMA_TOKEN='figd_...'
```

## 导出后校验（强制闸门）

```bash
skills/figma-png-export/scripts/validate_png.sh <本地.png路径>
```

脚本成功下载后会 **自动调用** 同目录下的 `validate_png.sh`（若存在且可执行）。

手动排查：

```bash
file <本地.png路径>
```

## 无 Token / API 不可用时的退化

若无法使用 Images API（无令牌、权限、限流等），可退化为：

- Figma **MCP `get_screenshot`**（**不可指定 `scale`**，倍率由服务决定），再 `curl` 落盘并同样做 PNG 校验；或
- 设计稿内 **手动 Export PNG**，再拷贝到目标目录。

## 在本仓库（detail-taro3）接入业务图

导出到例如 `src/assets/resources/<业务>/` 后：

1. 将文件命名为业务可读名（或保留默认名后 `mv`）。
2. 在对应 **`index.ts`** 中 `import` 并 `export`。
3. 业务组件通过资源模块引用，避免裸 URL。

提交前按需跑 ESLint 等（按项目规范）。

## SVG 误判为 PNG 时

若 `file` 显示为 SVG：禁止改后缀冒充 PNG；应重新用 Images API 导出 PNG，或对矢量做 **显式栅格化** 后再校验。

## 失败时应对用户说明

- 未拿到图片 URL / 节点不可导出  
- API 报错或仅返回空 `images`  
- 只能得到 SVG 且无法可靠转 PNG  

不要假装已成功导出。
