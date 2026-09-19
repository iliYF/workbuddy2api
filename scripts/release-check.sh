#!/bin/sh
# release-check.sh — 判断自上次 release 以来是否有值得发版的提交。
# 值得: feat/fix/refactor/perf(含 ! 破坏性); 跳过: chore/ci/docs/style/test/revert/prompt/Merge。
# canary tag 格式: v<YYYYMMDDHHMM>-<7位sha>。
# 用法: sh scripts/release-check.sh
set -eu
cd "$(dirname "$0")/.."

git fetch origin --tags --prune >/dev/null 2>&1 || true
git fetch upstream master >/dev/null 2>&1 || true

# 上次 release 点:master 上最近的 canary-* 或 v* tag(按 tagger 时间)。
LAST=$(git tag --merged HEAD --sort=-creatordate | grep -E '^(canary-|v)' | head -1 || true)

if [ -z "$LAST" ]; then
  BASE=$(git rev-list --max-parents=0 HEAD | head -1)
  echo "==> 无历史 release tag,以首个提交 ${BASE} 为基线"
else
  BASE="$LAST"
  echo "==> 上次 release: $LAST"
fi

# 有意义的新提交(排除合并提交与可忽略类型)。
NEW=$(git log --no-merges "$BASE..HEAD" --format='%h %s')
MEANINGFUL=$(printf '%s\n' "$NEW" | grep -E '^[0-9a-f]{7,}[[:space:]]+(feat|fix|refactor|perf)' || true)

if [ -n "$MEANINGFUL" ]; then
  echo
  echo "==> 有值得发布的提交,建议发 canary:"
  printf '%s\n' "$MEANINGFUL"
  echo
  TAG="v$(date +%Y%m%d%H%M)-$(git rev-parse --short=7 HEAD)"
  echo "打 tag 命令:"
  echo "  git tag \"$TAG\""
  echo "  git push origin \"$TAG\""
else
  echo
  echo "==> 仅有 chore/ci/docs 等,可跳过本次发布"
  [ -n "$NEW" ] && printf '%s\n' "$NEW" | head -20
fi
