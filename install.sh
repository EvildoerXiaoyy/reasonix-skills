#!/bin/bash
set -e

# ============================================================
# Reasonix Skills Installer
# 自动发现 skills/ 下所有 skill，无需手动维护列表
# 用法:
#   全局安装:    curl -sL ... | bash
#   项目级安装:  curl -sL ... | bash -s -- --project
# ============================================================

REPO="EvildoerXiaoyy/reasonix-skills"
BRANCH="${REPO_BRANCH:-main}"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"

# 判断安装模式
if [ "${1:-}" = "--project" ]; then
  INSTALL_DIR=".agents/skills"
else
  INSTALL_DIR="$HOME/.reasonix/skills"
fi

echo "📦 安装 Reasonix workflow skills → $INSTALL_DIR"
echo "========================================"
mkdir -p "$INSTALL_DIR"

# 通过 GitHub API 获取 skills/ 下的目录列表（自动发现，无需硬编码）
echo "🔍 自动发现 skill 列表..."
API_URL="https://api.github.com/repos/$REPO/contents/skills?ref=$BRANCH"
SKILLS=$(curl -sL --fail "$API_URL" 2>/dev/null | \
  python3 -c "import sys,json; [print(i['name']) for i in json.load(sys.stdin) if i['type']=='dir']" 2>/dev/null || true)

if [ -z "$SKILLS" ]; then
  echo "⚠️  无法通过 API 获取列表，尝试备选方式..."
  # 备选：直接尝试下载已知 skill 列表（最后兜底）
  SKILLS=""
fi

COUNT=0
FAIL=0

for s in $SKILLS; do
  URL="$BASE_URL/skills/$s/SKILL.md"
  TARGET="$INSTALL_DIR/$s/SKILL.md"
  echo -n "  $s ... "
  mkdir -p "$INSTALL_DIR/$s"
  if curl -sL --fail "$URL" -o "$TARGET" 2>/dev/null && [ -s "$TARGET" ]; then
    LINES=$(wc -l < "$TARGET")
    echo "✅ ($LINES 行)"
    COUNT=$((COUNT + 1))
  else
    echo "⚠️  跳过"
    FAIL=$((FAIL + 1))
  fi
done

echo "========================================"
echo "✅ 完成: $COUNT 个 skill 已安装"
[ "$FAIL" -gt 0 ] && echo "⚠️  跳过: $FAIL 个"
echo ""
echo "📋 下次启动 Reasonix 新会话即可使用。"
echo "   如需安装到项目级: curl -sL ... | bash -s -- --project"
