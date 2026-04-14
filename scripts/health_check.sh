#!/bin/bash
# agent-self-audit: 快速健康扫描脚本
# 执行 3 项关键检查，输出状态码供 agent 解读

set -euo pipefail

WORKSPACE="${HOME}/.openclaw/workspace"
SKILLS_DIR="${HOME}/.openclaw/skills"

# 1. MEMORY.md 行数
MEMORY_FILE="$WORKSPACE/MEMORY.md"
if [ -f "$MEMORY_FILE" ]; then
  MEMORY_LINES=$(wc -l < "$MEMORY_FILE")
  if [ "$MEMORY_LINES" -lt 80 ]; then
    echo "MEMORY_OK:$MEMORY_LINES"
  elif [ "$MEMORY_LINES" -lt 120 ]; then
    echo "MEMORY_WARN:$MEMORY_LINES"
  else
    echo "MEMORY_CRITICAL:$MEMORY_LINES"
  fi
else
  echo "MEMORY_MISSING"
fi

# 2. Skills 数量
SKILLS_COUNT=$(find "$SKILLS_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
if [ "$SKILLS_COUNT" -lt 50 ]; then
  echo "SKILLS_OK:$SKILLS_COUNT"
elif [ "$SKILLS_COUNT" -lt 70 ]; then
  echo "SKILLS_WARN:$SKILLS_COUNT"
else
  echo "SKILLS_CRITICAL:$SKILLS_COUNT"
fi

# 3. facts.yaml 存在性
FACTS_FILE="$WORKSPACE/memory/facts.yaml"
if [ -f "$FACTS_FILE" ]; then
  echo "FACTS_OK"
else
  echo "FACTS_MISSING"
fi
