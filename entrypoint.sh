#!/bin/bash

set -euxo pipefail

if [ ! -f .rustlings-state.txt ]; then
  echo "Missing .rustlings-state.txt"
  exit 1
fi

CURRENT=$(sed -n '3p' .rustlings-state.txt)
echo "Current: $CURRENT"

# Completed exercises from state file
tail -n +5 .rustlings-state.txt | sort | uniq >.completed.txt

# Get all exercises in order by directory and file
EXERCISES=()
while IFS= read -r -d '' file; do
  name=$(basename "$file" .rs)
  EXERCISES+=("$name")
done < <(find exercises -type f -name '*.rs' -print0 | sort -z)

# Calculate progress
declare -i TOTAL=${#EXERCISES[@]}
declare -i DONE=0

if ((TOTAL == 0)); then
  echo "No exercises found in exercises/*.rs. Check directory structure."
  exit 1
fi

# First, mark completed and count
COMPLETION_TABLE=()

for ex in "${EXERCISES[@]}"; do
  if grep -Fxq "$ex" .completed.txt; then
    COMPLETION_TABLE+=("| \`$ex\` | ✅ |")
    DONE=$((DONE + 1))
  else
    COMPLETION_TABLE+=("| \`$ex\` | ❌ |")
  fi
done

echo "# 🦀" >README.md
echo "" >>README.md
echo "## Rustlings Progress" >>README.md
echo "" >>README.md
echo "**Currently working on:** \`$CURRENT\`" >>README.md
echo "" >>README.md

PERCENT=$(awk "BEGIN { printf \"%.1f\", ($DONE/$TOTAL)*100 }")

echo "**$DONE of $TOTAL completed ($PERCENT%)**" >>README.md

MAX_WIDTH=40
FILL_COUNT=$((DONE * MAX_WIDTH / TOTAL))
FILLED=$(printf "%0.s#" $(seq 1 $FILL_COUNT))
CURRENT=">"
EMPTY=$(printf "%0.s-" $(seq 1 $((MAX_WIDTH - FILL_COUNT - 1))))

echo "[$FILLED$CURRENT$EMPTY]" >>README.md
echo "" >>README.md

echo "## 📋 Exercise Completion Table" >>README.md
echo "" >>README.md
echo "| Exercise Name | Completion |" >>README.md
echo "|---------------|------------|" >>README.md

printf "%s\n" "${COMPLETION_TABLE[@]}" >>README.md

git config --global user.name "github-actions[bot]"
git config --global user.email "github-actions[bot]@users.noreply.github.com"

git add README.md
if git diff --cached --quiet; then
  echo "No changes to commit"
else
  git commit -m "Update README with Rustlings progress"
  git push origin HEAD:main
fi
