#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <png-path>" >&2
  exit 2
fi

file_path="$1"

file_output="$(file "$file_path")"
echo "$file_output"

if ! echo "$file_output" | grep -q "PNG image data"; then
  echo "ERROR: file is not a PNG: $file_path" >&2
  exit 1
fi

echo "OK: file is a PNG."
