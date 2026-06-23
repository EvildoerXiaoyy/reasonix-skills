#!/bin/bash
set -e

# ============================================================
# Reasonix Skills Installer — 一键安装所有 workflow skill
# 用法: curl -sL https://raw.githubusercontent.com/<YOUR_USER>/reasonix-skills/main/install.sh | bash
# ============================================================

REPO_BRANCH="${REPO_BRANCH:-main}"
REPO_RAW="https://raw.githubusercontent.com/EvildoerXiaoyy/reasonix-skills/$REPO_BRANCH"

SKILLS=(
  workflow
  arch-workflow
  to-prd
  grill-me
  plan-eng-review
  dep-status
  mock-gen
  test-gen
  review-request
  refactor
  debug
  amend-contract
  codereview
  reconcile
  adr
  handoff
)

INSTALL_DIR="$HOME/.reasonix/skills"

echo "📦 安装 Reasonix workflow skills 到 $INSTALL_DIR"
echo "========================================"

# 创建安装目录
mkdir -p "$INSTALL_DIR"

# 逐个下载
for s in "${SKILLS[@]}"; do
  TARGET="$INSTALL_DIR/$s/SKILL.md"
  URL="$REPO_RAW/$s/SKILL.md"
  
  echo -n "  $s ... "
  mkdir -p "$INSTALL_DIR/$s"
  
  if curl -sL "$URL" -o "$TARGET" 2>/dev/null; then
    LINES=$(wc -l < "$TARGET")
    echo "✅ ($LINES 行)"
  else
    echo "❌ 下载失败"
    exit 1
  fi
done

echo "========================================"
echo "✅ 全部 ${#SKILLS[@]} 个 skill 已安装到 $INSTALL_DIR"
echo "下次启动 Reasonix 新会话即可使用。"
echo ""
echo "📋 包含命令:"
for s in "${SKILLS[@]}"; do
  echo "  /$s"
done
