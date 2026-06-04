#!/usr/bin/env bash
# 使用 Figma REST Images API 将指定节点导出为 PNG。
# 文档: https://www.figma.com/developers/api#get-images-endpoint
#
# 用法摘要（倍率默认 3；输出默认当前目录 ./figma-node-<node_id>.png，冒号改为连字符）:
#   ./export_node_png_figma_api.sh <file_key> <node_id> [scale] [输出文件或目录]
#
# 认证（任选其一，按顺序尝试）:
#   1) 环境变量 FIGMA_TOKEN
#   2) 当前工作目录下的 figma.local.env
#   3) 仓库根目录下的 figma.local.env（优先 git 解析仓库根，否则脚本目录向上三级）
#
# 参数说明:
#   file_key   Figma 文件 key（设计链接中 /design/<file_key>/）
#   node_id    节点 ID，如 1:3616（链接里 node-id=1-3616 需写成 1:3616）
#   scale      可选。导出倍率，默认 3（三倍图）。Figma API 一般支持 0.01～4。
#   第 4 参    可选。可以是:
#              - 具体 .png 路径（相对路径相对当前工作目录）
#              - 已存在目录，或必须以 / 结尾的路径 → 写入 figma-node-<node_id>.png
#
# 示例:
#   ./export_node_png_figma_api.sh fvvWsRAB9OmI0Mm9ucGlUi 1:3616
#   ./export_node_png_figma_api.sh fvvWsRAB9OmI0Mm9ucGlUi 1:3616 2
#   ./export_node_png_figma_api.sh fvvWsRAB9OmI0Mm9ucGlUi 1:3616 3 ./exports/
#   ./export_node_png_figma_api.sh fvvWsRAB9OmI0Mm9ucGlUi 1:3616 3 ./my-bg.png
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT:-}" ]]; then
  REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
fi

usage() {
  cat <<'USAGE'
export_node_png_figma_api.sh — Figma REST Images API 导出节点为 PNG

用法:
  export_node_png_figma_api.sh <file_key> <node_id> [scale] [输出文件或目录]

默认:
  scale=3（三倍图）；输出=当前目录 ./figma-node-<node_id>.png（冒号改为连字符）

认证（按顺序）: 环境变量 FIGMA_TOKEN → ./figma.local.env → 仓库根 figma.local.env

示例:
  export_node_png_figma_api.sh fvvWsRAB9OmI0Mm9ucGlUi 1:3616
  export_node_png_figma_api.sh fvvWsRAB9OmI0Mm9ucGlUi 1:3616 2
  export_node_png_figma_api.sh fvvWsRAB9OmI0Mm9ucGlUi 1:3616 3 ./exports/
  export_node_png_figma_api.sh fvvWsRAB9OmI0Mm9ucGlUi 1:3616 3 ./my-bg.png

文档: https://www.figma.com/developers/api#get-images-endpoint
USAGE
}

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

load_token() {
  if [[ -n "${FIGMA_TOKEN:-}" ]]; then
    return 0
  fi
  if [[ -f "${PWD}/figma.local.env" ]]; then
    # shellcheck disable=SC1090
    set -a
    source "${PWD}/figma.local.env"
    set +a
  fi
  if [[ -z "${FIGMA_TOKEN:-}" && -f "${REPO_ROOT}/figma.local.env" ]]; then
    # shellcheck disable=SC1090
    set -a
    source "${REPO_ROOT}/figma.local.env"
    set +a
  fi
}

load_token

if [[ -z "${FIGMA_TOKEN:-}" ]]; then
  echo "ERROR: 未设置 FIGMA_TOKEN。" >&2
  echo "  任选其一：" >&2
  echo "  1) export FIGMA_TOKEN='figd_...'" >&2
  echo "  2) 在当前目录或仓库根目录放置 figma.local.env（可参考 figma.local.env.example）" >&2
  echo "  3) ${0##*/} --help" >&2
  exit 2
fi

FILE_KEY="${1:?缺少 file_key}"
NODE_ID="${2:?缺少 node_id，例如 1:3616}"

SAFE_NODE="${NODE_ID//:/-}"
DEFAULT_NAME="figma-node-${SAFE_NODE}.png"
SCALE=3
OUT_PATH=""

argc=$#
if [[ "${argc}" -eq 2 ]]; then
  OUT_PATH="${PWD}/${DEFAULT_NAME}"
elif [[ "${argc}" -eq 3 ]]; then
  arg3="$3"
  if [[ "$arg3" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    SCALE="$arg3"
    OUT_PATH="${PWD}/${DEFAULT_NAME}"
  elif [[ -d "$arg3" ]] || [[ "$arg3" == */ ]]; then
    d="${arg3}"
    [[ "$d" != */ ]] && d="${d}/"
    OUT_PATH="${d}${DEFAULT_NAME}"
  else
    OUT_PATH="$arg3"
    if [[ "$OUT_PATH" != /* ]]; then
      OUT_PATH="${PWD}/${OUT_PATH}"
    fi
  fi
elif [[ "${argc}" -eq 4 ]]; then
  SCALE="$3"
  if [[ ! "$SCALE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "ERROR: 4 参数模式下第 3 个参数须为倍率数字，例如 3。见: $0 --help" >&2
    exit 2
  fi
  arg4="$4"
  if [[ -d "$arg4" ]] || [[ "$arg4" == */ ]]; then
    d="${arg4}"
    [[ "$d" != */ ]] && d="${d}/"
    OUT_PATH="${d}${DEFAULT_NAME}"
  else
    OUT_PATH="$arg4"
    if [[ "$OUT_PATH" != /* ]]; then
      OUT_PATH="${PWD}/${OUT_PATH}"
    fi
  fi
else
  echo "ERROR: 参数个数应为 2～4。见: $0 --help" >&2
  exit 2
fi

IDS_ENC="$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1], safe=''))" "$NODE_ID")"

API_URL="https://api.figma.com/v1/images/${FILE_KEY}?ids=${IDS_ENC}&format=png&scale=${SCALE}"
JSON="$(curl -fsSL -H "X-Figma-Token: ${FIGMA_TOKEN}" "$API_URL")"

IMG_URL="$(echo "$JSON" | python3 -c "
import json, sys
j = json.load(sys.stdin)
err = j.get('err')
if err:
    print('Figma API err:', err, file=sys.stderr)
    sys.exit(1)
images = j.get('images') or {}
url = images.get(sys.argv[1])
if not url:
    print('No image URL for node', sys.argv[1], 'keys:', list(images.keys()), file=sys.stderr)
    sys.exit(1)
print(url)
" "$NODE_ID")"

mkdir -p "$(dirname "$OUT_PATH")"
curl -fsSL -o "$OUT_PATH" "$IMG_URL"

file "$OUT_PATH"
if [[ -x "${SCRIPT_DIR}/validate_png.sh" ]]; then
  "${SCRIPT_DIR}/validate_png.sh" "$OUT_PATH"
fi

echo "OK: wrote $OUT_PATH (scale=${SCALE})"
