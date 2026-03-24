#!/bin/sh
set -eu

INDEX_FILE="/usr/share/nginx/html/index.html"
PLACEHOLDER="__INSTANA_EUM_KEY__"
EUM_KEY="${INSTANA_EUM_KEY:-}"

if [ -f "$INDEX_FILE" ] && [ -n "$EUM_KEY" ]; then
  ESCAPED_KEY=$(printf '%s' "$EUM_KEY" | sed -e 's/[\\/&]/\\\\&/g')
  sed -i "s/${PLACEHOLDER}/${ESCAPED_KEY}/g" "$INDEX_FILE"
fi
