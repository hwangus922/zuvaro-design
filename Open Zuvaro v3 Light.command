#!/bin/bash
# Starts Zuvaro v3 light design canvas (kills stale server on 8765 if needed).
cd "$(dirname "$0")"
PORT=8765
FILE="Zuvaro Painted v3 light.html"

if lsof -ti :$PORT >/dev/null 2>&1; then
  lsof -ti :$PORT | xargs kill 2>/dev/null
  sleep 0.3
fi

python3 -m http.server "$PORT" >/dev/null 2>&1 &
sleep 0.5

ENCODED=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$FILE")
open "http://127.0.0.1:${PORT}/${ENCODED}"
