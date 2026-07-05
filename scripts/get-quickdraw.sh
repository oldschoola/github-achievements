#!/usr/bin/env bash
# Opens an issue then immediately closes it to earn the Quickdraw achievement.
# Usage: ./scripts/get-quickdraw.sh <github-username> <repo-name> <token>
set -euo pipefail

OWNER="${1:?Usage: $0 <owner> <repo> <token>}"
REPO="${2:?}"
TOKEN="${3:?}"

API="https://api.github.com"
HEADERS=(-H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" -H "Content-Type: application/json")

echo "Opening issue..."
ISSUE=$(curl -sf "${HEADERS[@]}" -X POST "$API/repos/$OWNER/$REPO/issues" \
  -d '{"title":"Quickdraw test issue","body":"This issue will be closed immediately for the Quickdraw achievement."}')

ISSUE_NUMBER=$(echo "$ISSUE" | jq -r '.number')
echo "Created issue #$ISSUE_NUMBER — closing immediately..."

curl -sf "${HEADERS[@]}" -X PATCH "$API/repos/$OWNER/$REPO/issues/$ISSUE_NUMBER" \
  -d '{"state":"closed"}' > /dev/null

echo "Done! Issue #$ISSUE_NUMBER opened and closed. Quickdraw achievement should appear within 24 hours."
