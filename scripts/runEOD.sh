#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE=${PROJECT_ROOT}/docker/.env
SHARED_FILE=${PROJECT_ROOT}/docker/compose.yaml
BITMEX_FILE=${PROJECT_ROOT}/docker/compose-bitmex.yaml
BITFINEX_FILE=${PROJECT_ROOT}/docker/compose-bitfinex.yaml
FEEDS_FILE=${PROJECT_ROOT}/docker/compose-feeds.yaml

while IFS='=' read -r key port; do
    echo "Calling EOD on: ${key}"
    curl -X POST "http://localhost:${port}/eod"
    echo 
done < <(grep -i "sm" ${ENV_FILE} | grep -vi "EOI")