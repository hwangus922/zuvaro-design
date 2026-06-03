#!/bin/bash
cd "$(dirname "$0")"
PORT=8765
FILE="Zuvaro Painted v3 light.html"
ENCODED=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$FILE")
URL="http://127.0.0.1:${PORT}/${ENCODED}"

if ! lsof -i :$PORT >/dev/null 2>&1; then
  python3 -m http.server "$PORT" >/dev/null 2>&1 &
  sleep 0.5
fi

open "$URL"
echo "Zuvaro v3 light — live .jsx reload at $URL"
