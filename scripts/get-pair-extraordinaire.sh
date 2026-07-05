#!/usr/bin/env bash
# Creates co-authored commits and merges PRs for the Pair Extraordinaire achievement.
# Usage: ./scripts/get-pair-extraordinaire.sh <owner> <repo> <token> <count>
#        <coauthor-name> <coauthor-email>
#
# The co-author can be a friend's GitHub account or a bot account you control.
# Run from inside the cloned repo directory.
set -euo pipefail

OWNER="${1:?Usage: $0 <owner> <repo> <token> <count> <coauthor-name> <coauthor-email>}"
REPO="${2:?}"
TOKEN="${3:?}"
COUNT="${4:-1}"
COAUTHOR_NAME="${5:-"A Friend"}"
COAUTHOR_EMAIL="${6:-"friend@example.com"}"

API="https://api.github.com"
HEADERS=(-H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" -H "Content-Type: application/json")

git rev-parse --git-dir > /dev/null 2>&1 || { echo "Error: run this from inside the cloned repo."; exit 1; }

DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')
echo "Default branch: $DEFAULT_BRANCH"
echo "Co-author: $COAUTHOR_NAME <$COAUTHOR_EMAIL>"
echo "Will create $COUNT co-authored PR(s)..."

for i in $(seq 1 "$COUNT"); do
  BRANCH="pair-extraordinaire-$(date +%s)-$i"
  echo ""
  echo "[$i/$COUNT] Creating branch $BRANCH..."

  git checkout "$DEFAULT_BRANCH" -q
  git pull -q
  git checkout -b "$BRANCH" -q

  echo "Pair Extraordinaire run $i — $(date)" >> pair-log.txt
  git add pair-log.txt

  # Co-authored-by trailer is what GitHub uses to grant the badge
  git commit -q -m "chore: pair extraordinaire run $i

Co-authored-by: $COAUTHOR_NAME <$COAUTHOR_EMAIL>"

  git push -q origin "$BRANCH"

  echo "Opening PR..."
  PR=$(curl -sf "${HEADERS[@]}" -X POST "$API/repos/$OWNER/$REPO/pulls" \
    -d "{\"title\":\"Pair Extraordinaire #$i\",\"head\":\"$BRANCH\",\"base\":\"$DEFAULT_BRANCH\",\"body\":\"Co-authored PR for Pair Extraordinaire achievement.\"}")

  PR_NUMBER=$(echo "$PR" | jq -r '.number')
  PR_SHA=$(echo "$PR" | jq -r '.head.sha')
  echo "Opened PR #$PR_NUMBER — merging..."

  curl -sf "${HEADERS[@]}" -X PUT "$API/repos/$OWNER/$REPO/pulls/$PR_NUMBER/merge" \
    -d "{\"commit_title\":\"Merge pair branch $i\",\"sha\":\"$PR_SHA\",\"merge_method\":\"merge\"}" > /dev/null

  echo "Merged PR #$PR_NUMBER"
  git checkout "$DEFAULT_BRANCH" -q
  git pull -q
done

echo ""
echo "Done! Merged $COUNT co-authored PR(s)."
echo "Tiers: 1 (base) → 10 (bronze) → 24 (silver) → 48 (gold)"
echo "Note: the co-author ($COAUTHOR_EMAIL) also receives credit toward their badge."
