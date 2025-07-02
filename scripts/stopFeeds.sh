#!/usr/bin/env bash
#

pids=$(ps aux | grep -E 'quoteFeed|tradeFeed' | grep -v grep | awk '{print $2}')

if [[ -z "$pids" ]]; then
  echo "🔍 No running Feed processes found."
  exit 0
fi

echo "🛑 Killing Feed process(es): $pids"
kill $pids
