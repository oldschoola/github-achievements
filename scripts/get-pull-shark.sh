#!/usr/bin/env bash
# Creates N branches with small commits, opens PRs, and merges them to build Pull Shark tiers.
# Usage: ./scripts/get-pull-shark.sh <owner> <repo> <token> <count>
#
# Prerequisites: git must be installed and the repo must be cloned locally.
# Run from inside the cloned repo directory.
set -euo pipefail

OWNER="${1:?Usage: $0 <owner> <repo> <token> <count>}"
REPO="${2:?}"
TOKEN="${3:?}"
COUNT="${4:-2}"

API="https://api.github.com"
HEADERS=(-H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" -H "Content-Type: application/json")

# Make sure we are inside a git repo
git rev-parse --git-dir > /dev/null 2>&1 || { echo "Error: run this from inside the cloned repo."; exit 1; }

DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
echo "Default branch: $DEFAULT_BRANCH"
echo "Will create and merge $COUNT pull request(s)..."

for i in $(seq 1 "$COUNT"); do
  BRANCH="pull-shark-$(date +%s)-$i"
  echo ""
  echo "[$i/$COUNT] Creating branch $BRANCH..."

  git checkout "$DEFAULT_BRANCH" -q
  git pull -q
  git checkout -b "$BRANCH" -q

  # Make a small unique change
  echo "Pull Shark run $i — $(date)" >> pull-shark-log.txt
  git add pull-shark-log.txt
  git commit -q -m "chore: pull shark progress run $i"
  git push -q origin "$BRANCH"

  echo "Opening PR..."
  PR=$(curl -sf "${HEADERS[@]}" -X POST "$API/repos/$OWNER/$REPO/pulls" \
    -d "{\"title\":\"Pull Shark #$i\",\"head\":\"$BRANCH\",\"base\":\"$DEFAULT_BRANCH\",\"body\":\"Automated PR for Pull Shark achievement.\"}")

  PR_NUMBER=$(echo "$PR" | jq -r '.number')
  PR_SHA=$(echo "$PR" | jq -r '.head.sha')
  echo "Opened PR #$PR_NUMBER — merging..."

  curl -sf "${HEADERS[@]}" -X PUT "$API/repos/$OWNER/$REPO/pulls/$PR_NUMBER/merge" \
    -d "{\"commit_title\":\"Merge pull-shark branch $i\",\"sha\":\"$PR_SHA\",\"merge_method\":\"merge\"}" > /dev/null

  echo "Merged PR #$PR_NUMBER"

  git checkout "$DEFAULT_BRANCH" -q
  git pull -q
done

echo ""
echo "Done! Merged $COUNT PRs. Pull Shark achievement progress updated within 24 hours."
echo "Tiers: 2 (base) → 16 (bronze) → 128 (silver) → 1024 (gold)"
