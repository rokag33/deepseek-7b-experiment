#!/usr/bin/env bash
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: ./collect_logs.sh [--tail N] [--upload]

Options:
  --tail N    Print the last N lines of logs/loader.log. Default 200.
  --upload    Upload the full loader log to a GitHub Gist if GITHUB_TOKEN is set.

Examples:
  ./collect_logs.sh --tail 400
  GITHUB_TOKEN=xxx ./collect_logs.sh --upload
EOF
}

TAIL_LINES=200
UPLOAD=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --tail)
      shift
      TAIL_LINES=${1:-$TAIL_LINES}
      ;;
    --upload)
      UPLOAD=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1"
      usage
      exit 1
      ;;
  esac
  shift || true
done

LOGFILE="logs/loader.log"
if [ ! -f "$LOGFILE" ]; then
  echo "No logs found at $LOGFILE"
  exit 1
fi

echo "--- Showing last $TAIL_LINES lines of $LOGFILE ---"
tail -n "$TAIL_LINES" "$LOGFILE"

if [ "$UPLOAD" = true ]; then
  if [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "GITHUB_TOKEN is not set; cannot upload gist. Set GITHUB_TOKEN=ghp_xxx"
    exit 1
  fi
  echo "Uploading $LOGFILE as a private Gist..."
  GIST_PAYLOAD=$(jq -n --arg fn "$(basename $LOGFILE)" --arg content "$(cat $LOGFILE | sed 's/"/\"/g')" '{ "public": false, "files": { ($fn): { "content": $content } } }')
  RESP=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" -H "Content-Type: application/json" -d "$GIST_PAYLOAD" https://api.github.com/gists)
  GIST_URL=$(echo "$RESP" | jq -r .html_url)
  if [ "$GIST_URL" = "null" ]; then
    echo "Failed to create gist. Response: $RESP"
    exit 1
  fi
  echo "Gist created: $GIST_URL"
fi
